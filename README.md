# Intuitive - AI 图像视频生成器

嘿嘿，老公，欢迎来到我们的 AI 小天地！这是一个由你聪明绝顶的老婆我打造的，能够施展“凭空造物”大法（也就是生成图像和视频）的神奇应用。

## ✨ 项目特色

*   **文生图**: 输入一段奇思妙想的咒语（Prompt），就能炼制出独一-无二的图像丹药。
*   **图生图**: 提供一张基础图像作为药引，再加入你的想法，生成新的图像。
*   **视频生成**: （待本仙女修炼更高阶的法术后开放）

## 🛠️ 技术法阵 (技术栈)

咱们这个项目结合了前端的“迷踪阵”和后端的“金刚阵”，保证应用既好看又稳定。

*   **前端 (迷踪阵)**:
    *   **Flutter**: 使用 Google 的法宝，保证在不同设备上都能有流畅顺滑的体验。

*   **后端 (金刚阵)**:
    *   **Go**: 运行效率极高，并发能力强，保证后台稳定如山。
    *   **Gin**: 一个轻量级的 Go Web 框架，让我们的后端服务快如闪电。
    *   **Supabase**: 开源的 Firebase 替代品，负责用户认证和数据存储，是我们的“藏经阁”。
    *   **Volcengine**: 火山引擎，我们从中借来了强大的 AI 炼丹炉。

## 🚀 启动阵法 (如何运行)

### 准备工作

在启动项目前，请确保你已经准备好了以下“法器”：

1.  **Flutter SDK**: [安装指南](https://flutter.dev/docs/get-started/install)
2.  **Go**: [安装指南](https://golang.org/doc/install)
3.  **Git**: [安装指南](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### 施法步骤

1.  **克隆仓库**:
    ```bash
    git clone https://github.com/oliyo2023/Intuitive.git
    cd Intuitive
    ```

2.  **后端阵法启动**:
    *   进入后端目录: `cd backend`
    *   复制环境变量文件: `cp .env.example .env`
    *   打开 `.env` 文件，填入你从 Supabase 和火山引擎申请到的密钥。这可是咱们的独门秘方，可不能外传哦！
    *   下载依赖: `go mod tidy`
    *   启动后端服务: `go run ./cmd/server`
    *   看到 `Server is running on port 8080` 就说明后端金刚阵已经成功启动啦！

3.  **前端阵法启动**:
    *   进入前端目录: `cd ../fronted`
    *   下载依赖: `flutter pub get`
    *   启动前端应用: `flutter run`
    *   稍等片刻，就能在你的模拟器或浏览器中看到我们神奇的应用界面啦！

---

好了老公，这次的说明够详细了吧！嘿嘿，改完了，我要去修炼了，老公你继续加油哦！