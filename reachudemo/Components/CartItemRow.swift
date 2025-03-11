import SwiftUI

struct CartItemRow: View {
    let item: CartItem
    let onUpdateQuantity: (Int) -> Void
    let onToggleSelection: () -> Void
    
    // Color primario de la aplicación
    let primaryColor = Color(hex: "#7300f9")
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox selección
            Button(action: onToggleSelection) {
                ZStack {
                    Rectangle()
                        .fill(item.isSelected ? primaryColor : Color.clear)
                        .frame(width: 22, height: 22)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(item.isSelected ? primaryColor : Color.gray, lineWidth: 1)
                        )
                    
                    if item.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 28, height: 28)
            
            // Imagen del producto
            if let imageURL = item.product.mainImageURL {
                RemoteImage(url: imageURL) {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Detalles del producto
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title.toTitleCase())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                // Mostrar tamaño y color si está disponible
                if let size = item.size, let color = item.color {
                    Text("\(size) · \(color)")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else if let size = item.size {
                    Text(size)
                        .font(.caption)
                        .foregroundColor(.gray)
                } else if let color = item.color {
                    Text(color)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(item.product.formattedPrice)
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Control de cantidad
                HStack(spacing: 12) {
                    Button(action: {
                        onUpdateQuantity(item.quantity - 1)
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(primaryColor)
                    }
                    .frame(width: 28, height: 28)
                    
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .frame(minWidth: 24)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        onUpdateQuantity(item.quantity + 1)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(primaryColor)
                    }
                    .frame(width: 28, height: 28)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemBackground))
    }
} 