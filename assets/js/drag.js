import Sortable from "sortablejs";
export default {
  mounted() {
    console.log("mounted");
    const hook = this;
    document.querySelectorAll(".dropzone").forEach((dropzone) => {
      new Sortable(dropzone, {
        animation: 0,
        delay: 50,
        delayOnTouchOnly: true,
        group: "shared",
        draggable: ".draggable",
        ghostClass: "sortable-ghost",
        onEnd: function (evt) {
          let params = {
            draggedId: evt.item.id.substring(1), // id of the dragged item
            fromdropzoneId: evt.from.id, // id of the dragged item
            dropzoneId: evt.to.id, // id of the drop zone where the drop occured

            draggableIndex: evt.newDraggableIndex, // index where the item was dropped (relative to other items in the drop zone)
            fromdraggableIndex: evt.oldDraggableIndex,
          };
          hook.pushEvent("drag-drop", params);
        },
      });
    });
  },
};
