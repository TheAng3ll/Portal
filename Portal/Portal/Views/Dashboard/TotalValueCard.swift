import SwiftUI

struct TotalValueCard: View {
    let summary: PortfolioSummary
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Valor Total de Inversión")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(summary.formattedTotalValue)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("USD")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 4) {
                Image(systemName: summary.isPositiveReturn ? "arrow.up.forward" : "arrow.down.forward")
                    .font(.caption)
                
                Text(summary.formattedTotalReturn)
                    .font(.subheadline.bold())
                
                Text("Ganancia Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(summary.isPositiveReturn ? .green : .red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(summary.isPositiveReturn ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

#Preview {
    TotalValueCard(summary: .sample)
        .padding()
        .background(Color(.systemGroupedBackground))
}
