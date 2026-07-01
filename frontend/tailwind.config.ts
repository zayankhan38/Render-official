import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'render-dark': '#09090b',
        'render-red': '#ff1744',
        'render-red-dark': '#d01535',
        'render-red-light': '#ff4757',
        'render-gray': '#18181b',
        'render-gray-light': '#27272a',
      },
      fontFamily: {
        sans: ['var(--font-inter)', 'system-ui', 'sans-serif'],
      },
      animation: {
        'pulse-glow': 'pulse-glow 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        'pulse-glow': {
          '0%, 100%': { boxShadow: '0 0 0 0 rgba(255, 23, 68, 0.7)' },
          '50%': { boxShadow: '0 0 0 10px rgba(255, 23, 68, 0)' },
        },
      },
    },
  },
  plugins: [],
  darkMode: 'class',
};

export default config;
