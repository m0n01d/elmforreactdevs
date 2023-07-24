import { inject } from "@vercel/analytics";

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
type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    await elmLoaded;
    inject({
      mode:
        window.location.host == "elmforreactdevs.com" ? "production" : "dev",
    });
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};

export default config;
