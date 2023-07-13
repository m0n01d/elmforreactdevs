import { inject } from "@vercel/analytics";
type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    await elmLoaded;
    document.body.classList.add(process.env.VERCEL_ENV);
    inject({
      mode: typeof process.env.VERCEL_ENV != "undefined" ? "production" : "dev",
    });
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};

export default config;
