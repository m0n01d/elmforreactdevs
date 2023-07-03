import { inject } from "@vercel/analytics";

export default {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    inject();
    // console.log("App loaded", app);
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};
