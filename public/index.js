import { inject } from "@vercel/analytics";

export default {
  load: async function (elmLoaded) {
    inject();
    const app = await elmLoaded;
    console.log("App loaded", app);
  },
  flags: function () {
    return "Flags go here";
  },
};
