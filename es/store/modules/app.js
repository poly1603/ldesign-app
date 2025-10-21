/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */import{defineStore as h}from"@ldesign/store";import{ref as t,computed as s}from"vue";const k=h("app",()=>{const a=t("light"),n=t("zh-CN"),o=t(!1),r=t(!1),l=t(null),i=s(()=>a.value==="dark"),d=s(()=>n.value==="zh-CN");function u(e){a.value=e,e==="dark"?document.documentElement.classList.add("dark"):document.documentElement.classList.remove("dark")}function c(e){n.value=e}function m(){o.value=!o.value}function p(e){r.value=e}function f(e){l.value=e}function g(){l.value=null}function v(){const e=localStorage.getItem("app-theme");e&&u(e)}return{theme:a,language:n,sidebarCollapsed:o,loading:r,error:l,isDark:i,isZhCN:d,setTheme:u,setLanguage:c,toggleSidebar:m,setLoading:p,setError:f,clearError:g,initTheme:v}},{persist:{enabled:!0,paths:["theme","language","sidebarCollapsed"]}});/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{k as useAppStore};
//# sourceMappingURL=app.js.map
