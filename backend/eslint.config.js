export default [
  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        console: "readonly",
        process: "readonly",
        require: "readonly",
        module: "readonly"
      }
    },
    linterOptions: {
      reportUnusedDisableDirectives: "warn"
    },
    rules: {
      "no-unused-vars": "warn",
      "no-console": "off"
    },
    ignores: ["node_modules/**"]
  }
];
