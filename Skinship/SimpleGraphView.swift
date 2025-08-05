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
        f.dateFormat = "d"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 120) {
                Text("トレンド")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(spacing: 20) {
                    Text("スキンシップの回数")
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
                Button("← 前の週") {
                    currentWeekOffset -= 1
                    loadData()
                }
                
                Spacer()
                
                Button("次の週 →") {
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
                        x: .value("日付", labelFormatter.string(from: item.date)),
                        y: .value("回数", item.count)
                    )
                    .foregroundStyle(.blue)
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
        print("Loaded data count: \(allData.count)")
        for d in allData {
            print("data date: \(d.date), count: \(d.count)")
        }
        
        data = (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
            let normalizedDate = calendar.startOfDay(for: date)
            let count = allData.first(where: {
                calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: normalizedDate)
            })?.count ?? 0
            print("date: \(date), count: \(count)")
            return DailyData(date: date, count: count)
        }
    }





    
    func formattedMonthRange(from data: [DailyData]) -> String {
        guard let firstDate = data.first?.date,
              let lastDate = data.last?.date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        let startMonth = formatter.string(from: firstDate)
        let endMonth = formatter.string(from: lastDate)
        
        return startMonth == endMonth ? startMonth : "\(startMonth)〜\(endMonth)"
    }
}

// Dateの拡張（startOfWeekを取得）
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

