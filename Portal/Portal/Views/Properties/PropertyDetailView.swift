import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header con imagen
                    headerSection
                    
                    // Selector de tabs
                    tabSelector
                    
                    // Contenido según tab seleccionado
                    switch selectedTab {
                    case 0:
                        overviewTab
                    case 1:
                        paymentsTab
                    case 2:
                        performanceTab
                    default:
                        overviewTab
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            // Compartir
                        }) {
                            Label("Compartir", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: {
                            // Ver documentos
                        }) {
                            Label("Ver Documentos", systemImage: "doc.text")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Imagen/Icono grande
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "building.2.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
            }
            
            VStack(spacing: 8) {
                Text(property.name)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.orange)
                    Text("\(property.city), \(property.country)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Adquirida: \(property.formattedPurchaseDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Badge de rendimiento anual
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(String(format: "%.1f", property.annualYield))%")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("Rendimiento Anual")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.1))
                )
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(property.monthlyPayments.count)")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("Meses Pagados")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding()
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabButton(title: "Resumen", icon: "chart.pie", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Pagos", icon: "list.bullet.rectangle", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabButton(title: "Rendimiento", icon: "chart.line.uptrend.xyaxis", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.top)
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(spacing: 20) {
            // Card de valores
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Valor Inicial")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedInvestedValue)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Valor Actual")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedCurrentValue)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                    }
                }
                
                Divider()
                
                AppreciationRow(property: property)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
            
            // Card de rendimiento mensual
            VStack(alignment: .leading, spacing: 16) {
                Text("Rendimiento Mensual")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pago Mensual")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedMonthlyYield)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "percent")
                                .font(.caption)
                            Text("\(String(format: "%.2f", property.monthlyYieldPercentage))% mensual")
                                .font(.caption)
                        }
                        .foregroundStyle(.orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Total Recibido")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedTotalReceived)
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                        
                        Text("\(property.monthlyPayments.count) pagos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Explicación del cálculo
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cálculo del Rendimiento")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    
                    Text("Tu inversión genera un rendimiento anual del \(String(format: "%.1f", property.annualYield))%, pagado mensualmente. Esto equivale al \(String(format: "%.2f", property.monthlyYieldPercentage))% del capital invertido cada mes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                    
                    // Fórmula visual
                    HStack {
                        Text("\(property.formattedInvestedValue)")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        
                        Text("×")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(String(format: "%.2f", property.monthlyYieldPercentage))%")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        
                        Text("=")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(property.formattedMonthlyYield)")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
            
            // Ganancia Total
            TotalGainSection(property: property)
        }
        .padding(.vertical)
    }
    
    // MARK: - Payments Tab
    private var paymentsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Resumen de pagos
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Recibido")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedTotalReceived)
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Pagos Recibidos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(property.monthlyPayments.count)")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pago Mensual Promedio")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedMonthlyYield)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Próximo Pago")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("5 de \(nextMonth())")
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
            
            // Lista de pagos por año
            let paymentsByYear = groupPaymentsByYear()
            let sortedYears: [Int] = paymentsByYear.keys.sorted(by: >)
            
            ForEach(sortedYears, id: \.self) { year in
                VStack(alignment: .leading, spacing: 12) {
                    YearHeaderView(year: year, paymentsByYear: paymentsByYear)
                    
                    YearPaymentsList(year: year, paymentsByYear: paymentsByYear)
                }
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    // MARK: - Performance Tab
    private var performanceTab: some View {
        VStack(spacing: 20) {
            // Gráfico de acumulación de pagos
            VStack(alignment: .leading, spacing: 16) {
                Text("Acumulación de Pagos")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal)
                
                // Aquí iría un gráfico de líneas mostrando el acumulado
                // Por ahora mostramos una representación visual
                VStack(spacing: 12) {
                    SimpleBarChart(payments: Array(property.monthlyPayments.suffix(12)))
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal)
            }
            
            // Métricas de rendimiento
            VStack(spacing: 16) {
                Text("Métricas de Rendimiento")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    DetailMetricCard(
                        title: "Rendimiento Anual",
                        value: property.formattedAnnualYield,
                        subtitle: "Tasa fija garantizada",
                        color: .orange
                    )
                    
                    DetailMetricCard(
                        title: "Rendimiento Mensual",
                        value: property.formattedMonthlyYieldPercentage,
                        subtitle: "del capital invertido",
                        color: .blue
                    )
                    
                    DetailMetricCard(
                        title: "ROI Total",
                        value: String(format: "%.1f%%", property.totalGainPercentage),
                        subtitle: "Incluye plusvalía y pagos",
                        color: .green
                    )
                    
                    DetailMetricCard(
                        title: "Meses Invertido",
                        value: "\(property.monthlyPayments.count)",
                        subtitle: "desde la compra",
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
            
            // Proyección
            VStack(alignment: .leading, spacing: 16) {
                Text("Proyección a 5 Años")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                let projection = calculateFiveYearProjection()
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Proyección Conservadora")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(projection.conservative)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Proyección Optimista")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(projection.optimistic)
                            .font(.subheadline.bold())
                            .foregroundStyle(.green)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Esta proyección asume:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("• Rendimiento anual del \(String(format: "%.1f", property.annualYield))% mantenido")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("• Reinversión de pagos mensuales")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("• Plusvalía anual estimada del 5-8%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.vertical)
    }
    
    // MARK: - Helper Functions
    
    private func groupPaymentsByYear() -> [Int: [MonthlyPayment]] {
        var grouped: [Int: [MonthlyPayment]] = [:]
        let calendar = Calendar.current
        
        for payment in property.monthlyPayments {
            let year = calendar.component(.year, from: payment.month)
            grouped[year, default: []].append(payment)
        }
        
        return grouped
    }
    
    private func monthAbbreviation(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date).prefix(3).uppercased()
    }
    
    private func nextMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "es_MX")
        
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        return formatter.string(from: nextMonth).capitalized
    }
    
    private func calculateFiveYearProjection() -> (conservative: String, optimistic: String) {
        let months = 60 // 5 años
        let monthlyPayment = property.estimatedMonthlyYield
        let totalPayments = monthlyPayment * Decimal(months)
        
        // Conservador: solo pagos + valor actual
        let conservative = property.currentValue + totalPayments
        
        // Optimista: pagos + plusvalía proyectada (5% anual)
        let optimisticValue = property.currentValue * Decimal(pow(1.05, 5.0))
        let optimistic = optimisticValue + totalPayments
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        
        return (
            conservative: formatter.string(from: conservative as NSDecimalNumber) ?? "$0",
            optimistic: formatter.string(from: optimistic as NSDecimalNumber) ?? "$0"
        )
    }
}

// MARK: - Simple Bar Chart Component
struct SimpleBarChart: View {
    let payments: [MonthlyPayment]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(payments.enumerated()), id: \.element.id) { index, payment in
                let height = CGFloat(50 + (index * 8))
                
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green.opacity(0.6))
                        .frame(width: 20, height: height)
                    
                    Text(monthAbbreviation(payment.month))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 150)
        .padding()
    }
    
    private func monthAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date).prefix(3).uppercased()
    }
}

// MARK: - Year Header View Component
struct YearHeaderView: View {
    let year: Int
    let paymentsByYear: [Int: [MonthlyPayment]]
    
    private var yearTotalString: String {
        guard let yearPayments = paymentsByYear[year] else { return "$0" }
        let yearTotal = yearPayments.reduce(Decimal(0)) { $0 + $1.amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: yearTotal as NSDecimalNumber) ?? "$0"
    }
    
    var body: some View {
        HStack {
            Text("\(year)")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(yearTotalString)
                .font(.subheadline.bold())
                .foregroundStyle(.green)
        }
        .padding(.horizontal)
    }
}

// MARK: - Year Payments List Component
struct YearPaymentsList: View {
    let year: Int
    let paymentsByYear: [Int: [MonthlyPayment]]
    
    var body: some View {
        VStack(spacing: 0) {
            if let yearPayments = paymentsByYear[year] {
                let reversedPayments = Array(yearPayments.reversed())
                ForEach(reversedPayments) { payment in
                    PaymentDetailRow(payment: payment)
                    
                    if payment.id != reversedPayments.last?.id {
                        Divider()
                            .padding(.leading, 56)
                            .padding(.trailing)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal)
    }
}

// MARK: - Total Gain Section Component
struct TotalGainSection: View {
    let property: Property
    
    private var totalGain: Decimal {
        property.totalGain
    }
    
    private var totalGainString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: totalGain as NSDecimalNumber) ?? "$0"
    }
    
    private var appreciationString: String {
        let appreciation = property.currentValue - property.investedValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: appreciation as NSDecimalNumber) ?? "$0"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Ganancia Total Acumulada")
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 4) {
                Text(totalGain >= 0 ? "+\(totalGainString)" : totalGainString)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(totalGain >= 0 ? .green : .red)
                
                HStack(spacing: 2) {
                    Image(systemName: totalGain >= 0 ? "arrow.up" : "arrow.down")
                        .font(.subheadline)
                    Text(String(format: "%.1f%%", property.totalGainPercentage))
                        .font(.title3.bold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(totalGain >= 0 ? Color.green : Color.red)
                )
            }
            
            // Desglose
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text("Plusvalía")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(appreciationString)
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Pagos Recibidos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(property.formattedTotalReceived)
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
}

// MARK: - Appreciation Row Component
struct AppreciationRow: View {
    let property: Property
    
    private var appreciation: Decimal {
        property.currentValue - property.investedValue
    }
    
    private var appreciationString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: appreciation as NSDecimalNumber) ?? "$0"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plusvalía")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: property.isPositiveReturn ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    Text(property.formattedAppreciation)
                        .font(.subheadline.bold())
                }
                .foregroundStyle(property.isPositiveReturn ? .green : .red)
            }
            
            Spacer()
            
            // Diferencia en valor absoluto
            Text(appreciation >= 0 ? "+\(appreciationString)" : appreciationString)
                .font(.subheadline.bold())
                .foregroundStyle(appreciation >= 0 ? .green : .red)
        }
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .orange : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                VStack {
                    Spacer()
                    if isSelected {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(height: 2)
                    }
                }
            )
        }
    }
}

// MARK: - Payment Detail Row Component
struct PaymentDetailRow: View {
    let payment: MonthlyPayment
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono de estado
            ZStack {
                Circle()
                    .fill(payment.isPaid ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: payment.isPaid ? "checkmark" : "clock")
                    .font(.subheadline.bold())
                    .foregroundStyle(payment.isPaid ? .green : .orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.monthDisplay)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                if let paidDate = payment.paidDate {
                    Text("Pagado el \(formattedFullDate(paidDate))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(payment.formattedAmount)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                
                Text(String(format: "%.2f%%", payment.yieldPercentage))
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
    }
    
    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd 'de' MMMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}

// MARK: - Detail Metric Card Component
struct DetailMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForColor(color))
                    .font(.title3)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
    
    private func iconForColor(_ color: Color) -> String {
        switch color {
        case .orange: return "percent"
        case .blue: return "calendar.badge.clock"
        case .green: return "chart.line.uptrend.xyaxis"
        case .purple: return "clock"
        default: return "info.circle"
        }
    }
}

#Preview {
    PropertyDetailView(property: Property.sampleData[0])
}
