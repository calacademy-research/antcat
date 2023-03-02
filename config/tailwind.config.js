// NOTE: Colors may be duplicated in 'stylesheets/_colors.sass'.

const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{erb,haml,html,slim,rb}',
    './app/assets/javascripts/**/*.{js,coffee}',
    './app/javascript/**/*.{js,coffee}'
  ],
  theme: {
    extend: {
      colors: {
        'ac-blue': '#2188ff',
        'ac-blue-hover': '#0073f8', // TODO: Find better name.
        'ac-blue-pale': '#deedff', // TODO: Find better name.
        'revision-red': '#fcdcd6',
        'revision-green': '#dafebf',
        'danger-pale': '#fce6e2',
        'logged-in-only': '#deedff',
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        courier: ['"Courier New"', 'Courier', 'serif', 'monospace'],
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
