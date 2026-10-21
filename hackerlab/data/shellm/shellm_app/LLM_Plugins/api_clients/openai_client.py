import os
import requests
from typing import List, Dict, Any, Optional


class OpenAIClient:
    """
    OpenAI Chat Completions client with full trace logging.
    Uses raw HTTPS (requests) so we can capture method, URL, headers, body, and response.
    """

    API_URL = "https://api.openai.com/v1/chat/completions"

    def __init__(self, api_key: str, model: str, logger):
        if not api_key:
            raise ValueError("OPENAI_API_KEY is missing.")
        self.api_key = api_key
        self.model = model
        self.logger = logger

    def send_chat(self, model: Optional[str], messages: List[Dict[str, Any]]) -> str:
        mdl = model or self.model
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }

        # default body (non-reasoning models)
        body = {
            "model": mdl,
            "messages": messages,
            "temperature": 0.0,
            "max_tokens": 900,
        }

        # Special handling for GPT-5.1 reasoning model
        if mdl.startswith("gpt-5.1"):
            # reasoning models can't use temperature/max_tokens, must use max_completion_tokens
            body.pop("temperature", None)
            body.pop("max_tokens", None)
            body["max_completion_tokens"] = 900
            # optional: you could also set reasoning_effort / verbosity here if you want
            # body["reasoning_effort"] = "minimal"

        # TRACE: request
        self.logger.trace_request(
            method="POST",
            url=self.API_URL,
            headers=headers,
            body=body,
            provider_label="OpenAI",
        )

        resp = requests.post(self.API_URL, headers=headers, json=body, timeout=300)

        # TRACE: response
        try:
            resp_json = resp.json()
        except Exception:
            resp_json = {"_raw": resp.text}

        self.logger.trace_response(
            status=resp.status_code,
            headers=dict(resp.headers),
            body=resp_json,
            provider_label="OpenAI",
        )

        resp.raise_for_status()
        # normal chat.completions shape
        return resp_json["choices"][0]["message"]["content"]
