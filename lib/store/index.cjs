"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */Object.defineProperty(exports,"__esModule",{value:!0});var e=require("@ldesign/store"),r=require("../config/store.config.cjs");const i=e.useStore;function t(n={}){const o={...r.storeConfig,...n};return e.createStoreEnginePlugin(o)}function u(){return t(r.storeConfig)}var s={useStore:e.useStore,useState:e.useState,useAction:e.useAction,useGetter:e.useGetter,createStoreEnginePlugin:t,createStore:u};Object.defineProperty(exports,"useAction",{enumerable:!0,get:function(){return e.useAction}}),Object.defineProperty(exports,"useGetter",{enumerable:!0,get:function(){return e.useGetter}}),Object.defineProperty(exports,"useState",{enumerable:!0,get:function(){return e.useState}}),exports.createStore=u,exports.createStoreEnginePlugin=t,exports.default=s,exports.useStore=i;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=index.cjs.map
