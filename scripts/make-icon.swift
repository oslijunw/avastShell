import AppKit
import Foundation

let output = CommandLine.arguments[1]
let size = 1024
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: size, height: size).fill()
let background = NSBezierPath(roundedRect: NSRect(x: 72, y: 72, width: 880, height: 880), xRadius: 200, yRadius: 200)
NSGradient(starting: NSColor(red: 0.16, green: 0.09, blue: 0.4, alpha: 1),
           ending: NSColor(red: 0.04, green: 0.02, blue: 0.2, alpha: 1))!.draw(in: background, angle: 90)
let circle = NSBezierPath(ovalIn: NSRect(x: 270, y: 270, width: 484, height: 484))
NSColor(red: 0.19, green: 0.92, blue: 0.58, alpha: 1).setStroke()
circle.lineWidth = 22
circle.stroke()
let check = NSBezierPath()
check.move(to: NSPoint(x: 385, y: 510))
check.line(to: NSPoint(x: 474, y: 421))
check.line(to: NSPoint(x: 650, y: 607))
check.lineWidth = 28
check.lineCapStyle = .round
check.lineJoinStyle = .round
NSColor.white.setStroke()
check.stroke()
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: output))
