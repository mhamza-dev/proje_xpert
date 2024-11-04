export default {
  mounted() {
    function scrollToBottom() {
      const chatContainer = document.querySelector(".scroller");
      chatContainer.scrollTop = chatContainer.scrollHeight;
    }

    // Scroll to bottom when the page loads
    scrollToBottom();
  },
  updated() {
    this.mounted()
  },
};