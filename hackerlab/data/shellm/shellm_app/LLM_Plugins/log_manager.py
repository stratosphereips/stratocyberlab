import os
from datetime import datetime
import json

class LogManager:
    """
    Central logging manager for the SSH honeypot.
    Handles:
      - history.txt      → clean session text (sent to LLM)
      - history_ts.txt   → same, but with timestamps for audit
      - trace_log.txt    → HTTP requests/responses (if trace enabled)
      - command_history.txt → terminal arrow-key history (readline)
    All files are persistent (no per-session folders).
    """

    def __init__(self, log_dir, enable_trace=False,
                 provider=None, model=None, personality=None):
        self.log_dir = log_dir
        self.enable_trace = enable_trace
        self.provider = provider or "unknown"
        self.model = model or "unknown"
        self.personality = personality or "default"

        os.makedirs(self.log_dir, exist_ok=True)
        self.history_path = os.path.join(self.log_dir, "history.txt")
        self.history_ts_path = os.path.join(self.log_dir, "history_ts.txt")
        self.trace_path = os.path.join(self.log_dir, "trace_log.txt")
        self.command_history_path = os.path.join(self.log_dir, "command_history.txt")

        self._init_logs()

    # ------------------------------------------------------------
    # Initialization and session headers
    # ------------------------------------------------------------
    def _init_logs(self):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        is_new = not os.path.exists(self.history_path)

        if is_new:
            session_header = [
                f"--- SESSION START [{now}] ---",
                f"Provider: {self.provider}",
                f"Model: {self.model}",
                f"Personality: {self.personality}",
                "-" * 60,
                ""
            ]
            header_text = "\n".join(session_header) + "\n"
            self._append(self.history_path, header_text)
            self._append(self.history_ts_path, header_text)

        trace_header = f"\n--- TRACE LOG [{now}] ---\nTrace enabled: {self.enable_trace}\n\n"
        self._append(self.trace_path, trace_header)

        if not os.path.exists(self.command_history_path):
            self._append(self.command_history_path, "")


    # ------------------------------------------------------------
    # Basic file helpers
    # ------------------------------------------------------------
    @staticmethod
    def _exists(path):
        return os.path.exists(path) and os.path.getsize(path) > 0

    @staticmethod
    def _append(path, text):
        with open(path, "a", encoding="utf-8") as f:
            f.write(text)

    # ------------------------------------------------------------
    # History and response logging
    # ------------------------------------------------------------
    def log_user(self, command):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self._append(self.history_path, f"USER:\n{command.strip()}\n")
        self._append(self.history_ts_path, f"[{now}] USER:\n{command.strip()}\n")

    def log_response(self, text):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self._append(self.history_path, f"RESPONSE:\n{text.strip()}\n")
        self._append(self.history_ts_path, f"[{now}] RESPONSE:\n{text.strip()}\n")

    def log_system(self, text):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self._append(self.history_path, f"SYSTEM:\n{text.strip()}\n")
        self._append(self.history_ts_path, f"[{now}] SYSTEM:\n{text.strip()}\n")
    
    def record_initial_prompt(self, prompt_text: str):
        """Record the initial system/personality prompt at session start or after reset."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        block = f"SYSTEM:\n{prompt_text.strip()}\n"
        block_ts = f"[{now}] SYSTEM:\n{prompt_text.strip()}\n"

        self._append(self.history_path, block)
        self._append(self.history_ts_path, block_ts)

    def record_command(self, command):
        """Append command to command_history.txt (used for terminal arrow-key history)."""
        line = command.strip() + "\n"
        self._append(self.command_history_path, line)

    def log_marker(self, kind):
        """Adds 'SESSION STOPPED' or 'TOKEN RESET' markers."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        marker = f"--- {kind.upper()} [{now}] ---\n"
        if kind.lower() == "stopped":
            marker += "Session closed. Resume from next session.\n"
        elif kind.lower() == "token reset":
            marker += "Token limit reached. Reloading base personality.\n"
        self._append(self.history_path, marker)
        self._append(self.history_ts_path, marker)

    def parse_history_to_messages(self, base_prompt: str, continuation_text: str = None):
        """
        Returns (messages, has_prior_dialog)
        Optionally accepts a custom continuation_text (e.g., from personality YAML).
        """
        messages = [{"role": "system", "content": base_prompt}]
        has_prior_dialog = False

        if not os.path.exists(self.history_path) or os.path.getsize(self.history_path) == 0:
            return messages, has_prior_dialog

        current_role = None
        current_buffer = []

        with open(self.history_path, "r", encoding="utf-8") as f:
            for raw in f:
                stripped = raw.strip()
                if stripped.startswith("--- SESSION") or stripped.startswith("Provider:") \
                or stripped.startswith("Model:") or stripped.startswith("Personality:") \
                or (set(stripped) == {"-"}):
                    continue

                if stripped == "USER:":
                    if current_role and current_buffer:
                        messages.append({"role": current_role, "content": "\n".join(current_buffer).strip()})
                        current_buffer = []
                    current_role = "user"
                    continue

                if stripped == "RESPONSE:":
                    if current_role and current_buffer:
                        messages.append({"role": current_role, "content": "\n".join(current_buffer).strip()})
                        current_buffer = []
                    current_role = "assistant"
                    continue

                if current_role in ("user", "assistant"):
                    # Don't send internal logger markers to the LLM
                    if stripped.startswith("--- STOPPED [") or stripped.startswith("--- TOKEN RESET ["):
                        continue
                    if stripped in (
                        "Session closed. Resume from next session.",
                        "Token limit reached. Reloading base personality.",
                    ):
                        continue
                    current_buffer.append(raw.rstrip("\n"))


        if current_role and current_buffer:
            messages.append({"role": current_role, "content": "\n".join(current_buffer).strip()})

        for m in messages:
            if m["role"] in ("user", "assistant"):
                has_prior_dialog = True
                break

        if has_prior_dialog:
            messages.append({"role": "system", "content": continuation_text})

        return messages, has_prior_dialog




    # ------------------------------------------------------------
    # Trace-level HTTP logging
    # ------------------------------------------------------------
    def trace_request(self, method, url, headers, body, provider_label=None):
        """Log a detailed outbound API request."""
        if not self.enable_trace:
            return
        now = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
        label = provider_label or self.provider or "LLM"
        formatted = (
            f"{now} REQUEST → {label}\n"
            f"METHOD: {method}\n"
            f"URL: {url}\n"
            f"HEADERS: {json.dumps(headers, indent=2)}\n"
            f"BODY:\n{json.dumps(body, indent=2)}\n"
            + "-" * 78 + "\n"
        )
        self._append(self.trace_path, formatted)

    def trace_response(self, status, headers, body, provider_label=None):
        """Log a detailed inbound API response."""
        if not self.enable_trace:
            return
        now = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
        label = provider_label or self.provider or "LLM"
        formatted = (
            f"{now} RESPONSE ← {label}\n"
            f"STATUS: {status}\n"
            f"HEADERS: {json.dumps(headers, indent=2)}\n"
            f"BODY:\n{body if isinstance(body, str) else json.dumps(body, indent=2)}\n"
            + "-" * 78 + "\n"
        )
        self._append(self.trace_path, formatted)

    # ------------------------------------------------------------
    # Utility
    # ------------------------------------------------------------
    def close_session(self):
        """Mark session stop (called on KeyboardInterrupt or exit)."""
        self.log_marker("stopped")
