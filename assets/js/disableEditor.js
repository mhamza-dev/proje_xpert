export default {
  mounted() {
    const containerDiv = document.querySelector(".disabled_class");
    if (containerDiv && containerDiv.dataset.isDisabled != "false") {
      document.querySelector(".trix-editor").removeAttribute("contenteditable");
      document.querySelector(".trix-button-row").style.display = "none";
    }
  },
};
