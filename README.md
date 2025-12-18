# **nano11 🔬**

A PowerShell script to build an even more heavily trimmed-down Windows 11 image.

## **Introduction**

Introducing nano11 builder, a PowerShell script that creates an even smaller Windows 11 image!

The goal of nano11 is to automate the build of a streamlined Windows 11 image. The script uses only built-in DISM capabilities and the official oscdimg.exe (downloaded automatically) to create a bootable ISO with no external binaries. An included unattended answer file helps bypass the Microsoft Account requirement during setup and enables compact installation by default.
It's open-source, so feel free to modify and adapt it to your needs\! Also, feedback is much appreciated!

## **☢️ BEFORE YOU BEGIN:**

This is an **extreme experimental script** designed for creating a quick and dirty development testbed. It removes everything possible to get the smallest footprint, including the Windows Component Store (WinSxS), core services, and much more.

The resulting OS is **not serviceable**. This means you cannot add languages, drivers, or features, and you will not receive Windows Updates. It is intended only for testing, development, or embedded use in VMs where a minimal, static environment is required.

## **What is removed?**

The nano11.ps1 script is extremely aggressive. It removes:

* **All Bloatware Apps:** Clipchamp, News, Weather, Xbox, Office Hub, Solitaire, etc.  
* **Core System Components:**  
  * ⛔ **Windows Component Store (WinSxS)**  
  * ⛔ **Windows Update** (and its services)  
  * ⛔ **Windows Defender** (and its services)  
  * ⛔ Most **Drivers** (keeps VGA, Net, Storage only)  
  * ⛔ **All IMEs** (Asian languages)  
  * ⛔ Search, BitLocker, Biometrics, and Accessibility features  
  * ⛔ Most system services (including Audio)  
* **Other Components:**  
  * Microsoft Edge & OneDrive  
  * Internet Explorer & Tablet PC Math

⚠️ **Important:** You cannot add back features or languages in an image created with this script\!

## **Instructions**

1. **Download Windows 11** from the Microsoft website.  
2. **Mount the downloaded ISO** image by right-clicking it and selecting "Mount". Note the drive letter.  
3. **Open PowerShell as Administrator**.  
4. **Set the execution policy** for the current session by running this command:  
   Set-ExecutionPolicy Bypass \-Scope Process

5. **Navigate to the script's folder** and start it:  
   C:\\path\\to\\your\\nano11\\nano11.ps1

6. **Follow the prompts:** The script will ask for the drive letter of the mounted image and the edition (SKU) you want to base your image on.  
7. **Sit back and relax\!** When completed, the new ISO will be in the same folder as the script.

In the end you should get an image that is up to **3 times** as smaller as a standard Windows 11 image!
## 🎬 Watch the Demo

[![Here's how to use nano11 builder, including how you can get to an installation as small as 3GB!](https://img.youtube.com/vi/YIOesMc50Dw/maxresdefault.jpg)](https://www.youtube.com/watch?v=YIOesMc50Dw)

## Pre-built image
You can download a pre-built image (the one shown in the video!) from here: 
[archive.org](https://archive.org/details/nano11_25h2) 

## ❤️ Support the Project

If this project has helped you, please consider showing your support! A small donation helps me dedicate more time to projects like this.
Thank you!

**[Patreon](http://patreon.com/ntdev) | [PayPal](http://paypal.me/ntdev2) | [Ko-fi](http://ko-fi.com/ntdev)**
## And that's pretty much it for now\! Thanks for trying nano11 and let me know how you like it\!

为了提供最符合逻辑且操作简单的界面，我将 nano11builder.ps1 的核心逻辑与一个高度集成的 GUI 窗体进行了合并。
该界面采用了“一键预设”与“高级自定义”结合的设计：用户只需填入盘符，点击开始构建即可按默认极致方案执行；如果需要保留某些功能（如蓝牙或打印），只需在对应框内取消勾选。
nano11 极致精简集成工具 (GUI 版)
请将以下代码保存为 nano11_Ultimate_GUI.ps1 并以管理员权限运行
界面逻辑优势说明：
最少步骤:
用户只需确认盘符（通常脚本会自动挂载或由用户填入）。
默认勾选了 nano11 最核心的精简项（Bloatware, Defender, HW Bypass）。
安全性与灵活性:
WinSxS 极致清理默认不勾选。因为一旦执行，该系统将永远无法通过 Windows Update 更新，适合作为虚拟机的临时测试环境。
硬件绕过默认勾选。解决了在旧电脑或不合规的虚拟机上安装 Windows 11 的痛点。
反馈直观:
将命令行复杂的参数映射为通俗易懂的中文选项。
“开始构建”按钮醒目，点击后后台会自动处理复杂的 DISM 挂载与卸载操作。
注意事项：
权限：必须以“管理员权限”运行 PowerShell，否则 DISM 挂载镜像会失败。
空间：请确保系统盘（通常是 C 盘）有至少 15GB 的空余空间用于存放挂载的临时文件。
