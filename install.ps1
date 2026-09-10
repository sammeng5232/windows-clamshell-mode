<#
  install.ps1 — windows-clamshell-mode 安装脚本
  功能：
    1. 复制 toggle-lid-mode.ps1 到 ~\bin（-InstallDir 可自定义）
    2. 在桌面创建「切换盒盖模式」快捷方式（-ShortcutName 可自定义）
    3. 应用推荐电源配置：插电合盖=不采取任何操作，电池合盖=睡眠（-NoConfig 跳过）
  用法：
    powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
  无需管理员权限。
#>
param(
    [string]$InstallDir = (Join-Path $env:USERPROFILE 'bin'),
    [string]$ShortcutName = '切换盒盖模式',
    [switch]$NoConfig
)

$ErrorActionPreference = 'Stop'

# 1. 复制脚本
$src = Join-Path $PSScriptRoot 'toggle-lid-mode.ps1'
if (-not (Test-Path $src)) { throw "找不到 $src" }
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Path $InstallDir | Out-Null }
$dst = Join-Path $InstallDir 'toggle-lid-mode.ps1'
Copy-Item $src $dst -Force
Write-Host "已安装脚本: $dst"

# 2. 创建桌面快捷方式
$desktop = [Environment]::GetFolderPath('Desktop')
$ws = New-Object -ComObject WScript.Shell
$lnkPath = Join-Path $desktop "$ShortcutName.lnk"
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$lnk.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$dst`""
$lnk.WorkingDirectory = $InstallDir
$lnk.WindowStyle = 7
$lnk.Description = '切换电池合盖行为：省电(睡眠) / 挂机(不睡眠)'
if (Test-Path "$env:SystemRoot\System32\powercpl.dll") { $lnk.IconLocation = "$env:SystemRoot\System32\powercpl.dll,0" }
$lnk.Save()
Write-Host "已创建快捷方式: $lnkPath"

# 3. 应用推荐配置
if ($NoConfig) {
    Write-Host '已跳过电源配置（-NoConfig）'
} else {
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
    powercfg /setactive SCHEME_CURRENT
    Write-Host '已应用推荐配置：插电合盖=不动作（挂机），电池合盖=睡眠（省电）'
}

Write-Host '安装完成。双击桌面快捷方式即可切换模式。'
