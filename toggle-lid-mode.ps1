<#
  toggle-lid-mode.ps1 — windows-clamshell-mode
  https://github.com/sammeng5232/windows-clamshell-mode

  切换「用电池时合上盖子」的行为（插电时合盖始终不睡眠，不受本脚本影响）：
    省电模式 = 睡眠          （实测一晚约掉 2~4% 电，开盖即恢复）
    挂机模式 = 不采取任何操作（AI agent 等后台任务继续运行，约 15%/小时）
  用法：双击桌面上的「切换盒盖模式」快捷方式（由 install.ps1 创建）；
        在终端手动运行时可加 -Quiet 跳过弹窗。
#>
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'

function Get-BatteryLidAction {
    # /qh 单项查询输出中只有两行 0x 值：先交流(AC)后直流(DC)
    $out = (powercfg /qh SCHEME_CURRENT SUB_BUTTONS LIDACTION) -join "`n"
    $hex = [regex]::Matches($out, '0x([0-9A-Fa-f]{8})')
    if ($hex.Count -lt 2) { throw '无法读取当前的合盖设置' }
    [Convert]::ToInt32($hex[$hex.Count - 1].Groups[1].Value, 16)
}

try {
    $current = Get-BatteryLidAction
    if ($current -eq 1) {
        # 当前=睡眠，切到挂机模式
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
        powercfg /setactive SCHEME_CURRENT
        $title = '盒盖模式：挂机'
        $body  = "电池盒盖 = 不睡眠（AI agent 继续运行）`n耗电约 15%/小时，请留意剩余电量`n插电时盒盖不受影响（始终不睡眠）"
    } else {
        # 当前=挂机（或其他），切回省电模式
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
        powercfg /setactive SCHEME_CURRENT
        $title = '盒盖模式：省电'
        $body  = "电池盒盖 = 睡眠（一晚约掉 2~4% 电）`n插电时盒盖不受影响（始终不睡眠）"
    }
} catch {
    $title = '盒盖模式切换失败'
    $body  = $_.Exception.Message
}

Write-Host "[$title]"
Write-Host $body
if (-not $Quiet) {
    try { (New-Object -ComObject WScript.Shell).Popup($body, 4, $title, 64) | Out-Null } catch { }
}
