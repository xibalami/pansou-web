# PanSou Web

PanSou 的现代化 Web 前端界面，基于 Vue 3 构建的高性能网盘资源搜索应用。

[![Vue](https://img.shields.io/badge/Vue-3.5.17-4FC08D?style=flat-square&logo=vue.js)](https://vuejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8.3-3178C6?style=flat-square&logo=typescript)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-4.5.1-646CFF?style=flat-square&logo=vite)](https://vitejs.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.4.0-38B2AC?style=flat-square&logo=tailwind-css)](https://tailwindcss.com/)

## ✨ 特性

### 🚀 现代化技术栈
- **Vue 3** + **TypeScript** - 类型安全的现代前端框架
- **Tailwind CSS** - 原子化CSS框架，支持深色模式
- **Vite** - 极速的开发构建工具
- **响应式设计** - 完美适配桌面端和移动端

### 🎯 核心功能
- **智能搜索** - 渐进式搜索策略，先快速返回TG结果，再逐步完善
- **多源搜索** - 支持Telegram频道搜索和插件搜索
- **分类展示** - 按网盘类型（百度网盘、阿里云盘、夸克网盘等）智能分类
- **实时更新** - 搜索过程中自动更新结果，提供最新数据
- **状态监控** - API健康状态实时监控
- **API文档** - 内置交互式API文档

### 🔥 搜索策略
```
用户搜索 → TG快速搜索(2s内) → ALL源搜索(+2s) → 第二轮更新(+3s) → 完成
           ↓                ↓              ↓
         快速响应          综合结果        最新数据
```

### 📱 用户体验
- **毫秒级响应** - 优化的API调用和缓存策略
- **优雅动画** - 流畅的页面切换和加载动画
- **错误容错** - 网络异常时自动降级到模拟数据
- **无障碍设计** - 符合Web无障碍标准

## 🖼️ 界面预览

- **搜索界面** - 简洁直观的搜索体验
- **结果展示** - 按网盘类型分标签页展示
- **状态页面** - API服务状态和插件监控
- **文档页面** - 完整的API使用说明

## 🛠️ 技术架构

### 目录结构
```
src/
├── api/           # API接口封装
├── assets/        # 静态资源
├── components/    # Vue组件
│   ├── ui/        # 基础UI组件
│   ├── ApiDocs.vue    # API文档组件
│   ├── ApiStatus.vue  # API状态组件
│   ├── ResultTabs.vue # 搜索结果组件
│   ├── SearchForm.vue # 搜索表单组件
│   └── SearchStats.vue # 搜索统计组件
├── types/         # TypeScript类型定义
├── utils/         # 工具函数
├── App.vue        # 根组件
└── main.ts        # 入口文件
```

### 核心组件

#### SearchForm.vue
- 搜索关键词输入
- 搜索源选择（全部/TG/插件）
- 插件选择器
- 高级搜索选项

#### ResultTabs.vue  
- 按网盘类型分标签页

#### ApiStatus.vue
- 服务健康状态
- 插件状态监控
- 频道连接状态
- 性能指标展示

#### ApiDocs.vue
- 交互式API文档
- 请求示例
- 响应格式说明
- 参数详细说明

## 🚀 快速开始

### 环境要求

- Node.js 16+ 
- npm 或 yarn

### 安装依赖

```bash
npm install
```

### 开发调试

```bash
npm run dev
```

访问 http://localhost:5173 查看开发版本

> 开发模式下，API请求会代理到配置的后端地址（默认：`http://localhost:8888`）

### 构建生产版本

```bash
npm run build
```

构建产物输出到 `dist/` 目录

### 预览生产版本

```bash
npm run preview
```

## 🔧 环境变量配置

### 后端API地址配置

项目支持通过环境变量配置后端API地址，便于不同环境的部署。

#### 创建环境配置文件

在项目根目录创建 `.env` 文件：

```bash
# .env
VITE_API_BASE_URL=http://localhost:8888
```

#### 环境变量说明

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `VITE_API_BASE_URL` | 后端API基础地址 | `http://localhost:8888` | `https://api.example.com` |

#### 不同环境配置示例

```bash
# 开发环境 (.env.development)
VITE_API_BASE_URL=http://localhost:8888

# 生产环境 (.env.production) 
VITE_API_BASE_URL=https://your-pansou-api.com

# 测试环境 (.env.test)
VITE_API_BASE_URL=https://test-api.example.com
```

> **注意**: `.env` 文件不应提交到版本控制系统。请将其添加到 `.gitignore` 中。

## ⚙️ 配置说明

### Vite 配置 (vite.config.js)

```javascript
export default defineConfig(({ mode }) => {
  // 加载环境变量
  const env = loadEnv(mode, process.cwd(), '')
  
  return {
    plugins: [vue()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      }
    },
    server: {
      proxy: {
        '/api': {
          target: env.VITE_API_BASE_URL || 'http://localhost:8888',
          changeOrigin: true
        }
      }
    }
  }
})
```

### API 配置

```typescript
// src/api/index.ts
const api = axios.create({
  baseURL: '/api',  // 生产环境使用相对路径
  timeout: 10000
});
```

### 主题配置

项目使用 CSS 变量系统，支持明暗主题切换：

```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  /* ... 更多主题变量 */
}
```

## 🔌 API 集成

### 搜索接口

```typescript
interface SearchParams {
  kw: string;           // 搜索关键词
  refresh?: boolean;    // 是否刷新缓存
  res?: 'all' | 'results' | 'merge';  // 响应格式
  src?: 'all' | 'tg' | 'plugin';      // 搜索源
  plugins?: string;     // 指定插件
}
```

### 响应格式

```typescript
interface SearchResponse {
  total: number;                    // 总结果数
  results: ResultItem[];           // 详细结果列表
  merged_by_type: MergedResults;   // 按类型合并的结果
}
```

## 🎨 样式系统

### Tailwind CSS 定制

- **设计系统** - 基于 shadcn/ui 设计令牌
- **响应式** - Mobile-first 响应式设计
- **主题切换** - 支持明暗主题无缝切换
- **动画效果** - 流畅的过渡和加载动画

### 关键样式类

```css
.card - 卡片容器样式
.nav-button - 导航按钮样式
.bg-decorative - 背景装饰图案
```

## 📦 部署

### 单独部署

1. 构建项目：`npm run build`
2. 部署 `dist/` 目录到静态服务器
3. 配置服务器代理 `/api` 到 PanSou 后端

### Docker 集成部署

配合 PanSou 后端的 Docker 镜像：

```dockerfile
# 构建前端
COPY pansou-web/dist /app/frontend/dist/

# Nginx 配置
location /api/ {
  proxy_pass http://127.0.0.1:8888/api/;
}

location / {
  root /app/frontend/dist;
  try_files $uri $uri/ /index.html;
}
```
