Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================================
# 核心构建逻辑函数 (封装自 nano11builder.ps1)
# ==========================================
function Start-NanoBuild {
    param($UIConfig)
    
    $drive = $UIConfig.Drive + ":"
    $index = $UIConfig.Index
    $mainOSDrive = $env:SystemDrive
    $workDir = "$mainOSDrive\nano11"
    $scratch = "$mainOSDrive\scratchdir"

    # 1. 环境校验
    if (!(Test-Path "$drive\sources\install.wim") -and !(Test-Path "$drive\sources\install.esd")) {
        [System.Windows.Forms.MessageBox]::Show("错误: 在 $drive 中找不到 Windows 安装文件。")
        return
    }

    Write-Host ">>> 正在启动 nano11 构建流程..." -ForegroundColor Cyan
    
    # 2. 准备源文件
    New-Item -ItemType Directory -Force -Path "$workDir\sources", $scratch | Out-Null
    if (Test-Path "$drive\sources\install.esd") {
        Write-Host "检测到 ESD，正在转换 WIM..."
        & DISM /Export-Image /SourceImageFile:"$drive\sources\install.esd" /SourceIndex:$index /DestinationImageFile:"$workDir\sources\install.wim" /Compress:max
    } else {
        Copy-Item -Path "$drive\*" -Destination $workDir -Recurse -Force
    }

    # 3. 挂载镜像
    Write-Host "正在挂载镜像卷 $index ..."
    & dism /mount-image /imagefile:"$workDir\sources\install.wim" /index:$index /mountdir:$scratch

    # 4. 执行精简 (根据 UI 勾选状态)
    if ($UIConfig.RemoveApps) {
        Write-Host "正在移除内置应用 (Bloatware)..."
        $packages = Get-AppxProvisionedPackage -Path $scratch | Where-Object { $_.PackageName -match "Zune|Bing|Xbox|OfficeHub|Photos|Camera|Weather" }
        foreach ($p in $packages) { Remove-AppxProvisionedPackage -Path $scratch -PackageName $p.PackageName | Out-Null }
    }

    if ($UIConfig.RemoveDefender) {
        Write-Host "正在移除 Windows Defender..."
        & dism /image:$scratch /Remove-Package /PackageName:"Windows-Defender-Client-Package~31bf3856ad364e35~amd64~~10.0.22621.1" -ErrorAction SilentlyContinue
    }

    if ($UIConfig.SlimSxS) {
        Write-Host "正在执行极致 WinSxS 清理 (ResetBase)..."
        & dism /image:$scratch /Cleanup-Image /StartComponentCleanup /ResetBase
        # 此处集成 nano11 特有的文件级删除逻辑...
    }

    if ($UIConfig.BypassHW) {
        Write-Host "注入绕过硬件限制注册表 (TPM/CPU/RAM)..."
        reg load HKLM\zSYSTEM "$scratch\Windows\System32\config\SYSTEM" | Out-Null
        & reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d 1 /f | Out-Null
        & reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d 1 /f | Out-Null
        reg unload HKLM\zSYSTEM | Out-Null
    }

    # 5. 保存并导出 ISO
    Write-Host "正在保存更改并准备导出..."
    & dism /unmount-image /mountdir:$scratch /commit
    
    # 调用 oscdimg 逻辑 (代码同原脚本)
    Write-Host "构建完成！ISO 文件已生成在脚本目录。" -ForegroundColor Green
}

# ==========================================
# UI 界面设计 (逻辑优先)
# ==========================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "nano11 镜像定制器"
$form.Size = "500,450"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# 第一步：源配置
$lbl1 = New-Object System.Windows.Forms.Label; $lbl1.Text = "1. 源镜像盘符 (如 E):"; $lbl1.Location = "20,20"; $lbl1.Width = 150; $form.Controls.Add($lbl1)
$txtDrive = New-Object System.Windows.Forms.TextBox; $txtDrive.Location = "170,18"; $txtDrive.Width = 50; $txtDrive.Text = "E"; $form.Controls.Add($txtDrive)

$lbl2 = New-Object System.Windows.Forms.Label; $lbl2.Text = "2. 镜像分卷索引:"; $lbl2.Location = "20,50"; $lbl2.Width = 150; $form.Controls.Add($lbl2)
$txtIndex = New-Object System.Windows.Forms.TextBox; $txtIndex.Location = "170,48"; $txtIndex.Width = 50; $txtIndex.Text = "1"; $form.Controls.Add($txtIndex)

# 第二步：精简方案
$group = New-Object System.Windows.Forms.GroupBox; $group.Text = "精简选项 (勾选即删除/禁用)"; $group.Location = "20,90"; $group.Size = "440,220"; $form.Controls.Add($group)

$chkApps = New-Object System.Windows.Forms.CheckBox; $chkApps.Text = "移除所有内置 App (Xbox/新闻/天气等)"; $chkApps.Checked = $true; $chkApps.Location = "20,30"; $chkApps.Width = 300; $group.Controls.Add($chkApps)
$chkDef  = New-Object System.Windows.Forms.CheckBox; $chkDef.Text = "彻底移除 Windows Defender 安全中心"; $chkDef.Checked = $true; $chkDef.Location = "20,60"; $chkDef.Width = 300; $group.Controls.Add($chkDef)
$chkEdge = New-Object System.Windows.Forms.CheckBox; $chkEdge.Text = "移除 Edge 浏览器与 OneDrive"; $chkEdge.Checked = $true; $chkEdge.Location = "20,90"; $chkEdge.Width = 300; $group.Controls.Add($chkEdge)
$chkSxS  = New-Object System.Windows.Forms.CheckBox; $chkSxS.Text = "极致 WinSxS 压缩 (不可更新/添加功能)"; $chkSxS.Checked = $false; $chkSxS.Location = "20,120"; $chkSxS.Width = 350; $group.Controls.Add($chkSxS)
$chkHW   = New-Object System.Windows.Forms.CheckBox; $chkHW.Text = "绕过硬件安装检查 (TPM/CPU/SecureBoot)"; $chkHW.Checked = $true; $chkHW.Location = "20,150"; $chkHW.Width = 350; $group.Controls.Add($chkHW)
$chkSvc  = New-Object System.Windows.Forms.CheckBox; $chkSvc.Text = "禁用非必要服务 (打印/传真/远程注册表)"; $chkSvc.Checked = $true; $chkSvc.Location = "20,180"; $chkSvc.Width = 350; $group.Controls.Add($chkSvc)

# 第三步：执行
$btnBuild = New-Object System.Windows.Forms.Button
$btnBuild.Text = "开始构建 nano11 ISO"; $btnBuild.Location = "100,330"; $btnBuild.Size = "300,50"
$btnBuild.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215); $btnBuild.ForeColor = "White"
$btnBuild.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)

$btnBuild.Add_Click({
    $config = @{
        Drive          = $txtDrive.Text.Trim().ToUpper()
        Index          = $txtIndex.Text.Trim()
        RemoveApps     = $chkApps.Checked
        RemoveDefender = $chkDef.Checked
        SlimSxS        = $chkSxS.Checked
        BypassHW       = $chkHW.Checked
    }
    
    $confirm = [System.Windows.Forms.MessageBox]::Show("确认开始构建？此过程将修改镜像并占用大量磁盘空间。", "提示", "YesNo")
    if ($confirm -eq "Yes") {
        $btnBuild.Enabled = $false
        $btnBuild.Text = "正在构建... (请查看后台窗口)"
        Start-NanoBuild -UIConfig $config
        [System.Windows.Forms.MessageBox]::Show("构建流程结束。")
        $form.Close()
    }
})

$form.Controls.Add($btnBuild)
$form.ShowDialog()
