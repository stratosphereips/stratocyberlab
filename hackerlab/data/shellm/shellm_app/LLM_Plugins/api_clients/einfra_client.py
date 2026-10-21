import requests

class BackendUnavailable(Exception):
    pass

class BackendHTTPError(Exception):
    def __init__(self, status_code: int, body_preview: str = ""):
        super().__init__(f"HTTP {status_code}: {body_preview}")
        self.status_code = status_code
        self.body_preview = body_preview

class BackendParseError(Exception):
    pass


class EinfraClient:
    def __init__(self, api_key: str, model: str, logger=None):
        self.api_key = api_key
        self.model = model
        self.logger = logger
        self.base_url = "https://chat.ai.e-infra.cz/api/chat/completions"

    def send_chat(self, model: str, messages: list) -> str:
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }

        payload = {
            "model": model,
            "messages": messages,
            "temperature": 0.0,
            "max_tokens": 900,
            "stream": False
        }

        if self.logger:
            self.logger.trace_request("POST", self.base_url, headers, payload, provider_label="E-INFRA")

        try:
            resp = requests.post(self.base_url, headers=headers, json=payload, timeout=300)
        except requests.RequestException as e:
            if self.logger:
                # log full detail internally, don’t show to user
                self.logger.log_marker(f"einfra_request_exception: {repr(e)}")
            raise BackendUnavailable("E-INFRA backend unreachable") from e

        if self.logger:
            self.logger.trace_response(resp.status_code, dict(resp.headers), resp.text, provider_label="E-INFRA")

        if resp.status_code != 200:
            body_preview = (resp.text or "")[:300]
            if self.logger:
                self.logger.log_marker(f"einfra_http_error: {resp.status_code} {body_preview}")
            raise BackendHTTPError(resp.status_code, body_preview)

        try:
            data = resp.json()
            choices = data.get("choices", [])
            if choices and "message" in choices[0] and "content" in choices[0]["message"]:
                return choices[0]["message"]["content"].strip()
            if self.logger:
                self.logger.log_marker("einfra_no_content")
            raise BackendParseError("E-INFRA returned no content")
        except ValueError as e:
            if self.logger:
                self.logger.log_marker(f"einfra_json_parse_error: {repr(e)}")
            raise BackendParseError("E-INFRA response parse error") from e
