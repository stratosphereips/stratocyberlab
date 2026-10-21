
import argparse
import os
import random
import re
import time
from datetime import datetime
from time import sleep
import readline
import yaml
from dotenv import dotenv_values
from LLM_Plugins.log_manager import LogManager
from LLM_Plugins.api_clients.openai_client import OpenAIClient
import sys
from LLM_Plugins.api_clients.einfra_client import EinfraClient, BackendUnavailable, BackendHTTPError, BackendParseError


# -------- Helpers --------
def _extract_code(text: str) -> str:
    if not text:
        return " "
    m = re.search(r"```(?:\s*\w+)?\s*\r?\n([\s\S]*?)\r?\n```", text, re.DOTALL)
    if m:
        return m.group(1).strip()
    m2 = re.search(r"`([^`]+)`", text)
    if m2:
        return m2.group(1).strip()
    return text.strip()


def remove_think_blocks(text: str) -> str:
    if not isinstance(text, str):
        return text
    cleaned = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL)
    cleaned = re.sub(r"<\|.*?\|>", "", cleaned)
    cleaned = re.sub(r"<analysis>|</analysis>|<final>|</final>", "", cleaned, flags=re.IGNORECASE)
    return cleaned.strip()

END_MARKER = "<|end|>"

def strip_after_end_marker(text: str, marker: str = END_MARKER) -> str:
    """Cut everything from the first <|end|> (or marker) to the end."""
    if not isinstance(text, str):
        return text
    return text.split(marker, 1)[0]


def simulate_ping_output(response: str) -> str:
    """
    Stream ping-like output line by line.

    IMPORTANT: we *do not* print the final prompt line, we return it so the
    caller can pass it as the argument to input(). That way readline knows
    where the prompt ends and will not let the user backspace over it.
    """
    lines = [line for line in response.split("\n") if line.strip()]
    if len(lines) < 4 or not any(("icmp_seq" in l.lower()) or ("ping " in l.lower()) for l in lines):
        # Not really ping output – keep old behaviour
        print(response)
        return lines[-1] if lines else ""

    # Stream everything except the last line (usually the shell prompt)
    for line in lines[:-1]:
        print(line)
        time.sleep(random.uniform(0.12, 0.25))

    # Do NOT print the last line here – let the caller treat it as a prompt
    return lines[-1] if lines else ""



def load_personality_text(personality_path: str) -> dict:
    """Load both prompt and continuation from a personality YAML."""
    with open(personality_path, "r", encoding="utf-8") as f:
        raw = f.read()
    try:
        data = yaml.safe_load(raw)
        if isinstance(data, dict):
            if "personality" in data and isinstance(data["personality"], dict):
                prompt = str(data["personality"].get("prompt", "")).strip()
                continuation = str(data["personality"].get("continuation", "")).strip()
                return {"prompt": prompt, "continuation": continuation}
            elif "prompt" in data:
                return {"prompt": str(data["prompt"]).strip(), "continuation": ""}
        # fallback if YAML structure unexpected
        return {"prompt": raw.strip(), "continuation": ""}
    except Exception:
        return {"prompt": raw.strip(), "continuation": ""}


def wrap_for_test(text: str, enabled: bool) -> str:
    """Wrap model output in identifiable markers for test runs (terminal only)."""
    if not enabled or not isinstance(text, str):
        return text
    return f"<<BEGIN_MSG>>\n{text}\n<<END_MSG>>"

PROMPT_LINE_RE = re.compile(r".*[#$]\s*$")

def extract_prompt_line(text: str, allow_bare_shell: bool = False) -> str | None:
    if not isinstance(text, str):
        return None

    shell_candidates = []

    for ln in reversed(text.splitlines()):
        s = ln.strip()
        if not s:
            continue

        # REPL prompts
        if s in (">>>", "..."):
            return s

        # Shell prompts
        if s.endswith("$") or s.endswith("#"):
            # avoid learning bare "$" or "#" (common in bad outputs / errors)
            if not allow_bare_shell and s in ("$", "#"):
                continue
            shell_candidates.append(s)

    if not shell_candidates:
        return ("$" if allow_bare_shell else None)

    # Prefer "real" prompts like user@host:path$ over short junk
    def score(p: str) -> int:
        sc = 0
        if "@" in p: sc += 100
        if ":" in p: sc += 30
        if "~" in p or "/" in p: sc += 10
        sc += min(len(p), 80)
        return sc

    return max(shell_candidates, key=score)


def find_prompt_in_messages(messages: list) -> str | None:
    for m in reversed(messages or []):
        if isinstance(m, dict) and m.get("role") == "assistant":
            p = extract_prompt_line(m.get("content", ""), allow_bare_shell=False)
            if p:
                return p
    return None


def ensure_prompt_at_end(text: str, last_prompt: str | None) -> str:
    if not isinstance(text, str):
        return "$ "

    p = extract_prompt_line(text, allow_bare_shell=False)

    # If response contains a prompt somewhere, TRIM to the last occurrence of that prompt.
    if p:
        lines = text.splitlines()
        cut = None
        for i in range(len(lines) - 1, -1, -1):
            if lines[i].strip() == p:
                cut = i
                break
        if cut is not None:
            text = "\n".join(lines[:cut + 1])

        return text if text.endswith(" ") else (text + " ")

    # Otherwise append last known prompt
    if last_prompt:
        base = (text or "").rstrip("\n ")
        if base:
            return base + "\n" + last_prompt + " "
        return last_prompt + " "

    return (text if text.endswith(" ") else (text + " "))



# -------- Main --------
def main():
    parser = argparse.ArgumentParser(description="LLM-driven interactive SSH honeypot (OpenAI)")
    parser.add_argument("--provider", type=str, required=True,
                    choices=["openai", "einfra", "ollama", "localqlora", "groq"],
                    help="LLM backend provider")
    parser.add_argument("--model", type=str, required=True)
    parser.add_argument("--personality", type=str, required=True,
                        help="Name of the personality file in LLM_Plugins/personalities (without .yml)")
    parser.add_argument("--trace", action="store_true", help="Enable detailed API tracing")
    parser.add_argument("--testing", action="store_true", default=False,
                        help="Wrap all model outputs in identifiable markers for testing (terminal only)")
    parser.add_argument("--cleaned", action="store_true", default=False,
                        help="Delete all files inside the logs folder before starting")
    args = parser.parse_args()

    # Always work from this script’s directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Paths & env
    base_dir = os.path.dirname(__file__)
    logs_dir = os.path.join(base_dir, "logs")
    os.makedirs(logs_dir, exist_ok=True)

    if args.cleaned:
        try:
            for f in os.listdir(logs_dir):
                full = os.path.join(logs_dir, f)
                try:
                    if os.path.isfile(full) or os.path.islink(full):
                        os.remove(full)
                    elif os.path.isdir(full):
                        import shutil
                        shutil.rmtree(full)
                except:
                    pass
        except:
            pass

    # .env resolution: explicit ENV_FILE env var > .env next to this script >
    # .env in this image's app root (/opt/shellm/.env) > original upstream
    # convention (two directories above this script), kept for compatibility
    # with the unmodified shelLMv2 layout.
    candidate_paths = [
        os.environ.get("ENV_FILE"),
        os.path.join(base_dir, ".env"),
        "/opt/shellm/.env",
        os.path.join(base_dir, "..", "..", ".env"),
    ]
    env_path = next((p for p in candidate_paths if p and os.path.exists(p)), None)
    if not env_path:
        raise FileNotFoundError(
            ".env not found. Looked in: " + ", ".join(p for p in candidate_paths if p)
        )
    config = dotenv_values(env_path)

    # History (readline)
    cmd_hist_file = os.path.join(base_dir, "command_history.txt")
    readline.parse_and_bind("set editing-mode emacs")
    readline.parse_and_bind('"\\e[A": previous-history')
    readline.parse_and_bind('"\\e[B": next-history')
    readline.parse_and_bind('"\t": ""')

    # --- History file path ---
    cmd_hist_file = os.path.join(logs_dir, "command_history.txt")

    # Load history if it already exists (APPEND MODE)
    if os.path.exists(cmd_hist_file):
        try:
            readline.read_history_file(cmd_hist_file)
        except Exception:
            pass

    # Logger
    logger = LogManager(
        log_dir=logs_dir,
        enable_trace=args.trace,
        provider=args.provider,
        model=args.model,
        personality=args.personality,
    )

    # IMPORTANT: make logger use the SAME history file
    logger.command_history_path = cmd_hist_file

    # --- Select client based on provider ---
    if args.provider.lower() == "einfra":
        from LLM_Plugins.api_clients.einfra_client import EinfraClient
        api_key = config.get("EINFRA_API_KEY")
        client = EinfraClient(api_key=api_key, model=args.model, logger=logger)
    elif args.provider.lower() == "groq":
        from LLM_Plugins.api_clients.groq_client import GroqClient
        api_key = config.get("GROQ_API_KEY")
        client = GroqClient(api_key=api_key, model=args.model, logger=logger)
    elif args.provider.lower() == "ollama":
        from LLM_Plugins.api_clients.ollama_client import OllamaClient
        ollama_base = config.get("OLLAMA_BASE_URL")
        client = OllamaClient(base_url=ollama_base, model=args.model, logger=logger)
    elif args.provider.lower() == "localqlora":
        from LLM_Plugins.api_clients.local_hfqlora_client import LocalHFQLoRAClient

        # base_dir:   .../Linux_Terminal_Chatbot_MS/Honeypots - separate/SSH
        project_root = os.path.abspath(os.path.join(base_dir, "..", ".."))
        #            => .../Linux_Terminal_Chatbot_MS

        adapter_dir = os.path.join(
            project_root,
            "Files_for_Fine-tuning",
            "llama31-8b-qlora-terminal",
        )

        client = LocalHFQLoRAClient(
            base_model_id=args.model,   # "meta-llama/Llama-3.1-8B-Instruct"
            adapter_dir=adapter_dir,
            logger=logger,
        )
    else:
        from LLM_Plugins.api_clients.openai_client import OpenAIClient
        api_key = config.get("OPENAI_API_KEY")
        client = OpenAIClient(api_key=api_key, model=args.model, logger=logger)


    # Personality (accepts either .yml or .yaml, tried in that order)
    personality_dir = os.path.join(base_dir, "LLM_Plugins", "personalities")
    personality_path = None
    for ext in (".yml", ".yaml"):
        candidate = os.path.join(personality_dir, f"{args.personality}{ext}")
        if os.path.exists(candidate):
            personality_path = candidate
            break
    if not personality_path:
        raise FileNotFoundError(
            f"Personality file not found: {os.path.join(personality_dir, args.personality)}.yml(.yaml)"
        )
    personality_data = load_personality_text(personality_path)
    system_personality = personality_data.get("prompt", "")
    continuation_text_yaml = personality_data.get("continuation", "")

    # Rebuild previous conversation as structured messages
    messages, has_prior_dialog = logger.parse_history_to_messages(system_personality, continuation_text_yaml)

    last_known_prompt = find_prompt_in_messages(messages)

    if has_prior_dialog:
        continuation_text = continuation_text_yaml
        logger.log_system(continuation_text)
    else:
        logger.record_initial_prompt(system_personality)
        logger.log_system("Fresh start — loaded initial personality prompt.")

    # Estimate token count to prevent overflow
    try:
        import tiktoken
        enc = tiktoken.encoding_for_model("gpt-3.5-turbo")
        total_tokens = sum(len(enc.encode(m["content"])) for m in messages)
    except Exception:
        total_tokens = 0  # fail-safe

    # TOKEN RESET POINT 👇
    if total_tokens > 15500:
        logger.log_marker("token reset")
        # Token limit reached — reloading base personality...

        # Reload personality
        with open(personality_path, "r", encoding="utf-8") as f:
            new_identity = yaml.safe_load(f)
        if isinstance(new_identity, dict) and "personality" in new_identity:
            prompt_text = new_identity["personality"].get("prompt", "")
        else:
            prompt_text = str(new_identity)

        # Reset message history
        messages = [{"role": "system", "content": prompt_text}]
        logger.record_initial_prompt(prompt_text)

        # Optionally truncate local history file
        with open(logger.history_path, "w", encoding="utf-8") as hf:
            hf.write("")
        with open(logger.history_ts_path, "w", encoding="utf-8") as hf:
            hf.write("")

    # Initial call to get first prompt
    try:
        init_output = client.send_chat(args.model, messages)
    except (BackendUnavailable, BackendHTTPError, BackendParseError):
        # Realistic message, no backend internals
        print("ssh: connect to host: Network is unreachable")
        # kick user out (your choice):
        try:
            logger.close_session()
        except Exception:
            pass
        return


    # Strip anything after <|end|> first
    raw_init = strip_after_end_marker(init_output or "").strip()

    # RAW model text (no markers) – used for LLM + logs only
    #assistant_raw = remove_think_blocks(
    #    _extract_code(remove_think_blocks(raw_init))
    #).strip()
    assistant_raw = raw_init

    # Log + history + LLM get ONLY raw
    logger.log_response(assistant_raw)
    messages.append({"role": "assistant", "content": assistant_raw})

    # What is shown in the terminal (can be tweaked, then wrapped)
    display_text = assistant_raw
    if "$cd" in display_text or "$ cd" in display_text:
        parts = display_text.split("\n", 1)
        display_text = parts[1] if len(parts) > 1 else display_text

    # Only the terminal gets wrapped
    cleaned = wrap_for_test(display_text, args.testing)
    cleaned = ensure_prompt_at_end(cleaned, last_known_prompt)
    last_known_prompt = extract_prompt_line(cleaned) or last_known_prompt


    # Interactive loop
    while True:
        try:
            # Visible prompt that will be passed to input()
            prompt = cleaned

            # Safety: if for some reason the prompt still has ping output in it,
            # squash it down to just the final "$" / "#" line.
            if "PING " in prompt.upper() or "ICMP_SEQ=" in prompt.lower():
                last_prompt = None
                for ln in reversed(prompt.splitlines()):
                    s = ln.strip()
                    if s.endswith("$") or s.endswith("#"):
                        last_prompt = s
                        break
                prompt = (last_prompt or "$")

            if not prompt.endswith(" "):
                prompt += " "

            user_cmd = input(prompt).strip()


            if not user_cmd:
                # 1) Try to extract a prompt from the *current* cleaned text.
                #    This will catch normal shell prompts AND REPL prompts like >>> / ...
                p = extract_prompt_line(cleaned, allow_bare_shell=False)

                # 2) If extraction fails (model forgot the prompt), reuse the last good one.
                #    IMPORTANT: last_known_prompt should be initialized to something real
                #    (e.g., "admin@kodalabs:~$") so we never drop to bare "$".
                if not p:
                    p = last_known_prompt

                # 3) As a hard safety net, only if last_known_prompt is somehow None,
                #    you can keep "$" as absolute last resort (should basically never happen).
                if not p:
                    p = "$ "

                # 4) Next input prompt must be just the prompt line + space (not the full old output).
                cleaned = p + " "

                # 5) Keep prompt memory in sync (especially useful if p is >>> or ...).
                last_known_prompt = p

                continue


            if user_cmd.lower() in ["exit", "quit", "logout"]:
                # session ended by user
                break

            logger.log_user(user_cmd)
            logger.record_command(user_cmd + "\n")

            # build message list for this turn (RAW user text)
            messages.append({"role": "user", "content": user_cmd})

            # --- TOKEN RESET CHECK ---
            try:
                import tiktoken
                enc = tiktoken.encoding_for_model("gpt-3.5-turbo")
                total_tokens = sum(len(enc.encode(m["content"])) for m in messages)
            except Exception:
                total_tokens = 0

            if total_tokens > 15500:
                logger.log_marker("token reset")
                # Token limit reached — reloading base personality...

                with open(personality_path, "r", encoding="utf-8") as f:
                    new_identity = yaml.safe_load(f)
                if isinstance(new_identity, dict) and "personality" in new_identity:
                    prompt_text = new_identity["personality"].get("prompt", "")
                else:
                    prompt_text = str(new_identity)

                messages = [{"role": "system", "content": prompt_text}]
                logger.record_initial_prompt(prompt_text)
                with open(logger.history_path, "w", encoding="utf-8") as hf:
                    hf.write("")
                with open(logger.history_ts_path, "w", encoding="utf-8") as hf:
                    hf.write("")

            # proceed to send
            try:
                model_output = client.send_chat(args.model, messages)
            except (BackendUnavailable, BackendHTTPError, BackendParseError):
                print("Connection to remote host was lost.")
                try:
                    logger.close_session()
                except Exception:
                    pass
                break


            # --- RAW assistant output (no markers) ---
            raw_output = strip_after_end_marker(model_output or "").strip()
            #assistant_raw = remove_think_blocks(
            #    _extract_code(remove_think_blocks(raw_output))
            #).strip()

            assistant_raw = raw_output


            # logging & LLM history: RAW ONLY
            messages.append({"role": "assistant", "content": assistant_raw})
            logger.log_response(assistant_raw)

            # terminal text (can be munged, but still RAW at this point)
            display_text = assistant_raw

            if "$cd" in display_text or "$ cd" in display_text:
                parts = display_text.split("\n", 1)
                display_text = parts[1] if len(parts) > 1 else display_text

            # terminal: wrapped if testing
            cleaned = wrap_for_test(display_text, args.testing)
            cleaned = ensure_prompt_at_end(cleaned, last_known_prompt)
            last_known_prompt = extract_prompt_line(cleaned) or last_known_prompt

            # ping animation
            if "PING " in display_text.upper() or "ICMP_SEQ=" in display_text.lower():
                if not args.testing:
                    # Normal interactive mode: stream ping output, but *do not*
                    # print the final prompt line here. We get it back as return value.
                    last_line = simulate_ping_output(display_text)

                    # Work out what the next prompt should look like
                    prompt_line = None
                    for ln in reversed(display_text.splitlines()):
                        s = ln.strip()
                        if s.endswith("$") or s.endswith("#"):
                            prompt_line = s
                            break

                    if not prompt_line:
                        # Fall back to whatever the last line was, or to a basic "$"
                        prompt_line = extract_prompt_line(display_text, allow_bare_shell=False) or (last_line or "").strip() or last_known_prompt

                    # This is what we'll pass to input() on the next loop
                    cleaned = prompt_line + " "
                    last_known_prompt = prompt_line or last_known_prompt

                    # Persist readline history even for ping commands
                    try:
                        readline.write_history_file(cmd_hist_file)
                    except Exception:
                        pass

                    continue
                else:
                    # Testing mode: output once as wrapped text (no streaming),
                    # so tests see a single BEGIN/END_MSG block.
                    print(cleaned, flush=True)

                    # In testing, don't print an extra bare prompt on the next loop.
                    # Let the next input() use an empty prompt string.
                    cleaned = ""

                    try:
                        readline.write_history_file(cmd_hist_file)
                    except Exception:
                        pass

                    continue




            # persist readline history to disk
            try:
                readline.write_history_file(cmd_hist_file)
            except Exception:
                pass

        except KeyboardInterrupt:
            # 1) Extract prompt from current output; else fall back to last_known_prompt
            p = extract_prompt_line(cleaned, allow_bare_shell=False) or last_known_prompt or "$"

            # 2) Python REPL behaviour: print KeyboardInterrupt, then >>> 
            if p.strip() in (">>>", "..."):
                # In Python, Ctrl+C cancels the current input and re-prompts at >>>
                print("\nKeyboardInterrupt")
                p = ">>>"
                cleaned = p + " "
                last_known_prompt = p

                try:
                    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    with open(logger.history_ts_path, "a", encoding="utf-8") as hf:
                        hf.write(f"[{ts}] USER:\n{p} KeyboardInterrupt\n")
                except Exception:
                    pass

                continue

            # 3) Shell behaviour: show ^C and reprint prompt
            print("^C")
            cleaned = p + " "
            last_known_prompt = p

            try:
                ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                with open(logger.history_ts_path, "a", encoding="utf-8") as hf:
                    hf.write(f"[{ts}] USER:\n{p} ^C\n")
            except Exception:
                pass

            continue

        except EOFError:
            logger.close_session()
            break
        except Exception as e:
            print("Connection closed by remote host.")
            break


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        # optional: try to mark stop (only if main() didn't already)
        try:
            from LLM_Plugins.log_manager import LogManager  # only if you can access a global instance (usually you can't)
        except Exception:
            pass
        sys.exit(130)
    except SystemExit:
        # keep intended exits unchanged
        raise
    except Exception:
        # do NOT leak traceback to attacker; still exit non-zero
        sys.exit(1)
