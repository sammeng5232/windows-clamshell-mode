# windows-clamshell-mode

Windows 笔记本「合盖双模式」：**插电合盖继续挂机跑 AI agent，用电池合盖省电睡眠**，桌面一键切换。

## 解决什么问题

用笔记本跑 AI agent（通宵编码、长任务）时常常需要合盖挂机；但平时合盖又希望它睡眠省电。Windows 只给「合上盖子时」一个动作，两者不可兼得。

这套工具利用 Windows 为「插电 / 电池」分别保存合盖行为的特点，把两种需求装进同一台机器：

| 场景 | 合盖行为 |
| --- | --- |
| 插电时合盖 | 不采取任何操作 —— agent / 下载 / 渲染继续跑 |
| 用电池时合盖 | 睡眠 —— 实测一晚仅掉 2~4% 电（Modern Standby 机型） |

偶尔想在电池上也挂机？双击桌面「切换盒盖模式」切到挂机模式，再双击切回。

## 安装

```powershell
git clone https://github.com/sammeng5232/windows-clamshell-mode.git
cd windows-clamshell-mode
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

install.ps1 会：

1. 把 `toggle-lid-mode.ps1` 复制到 `~\bin`（`-InstallDir` 可自定义）
2. 在桌面创建「切换盒盖模式」快捷方式（`-ShortcutName` 可自定义）
3. 应用推荐的电源配置：插电合盖=不动作、电池合盖=睡眠（`-NoConfig` 跳过）

无需管理员权限。

## 使用

- **切换**：双击桌面「切换盒盖模式」，弹窗提示当前模式（4 秒自动消失）
- **查询当前模式**（不切换）：

  ```powershell
  powercfg /qh SCHEME_CURRENT SUB_BUTTONS LIDACTION
  ```

  「当前直流电源设置索引」= `0x00000001` 省电模式，`0x00000000` 挂机模式
- **终端运行**：`powershell -File toggle-lid-mode.ps1 -Quiet`（跳过弹窗）

## 原理与实测行为

Windows 对「合盖动作」维护**两套独立设置**（插电 AC / 电池 DC），本工具只切换电池侧，插电侧固定为「不采取任何操作」（保底挂机）。

经实测验证（Dell Pro 14 / Windows 11 / Modern Standby）的关键行为：

1. **合盖动作只在合盖瞬间触发一次**，依据当时的电源来源取对应设置；之后插拔电源不会重新触发
2. 插电合盖挂机后**断电**：机器继续运行，耗电约 15%/小时，降至临界电量（默认 2~3%）自动**休眠**兜底 —— 后台任务是冻结而非被杀，来电开盖即可继续
3. 电池合盖睡眠后插电：**不会自动唤醒**，继续睡眠
4. 「自动睡眠」保持「从不」—— 屏幕关闭、系统空闲都不会中断后台任务

## 卸载

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1
```

删除快捷方式与脚本。加 `-RestoreDefaults` 顺带恢复 Windows 默认（插电/电池合盖均=睡眠）。

## 兼容性

- Windows 10 / 11；Modern Standby（S0）与传统 S3 机型均适用
- 无需管理员权限（仅修改当前电源方案）
- 已在 Dell Pro 14（PC14250）/ Windows 11 实测

## English

A dual-mode lid-close policy for Windows laptops: keep AI agents (or any background jobs) running with the lid closed while plugged in, and sleep to save battery when running on battery power. A desktop shortcut toggles the battery-side lid action between *sleep* and *do nothing*; the AC side always stays *do nothing* (guaranteed overnight headless runs).

Key verified behaviors: the lid action fires once at lid-close time based on the current power source and is not re-triggered by later plug/unplug events; if power is cut while running lid-closed, the machine keeps running (~15%/h) and hibernates at the critical battery level (~2-3%), freezing background tasks safely instead of killing them.

Install with `install.ps1` (no admin rights required). See the Chinese sections above for details.

## License

[MIT](./LICENSE)
