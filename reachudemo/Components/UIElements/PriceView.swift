import SwiftUI

/// Componente reutilizable para mostrar precios con o sin descuento
struct PriceView: View {
    let price: String
    let currency: String
    let comparePrice: String?
    let showCurrency: Bool
    let textStyle: Font?
    let discountStyle: Font?
    
    init(
        price: String,
        currency: String = "",
        comparePrice: String? = nil,
        showCurrency: Bool = true,
        textStyle: Font? = nil,
        discountStyle: Font? = nil
    ) {
        self.price = price
        self.currency = currency
        self.comparePrice = comparePrice
        self.showCurrency = showCurrency
        self.textStyle = textStyle
        self.discountStyle = discountStyle
    }
    
    var body: some View {
        if let comparePrice = comparePrice, !comparePrice.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(comparePrice)
                    .font(discountStyle ?? AppTheme.TextStyle.comparePrice)
                    .foregroundColor(.gray)
                    .strikethrough()
                
                Text(formattedPrice)
                    .font(textStyle ?? AppTheme.TextStyle.price)
                    .foregroundColor(AppTheme.primaryColor)
            }
        } else {
            Text(formattedPrice)
                .font(textStyle ?? AppTheme.TextStyle.price)
                .foregroundColor(AppTheme.primaryColor)
        }
    }
    
    // Formateador de precio para mostrar la moneda correctamente
    private var formattedPrice: String {
        if showCurrency && !currency.isEmpty {
            return "\(currency) \(price)"
        }
        return price
    }
}

// Extensión para crear PriceView directamente desde ReachuPrice
extension PriceView {
    init(from reachuPrice: ReachuPrice, textStyle: Font? = nil, discountStyle: Font? = nil) {
        self.init(
            price: reachuPrice.amount,
            currency: reachuPrice.currency_code,
            comparePrice: reachuPrice.hasDiscount ? reachuPrice.compare_at : nil,
            showCurrency: true,
            textStyle: textStyle,
            discountStyle: discountStyle
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PriceView(price: "100", currency: "USD")
        PriceView(price: "100", currency: "USD", comparePrice: "150")
        PriceView(from: ReachuPrice(currency_code: "USD", amount: "75.99", compare_at: "99.99"))
    }
    .padding()
} 