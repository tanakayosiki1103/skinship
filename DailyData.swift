import Foundation

struct DailyData: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var count: Int
}
