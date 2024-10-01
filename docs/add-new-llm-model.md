# How to change the LLM model

To change the LLM model, you need to do

1. Edit which model you want to use in the file [dashboard/server/llm.py](/dashboard/server/llm.py). Replace value of a global variable:

    `DEFAULT_MODEL="phi3.5"`

You can choose any model in this list of [ollama](https://ollama.com/library)

4. Start the stratocyberlab

    `docker compose up --build`

## How to remove the old model
While the cyberlab is running, open another terminal and do the following:
1. Fetch the list of downloaded models
   
    `docker exec ollama ollama list`
   
2. Delete the models that are not needed anymore (replace model name with the name of the model you want to delete)

    `docker exec ollama ollama rm <model name>`
