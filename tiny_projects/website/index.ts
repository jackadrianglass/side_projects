type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    // @ts-ignore
    await import("https://unpkg.com/elm-canvas@2.2/elm-canvas.js");
  },
  flags: function () {
    function getScrollBarWidth() {
      let el = document.createElement("div");
      el.style.cssText = "overflow:scroll; visibility:hidden; position:absolute;";
      document.body.appendChild(el);
      let width = el.offsetWidth - el.clientWidth;
      el.remove();
      return width;
    }
    return {
      windowWidth: window.innerWidth,
      windowHeight: window.innerHeight,
      scrollBarWidth: getScrollBarWidth(),
    };
  },
};

export default config;
