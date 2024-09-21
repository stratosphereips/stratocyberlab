# How to change the LLM model

To change the LLM model, you need to do

1. Edit which model you want to used in the file `dashboard/server/llm.py`

    `DEFAULT_MODEL="phi3.5"`

You can choose any model in this list of [ollama](https://ollama.com/library)

4. Start the stratocyberlab

    `docker compose up --build`
