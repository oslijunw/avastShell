# AvastShell

一个使用 SwiftUI 编写的 macOS 界面原型，外观参考 Avast Security。

扫描和检查更新均为本地模拟，不执行真实病毒检测，也不联网更新。本项目与 Avast 官方无关联。

## 下载运行

在 [Releases](https://github.com/oslijunw/avastShell/releases/latest) 下载 `AvastShell-1.3.0-macOS-universal.zip`，解压后将 `AvastShell.app` 拖入“应用程序”并打开。

- 系统要求：macOS 15 或更新版本。
- 支持 Apple Silicon 和 Intel Mac。
- 发布包使用本地签名，尚未进行 Apple 公证。macOS 可能提示无法验证开发者；确认下载来源后，可在“系统设置 → 隐私与安全性”中按系统提示允许打开。

## 使用

- 首页“运行智能扫描”：约 4 秒完成模拟扫描。
- “病毒扫描”：进入扫描中心，可启动深度扫描、取消扫描及查看历史。
- 扫描历史保留最近一个月，按原执行时间显示，退出、重启后仍保留。
- “菜单 → 检查更新”：快速显示模拟检查结果。
- 首页“上次更新”默认显示本次启动时间前半小时。

## 数据文件

所有持久数据统一保存在 `~/avast.jsonl`，不随程序打包。

第一行 `type: settings` 保存配置、启动时间、更新时间和每周自动扫描时间；后续 `type: scan` 行保存扫描记录。程序使用原子写入，并在启动及保存时清理超过一个月的记录。

首次启动会兼容迁入旧版的 `scan-history.json`。每周自动扫描仍为应用内模拟，在启动时补记，不包含后台扫描服务。

## 源码运行

需要 Xcode 26.2 或更新版本、Swift 6.2 工具链。

```sh
swift run AvastShellApp
```

测试：

```sh
swift test
```

构建同时支持两种架构的发布包：

```sh
./scripts/release.sh 1.3.0
```

生成文件位于 `dist/`。构建脚本不会上传、发布或附带本地扫描数据。
