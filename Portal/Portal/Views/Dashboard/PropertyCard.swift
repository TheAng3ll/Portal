import SwiftUI

struct PropertyCard: View {
    let property: Property
    
    var body: some View {
        HStack(spacing: 16) {
            // Imagen de la propiedad (placeholder)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(property.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("\(property.city), \(property.country)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack {
                    Text(property.formattedCurrentValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: property.isPositiveReturn ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        
                        Text(property.formattedAppreciation)
                            .font(.caption.bold())
                    }
                    .foregroundStyle(property.isPositiveReturn ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(property.isPositiveReturn ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    )
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    PropertyCard(property: Property.sampleData[0])
        .padding()
        .background(Color(.systemGroupedBackground))
}
