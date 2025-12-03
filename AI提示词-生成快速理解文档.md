# AI Prompt：生成模块快速理解文档

> 直接复制下方提示词，替换 `[模块路径]` 后发送给 AI 助手。

---

## 📋 中文提示词

```
请为 [模块路径] 生成一个"快速理解.md"文档。

要求：
1. 文档总长度不超过 110 行
2. 必须包含以下 9 个章节（使用 emoji）：
   - 📌 核心定位（说明是否连接数据库、调用哪些服务）
   - 🎯 主要功能（3-7 个功能点，每条 10 字以内）
   - 🏗️ 技术栈（不超过 5 个核心技术）
   - 📁 核心目录结构（2-3 层深度，列出 3-5 个关键文件）
   - 🔑 核心接口（如有对外 API，列出 5-10 个）
   - 🏛️ 微服务架构（如有依赖其他服务，用 ASCII 图展示）
   - 🔥 技术亮点（3-5 个设计特色）
   - 🚀 快速启动（列出依赖服务 + 启动命令）
   - 📌 注意事项（3-7 条，第一条加粗）

3. 编写原则：
   - 精简至上：每个章节不超过 15 行
   - 避免冗余：不写背景介绍、技术选型理由、详细配置
   - 突出重点：用加粗、代码块、emoji 标注关键信息
   - 面向新人：用简单直白的语言，假设读者了解 Spring Boot 但不了解本项目

4. 特别注意：
   - 在"核心定位"中明确说明本模块是否直接连接数据库
   - 如果不连接数据库，说明通过什么方式获取数据（如 Dubbo RPC）
   - "技术栈"只列核心框架，不列通用依赖（Lombok、Jackson 等）
   - "注意事项"第一条必须说明数据源或依赖关系

参考示例：xypai-auth/快速理解.md
```

---

## 📋 English Prompt

```
Please generate a "Quick Understanding.md" document for the module at [module-path].

Requirements:
1. Total length ≤ 110 lines
2. Must include these 9 sections (with emoji):
   - 📌 Core Positioning (explain database connection & service dependencies)
   - 🎯 Main Features (3-7 items, ≤10 words each)
   - 🏗️ Tech Stack (≤5 core technologies)
   - 📁 Core Directory Structure (2-3 levels, 3-5 key files)
   - 🔑 Core APIs (if applicable, 5-10 endpoints)
   - 🏛️ Microservice Architecture (ASCII diagram if depends on other services)
   - 🔥 Technical Highlights (3-5 design features)
   - 🚀 Quick Start (dependencies + startup commands)
   - 📌 Important Notes (3-7 items, bold the first one)

3. Writing Principles:
   - Concise: Each section ≤15 lines
   - No Redundancy: No background, tech selection reasons, or detailed configs
   - Highlight Key Points: Use bold, code blocks, and emoji
   - Beginner-Friendly: Simple language, assume Spring Boot knowledge but not project knowledge

4. Special Notes:
   - In "Core Positioning", clearly state if this module connects to database directly
   - If no direct DB connection, explain how it gets data (e.g., Dubbo RPC)
   - "Tech Stack" only lists core frameworks, not common dependencies (Lombok, Jackson, etc.)
   - First item in "Important Notes" must explain data source or dependencies

Reference example: xypai-auth/快速理解.md
```

---

## 🎯 快速使用步骤

### 场景 1：为新模块生成文档
```bash
# 1. 复制上方提示词
# 2. 替换 [模块路径] 为实际路径，如：
#    e:\Users\Administrator\Documents\GitHub\RuoYi-Cloud-Plus\xypai-payment

# 3. 发送给 AI 助手（Claude、GPT-4、通义千问等）

# 4. AI 会生成文档，保存为：[模块根目录]/快速理解.md
```

### 场景 2：批量生成多个模块文档
```
请为以下模块生成"快速理解.md"文档：
1. xypai-payment
2. xypai-activity
3. xypai-moment

要求同上。
```

---

## 💡 提示词优化建议

### 如果生成的文档太详细：
```
文档太长了，请精简到 100 行以内。去掉：
- 代码示例
- 详细配置说明
- 背景介绍
只保留最核心的信息。
```

### 如果某个章节缺失：
```
请补充"🏛️ 微服务架构"章节，用 ASCII 图展示：
本模块 → 调用哪些服务 → 连接哪个数据库
```

### 如果数据库信息不准确：
```
更正：本模块不直接连接数据库，而是通过 Dubbo RPC 调用 xypai-xxx 服务。
请更新以下章节：
- 📌 核心定位
- 🏛️ 微服务架构
- 📌 注意事项
```

---

## 📚 相关文件

- `快速理解.md` - 示例文档（xypai-auth 模块）
- `模块文档编写模板.md` - 详细编写指南（人工编写用）
- 本文件 - AI 提示词（AI 辅助生成用）
