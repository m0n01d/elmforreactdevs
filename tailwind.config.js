/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./app/**/*.elm",
    "./src/**/*.{elm,js,ts,jsx,tsx}",
    "./app/Route/**/*.elm",
  ],
  safelist: [
    {
      pattern: /./, // the "." means "everything"
    },
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
