// NOTE: Colors may be duplicated in 'stylesheets/_colors.sass'.

const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/assets/javascripts/**/*.{js,coffee}',
    './app/javascript/**/*.{js,coffee}'
  ],
  theme: {
    extend: {
      colors: {
        'ac-blue': '#2188ff',
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      screens: {
        'nottiny': { 'raw': '(min-height: 640px) and (min-width: 640px)' },
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
