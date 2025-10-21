/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */class r{constructor(){Object.defineProperty(this,"timer",{enumerable:!0,configurable:!0,writable:!0,value:null})}start(){console.log("\u{1F504} \u8DEF\u7531\u5207\u6362\u5F00\u59CB...")}done(){this.timer&&(clearTimeout(this.timer),this.timer=null),console.log("\u2705 \u8DEF\u7531\u5207\u6362\u5B8C\u6210")}}const u=new r;function o(e){e.beforeEach((s,n,t)=>{u.start(),t()}),e.afterEach(()=>{u.done()})}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{o as setupProgressGuard};
//# sourceMappingURL=progress.guard.js.map
