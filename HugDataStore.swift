import Foundation

class HugDataStore {
    static let shared = HugDataStore()
    private let key = "hugDailyData"
    
    func load() -> [DailyData] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([DailyData].self, from: data)
        else {
            return []
        }
        return decoded
    }
    
    func save(_ data: [DailyData]) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func addHug(for date: Date = Date()) {
        var allData = load()
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        if let index = allData.firstIndex(where: {
            calendar.isDate($0.date, inSameDayAs: normalizedDate)
        }) {
            allData[index].count += 1
        } else {
            allData.append(DailyData(date: normalizedDate, count: 1))
        }
        
        save(allData)
    }
}
