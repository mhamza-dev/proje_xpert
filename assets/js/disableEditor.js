export default {
  mounted() {
    const containerDiv = document.querySelector("#trix-editor-container");
    if (containerDiv.dataset.isDisabled != "false") {
      document.querySelector(".trix-editor").removeAttribute("contenteditable");
    }
  },
};
