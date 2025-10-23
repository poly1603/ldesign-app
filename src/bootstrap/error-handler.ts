/**
 * 错误处理模块
 * 统一管理应用的错误处理逻辑
 */

/**
 * 设置错误处理
 */
export function setupErrorHandling(error: Error): void {
  // 记录错误
  console.error('[Error Handler] 捕获错误:', error)

  // 这里可以集成错误上报服务
  // 例如：Sentry, LogRocket 等
}

/**
 * 显示错误页面
 */
export function showErrorPage(error: Error): void {
  const app = document.querySelector('#app')
  if (app) {
    app.innerHTML = `
      <div style="
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100vh;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 20px;
        text-align: center;
      ">
        <h1 style="font-size: 48px; margin: 0 0 20px 0;">😵 应用启动失败</h1>
        <p style="font-size: 18px; margin: 0 0 30px 0; opacity: 0.9;">
          抱歉，应用在启动时遇到了问题
        </p>
        <div style="
          background: rgba(255, 255, 255, 0.2);
          border-radius: 8px;
          padding: 20px;
          margin: 0 0 30px 0;
          max-width: 600px;
          text-align: left;
        ">
          <p style="margin: 0; font-family: monospace; font-size: 14px; word-break: break-all;">
            ${error.message || '未知错误'}
          </p>
        </div>
        <button 
          onclick="location.reload()" 
          style="
            background: white;
            color: #667eea;
            border: none;
            padding: 12px 32px;
            border-radius: 24px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
          "
          onmouseover="this.style.transform='scale(1.05)'"
          onmouseout="this.style.transform='scale(1)'"
        >
          重新加载
        </button>
      </div>
    `
  }
}
