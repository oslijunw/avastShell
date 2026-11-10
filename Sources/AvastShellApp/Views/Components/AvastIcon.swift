import SwiftUI

enum AvastIconKind {
    case search, scam, globe, network, mail, ransomware, shield, quarantine
    case brain, deep, folder, usb
}

/// Vector line art matching the supplied desktop references.
struct AvastIcon: View {
    let kind: AvastIconKind
    var body: some View {
        IconShape(kind: kind)
            .stroke(.white.opacity(0.94), style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
            .aspectRatio(1, contentMode: .fit)
            .accessibilityHidden(true)
    }
}

private struct IconShape: Shape {
    let kind: AvastIconKind
    func path(in rect: CGRect) -> Path {
        var p = Path()
        func line(_ points: [(CGFloat, CGFloat)], close: Bool = false) {
            guard let first = points.first else { return }
            p.move(to: CGPoint(x: first.0, y: first.1))
            for point in points.dropFirst() { p.addLine(to: CGPoint(x: point.0, y: point.1)) }
            if close { p.closeSubpath() }
        }
        func ellipse(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
            p.addEllipse(in: CGRect(x: x, y: y, width: w, height: h))
        }
        func shield(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
            p.move(to: CGPoint(x: x + w / 2, y: y))
            p.addLine(to: CGPoint(x: x + w, y: y + 5))
            p.addLine(to: CGPoint(x: x + w, y: y + h * 0.45))
            p.addQuadCurve(to: CGPoint(x: x + w / 2, y: y + h), control: CGPoint(x: x + w, y: y + h * 0.8))
            p.addQuadCurve(to: CGPoint(x: x, y: y + h * 0.45), control: CGPoint(x: x, y: y + h * 0.8))
            p.addLine(to: CGPoint(x: x, y: y + 5))
            p.closeSubpath()
        }
        switch kind {
        case .search:
            ellipse(4, 4, 32, 32)
            p.addArc(center: CGPoint(x: 20, y: 20), radius: 12, startAngle: .degrees(185), endAngle: .degrees(265), clockwise: false)
            line([(33, 29), (46, 42), (43, 46), (30, 33)])
        case .shield, .scam:
            shield(10, 5, 30, 40)
            if kind == .shield {
                p.move(to: CGPoint(x: 16, y: 15))
                p.addQuadCurve(to: CGPoint(x: 23, y: 36), control: CGPoint(x: 13, y: 28))
            } else {
                line([(25, 17), (28, 23), (34, 26), (28, 29), (25, 35), (22, 29), (16, 26), (22, 23)], close: true)
                line([(9, 2), (11, 6), (15, 8), (11, 10), (9, 14), (7, 10), (3, 8), (7, 6)], close: true)
            }
        case .globe:
            ellipse(3, 3, 44, 44)
            line([(14, 7), (16, 13), (12, 19), (6, 18), (5, 25), (13, 29), (17, 36), (18, 44)])
            line([(27, 4), (25, 12), (30, 17), (37, 15), (42, 20), (36, 24), (36, 31), (30, 37), (30, 46)])
            line([(17, 21), (23, 18), (29, 23), (26, 29), (21, 28), (17, 21)])
        case .network:
            line([(3, 23), (23, 3), (43, 23), (39, 26), (23, 10), (8, 26), (3, 23)])
            line([(10, 23), (10, 40), (22, 40), (22, 25), (16, 25), (16, 35)])
            shield(28, 25, 18, 23)
            line([(3, 45), (15, 45), (15, 48), (21, 48)])
        case .mail:
            line([(3, 9), (44, 9), (44, 24)])
            line([(3, 9), (23, 27), (44, 9)])
            line([(3, 9), (3, 40), (24, 40)])
            line([(4, 39), (18, 25)])
            shield(28, 27, 19, 22)
        case .ransomware, .quarantine:
            p.addRoundedRect(in: CGRect(x: 7, y: 10, width: 36, height: 33), cornerSize: CGSize(width: 3, height: 3))
            p.addRoundedRect(in: CGRect(x: 20, y: 4, width: 11, height: 6), cornerSize: CGSize(width: 2, height: 2))
            line([(7, 18), (3, 18), (3, 25), (7, 25)])
            line([(43, 18), (47, 18), (47, 25), (43, 25)])
            if kind == .ransomware {
                line([(30, 18), (19, 18), (16, 22), (20, 26), (29, 29), (31, 34), (26, 37), (16, 35)])
                line([(24, 14), (24, 40)])
            } else {
                ellipse(14, 18, 5, 5); ellipse(30, 18, 5, 5)
                line([(22, 31), (27, 31), (25, 27)], close: true)
            }
        case .brain:
            p.move(to: CGPoint(x: 24, y: 9))
            p.addCurve(to: CGPoint(x: 13, y: 11), control1: CGPoint(x: 19, y: 3), control2: CGPoint(x: 13, y: 5))
            p.addCurve(to: CGPoint(x: 9, y: 25), control1: CGPoint(x: 4, y: 12), control2: CGPoint(x: 4, y: 21))
            p.addCurve(to: CGPoint(x: 14, y: 37), control1: CGPoint(x: 3, y: 31), control2: CGPoint(x: 8, y: 37))
            p.addCurve(to: CGPoint(x: 24, y: 41), control1: CGPoint(x: 13, y: 45), control2: CGPoint(x: 22, y: 45))
            line([(24, 9), (24, 41)])
            p.move(to: CGPoint(x: 27, y: 9))
            p.addCurve(to: CGPoint(x: 38, y: 11), control1: CGPoint(x: 32, y: 3), control2: CGPoint(x: 38, y: 5))
            p.addCurve(to: CGPoint(x: 42, y: 25), control1: CGPoint(x: 47, y: 12), control2: CGPoint(x: 47, y: 21))
            p.addCurve(to: CGPoint(x: 37, y: 37), control1: CGPoint(x: 48, y: 31), control2: CGPoint(x: 43, y: 37))
            p.addCurve(to: CGPoint(x: 27, y: 41), control1: CGPoint(x: 38, y: 45), control2: CGPoint(x: 29, y: 45))
            line([(27, 9), (27, 41)])
            line([(14, 16), (18, 20), (16, 27)]); line([(37, 17), (33, 22), (36, 29)])
        case .deep:
            line([(28, 3), (38, 9), (38, 21), (28, 27), (18, 21), (18, 9)], close: true)
            line([(17, 23), (27, 29), (27, 41), (17, 47), (7, 41), (7, 29)], close: true)
            ellipse(25, 10, 6, 6)
        case .folder:
            line([(4, 13), (4, 7), (19, 7), (24, 13), (45, 13), (41, 42), (7, 42), (4, 13)], close: true)
            line([(7, 18), (41, 18)])
        case .usb:
            p.addRoundedRect(in: CGRect(x: 15, y: 15, width: 20, height: 31), cornerSize: CGSize(width: 6, height: 6))
            line([(20, 15), (20, 5), (30, 5), (30, 15)])
            line([(24, 9), (26, 9)])
        }
        return p.applying(CGAffineTransform(scaleX: rect.width / 50, y: rect.height / 50)
            .concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY)))
    }
}
