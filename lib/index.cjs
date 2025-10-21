"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});const o="1.0.0",i="LDesign Simple App",f="\u73B0\u4EE3\u5316\u524D\u7AEF\u5F00\u53D1\u6846\u67B6\u793A\u4F8B\u5E94\u7528";function a(e){if(e===0)return"0 Bytes";const n=1024,t=["Bytes","KB","MB","GB","TB"],r=Math.floor(Math.log(e)/Math.log(n));return Math.round(e/Math.pow(n,r)*100)/100+" "+t[r]}function l(e){if(e<1e3)return`${e}ms`;const n=Math.floor(e/1e3),t=Math.floor(n/60);return t===0?`${n}s`:`${t}m ${n%60}s`}function u(e){if(e===null||typeof e!="object")return e;if(e instanceof Date)return new Date(e.getTime());if(e instanceof Array)return e.map(n=>u(n));if(e instanceof Object){const n={};for(const t in e)e.hasOwnProperty(t)&&(n[t]=u(e[t]));return n}return e}function s(e,n){let t=null;return function(...r){t&&clearTimeout(t),t=setTimeout(()=>e.apply(this,r),n)}}function c(e,n){let t;return function(...r){t||(e.apply(this,r),t=!0,setTimeout(()=>t=!1,n))}}var m={VERSION:o,APP_NAME:i,APP_DESCRIPTION:f,formatFileSize:a,formatTime:l,deepClone:u,debounce:s,throttle:c};exports.APP_DESCRIPTION=f,exports.APP_NAME=i,exports.VERSION=o,exports.debounce=s,exports.deepClone=u,exports.default=m,exports.formatFileSize=a,exports.formatTime=l,exports.throttle=c;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=index.cjs.map
