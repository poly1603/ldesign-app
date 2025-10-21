/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */const o="1.0.0",i="LDesign Simple App",f="\u73B0\u4EE3\u5316\u524D\u7AEF\u5F00\u53D1\u6846\u67B6\u793A\u4F8B\u5E94\u7528";function a(e){if(e===0)return"0 Bytes";const t=1024,n=["Bytes","KB","MB","GB","TB"],u=Math.floor(Math.log(e)/Math.log(t));return Math.round(e/Math.pow(t,u)*100)/100+" "+n[u]}function s(e){if(e<1e3)return`${e}ms`;const t=Math.floor(e/1e3),n=Math.floor(t/60);return n===0?`${t}s`:`${n}m ${t%60}s`}function r(e){if(e===null||typeof e!="object")return e;if(e instanceof Date)return new Date(e.getTime());if(e instanceof Array)return e.map(t=>r(t));if(e instanceof Object){const t={};for(const n in e)e.hasOwnProperty(n)&&(t[n]=r(e[n]));return t}return e}function l(e,t){let n=null;return function(...u){n&&clearTimeout(n),n=setTimeout(()=>e.apply(this,u),t)}}function c(e,t){let n;return function(...u){n||(e.apply(this,u),n=!0,setTimeout(()=>n=!1,t))}}var p={VERSION:o,APP_NAME:i,APP_DESCRIPTION:f,formatFileSize:a,formatTime:s,deepClone:r,debounce:l,throttle:c};/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{f as APP_DESCRIPTION,i as APP_NAME,o as VERSION,l as debounce,r as deepClone,p as default,a as formatFileSize,s as formatTime,c as throttle};
//# sourceMappingURL=index.js.map
