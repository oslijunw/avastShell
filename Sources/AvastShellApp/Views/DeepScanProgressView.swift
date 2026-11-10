import SwiftUI

struct DeepScanProgressView: View {
    let state: AppState
    @State private var animationStart = Date()

    var body: some View {
        ZStack {
            Text(state.scanTitle)
                .font(.system(size: 32, weight: .semibold))
                .position(x: 504, y: 68)

            TimelineView(.animation) { timeline in
                let phase = timeline.date.timeIntervalSince(animationStart)
                ScanOrb(progress: Double(state.scanProgress) / 100, phase: phase)
            }
            .frame(width: 280, height: 280)
            .position(x: 504, y: 312)
            .accessibilityLabel("扫描进度 \(state.scanProgress)%")

            Text(currentPath)
                .font(.system(size: 13))
                .foregroundStyle(AvastTheme.textSecondary)
                .lineLimit(1).truncationMode(.middle)
                .frame(width: 790)
                .position(x: 504, y: 536)

            Button("取消") { try? state.cancelActiveScan(now: Date()) }
                .buttonStyle(AvastOutlineButtonStyle())
                .frame(width: 120)
                .position(x: 504, y: 584)
        }
        .foregroundStyle(.white)
        .task {
            animationStart = Date()
            // Visual simulation only: no filesystem access or scanning work.
            for step in 1...40 {
                do { try await Task.sleep(for: .milliseconds(90)) }
                catch { return }
                guard state.page == .deepScanProgress else { return }
                withAnimation(.linear(duration: 0.09)) {
                    state.scanProgress = min(100, step * 100 / 40)
                }
            }
            do { try await Task.sleep(for: .milliseconds(250)) }
            catch { return }
            guard state.page == .deepScanProgress else { return }
            try? state.completeActiveScan(now: Date())
        }
    }

    private var currentPath: String {
        switch state.scanProgress {
        case ..<25: "/System/Library/CoreServices/…"
        case ..<50: "/Applications/…/Contents/MacOS/…"
        case ..<80: "~/Library/Containers/…/Data/Library/Caches/…"
        default: "/Library/Application Support/…"
        }
    }
}

private struct ScanOrb: View {
    let progress: Double
    let phase: Double
    var body: some View {
        ZStack {
            tickMarks
            Circle().stroke(.white.opacity(0.12), lineWidth: 8).padding(14)
            Circle().trim(from: 0, to: progress)
                .stroke(AvastTheme.primary, style: StrokeStyle(lineWidth: 4, lineCap: .butt))
                .rotationEffect(.degrees(-90)).padding(14)
            ForEach(0..<3) { orbit in
                ScanOrbit(index: orbit, phase: phase)
            }
            Text("\(Int(progress * 100))%")
                .font(.system(size: 48, weight: .semibold))
                .monospacedDigit()
                .transaction { $0.animation = nil }
        }
    }
    private var tickMarks: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for tick in 0..<100 {
                let angle = Double(tick) / 100 * .pi * 2 - .pi / 2
                let x = CGFloat(cos(angle))
                let y = CGFloat(sin(angle))
                var path = Path()
                path.move(to: CGPoint(x: center.x + x * 134, y: center.y + y * 134))
                path.addLine(to: CGPoint(x: center.x + x * 140, y: center.y + y * 140))
                let color = Double(tick) < progress * 100 ? AvastTheme.primary : Color.white.opacity(0.12)
                context.stroke(path, with: .color(color), lineWidth: 1.6)
            }
        }
    }

}

private struct ScanOrbit: View {
    let index: Int
    let phase: Double
    var body: some View {
        let width = CGFloat(172 + index * 13)
        let rotation = Double(index) * 48 - 28 + phase * 25
        let tilt = sin(phase * 1.3 + Double(index)) * 24
        Ellipse()
            .stroke(AvastTheme.primary.opacity(index == 2 ? 0.7 : 0.95), lineWidth: 1.2)
            .frame(width: width, height: 226)
            .rotationEffect(.degrees(rotation))
            .rotation3DEffect(.degrees(tilt), axis: (x: 0, y: 1, z: 0))
    }
}
