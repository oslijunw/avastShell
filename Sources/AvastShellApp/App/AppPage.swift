enum AppPage: Equatable, Sendable {
    case home
    case scanCenter
    case deepScanProgress
    case scanResult
    case scanHistory
}

/// 页面切换方向，决定滑动过渡的方向：前进时新页面从右缘滑入，后退时从左缘滑入；
/// instant 表示纯内容切换（如扫描中心内部 tab），不播放滑动动画。
enum NavigationDirection: Equatable, Sendable {
    case forward
    case backward
    case instant
}
