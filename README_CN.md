# **nano11 极致精简构建器 (GUI 交互版) 🔬**

基于 NTDEV 的 nano11 项目，通过 PowerShell 自动化构建超轻量级 Windows 11 镜像。

---

## **❤️ 致谢原作者**

本项目核心逻辑源于 **NTDEV** 的 `nano11` 开源脚本。感谢原作者为 Windows 精简社区做出的杰出贡献。如果您喜欢这个项目，请考虑通过以下方式支持原作者：
* **[Patreon](http://patreon.com/ntdev)** | **[PayPal](http://paypal.me/ntdev2)** | **[Ko-fi](http://ko-fi.com/ntdev)**

---

## **☢️ 极其重要：操作前必读**

这是一个 **高度实验性** 的脚本，旨在创建极小化的开发测试环境。
* **不可维护性：** 生成的系统移除了 **Windows 组件库 (WinSxS)**、**Windows Update** 和 **Windows Defender**。
* **无法还原：** 您将无法添加新功能、语言包、驱动程序，也无法接收任何安全更新。
* **移除内容：** 包括绝大部分 bloatware 应用、搜索、BitLocker、生物识别以及除 VGA、网络、存储之外的大多数驱动程序。
* **用途：** 仅推荐用于虚拟机、嵌入式测试或极速开发环境。

---

## **🖥️ GUI 工具使用说明**

为了让精简过程更加直观，我们新增了图形用户界面 (GUI)，让您无需修改脚本代码即可自定义精简方案。

### **1. 准备工作**
1. **下载 ISO：** 从微软官网获取 Windows 11 ISO 镜像。
2. **挂载镜像：** 右键点击 ISO 文件，选择“装载”，并记下该虚拟光驱的**盘符**（例如 `E:`）。
3. **环境权限：** 以管理员身份打开 PowerShell，运行以下命令允许脚本执行：
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process
