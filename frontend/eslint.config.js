import vuePlugin from "eslint-plugin-vue";

export default [
  {
    plugins: { vue: vuePlugin },
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        window: "readonly",
        document: "readonly",
        navigator: "readonly"
      }
    },
    linterOptions: {
      reportUnusedDisableDirectives: "warn"
    },
    rules: {
      "no-unused-vars": "warn",
      "no-console": "off",
      "vue/no-unused-components": "warn",
      "vue/html-self-closing": ["warn", {
        "html": { "void": "never", "normal": "never", "component": "always" },
        "svg": "always",
        "math": "always"
      }]
    },
    ignores: ["node_modules/**", "dist/**"]
  }
];
