"use strict";/*!
 * ***********************************
 * ldesign-simple-app v1.0.0       *
 * Built with rollup               *
 * Build time: 2024-10-21 11:21:49 *
 * Build mode: production          *
 * Minified: No                    *
 * ***********************************
 */function e(r){const o=r.message||"\u672A\u77E5\u9519\u8BEF";document.body.innerHTML=`
    <div style="
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      font-family: system-ui;
      background: linear-gradient(135deg, var(--ld-color-primary-500, #667eea) 0%, var(--ld-color-primary-700, #764ba2) 100%);
      color: var(--ld-color-gray-50, white);
      text-align: center;
      padding: 20px;
    ">
      <h1 style="font-size: 48px; margin: 0 0 20px 0;">\u{1F614}</h1>
      <h2 style="font-size: 24px; margin: 0 0 10px 0;">\u5E94\u7528\u542F\u52A8\u5931\u8D25</h2>
      <p style="font-size: 16px; margin: 0 0 20px 0; opacity: 0.9;">${o}</p>
      <button 
        onclick="location.reload()" 
        style="
          padding: 12px 24px;
          font-size: 16px;
          border: 2px solid var(--ld-color-gray-50, white);
          background: transparent;
          color: var(--ld-color-gray-50, white);
          border-radius: 8px;
          cursor: pointer;
          transition: all 0.3s;
        "
        onmouseover="this.style.background='var(--ld-color-gray-50, white)'; this.style.color='var(--ld-color-primary-500, #667eea)';"
        onmouseout="this.style.background='transparent'; this.style.color='var(--ld-color-gray-50, white)';"
      >
        \u91CD\u65B0\u52A0\u8F7D
      </button>
    </div>
  `}function t(r,o){console.error(`[\u5E94\u7528\u9519\u8BEF] ${o}:`,r)}exports.handleAppError=t,exports.showErrorPage=e;/*! End of ldesign-simple-app | Powered by @ldesign/builder */
//# sourceMappingURL=error-handler.cjs.map
