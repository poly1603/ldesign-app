/**
 * 错误处理模块
 * 处理应用启动失败的情况
 */
/**
 * 显示启动失败错误页面
 */
export declare function showErrorPage(error: Error): void;
/**
 * 应用错误处理器
 */
export declare function handleAppError(error: Error, context: string): void;
