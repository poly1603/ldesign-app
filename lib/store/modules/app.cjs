"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */var v=require("@ldesign/store"),t=require("vue");const h=v.defineStore("app",()=>{const a=t.ref("light"),r=t.ref("zh-CN"),n=t.ref(!1),l=t.ref(!1),u=t.ref(null),s=t.computed(()=>a.value==="dark"),i=t.computed(()=>r.value==="zh-CN");function o(e){a.value=e,e==="dark"?document.documentElement.classList.add("dark"):document.documentElement.classList.remove("dark")}function c(e){r.value=e}function d(){n.value=!n.value}function f(e){l.value=e}function m(e){u.value=e}function p(){u.value=null}function g(){const e=localStorage.getItem("app-theme");e&&o(e)}return{theme:a,language:r,sidebarCollapsed:n,loading:l,error:u,isDark:s,isZhCN:i,setTheme:o,setLanguage:c,toggleSidebar:d,setLoading:f,setError:m,clearError:p,initTheme:g}},{persist:{enabled:!0,paths:["theme","language","sidebarCollapsed"]}});exports.useAppStore=h;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=app.cjs.map
