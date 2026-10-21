import requests
from typing import List, Dict, Any, Optional


class GroqClient:
    """
    Groq Chat Completions client. Groq's API is OpenAI-compatible, so this
    mirrors OpenAIClient almost exactly, just with Groq's endpoint and no
    special-casing for OpenAI-specific reasoning models.
    Free API keys: https://console.groq.com/keys
    """

    API_URL = "https://api.groq.com/openai/v1/chat/completions"

    def __init__(self, api_key: str, model: str, logger):
        if not api_key:
            raise ValueError("GROQ_API_KEY is missing.")
        self.api_key = api_key
        self.model = model
        self.logger = logger

    def send_chat(self, model: Optional[str], messages: List[Dict[str, Any]]) -> str:
        mdl = model or self.model
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        body = {
            "model": mdl,
            "messages": messages,
            "temperature": 0.0,
            "max_tokens": 900,
        }

        self.logger.trace_request(
            method="POST",
            url=self.API_URL,
            headers=headers,
            body=body,
            provider_label="Groq",
        )

        resp = requests.post(self.API_URL, headers=headers, json=body, timeout=300)

        try:
            resp_json = resp.json()
        except Exception:
            resp_json = {"_raw": resp.text}

        self.logger.trace_response(
            status=resp.status_code,
            headers=dict(resp.headers),
            body=resp_json,
            provider_label="Groq",
        )

        resp.raise_for_status()
        return resp_json["choices"][0]["message"]["content"]
