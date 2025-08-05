import Foundation

struct DailyData: Identifiable, Codable {
    var id: UUID
    var date: Date
    var count: Int
    
    init(id: UUID = UUID(), date: Date, count: Int) {
        self.id = id
        self.date = date
        self.count = count
    }
}
