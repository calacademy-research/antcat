// NOTE: Colors may be duplicated in 'stylesheets/_colors.sass'.

const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/assets/images/icons/**/*.svg',
    './app/assets/javascripts/**/*.{js,coffee}',
    './app/components/**/*.{erb,haml,html,slim,rb}',
    './app/decorators/**/*.rb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/javascript/**/*.{js,coffee}',
    './app/presenters/**/*.rb',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      // TODO: Improve names.
      colors: {
        'ac-blue': '#2188ff',
        'ac-blue-text': '#096adc',
        'ac-blue-text-darker': '#0753ae',
        'ac-blue-darker': '#0073f8',
        'ac-blue-pale': '#deedff',
        'ac-blue-saves': '#044289',
        'ac-blue-saves-darker': '#03356e',
        'ac-red-danger': '#ec5840',
        'ac-red-danger-darker': '#da3116',
        'revision-red': '#fcdcd6',
        'revision-green': '#dafebf',
        'danger-pale': '#fce6e2',
        'logged-in-only': '#deedff',
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        courier: ['"Courier New"', 'Courier', 'serif', 'monospace'],
        heading: ['Montserrat', '"Helvetica Neue"', 'Helvetica', 'Roboto', 'Arial', 'sans-serif'],
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
