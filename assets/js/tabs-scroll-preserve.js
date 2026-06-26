(function () {
  /**
   * Keep the clicked tab block at the same viewport position when its height
   * changes. Works with synced tab groups where several blocks resize at once.
   */
  document.addEventListener(
    "click",
    (event) => {
      const button = event.target.closest(".tab__button");
      if (!button) return;

      const container = button.closest(".tab__container");
      if (!container) return;

      container.dataset.tabScrollBeforeTop = String(container.getBoundingClientRect().top);
    },
    true,
  );

  document.addEventListener("click", (event) => {
    const button = event.target.closest(".tab__button");
    if (!button) return;

    const container = button.closest(".tab__container");
    if (!container || container.dataset.tabScrollBeforeTop === undefined) return;

    const beforeTop = Number.parseFloat(container.dataset.tabScrollBeforeTop);
    delete container.dataset.tabScrollBeforeTop;

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        const delta = container.getBoundingClientRect().top - beforeTop;
        if (Math.abs(delta) < 0.5) return;

        window.scrollBy({
          top: delta,
          left: 0,
          behavior: "instant",
        });
      });
    });
  });
})();
