enum AppPage: Equatable, Sendable {
    case home
    case scanCenter
    case deepScanProgress
    case scanHistory
}

/// 页面切换方向，决定滑动过渡的方向：前进时新页面从右缘滑入，后退时从左缘滑入。
enum NavigationDirection: Equatable, Sendable {
    case forward
    case backward
}
