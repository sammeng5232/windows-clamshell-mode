<#
  uninstall.ps1 — 移除 windows-clamshell-mode
  功能：删除桌面快捷方式与已安装的脚本；
        加 -RestoreDefaults 同时恢复 Windows 默认合盖行为（插电/电池均=睡眠）
  用法：
    powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1
#>
param(
    [string]$InstallDir = (Join-Path $env:USERPROFILE 'bin'),
    [string]$ShortcutName = '切换盒盖模式',
    [switch]$RestoreDefaults
)

$ErrorActionPreference = 'Stop'

$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop "$ShortcutName.lnk"
if (Test-Path $lnkPath) {
    Remove-Item $lnkPath
    Write-Host "已删除快捷方式: $lnkPath"
}

$dst = Join-Path $InstallDir 'toggle-lid-mode.ps1'
if (Test-Path $dst) {
    Remove-Item $dst
    Write-Host "已删除脚本: $dst"
}

if ($RestoreDefaults) {
    powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
    powercfg /setactive SCHEME_CURRENT
    Write-Host '已恢复 Windows 默认：合盖=睡眠（插电/电池）'
} else {
    Write-Host '电源设置未改动。如需恢复 Windows 默认（合盖=睡眠），运行:'
    Write-Host '  powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1'
    Write-Host '  powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1'
    Write-Host '  powercfg /setactive SCHEME_CURRENT'
}
