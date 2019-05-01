module.exports = {
  plugins: ['stylelint-prettier', 'stylelint-scss'],
  extends: [
    './node_modules/prettier-stylelint/config.js',
    'stylelint-config-standard',
    'stylelint-config-recess-order'
  ],
  rules: {
    'no-descending-specificity': null,
    'prettier/prettier': true
  }
}
