import SwiftUI

struct PropertyRowView: View {
    let property: Property
    @State private var showPaymentsDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header con imagen e información principal
            HStack(spacing: 16) {
                // Imagen/Icono de la propiedad
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Nombre
                    Text(property.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    // Ubicación
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(property.city), \(property.country)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Fecha de compra
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Comprado: \(property.formattedPurchaseDate)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Badge de rendimiento anual
                VStack(spacing: 4) {
                    Text(property.formattedAnnualYield)
                        .font(.title3.bold())
                        .foregroundStyle(.green)
                    Text("anual")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Divisor
            Divider()
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            // Sección de valores
            HStack(spacing: 0) {
                // Valor inicial
                VStack(spacing: 4) {
                    Text("Valor Inicial")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(property.formattedInvestedValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                // Valor actual
                VStack(spacing: 4) {
                    Text("Valor Actual")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(property.formattedCurrentValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                // Plusvalía
                VStack(spacing: 4) {
                    Text("Plusvalía")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 2) {
                        Image(systemName: property.isPositiveReturn ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        Text(property.formattedAppreciation)
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(property.isPositiveReturn ? .green : .red)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Divisor
            Divider()
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            // Sección de rendimiento mensual
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Rendimiento Mensual")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(property.monthlyPayments.count) pagos recibidos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Card de pago mensual
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pago mensual estimado")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedMonthlyYield)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    // Badge con el porcentaje mensual
                    HStack(spacing: 4) {
                        Text(property.formattedMonthlyYieldPercentage)
                            .font(.subheadline.bold())
                        Text("mensual")
                            .font(.caption)
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    )
                }
                
                // Total recibido
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total recibido en pagos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(property.formattedTotalReceived)
                            .font(.subheadline.bold())
                            .foregroundStyle(.green)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showPaymentsDetail.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(showPaymentsDetail ? "Ocultar" : "Ver detalle")
                                .font(.caption)
                            Image(systemName: showPaymentsDetail ? "chevron.up" : "chevron.down")
                                .font(.caption)
                        }
                        .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.horizontal)
            
            // Desglose de pagos (expandible)
            if showPaymentsDetail {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                        .padding(.vertical, 12)
                    
                    Text("Historial de Pagos")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    // Lista de pagos (últimos 6 meses)
                    LazyVStack(spacing: 0) {
                        ForEach(property.monthlyPayments.suffix(6).reversed()) { payment in
                            PaymentRow(payment: payment)
                            
                            if payment.id != property.monthlyPayments.suffix(6).reversed().last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    
                    if property.monthlyPayments.count > 6 {
                        Button(action: {
                            // Navegar a detalle completo
                        }) {
                            Text("Ver todos los pagos (\(property.monthlyPayments.count))")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .background(Color(.systemGray6).opacity(0.5))
                .padding(.top, 12)
            }
            
            // Footer con ganancia total
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ganancia Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    let totalGain = property.totalGain
                    let totalGainPercentage = property.totalGainPercentage
                    
                    HStack(spacing: 4) {
                        Text(totalGain >= 0 ? "+" : "")
                        Text(property.formattedTotalReceived)
                            .font(.title3.bold())
                        
                        HStack(spacing: 2) {
                            Image(systemName: totalGain >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption)
                            Text(String(format: "%.1f%%", totalGainPercentage))
                                .font(.subheadline.bold())
                        }
                        .foregroundStyle(totalGain >= 0 ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(totalGain >= 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        )
                    }
                    .foregroundStyle(totalGain >= 0 ? .green : .red)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Payment Row Component
struct PaymentRow: View {
    let payment: MonthlyPayment
    
    var body: some View {
        HStack {
            // Icono de pago
            ZStack {
                Circle()
                    .fill(payment.isPaid ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: payment.isPaid ? "checkmark" : "clock")
                    .font(.caption.bold())
                    .foregroundStyle(payment.isPaid ? .green : .orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.monthDisplay)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                if let paidDate = payment.paidDate {
                    Text("Pagado el \(formattedDate(paidDate))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(payment.formattedAmount)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                
                Text(String(format: "%.2f%%", payment.yieldPercentage))
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 16) {
            PropertyRowView(property: Property.sampleData[0])
            PropertyRowView(property: Property.sampleData[1])
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
