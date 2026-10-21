import os
import requests
from typing import List, Dict, Any, Optional


class OllamaClient:
    """
    Ollama /api/chat client with full trace logging.
    Defaults to a local daemon (http://localhost:11434), no auth.
    Response shape (when stream=false):
      { "model": "...", "message": {"role":"assistant","content":"..."}, "done": true, ... }
    """

    def __init__(self, base_url: Optional[str], model: str, logger):
        self.base_url = (base_url or os.getenv("OLLAMA_BASE_URL") or "http://localhost:11434").rstrip("/")
        self.api_url = f"{self.base_url}/api/chat"
        self.model = model
        self.logger = logger

    def send_chat(self, model: Optional[str], messages: List[Dict[str, Any]]) -> str:
        mdl = model or self.model

        headers = {
            "Content-Type": "application/json",
        }
        body = {
            "model": mdl,
            "messages": messages,
            "stream": False,   # important: we want a single JSON response
            # you can add temperature, num_ctx, top_p, etc. if needed
        }

        # TRACE: request
        if self.logger:
            self.logger.trace_request(
                method="POST",
                url=self.api_url,
                headers=headers,
                body=body,
                provider_label="Ollama",
            )

        try:
            resp = requests.post(self.api_url, headers=headers, json=body, timeout=300)
        except requests.RequestException as e:
            return f"[Ollama connection error: {e}]"

        # TRACE: response
        try:
            resp_json = resp.json()
        except Exception:
            resp_json = {"_raw": resp.text}

        if self.logger:
            self.logger.trace_response(
                status=resp.status_code,
                headers=dict(resp.headers),
                body=resp_json,
                provider_label="Ollama",
            )

        if resp.status_code != 200:
            # keep a short error body preview
            preview = resp.text[:300] if isinstance(resp.text, str) else str(resp.text)[:300]
            return f"[Ollama HTTP {resp.status_code}: {preview}]"

        # Expected format: {"message":{"role":"assistant","content":"..."},"done":true,...}
        try:
            msg = resp_json.get("message", {})
            content = (msg.get("content") or "").strip()
            if content:
                return content
            return "[Ollama returned no content]"
        except Exception:
            return "[Ollama response parse error]"
