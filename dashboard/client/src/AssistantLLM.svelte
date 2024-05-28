<script>
  import { onMount } from "svelte";
  import { writable, get } from "svelte/store";

  let modelAvailable;
  let chatHistory = writable([]);
  let newMessage = "";

  let waiting = false;

  onMount(async () => {
      const response = await fetch("/llm/is_model_available");
      const data = await response.json();
      modelAvailable = data.available;
  });

  async function pullModel() {
      const response = await fetch("/llm/pull_model", {
          method: "POST"
      });
      if (response.ok) {
          modelAvailable = true;
      }
  }

  async function sendMessage() {
      chatHistory.update(history => {
          return [...history, {role: "user", content: newMessage}];
      });
      newMessage = "";

      waiting = true
      try {
          const body = get(chatHistory);
          const response = await fetch("/llm/chat", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify(body)
          });
          chatHistory.set(await response.json());

      } catch(err) {
          alert(err)
      }
      waiting = false
  }

  function clearChat() {
      chatHistory.set([]);
  }

  function handleKeyPress(event) {
      if (event.key === "Enter" && !event.shiftKey) {
          event.preventDefault();
          sendMessage();
      }
  }
</script>

<style>
  .container {
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  .chat {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
  }
  .messages {
    flex-grow: 1;
    overflow-y: auto;
    padding: 10px;
    height: calc(100% - 80px); /* Adjust based on the height of the input area */
  }
  .input-area {
    display: flex;
    padding: 10px;
    background: white;
  }
  .message {
    margin-bottom: 10px;
    padding: 10px;
    border-radius: 5px;
  }
  .message.user {
    background: grey;
    color: white;
    align-self: flex-end;
  }
  .message.bot {
    background: #4141ff;
    color: white;
    align-self: flex-start;
  }
  .typing-indicator {
    display: inline-block;
    font-size: 1.5em;
  }
  .typing-indicator span {
    display: inline-block;
    animation: blink 1s infinite;
  }
  .typing-indicator span:nth-child(2) {
    animation-delay: 0.3s;
  }
  .typing-indicator span:nth-child(3) {
    animation-delay: 0.6s;
  }
  @keyframes blink {
    0%, 100% {
      opacity: 0;
    }
    50% {
      opacity: 1;
    }
  }
  .title {
    position: absolute;
    top: -20px;
    left: 20px;
    background: white;
    padding: 0 10px;
    font-size: 1.25em;
    font-weight: bold;
  }
</style>

<div class="mt-1 position-relative h-100 w-100 border border-3 rounded border-dark ">
  <div class="title">LLM Assistant</div>
  {#if modelAvailable === undefined}
   Loading! TODO
  {:else if !modelAvailable}
  <div class="container">
      <button class="btn btn-secondary" on:click={pullModel}>Pull Model</button>
  </div>
  {:else}
  <div class="chat container-fluid">
    <div class="messages">
      {#each $chatHistory as { role, content }}
        <div class="message {role === 'user' ? 'user' : 'bot'}">
          {content}
        </div>
      {/each}
      {#if waiting}
      <div class="typing-indicator">
        <span>.</span>
        <span>.</span>
        <span>.</span>
      </div>
      {/if}
    </div>
    <div class="input-area input-group">
      <textarea class="form-control" bind:value={newMessage} placeholder="Type a message..." on:keypress={handleKeyPress}></textarea>
      <button class="btn btn-primary {waiting ? 'disabled' : ''}" on:click={sendMessage}>Send</button>
      <button class="btn btn-secondary ms-2" on:click={clearChat}>Clear</button>
    </div>
  </div>
  {/if}
</div>