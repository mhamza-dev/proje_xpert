export default {
  mounted() {
    let flash = document.querySelector(".flash");
    if (flash) {
      setTimeout(() => {
        flash.classList.add("animate-fade-out-left");
        setTimeout(() => {
          this.pushEvent("lv:clear-flash");
        }, 500);
      }, 3000);
    }
  },

  updated() {
    let flash = document.querySelector(".flash");
    if (flash) {
      setTimeout(() => {
        flash.classList.add("animate-fade-out-left");
        setTimeout(()=> {
          this.pushEvent("lv:clear-flash");
        }, 500)
      }, 3000);
    }
  },
};
