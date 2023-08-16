import Prism from "prismjs";
import "prismjs/plugins/normalize-whitespace/prism-normalize-whitespace.js";
import "prismjs/components/prism-elm";

Prism.plugins.NormalizeWhitespace.setDefaults({
  "remove-trailing": true,
  "remove-indent": true,
  "left-trim": true,
  "right-trim": true,
  "break-lines": 110,
});

export default customElements.define(
  "ui-prism",
  class extends HTMLElement {
    constructor() {
      super();
    }

    connectedCallback() {
      const snippets = [...this.querySelectorAll("pre")];
      snippets.forEach((snippet) => {
        const $el = snippet.querySelector("code");
        const txt = $el.innerText;
        Prism.highlightElement($el);
      });
    }
  }
);
