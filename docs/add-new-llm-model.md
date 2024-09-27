# How to change the LLM model

To change the LLM model, you need to do

1. Edit which model you want to used in the file [`dashboard/server/llm.py`](https://github.com/xyizko/stratocyberlab/blob/main/dashboard/server/llm.py#L13)

    `DEFAULT_MODEL="phi3.5"`

2. You can choose any model in this list of [ollama](https://ollama.com/library)

3. Start the stratocyberlab

    `docker compose up --build`

4. Regarding LLM model choice. 
- As of the date on which this PR has been made. There is a very capable llm model designed for smaller devices, ie., has a smaller size - [`llama 3.2`](https://ai.meta.com/blog/llama-3-2-connect-2024-vision-edge-mobile-devices/)
- It is now available on [`ollama`](https://ollama.com/library/llama3.2:3b) - 2.0GB
- To set this above model -

```py 
DEFAULT_MODEL="llama3.2"
```