import SwiftUI
import AVKit
import WebKit

struct VideoResponse: Codable {
    let url: String
    let executed: Bool
    let message: String
}

// Modelo para productos demo
struct DemoProduct: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let image: String
}

struct VideoPlayerView: View {
    let videoId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var videoURL: URL?
    @State private var showProductsOverlay = false
    @State private var errorMessage: String = ""
    @State private var showProductDetail = false
    @State private var selectedProduct: ReachuProduct?
    @State private var isPlaying = false
    
    // Usar el LiveShowViewModel para acceder a productos reales
    @StateObject private var viewModel = LiveShowViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo negro siempre
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Video embebido con WebView
                if let url = videoURL {
                    WebViewVideoPlayer(videoURL: url, isPlaying: $isPlaying)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            isLoading = false
                        }
                } else {
                    // Imagen de fondo como fallback si el video no carga
                    VStack {
                        Image(systemName: "video.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text("Loading video...")
                            .foregroundColor(.white)
                            .padding()
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(Color(hex: "#7300f9"))
                                .font(.caption)
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
                
                // Botón grande de play/pause en el centro
                if !isLoading {
                    Button(action: {
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white.opacity(0.8))
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Overlay de controles y productos
                VStack(spacing: 0) {
                    // Controles superiores
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding([.top, .leading], 16)
                        
                        Spacer()
                        
                        // Botón para mostrar/ocultar productos
                        Button(action: {
                            withAnimation {
                                showProductsOverlay.toggle()
                            }
                        }) {
                            Image(systemName: showProductsOverlay ? "bag.fill" : "bag")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding([.top, .trailing], 8)
                        
                        Button(action: {}) {
                            Image(systemName: "heart")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding([.top, .trailing], 8)
                        
                        Button(action: {}) {
                            Image(systemName: "arrowshape.turn.up.right")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding([.top, .trailing], 16)
                    }
                    
                    Spacer()
                    
                    // Video Controls
                    HStack(spacing: 40) {
                        Button(action: {
                            // Acción para retroceder 10 segundos
                        }) {
                            Image(systemName: "gobackward.10")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            isPlaying.toggle()
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            // Acción para avanzar 10 segundos
                        }) {
                            Image(systemName: "goforward.10")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                    .padding(.bottom, 24)
                    
                    // Panel de productos opcional que se puede mostrar/ocultar
                    if showProductsOverlay {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.products) { product in
                                    LiveShowProductCard(
                                        product: product,
                                        onAddToCart: {
                                            // Simulación de agregar al carrito
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                        }
                                    )
                                    .frame(width: 280)
                                    .onTapGesture {
                                        selectedProduct = product
                                        showProductDetail = true
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .frame(height: 180)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Carrusel flotante en la parte inferior
                if !viewModel.products.isEmpty {
                    VStack {
                        Spacer()
                        LiveProductCarousel(
                            products: viewModel.products,
                            onProductTap: { product in
                                selectedProduct = product
                                showProductDetail = true
                            },
                            onAddToCart: { product in
                                // Simulación de agregar al carrito
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        )
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 16)
                    }
                }
                
                // Indicador de carga
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.white)
                }
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            // Usar una URL de fallback por si la API falla
            let fallbackURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            
            // Configurar el reproductor inmediatamente con la URL de fallback
            self.videoURL = fallbackURL
            
            // Intentar cargar el video real
            fetchVideoURL()
        }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                // Usar el componente ProductDetailModal existente
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header con botón de cierre
                        HStack {
                            Button(action: {
                                showProductDetail = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            Text("Product Details")
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding()
                        
                        // Usar el ProductDetailModal existente
                        ProductDetailModal(
                            product: product,
                            isPresented: $showProductDetail,
                            onAddToCart: { product, size, color, quantity in
                                showProductDetail = false
                            }
                        )
                    }
                }
            }
        }
    }
    
    private func fetchVideoURL() {
        let urlString = "https://microservices.tipioapp.com/videos/video/cosmedbeauty-desember2024"
        guard let url = URL(string: urlString) else {
            print("❌ Error: URL de API inválida")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error en la petición: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(VideoResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if let videoURL = URL(string: response.url) {
                        self.videoURL = videoURL
                    } else {
                        self.errorMessage = "URL de video inválida"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error al procesar datos: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// Reproductor de video usando WebView
struct WebViewVideoPlayer: UIViewRepresentable {
    let videoURL: URL
    @Binding var isPlaying: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        
        // Configuración necesaria para reproducción automática
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Primero cargar el contenido si no está cargado
        if context.coordinator.videoString == nil {
            let videoString = createVideoHTML()
            context.coordinator.videoString = videoString
            uiView.loadHTMLString(videoString, baseURL: nil)
        }
        
        // Luego actualizar el estado de reproducción
        if isPlaying {
            uiView.evaluateJavaScript("document.getElementById('videoPlayer').play();", completionHandler: nil)
        } else {
            uiView.evaluateJavaScript("document.getElementById('videoPlayer').pause();", completionHandler: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewVideoPlayer
        var videoString: String?
        
        init(_ parent: WebViewVideoPlayer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Script para forzar la reproducción automática cuando se solicite
            webView.evaluateJavaScript("""
                var video = document.querySelector('video');
                if (video) {
                    video.muted = true;
                    if (\(parent.isPlaying)) {
                        video.play();
                    } else {
                        video.pause();
                    }
                    
                    // Listeners para mantener la reproducción sincronizada
                    video.addEventListener('play', function() {
                        window.webkit.messageHandlers.playing.postMessage(true);
                    });
                    video.addEventListener('pause', function() {
                        window.webkit.messageHandlers.playing.postMessage(false);
                    });
                }
            """, completionHandler: nil)
        }
    }
    
    private func createVideoHTML() -> String {
        // Para videos MP4 u otros formatos directos
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
            <style>
                body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; background-color: #000000; }
                .video-container { position: relative; width: 100%; height: 100%; display: flex; justify-content: center; align-items: center; }
                video { width: 100%; height: 100%; object-fit: contain; background: #000; }
                .controls { display: none; }
            </style>
        </head>
        <body>
            <div class="video-container">
                <video id="videoPlayer" autoplay muted playsinline loop>
                    <source src="\(videoURL.absoluteString)" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            </div>
            <script>
                // Cuando la página esté lista
                document.addEventListener('DOMContentLoaded', function() {
                    var video = document.getElementById('videoPlayer');
                    
                    // Inicialmente establecemos el video según el valor del binding
                    if (\(isPlaying)) {
                        video.play();
                    } else {
                        video.load();
                        video.pause();
                    }
                    
                    // Prevenir que el video tome toda la pantalla en iOS
                    video.addEventListener('webkitbeginfullscreen', function(e) {
                        e.preventDefault();
                        video.webkitExitFullscreen();
                        return false;
                    });
                });
            </script>
        </body>
        </html>
        """
    }
}

// Vista previa
#Preview {
    VideoPlayerView(videoId: "cosmedbeauty-desember2024")
} 