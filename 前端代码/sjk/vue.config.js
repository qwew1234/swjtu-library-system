const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  // 在这里添加以下这行代码，来禁用 ESLint
  lintOnSave: false
})