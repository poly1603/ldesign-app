<script setup lang="ts">
import { RouterView } from '@ldesign/router';
// 导入模板系统的 CSS 变量
import '@ldesign/template/styles/variables.css';
// 导入统一样式系统
import './styles/index.css';
</script>

<template>
  <RouterView transition="fade"></RouterView>
</template>
<style>
/* 全局样式已移至 styles/index.css */
</style>
