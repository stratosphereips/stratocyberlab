FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/shellm

COPY shellm_app/requirements.txt shellm_app/requirements.txt
RUN pip install --no-cache-dir -r shellm_app/requirements.txt

COPY shellm_app/ shellm_app/
COPY personality_prompt.yaml shellm_app/LLM_Plugins/personalities/personality_prompt.yaml
COPY docker_config/ docker_config/

RUN chmod +x docker_config/entrypoint.sh docker_config/run_shellm.sh

EXPOSE 1397

ENTRYPOINT ["/opt/shellm/docker_config/entrypoint.sh"]
