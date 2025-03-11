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
    
    // Demo productos
    let demoProducts = [
        DemoProduct(name: "Crema Hidratante", price: "$49.99", image: "face.smile"),
        DemoProduct(name: "Suero Vitamina C", price: "$59.99", image: "drop.fill"),
        DemoProduct(name: "Protector Solar", price: "$29.99", image: "sun.max.fill")
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Video embebido o placeholder
            if let url = videoURL {
                WebViewVideoPlayer(videoURL: url)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        print("📹 WebViewVideoPlayer apareció con URL: \(url.absoluteString)")
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
            
            // Controles superpuestos
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
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
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding([.top, .trailing], 8)
                    
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding([.top, .trailing], 8)
                    
                    Button(action: {}) {
                        Image(systemName: "arrowshape.turn.up.right")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding([.top, .trailing], 16)
                }
                
                Spacer()
                
                // Demo de productos
                if showProductsOverlay {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(demoProducts) { product in
                                VideoProductCard(product: product)
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .foregroundColor(.white)
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            print("🔍 VideoPlayerView apareció para videoId: \(videoId)")
            
            // Usar una URL de fallback por si la API falla
            let fallbackURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            print("🔄 Configurando URL de fallback: \(fallbackURL.absoluteString)")
            self.videoURL = fallbackURL
            
            // Intentar cargar el video real
            fetchVideoURL()
        }
    }
    
    private func fetchVideoURL() {
        guard let url = URL(string: "https://microservices.tipioapp.com/videos/video/cosmedbeauty-desember2024") else {
            print("❌ Error: URL de API inválida")
            return
        }
        
        print("🔍 Comenzando petición a: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error en la petición: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Código de respuesta HTTP: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }
            
            print("📦 Datos recibidos: \(data.count) bytes")
            print("📄 Respuesta como string: \(String(data: data, encoding: .utf8) ?? "No se pudo convertir")")
            
            do {
                let response = try JSONDecoder().decode(VideoResponse.self, from: data)
                print("✅ JSON decodificado: url=\(response.url), executed=\(response.executed), message=\(response.message)")
                
                DispatchQueue.main.async {
                    if let videoURL = URL(string: response.url) {
                        print("🎬 URL de video obtenida: \(videoURL.absoluteString)")
                        self.videoURL = videoURL
                    } else {
                        print("❌ No se pudo crear URL a partir de: \(response.url)")
                        self.errorMessage = "URL de video inválida"
                    }
                }
            } catch {
                print("❌ Error decodificando JSON: \(error.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 JSON recibido: \(jsonString)")
                }
                DispatchQueue.main.async {
                    self.errorMessage = "Error al procesar datos: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct WebViewVideoPlayer: UIViewRepresentable {
    let videoURL: URL
    
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
        print("🔄 Actualizando WebView con URL: \(videoURL.absoluteString)")
        
        let videoString: String
        
        // Determinar el tipo de URL y crear el HTML adecuado
        if videoURL.absoluteString.contains("vimeo.com") {
            // Si es Vimeo, usar iframe para el reproductor de Vimeo
            let vimeoId = videoURL.lastPathComponent
            print("🎬 ID de Vimeo detectado: \(vimeoId)")
            
            videoString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
                <style>
                    body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; background-color: #000000; }
                    .video-container { position: relative; width: 100%; height: 100%; }
                    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
                </style>
            </head>
            <body>
                <div class="video-container">
                    <iframe src="https://player.vimeo.com/video/\(vimeoId)?autoplay=1&loop=1&autopause=0" 
                            frameborder="0" 
                            allow="autoplay; fullscreen" 
                            allowfullscreen
                            style="position:absolute;top:0;left:0;width:100%;height:100%;">
                    </iframe>
                </div>
            </body>
            </html>
            """
        } else {
            // Para videos MP4 u otros formatos directos
            print("🎬 URL de video directo detectada")
            
            videoString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
                <style>
                    body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; background-color: #000000; }
                    .video-container { position: relative; width: 100%; height: 100%; display: flex; justify-content: center; align-items: center; }
                    video { width: 100%; height: 100%; object-fit: contain; }
                </style>
            </head>
            <body>
                <div class="video-container">
                    <video controls autoplay playsinline>
                        <source src="\(videoURL.absoluteString)" type="video/mp4">
                        Your browser does not support the video tag.
                    </video>
                </div>
            </body>
            </html>
            """
        }
        
        uiView.loadHTMLString(videoString, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewVideoPlayer
        
        init(_ parent: WebViewVideoPlayer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView cargó correctamente")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Error cargando WebView: \(error.localizedDescription)")
        }
    }
}

struct VideoProductCard: View {
    let product: DemoProduct
    
    var body: some View {
        VStack {
            Image(systemName: product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(product.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(product.price)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Button(action: {}) {
                Text("Add")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#7300f9"))
                    .cornerRadius(20)
            }
        }
        .frame(width: 120)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

// Vista previa
#Preview {
    VideoPlayerView(videoId: "cosmedbeauty-desember2024")
} 