/**
 * 工具类型定义
 */

/**
 * 深度部分类型
 */
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P]
}

/**
 * 深度只读类型
 */
export type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P]
}

/**
 * 可选字段类型
 */
export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>

/**
 * 必需字段类型
 */
export type Required<T, K extends keyof T> = T & {
  [P in K]-?: T[P]
}

/**
 * 提取函数类型
 */
export type ExtractFunctions<T> = {
  [K in keyof T]: T[K] extends (...args: any[]) => any ? T[K] : never
}

/**
 * 提取属性类型
 */
export type ExtractProperties<T> = {
  [K in keyof T]: T[K] extends (...args: any[]) => any ? never : T[K]
}

/**
 * Promise 返回值类型
 */
export type PromiseValue<T> = T extends Promise<infer U> ? U : T

/**
 * 数组元素类型
 */
export type ArrayElement<T> = T extends (infer U)[] ? U : never

/**
 * 函数参数类型
 */
export type FunctionParams<T> = T extends (...args: infer P) => any ? P : never

/**
 * 函数返回值类型
 */
export type FunctionReturn<T> = T extends (...args: any[]) => infer R ? R : never

