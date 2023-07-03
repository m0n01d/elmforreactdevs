/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./app/**/*.elm",
    "./src/**/*.{elm,js,ts,jsx,tsx}",
    "./app/Route/**/*.elm",
  ],
  safelist:
    typeof process.env.VERCEL_ENV == "undefined"
      ? [
          {
            pattern: /./, // the "." means "everything"
          },
        ]
      : [],
  theme: {
    extend: {},
  },
  plugins: [],
};
