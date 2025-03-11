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
        
        init(url: URL) {
            self.url = url
            loadImage()
        }
        
        func loadImage() {
            state = .loading
            
            task?.cancel()
            
            task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error cargando imagen: \(error.localizedDescription)")
                        self.state = .failure
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ No es una respuesta HTTP válida")
                        self.state = .failure
                        return
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        print("❌ Código de respuesta HTTP incorrecto: \(httpResponse.statusCode)")
                        self.state = .failure
                        return
                    }
                    
                    guard let data = data, data.count > 0 else {
                        print("❌ Datos de imagen vacíos o nulos")
                        self.state = .failure
                        return
                    }
                    
                    self.data = data
                    self.state = .success
                    print("✅ Imagen cargada correctamente: \(self.url.absoluteString)")
                }
            }
            
            task?.resume()
        }
        
        func retry() {
            loadImage()
        }
        
        deinit {
            task?.cancel()
        }
    }
    
    @StateObject private var loader: Loader
    var placeholder: AnyView
    
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
                    .background(Color.blue)
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