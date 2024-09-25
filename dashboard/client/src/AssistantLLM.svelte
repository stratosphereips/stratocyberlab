<script>
  import { onMount } from "svelte";
  import { writable, get } from "svelte/store";
  import { marked } from "marked";

  let modelAvailable;
  let chatHistory = writable([]);
  let newMessage = "";

  let pullingModel = false;
  let waitingForReply = false;

  const INTERVAL_CHECKING = 5000 // 5 seconds

  onMount(async () => {
      await checkModelAvailability()
  });

  async function pullModel() {
      pullingModel = true
      try {
          const response = await fetch("/api/llm/pull_model", {
              method: "POST"
          });
          // 409 happens if pulling was already in progress
          if (!response.ok && response.status !== 409) {
              throw new Error(`Failed to start pulling the model: ${response.status}`)
          }

          // check model availability after 5 seconds
          setTimeout(checkModelAvailability, INTERVAL_CHECKING);

      } catch(err) {
          alert(err)
          pullingModel = false
      }
  }

  async function checkModelAvailability() {
      const response = await fetch("/api/llm/is_model_available");
      const data = await response.json();

      modelAvailable = data.available;
      pullingModel = data.pulling

      if (!modelAvailable && pullingModel) {
          // recheck after 5 seconds if pulling is in progress
          setTimeout(checkModelAvailability, INTERVAL_CHECKING);
      }
  }

  async function sendMessage() {
      chatHistory.update(history => {
          return [...history, {role: "user", content: newMessage}];
      });
      newMessage = "";

      waitingForReply = true
      try {
          const body = get(chatHistory);
          const response = await fetch("/api/llm/chat", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify(body)
          });
          chatHistory.set(await response.json());

      } catch(err) {
          alert(err)
      }
      waitingForReply = false
  }

  function clearChat() {
      chatHistory.set([]);
  }

  function handleKeyPress(event) {
      if (event.key === "Enter" && !event.shiftKey) {
          event.preventDefault();

          if (!waitingForReply){
              sendMessage();
          }
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
  background:  #FFE6E6;
  color: black;
  align-self: flex-end;
  text-align: left;
  max-width: 92%;
  padding: 10px;
  border-radius: 5px;
  margin-left: auto;
  width: max-content;
}

.message.bot {
  background: #f8f8f8;
  color: black;
  align-self: flex-start;
  text-align: left;
  max-width: fit-content;
  padding: 10px;
  border-radius: 5px;
  margin-right: auto;
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
  .reset-button {
    position: absolute;
    top: -20px;
    right: 20px;
    background: white;
    padding: 0 10px;
    font-size: 1.25em;
    font-weight: bold;
  }
</style>

<div class="mt-1 pt-2 position-relative h-100 w-100 border border-3 rounded border-dark ">
  <div class="title">AI Assistant</div>
  <div class="reset-button">
    <button class="btn btn-sm btn-dark" on:click={clearChat}>reset</button>
  </div>
  {#if modelAvailable === undefined}
     <div class="container"> Loading... </div>
  {:else if !modelAvailable}
  <div class="container">
      <button class="btn btn-secondary {pullingModel ? 'disabled' : ''}" on:click={pullModel}>
        {pullingModel ? 'Pulling Model...' : 'Pull Model'}
      </button>
  </div>
  {:else}
  <div class="chat container-fluid">
    <div class="mt-2 messages">
      {#each $chatHistory as { role, content }}
        <div class="message {role === 'user' ? 'user' : 'bot'}">
          {#if (role === 'user')}
            {content}
          {:else}
            <!-- render the ollama response -->
            {@html marked.parse(content)}
          {/if}
        </div>
      {/each}
      {#if waitingForReply}
      <div class="ms-3 typing-indicator">
        <span>.</span>
        <span>.</span>
        <span>.</span>
      </div>
      {/if}
    </div>
    <div class="input-area input-group">
      <textarea class="bg-light form-control" bind:value={newMessage} placeholder="Type a message and hit enter" on:keypress={handleKeyPress}></textarea>
    </div>
  </div>
  {/if}
</div>