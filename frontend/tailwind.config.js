/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./*.html",          // todos los HTML en la raíz
    "./src/**/*.{ts,js}", // todos los .ts y .js dentro de src y subcarpetas
  ],
  theme: {
    extend: {
      colors: {
        'poke-red': '#f85858',
        'poke-blue': '#5890f8',
        'poke-yellow': '#f8d058',
        'poke-dark': '#404040',
        'poke-light': '#f7f7f7',
        'poke-white': '#ffffff',
        'poke-violet': '#693F8E',

      },
      fontFamily: {
        'pixel': ['"Press Start 2P"', 'cursive'],
      },
      borderWidth: {
        '3': '3px',
      },
      // Add these new sections for the animation
      keyframes: {
        'press': {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(2px)' },
        }
      },
      animation: {
        'press': 'press 0.2s ease-in-out',
      }
    },
  },
  plugins: [],
}