import SwiftUI
import Charts

struct PerformanceChartView: View {
    let data: [PerformancePoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rendimiento del Portafolio")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Chart(data) { point in
                    LineMark(
                        x: .value("Mes", point.month),
                        y: .value("Valor", point.value)
                    )
                    .foregroundStyle(Color.green)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Mes", point.month),
                        y: .value("Valor", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.green.opacity(0.3), Color.green.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    if point.month == "Dic" {
                        PointMark(
                            x: .value("Mes", point.month),
                            y: .value("Valor", point.value)
                        )
                        .foregroundStyle(Color.green)
                        .symbolSize(50)
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartPlotStyle { plotArea in
                    plotArea
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.2))
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let strValue = value.as(String.self) {
                                Text(strValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 200)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Rendimiento")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    PerformanceChartView(
        data: [
            PerformancePoint(month: "Ene", value: 100),
            PerformancePoint(month: "Feb", value: 102),
            PerformancePoint(month: "Mar", value: 105),
            PerformancePoint(month: "Abr", value: 104),
            PerformancePoint(month: "May", value: 107),
            PerformancePoint(month: "Jun", value: 108),
            PerformancePoint(month: "Jul", value: 110),
            PerformancePoint(month: "Ago", value: 112),
            PerformancePoint(month: "Sep", value: 115),
            PerformancePoint(month: "Oct", value: 117),
            PerformancePoint(month: "Nov", value: 120),
            PerformancePoint(month: "Dic", value: 125)
        ]
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
