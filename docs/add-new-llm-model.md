# How to change the LLM model

To change the LLM model, you need to do

1. Download a new model (this will not be permanent for now)

    `docker exec -it ollama ollama pull phi3.5`

2. Edit which model is used in file `dashboard/server/llm.py`

    `DEFAULT_MODEL="phi3.5"`
   
4. Start the stratocyberlab

    `docker compose up --force-recreate`
