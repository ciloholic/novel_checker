module.exports = {
    parser: 'babel-eslint',
    env: {
        browser: true,
        es6: true,
        node: true
    },
    extends: ['airbnb-base', 'prettier'],
    plugins: ['prettier'],
    rules: {
        'semi': [2, 'never'],
        'no-console': 'off',
        'no-empty': 'off',
        'import/no-extraneous-dependencies': [
            'error', {
                'devDependencies': true
            }
        ],
        'prettier/prettier': [
            'error', {
                'semi': false,
                'singleQuote': true,
                'printWidth': 120
            }
        ]
    }
}
