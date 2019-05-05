const { environment } = require('@rails/webpacker')

if (process.env.NODE_ENV !== 'production') {
  const eslint = require('./loaders/eslint')
  environment.loaders.append('eslint', eslint)
}

module.exports = environment
