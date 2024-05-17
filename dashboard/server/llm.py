from ollama import Client

# If we need it to be async
# import asyncio
# from ollama import AsyncClient


BASE_URL = "http://localhost:11434/"
PROMPT = """
You are an experienced teacher of network security and penetration testing.
Your goal is to help the students with their questions.
"""

client = Client(host=BASE_URL)

def init_message_history() -> list:
    """
    Initailize the messages list with the basic prompt.
    Each chat request will add a user and an assistant message in the list.
    """
    messages = [
        {"role": "system", "content": PROMPT},
        {"role": "assistant", "content": "Answer the following question:"}
    ]
    
    return messages

def is_model_available(model: str) -> bool:
    """
    Check if the model is downloaded
    """
    models_dict = client.list()
    models = models_dict["models"]

    found = False
    for m in models:
        if model in m["name"]:
            found = True
    return found
    
def chat_with_llm(messages: list, model: str) -> list:
    """
    Send a chat reuest to the model defined by the model string.
    The last message in the list should contain a "user" role and the question.
    """

    # If the model is not present pull it
    if not is_model_available(model):
        response = client.pull(model, stream=False)
        print(response)

        # TODO handle errors in the model
        if response["status"] != "success":
            return messages

    response = client.chat(model=model, messages=messages)
    messages.append({"role": "assistant", "content": response['message']['content']})
    print(response['message']['content'])

    return messages

if __name__ == '__main__':
    messages = init_message_history()

    messages.append({
        "role": "user", "content": "What does the tcpdump command do?"
    })

    messages = chat_with_llm(messages, model="phi3")
    # print(messages)