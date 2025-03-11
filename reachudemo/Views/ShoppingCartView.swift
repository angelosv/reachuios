import SwiftUI

struct ShoppingCartView: View {
    @ObservedObject var viewModel: StoreViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCheckout = false
    
    // Color primario de la aplicación
    let primaryColor = Color(hex: "#7300f9")
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.cartItems.isEmpty {
                    // Carrito vacío
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                        
                        Text("Tu carrito está vacío")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Parece que aún no has agregado productos a tu carrito")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Ir a comprar")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(primaryColor)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    }
                    .padding()
                } else {
                    // Mostrar productos del carrito
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.cartItems) { item in
                                CartItemRow(
                                    item: item,
                                    onUpdateQuantity: { newQuantity in
                                        viewModel.updateCartItemQuantity(itemId: item.id, newQuantity: newQuantity)
                                    },
                                    onToggleSelection: {
                                        viewModel.toggleCartItemSelection(itemId: item.id)
                                    }
                                )
                                Divider()
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // Footer con resumen y botón de checkout
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            Text("\(viewModel.selectedItemsCount) items selected")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(viewModel.formattedSelectedItemsTotal)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            showingCheckout = true
                        }) {
                            Text("Check Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(primaryColor)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .disabled(viewModel.selectedItemsCount == 0)
                    }
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Shopping Cart")
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
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView(viewModel: viewModel)
        }
    }
} 