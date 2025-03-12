import SwiftUI
import WebKit
import AVFoundation
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "reachudemo", category: "VideoPlayer")

struct VideoResponse: Codable {
    let url: String
    let executed: Bool
    let message: String
}

// Extension to print player status
extension AVPlayer.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .readyToPlay: return "readyToPlay"
        case .failed: return "failed"
        @unknown default: return "unknown default"
        }
    }
}

// Extension to print playerItem status
extension AVPlayerItem.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .readyToPlay: return "readyToPlay"
        case .failed: return "failed"
        @unknown default: return "unknown default"
        }
    }
}

// Demo product model
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
    @State private var isPlaying = true
    @State private var showProductsOverlay = false
    @State private var errorMessage: String = ""
    @State private var showProductDetail = false
    @State private var selectedProduct: ReachuProduct?
    @State private var videoUrl: String? = nil
    @State private var debugLog: String = ""
    
    // Simple fallback URL with minimal parameters - prevent fullscreen
    private let fallbackVideoURL = "https://player.vimeo.com/video/760249219?autoplay=1&title=0&byline=0&portrait=0&fullscreen=0"
    
    // Use LiveShowViewModel to access real products
    @StateObject private var viewModel = LiveShowViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Always black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Video player
                if let videoUrlString = videoUrl, !videoUrlString.isEmpty {
                    SimpleVideoWebView(urlString: videoUrlString)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        addLog("WebView appeared with URL: \(videoUrlString)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isLoading = false
                        }
                    }
                } else {
                    // Loading view while waiting for URL
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
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                        }
                        
                        // Show logs for diagnostics
                        ScrollView {
                            Text(debugLog)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .frame(height: 200)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
                
                // Large play button in the center - simplified
                if !isLoading {
                    Button(action: {
                        isPlaying.toggle()
                        addLog("Play/Pause toggled: \(isPlaying ? "Playing" : "Paused")")
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
                
                // Controls and products overlay
                VStack(spacing: 0) {
                    // Top controls
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
                        
                        // Button to show/hide products
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
                            addLog("Rewinding 10 seconds (not implemented)")
                        }) {
                            Image(systemName: "gobackward.10")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            isPlaying.toggle()
                            addLog("Play/Pause from bottom controls: \(isPlaying ? "Playing" : "Paused")")
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            addLog("Fast forwarding 10 seconds (not implemented)")
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
                    
                    // Optional products panel that can be shown/hidden
                    if showProductsOverlay {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.products) { product in
                                    LiveShowProductCard(
                                        product: product,
                                        onAddToCart: {
                                            // Simulate adding to cart
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
                
                // Floating carousel at the bottom - moved up with padding bottom
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
                                // Simulate adding to cart
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        )
                        // Added more padding to move it up
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 60 : 80)
                    }
                }
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.white)
                }
                
                // Debug button to show log
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            addLog("Debug button pressed")
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                    Spacer()
                }
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            addLog("🏁 VideoPlayerView appeared")
            fetchVideo()
        }
        .sheet(isPresented: $showProductDetail) {
            if let product = selectedProduct {
                // Use existing ProductDetailModal component
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header with close button
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
                        
                        // Use the existing ProductDetailModal
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
    
    // Function to add logs with timestamp
    private func addLog(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())
        debugLog = "[\(timestamp)] \(message)\n" + debugLog
        
        // Limit log to last 15 entries to avoid a very long log
        let lines = debugLog.components(separatedBy: "\n")
        if lines.count > 15 {
            debugLog = lines.prefix(15).joined(separator: "\n")
        }
        
        logger.log("📹 VideoLog: \(message)")
        print("📹 VideoLog: \(message)")
    }
    
    private func fetchVideo() {
        // Start with fallback video URL for faster loading
        addLog("Setting fallback video URL: \(fallbackVideoURL)")
        videoUrl = fallbackVideoURL
        
        // Try to get the real video
        addLog("Attempting to get real video URL...")
        let urlString = "https://microservices.tipioapp.com/videos/video/\(videoId)"
        
        addLog("Fetching video from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            addLog("❌ Invalid API URL: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                addLog("❌ Request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                addLog("📡 API response code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                addLog("❌ No data received")
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(VideoResponse.self, from: data)
                addLog("✅ API response decoded: \(response.url)")
                
                if response.executed {
                    DispatchQueue.main.async {
                        if !response.url.isEmpty {
                            // Use the API response URL but add minimal required parameters
                            var modifiedUrl = response.url
                            if !modifiedUrl.contains("?") {
                                modifiedUrl += "?autoplay=1&title=0&byline=0&portrait=0&fullscreen=0"
                            } else if !modifiedUrl.contains("autoplay=") {
                                modifiedUrl += "&autoplay=1&fullscreen=0"
                            }
                            addLog("🔄 Using video URL: \(modifiedUrl)")
                            self.videoUrl = modifiedUrl
                        } else {
                            addLog("⚠️ Empty URL in response, keeping fallback")
                        }
                    }
                } else {
                    addLog("⚠️ API reports it was not executed correctly: \(response.message)")
                }
            } catch {
                addLog("❌ Error decoding JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    errorMessage = "Error processing data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// Simple WebView for playing Vimeo videos
struct SimpleVideoWebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        print("Creating simple WebView with URL: \(urlString)")
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        
        // Disable user interaction to prevent fullscreen
        webView.allowsBackForwardNavigationGestures = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        print("Loading URL in WebView: \(urlString)")
        webView.load(URLRequest(url: url))
        
        // Add simple CSS to enlarge the video (zoom effect) and prevent fullscreen
        let cssScript = """
        setTimeout(function() {
            var style = document.createElement('style');
            style.textContent = `
                video {
                    transform: scale(1.5) !important;
                    transform-origin: center !important;
                }
                .vp-controls, .vp-title, .vp-logo, .vp-portrait, .vp-sidedock, 
                button, .vp-fullscreen-button, .vp-picture-in-picture-button,
                .vp-menu-button, .vp-volume-button, .vp-playback-rate-button {
                    display: none !important;
                    opacity: 0 !important;
                    visibility: hidden !important;
                    pointer-events: none !important;
                }
                
                /* Prevent fullscreen mode */
                .vp-fullscreen, .vp-target {
                    pointer-events: none !important;
                }
                
                /* Make video fill entire screen */
                .vp-player, .vp-player video, .vp-telecine {
                    width: 100vw !important;
                    height: 100vh !important;
                    max-width: none !important;
                    max-height: none !important;
                    object-fit: cover !important;
                }
            `;
            document.head.appendChild(style);
            console.log('Added CSS for zoom effect');
            
            // Prevent fullscreen JavaScript
            document.addEventListener('fullscreenchange', function(e) {
                if (document.fullscreenElement) {
                    document.exitFullscreen();
                    console.log('Exited fullscreen mode');
                }
            }, false);
            
            // Disable all click events on the player
            const playerElements = document.querySelectorAll('.vp-player, .vp-player *');
            playerElements.forEach(function(element) {
                element.addEventListener('click', function(e) {
                    // Allow only video play/pause
                    if (e.target.tagName.toLowerCase() === 'video') {
                        return;
                    }
                    e.stopPropagation();
                    e.preventDefault();
                    console.log('Blocked click event');
                    return false;
                }, true);
            });
        }, 1000);
        """
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            webView.evaluateJavaScript(cssScript) { _, error in
                if let error = error {
                    print("Error applying CSS: \(error.localizedDescription)")
                } else {
                    print("CSS applied successfully")
                }
            }
        }
        
        // Additional script to ensure no fullscreen mode
        let preventFullscreenScript = """
        setTimeout(function() {
            // Disable fullscreen API
            const originalRequestFullscreen = Element.prototype.requestFullscreen;
            Element.prototype.requestFullscreen = function() {
                console.log('Fullscreen request blocked');
                return;
            };
            
            // Find and disable fullscreen button
            const fullscreenButtons = document.querySelectorAll('[aria-label*="full screen"], [title*="full screen"], .fullscreen-button, .vp-fullscreen');
            fullscreenButtons.forEach(function(button) {
                button.style.display = 'none';
                button.style.visibility = 'hidden';
                button.disabled = true;
                button.setAttribute('aria-hidden', 'true');
                button.remove();
            });
            
            // Block all touch events that might trigger fullscreen
            document.addEventListener('touchstart', function(e) {
                if (e.target.closest('.vp-controls, .vp-player')) {
                    if (e.target.tagName.toLowerCase() !== 'video') {
                        e.stopPropagation();
                    }
                }
            }, true);
        }, 1500);
        """
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            webView.evaluateJavaScript(preventFullscreenScript) { _, error in
                if let error = error {
                    print("Error applying fullscreen prevention: \(error.localizedDescription)")
                } else {
                    print("Fullscreen prevention applied")
                }
            }
        }
    }
}

// Preview
#Preview {
    VideoPlayerView(videoId: "cosmedbeauty-desember2024")
} 