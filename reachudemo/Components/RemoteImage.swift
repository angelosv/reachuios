import SwiftUI

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        @Published var data = Data()
        @Published var state = LoadState.loading
        
        private var url: URL
        private var task: URLSessionDataTask?
        private var retryCount = 0
        private let maxRetries = 2
        
        init(url: URL) {
            self.url = url
            loadImage()
        }
        
        func loadImage() {
            state = .loading
            
            task?.cancel()
            
            print("🔄 Cargando imagen desde: \(url.absoluteString)")
            
            task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error cargando imagen: \(error.localizedDescription)")
                        self.handleError()
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ No es una respuesta HTTP válida")
                        self.handleError()
                        return
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        print("❌ Código de respuesta HTTP incorrecto: \(httpResponse.statusCode)")
                        self.handleError()
                        return
                    }
                    
                    guard let data = data, data.count > 0 else {
                        print("❌ Datos de imagen vacíos o nulos")
                        self.handleError()
                        return
                    }
                    
                    // Verificar que los datos sean una imagen válida
                    if UIImage(data: data) == nil {
                        print("❌ Los datos no corresponden a una imagen válida")
                        self.handleError()
                        return
                    }
                    
                    self.retryCount = 0
                    self.data = data
                    self.state = .success
                    print("✅ Imagen cargada correctamente: \(self.url.absoluteString)")
                }
            }
            
            task?.resume()
        }
        
        func handleError() {
            if retryCount < maxRetries {
                retryCount += 1
                print("🔄 Reintentando carga de imagen (\(retryCount)/\(maxRetries)): \(url.absoluteString)")
                
                // Esperar un poco antes de reintentar
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.loadImage()
                }
            } else {
                print("❌ Falló la carga de imagen después de \(maxRetries) intentos: \(url.absoluteString)")
                state = .failure
            }
        }
        
        func retry() {
            retryCount = 0
            loadImage()
        }
        
        deinit {
            task?.cancel()
        }
    }
    
    @StateObject private var loader: Loader
    var placeholder: AnyView
    
    // Color primario de la aplicación
    let primaryColor = Color(hex: "#7300f9")
    
    init(url: URL, @ViewBuilder placeholder: @escaping () -> some View) {
        self._loader = StateObject(wrappedValue: Loader(url: url))
        self.placeholder = AnyView(placeholder())
    }
    
    var body: some View {
        ZStack {
            if loader.state == .loading {
                placeholder
            } else if loader.state == .failure {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Error al cargar imagen")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button("Reintentar") {
                        loader.retry()
                    }
                    .font(.caption)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
            } else {
                if let uiImage = UIImage(data: loader.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.1))
                }
            }
        }
    }
} 