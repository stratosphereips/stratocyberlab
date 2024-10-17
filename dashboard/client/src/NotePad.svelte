<script>
  import { onMount } from 'svelte';
  import { saveAs } from 'file-saver'; // npm package for saving blobs

  export let notePadContent = ''; // Default content for the note pad
  let modalElement; // Variable to hold the modal DOM element

  // Lifecycle function that runs when the component is mounted
  onMount(() => {
    modalElement = document.getElementById('notePadModal'); // Get the modal element by its ID
  });

  // Function to trap focus within the modal for better accessibility
  function trapFocus(element) {
    const focusableElements = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
    const modal = element.querySelector('.modal-content');
    const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
    const focusableContent = modal.querySelectorAll(focusableElements);
    const lastFocusableElement = focusableContent[focusableContent.length - 1];

    // Event listener for keydown events, specifically for the Tab key
    document.addEventListener('keydown', function(e) {
      const isTabPressed = e.key === 'Tab';

      if (!isTabPressed) {
        return;
      }

      if (e.shiftKey) { // if shift key pressed for shift + tab combination
        if (document.activeElement === firstFocusableElement) {
          lastFocusableElement.focus(); // Move focus to the last focusable element
          e.preventDefault();
        }
      } else { // if tab key is pressed
        if (document.activeElement === lastFocusableElement) { // If focus reaches the last element, loop back to the first
          firstFocusableElement.focus(); // Move focus to the first focusable element
          e.preventDefault();
        }
      }
    });

    firstFocusableElement.focus(); // Focus on the first focusable element when the modal opens
  }

  // Function to open the modal
  function openModal() {
    modalElement.classList.add('show'); // Add 'show' class to display the modal
    modalElement.style.display = 'block'; // Ensure the modal is visible
    trapFocus(modalElement); // Trap focus within the modal for accessibility
  }

  // Function to close the modal
  function closeModal() {
    modalElement.classList.remove('show'); // Remove 'show' class to hide the modal
    modalElement.style.display = 'none'; // Ensure the modal is hidden
  }

  // Function to save the note pad content to a text file
  function saveToFile() {
    const blob = new Blob([notePadContent], { type: "text/plain;charset=utf-8" }); // Create a Blob from the note pad content
    saveAs(blob, "note_pad.txt"); // Use FileSaver.js to save the Blob as a text file
  }
</script>

<style>
  /* Styles for the modal when it is shown */
  .modal.show {
    display: block;
    background-color: rgba(0, 0, 0, 0.5); /* Semi-transparent background */
  }

  /* Styles for the modal content */
  .modal-content {
    border: 2px solid #000; /* Black border */
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.5); /* Shadow */
  }

  /* Styles for the modal header and footer */
  .modal-header, .modal-footer {
    border-color: #000; /* Black border for header and footer */
  }
</style>

<!-- Modal structure -->
<div id="notePadModal" class="modal fade" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Note Pad</h5>
        <button type="button" class="btn-close" on:click="{closeModal}"></button> <!-- Close button -->
      </div>
      <div class="modal-body">
        <textarea class="form-control" rows="10" bind:value={notePadContent}></textarea> <!-- Textarea for note pad content -->
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" on:click="{closeModal}">Close</button> <!-- Close button -->
        <button type="button" class="btn btn-primary" on:click="{saveToFile}">Save to File</button> <!-- Save button -->
      </div>
    </div>
  </div>
</div>