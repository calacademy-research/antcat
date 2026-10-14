// ESLint flat config (ESLint 10). Replaces .eslintrc.json + eslint-config-airbnb-base,
// which never supported ESLint 9+. Core correctness rules come from @eslint/js;
// the airbnb-style formatting rules AntCat relied on come from @stylistic.
import js from '@eslint/js'
import stylistic from '@stylistic/eslint-plugin'
import globals from 'globals'

export default [
  js.configs.recommended,
  {
    files: ['app/javascript/**/*.js', 'app/assets/javascripts/**/*.js'],
    plugins: { '@stylistic': stylistic },
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: { ...globals.browser, AntCat: 'readonly' },
    },
    rules: {
      // Correctness / best practice (airbnb-base subset)
      'eqeqeq': ['error', 'always', { null: 'ignore' }],
      'no-var': 'error',
      'prefer-const': 'error',
      'object-shorthand': 'error',
      'prefer-arrow-callback': 'error',
      'prefer-template': 'error',
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'no-unused-expressions': ['error', { allowShortCircuit: true }],
      'no-shadow': 'error',
      'no-use-before-define': ['error', { functions: false }],
      'no-useless-concat': 'error',
      'no-useless-return': 'error',
      'dot-notation': 'error',
      'curly': ['error', 'multi-line'],
      'no-new': 'error',
      'no-template-curly-in-string': 'error',
      'max-classes-per-file': ['error', 1],
      'no-restricted-globals': ['error', 'isNaN', 'isFinite'],

      // Formatting (airbnb-style)
      '@stylistic/semi': ['error', 'never'],
      '@stylistic/indent': ['error', 2, { SwitchCase: 1 }],
      '@stylistic/comma-dangle': ['error', 'always-multiline'],
      '@stylistic/comma-spacing': 'error',
      '@stylistic/object-curly-spacing': ['error', 'always'],
      '@stylistic/array-bracket-spacing': ['error', 'never'],
      '@stylistic/arrow-parens': ['error', 'always'],
      '@stylistic/arrow-spacing': 'error',
      '@stylistic/brace-style': ['error', '1tbs', { allowSingleLine: true }],
      '@stylistic/keyword-spacing': 'error',
      '@stylistic/space-infix-ops': 'error',
      '@stylistic/space-before-blocks': 'error',
      '@stylistic/no-multi-spaces': 'error',
      '@stylistic/no-trailing-spaces': 'error',
      '@stylistic/eol-last': 'error',
      '@stylistic/no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0 }],
      '@stylistic/quote-props': ['error', 'as-needed'],
      '@stylistic/dot-location': ['error', 'object'],
      '@stylistic/padded-blocks': ['error', 'never'],
    },
  },
  {
    // Sprockets files: classic scripts with jQuery and typeahead's Bloodhound.
    files: ['app/assets/javascripts/**/*.js'],
    languageOptions: {
      sourceType: 'script',
      globals: { ...globals.jquery, Bloodhound: 'readonly' },
    },
  },
]
