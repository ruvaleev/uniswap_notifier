module.exports = {
  'env': {
    'commonjs': true,
    'es2021': true,
    'node': true,
  },
  'extends': ['eslint:recommended', 'plugin:node/recommended', 'plugin:jest/recommended', 'prettier'],
  'parserOptions': {
    'ecmaVersion': 2023,
    'sourceType': 'module'
  },
  'rules': {
    'quotes': ['error', 'single'],
    'no-multi-spaces': 'error',
    'space-infix-ops': 'error',
    'no-multiple-empty-lines': 'error',
    'no-trailing-spaces': 'error'
  }
};
