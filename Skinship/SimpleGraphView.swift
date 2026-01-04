import SwiftUI
import Charts

struct SimpleGraphView: View {
    @State private var currentWeekOffset = 0
    @State private var data: [DailyData] = []
    
    var maxYValue: Double {
        Double(data.map { $0.count }.max() ?? 10)
    }
    
    let labelFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d" // 日だけ（これは多言語でもOK）
        return f
    }()
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 120) {
                Text(NSLocalizedString("trend_title", comment: "Trend title"))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(spacing: 20) {
                    Text(NSLocalizedString("trend_count_title", comment: "Count title"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(formattedMonthRange(from: data))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // 週切り替えボタン
            HStack {
                Button(NSLocalizedString("trend_prev_week", comment: "Previous week")) {
                    currentWeekOffset -= 1
                    loadData()
                }
                
                Spacer()
                
                Button(NSLocalizedString("trend_next_week", comment: "Next week")) {
                    if currentWeekOffset < 0 {
                        currentWeekOffset += 1
                        loadData()
                    }
                }
                .disabled(currentWeekOffset >= 0)
            }
            .padding(.horizontal)
            
            // グラフ表示
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value(NSLocalizedString("chart_axis_date", comment: "X axis"), labelFormatter.string(from: item.date)),
                        y: .value(NSLocalizedString("chart_axis_count", comment: "Y axis"), item.count)
                    )
                }
            }
            .chartYScale(domain: 0...(maxYValue + 2))
            .chartXAxis {
                AxisMarks(values: data.map { labelFormatter.string(from: $0.date) }) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let startDate = calendar.date(byAdding: .day, value: -6 + (currentWeekOffset * 7), to: calendar.startOfDay(for: today)) else {
            data = []
            return
        }
        
        let allData = HugDataStore.shared.load()
        
        data = (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
            let normalizedDate = calendar.startOfDay(for: date)
            let count = allData.first(where: {
                calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: normalizedDate)
            })?.count ?? 0
            
            return DailyData(date: date, count: count)
        }
    }
    
    func formattedMonthRange(from data: [DailyData]) -> String {
        guard let firstDate = data.first?.date,
              let lastDate = data.last?.date else {
            return ""
        }
        
        let formatter = DateFormatter()
        // ✅ ここが重要：言語ごとに “自然な月表示” にする
        formatter.setLocalizedDateFormatFromTemplate("yMMMM") // 例: 2025年12月 / December 2025
        
        let startMonth = formatter.string(from: firstDate)
        let endMonth = formatter.string(from: lastDate)
        
        return startMonth == endMonth ? startMonth : "\(startMonth)–\(endMonth)"
    }
}

// Dateの拡張（startOfDay）
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
