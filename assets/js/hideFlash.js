export default {
  mounted() {
    let flash = document.querySelector(".flash");
    if (flash) {
      setTimeout(() => {
        flash.classList.add("hide");
        this.pushEvent("lv:clear-flash");
      }, 3000);
    }
  },

  updated() {
    let flash = document.querySelector(".flash");
    if (flash) {
      setTimeout(() => {
        flash.classList.add("hide");
        this.pushEvent("lv:clear-flash");
      }, 3000);
    }
  },
};
