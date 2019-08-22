module.exports = {
  env: {
    browser: true,
    es6: true,
  },
  extends: ['airbnb-base', 'plugin:vue/base'],
  globals: {
    Atomics: 'readonly',
    SharedArrayBuffer: 'readonly',
  },
  parserOptions: {
    ecmaVersion: 2018,
    sourceType: 'module',
  },
  plugins: [
    'vue',
  ],
  rules: {
    "no-console": "off",
    'no-shadow': ["error", { "allow": ["state"] }],
    'linebreak-style': 0,
    'import/no-unresolved': 0,
    'import/extensions': 0,
    "no-param-reassign": [2, {"props": false}],
    "prefer-destructuring": ["error", {
      "array": false,
      "object": true
    }, {
      "enforceForRenamedProperties": false
    }],
    "new-cap": ["error", { "newIsCap": false }],
  },
};
