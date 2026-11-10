import Foundation

struct ScanRecord: Codable, Equatable, Identifiable, Sendable {
    enum Kind: String, Codable, Equatable, Sendable {
        case smart = "智能扫描"
        case deep = "深度扫描"
        case weeklyAutomatic = "每周自动扫描"
    }

    enum Status: String, Codable, Equatable, Sendable {
        case completedNoThreats = "未发现任何威胁"
        case canceledNoThreats = "在取消之前未发现任何威胁"
    }

    let id: UUID
    let kind: Kind
    let status: Status
    let createdAt: Date
    let fileCount: Int
}
