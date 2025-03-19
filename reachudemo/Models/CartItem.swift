import Foundation

struct CartItem: Identifiable {
    let id: UUID = UUID()
    let product: ReachuProduct
    var quantity: Int
    var isSelected: Bool = true
    var size: String?
    var color: String?
    
    var subtotal: Double {
        if let amount = Double(product.price.amount_incl_taxes) {
            return amount * Double(quantity)
        }
        return 0
    }
    
    var formattedSubtotal: String {
        return "\(product.price.currency_code)\(Int(subtotal))"
    }
} 