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
    'node/no-unsupported-features/es-builtins': ['error', {
      'version': '>=18'
    }],
    'node/no-unsupported-features/es-syntax': ['error', {
      'version': '>=18'
    }],
    'no-multiple-empty-lines': 'error',
    'no-multi-spaces': 'error',
    'no-trailing-spaces': 'error',
    'quotes': ['error', 'single'],
    'space-infix-ops': 'error'

  }
};
