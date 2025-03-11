import SwiftUI

struct CheckoutView: View {
    @ObservedObject var viewModel: StoreViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSuccessAlert = false
    @State private var selectedPaymentMethod = 0
    @State private var couponCode = ""
    
    // Color primario de la aplicación
    let primaryColor = Color(hex: "#7300f9")
    
    // Datos de envío simulados
    let shippingAddress = "Jl. Pantai Indah Kapuk No. 56, Jakarta Utara"
    let paymentMethods = ["Credit Card", "Bank Transfer", "PayPal", "Virtual Account"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Dirección de envío
                    GroupBox(
                        label: HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(primaryColor)
                            Text("Shipping Address")
                                .font(.headline)
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("John Doe")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(shippingAddress)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("+62 812 3456 7890")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Spacer()
                                Button(action: {}) {
                                    Text("Change")
                                        .font(.caption)
                                        .foregroundColor(primaryColor)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Métodos de pago
                    GroupBox(
                        label: HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(primaryColor)
                            Text("Payment Method")
                                .font(.headline)
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Payment Method", selection: $selectedPaymentMethod) {
                                ForEach(0..<paymentMethods.count, id: \.self) { index in
                                    Text(paymentMethods[index]).tag(index)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            if selectedPaymentMethod == 0 {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Card Number")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    TextField("XXXX XXXX XXXX XXXX", text: .constant("4242 4242 4242 4242"))
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    
                                    HStack(spacing: 10) {
                                        VStack(alignment: .leading) {
                                            Text("Expiry Date")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            TextField("MM/YY", text: .constant("12/25"))
                                                .padding()
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("CVV")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            TextField("123", text: .constant("123"))
                                                .padding()
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            } else {
                                Text("Please follow the instructions after placing your order for \(paymentMethods[selectedPaymentMethod]).")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 20)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Resumen del pedido
                    GroupBox(
                        label: HStack {
                            Image(systemName: "bag.fill")
                                .foregroundColor(primaryColor)
                            Text("Order Summary")
                                .font(.headline)
                        }
                    ) {
                        VStack(spacing: 12) {
                            // Lista de productos seleccionados
                            ForEach(viewModel.cartItems.filter({ $0.isSelected })) { item in
                                HStack {
                                    Text("\(item.quantity)x")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text(item.product.title.toTitleCase())
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text(item.formattedSubtotal)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            Divider()
                            
                            // Cupón
                            HStack {
                                TextField("Coupon code", text: $couponCode)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Button(action: {}) {
                                    Text("Apply")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(primaryColor)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Divider()
                            
                            // Subtotal
                            HStack {
                                Text("Subtotal")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text(viewModel.formattedSelectedItemsTotal)
                                    .font(.subheadline)
                            }
                            
                            // Shipping
                            HStack {
                                Text("Shipping")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("Free")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            
                            // Taxes
                            HStack {
                                Text("Tax (10%)")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                let tax = viewModel.selectedItemsTotal * 0.1
                                let formattedTax = viewModel.cartItems.first?.product.price.currency_code ?? "Rp" + "\(Int(tax))"
                                Text(formattedTax)
                                    .font(.subheadline)
                            }
                            
                            Divider()
                            
                            // Total
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                let total = viewModel.selectedItemsTotal * 1.1 // Subtotal + 10% tax
                                let formattedTotal = viewModel.cartItems.first?.product.price.currency_code ?? "Rp" + "\(Int(total))"
                                Text(formattedTotal)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Checkout")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(primaryColor)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    // Simular proceso de pago
                    showingSuccessAlert = true
                }) {
                    Text("Place Order")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(primaryColor)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
            }
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Order Placed Successfully"),
                    message: Text("Thank you for your purchase! Your order has been placed and will be processed shortly."),
                    dismissButton: .default(Text("OK")) {
                        // Al confirmar, limpiar los items seleccionados del carrito
                        viewModel.cartItems.removeAll(where: { $0.isSelected })
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
} 