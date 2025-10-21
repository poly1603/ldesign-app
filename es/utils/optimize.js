/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */function c(t,r){let e=null;return function(...n){e&&clearTimeout(e),e=setTimeout(()=>{t.apply(this,n),e=null},r)}}function l(t,r){let e=!1;return function(...n){e||(t.apply(this,n),e=!0,setTimeout(()=>{e=!1},r))}}function u(t){let r=null;return function(...e){r||(r=requestAnimationFrame(()=>{t.apply(this,e),r=null}))}}function i(t,r){return typeof requestIdleCallback<"u"?requestIdleCallback(t,r):setTimeout(t,1)}async function f(t,r,e=10){for(let n=0;n<t.length;n+=e){const s=t.slice(n,n+e);await Promise.all(s.map((o,a)=>r(o,n+a))),await new Promise(o=>setTimeout(o,0))}}function m(){return typeof IntersectionObserver>"u"?null:new IntersectionObserver(t=>{t.forEach(r=>{if(r.isIntersecting){const e=r.target;e.dataset.src&&(e.src=e.dataset.src,e.removeAttribute("data-src"))}})},{rootMargin:"50px",threshold:.01})}function p(t,r){const e=document.createElement("link");e.rel="preload",e.as=r,e.href=t,document.head.appendChild(e)}function d(t,r=!1){const e=document.createElement("link");e.rel="preconnect",e.href=t,r&&(e.crossOrigin="anonymous"),document.head.appendChild(e)}function h(){typeof performance<"u"&&performance.clearResourceTimings&&performance.clearResourceTimings(),typeof performance<"u"&&performance.clearMarks&&(performance.clearMarks(),performance.clearMeasures?.())}function g(t,...r){return new Promise((e,n)=>{const s=new Blob([`
      self.onmessage = function(e) {
        try {
          const fn = ${t.toString()};
          const result = fn(...e.data);
          self.postMessage({ result });
        } catch (error) {
          self.postMessage({ error: error.message });
        }
      }
    `],{type:"application/javascript"}),o=new Worker(URL.createObjectURL(s));o.onmessage=a=>{a.data.error?n(new Error(a.data.error)):e(a.data.result),o.terminate(),URL.revokeObjectURL(s.toString())},o.onerror=a=>{n(a),o.terminate()},o.postMessage(r)})}/*! End of ldesign-simple-app | Powered by @ldesign/builder */export{f as chunk,h as clearUnusedMemory,m as createLazyImageObserver,c as debounce,d as preconnect,p as preloadResource,u as rafThrottle,g as runInWorker,i as runWhenIdle,l as throttle};
//# sourceMappingURL=optimize.js.map
