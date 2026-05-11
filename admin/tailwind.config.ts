import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#f3f7ff',
          500: '#3b6cf2',
          600: '#2f57d9',
          700: '#2244b3',
        },
      },
    },
  },
  plugins: [],
};

export default config;
