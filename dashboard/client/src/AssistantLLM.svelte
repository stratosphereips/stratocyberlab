<script>
  import { onMount } from "svelte";
  import { writable, get } from "svelte/store";

  let modelAvailable = writable(false);
  let chatHistory = writable([]);
  let newMessage = "";

  let waiting = false;

  onMount(async () => {
      const response = await fetch("/llm/is_model_available");
      const data = await response.json();
      modelAvailable.set(data.available);
  });

  async function pullModel() {
      const response = await fetch("/llm/pull_model", {
          method: "POST"
      });
      if (response.ok) {
          modelAvailable.set(true);
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
    background: rgba(0, 0, 0, 0.1);
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
</style>

{#if $modelAvailable}
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
{:else}
  <div class="container">
    <button class="btn btn-secondary" on:click={pullModel}>Pull Model</button>
  </div>
{/if}
