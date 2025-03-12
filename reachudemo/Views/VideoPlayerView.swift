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
    @State private var showProductsOverlay = false
    @State private var errorMessage: String = ""
    @State private var showProductDetail = false
    @State private var selectedProduct: ReachuProduct?
    @State private var videoUrl: String? = nil
    @State private var debugLog: String = ""
    @State private var isPlaying: Bool = true
    @State private var videoProgress: Double = 0.0
    @State private var videoDuration: Double = 100.0 // Default value until we get the real duration
    
    // Fallback video URL - using the correct Vimeo ID
    private let fallbackVideoURL = "https://player.vimeo.com/video/1038569063"
    
    // Use LiveShowViewModel to access real products
    @StateObject private var viewModel = LiveShowViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Always black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Super simple video player - just load the URL directly
                if let videoUrlString = videoUrl, !videoUrlString.isEmpty {
                    SuperSimpleVideoPlayer(
                        urlString: videoUrlString,
                        isPlaying: $isPlaying,
                        videoProgress: $videoProgress,
                        videoDuration: $videoDuration
                    )
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        addLog("Video player appeared with URL: \(videoUrlString)")
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
                
                // Controls and products overlay
                VStack(spacing: 0) {
                    // Top controls - just back button
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
                    }
                    
                    Spacer()
                    
                    // Bottom area with products carousel and video controls
                    VStack(spacing: 16) {
                        // Floating carousel at the bottom
                        if !viewModel.products.isEmpty && !isLoading {
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
                            .padding(.bottom, 24)
                        }
                        
                        // Video controls
                        if !isLoading {
                            VideoControlsView(
                                isPlaying: $isPlaying,
                                progress: $videoProgress,
                                duration: $videoDuration
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 16 : 24)
                            .background(Color.black.opacity(0.6))
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.white)
                }
                
                // Debug overlay - tap to show logs
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Debug logs: \n\(debugLog)")
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(8)
                                .background(Color.black.opacity(0.5))
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
    
    // Convert Vimeo URL from "https://vimeo.com/ID" to "https://player.vimeo.com/video/ID"
    private func convertVimeoUrl(_ originalUrl: String) -> String {
        addLog("Converting Vimeo URL: \(originalUrl)")
        
        // Check if it's already in the player format
        if originalUrl.contains("player.vimeo.com/video") {
            addLog("URL already in player format")
            return originalUrl
        }
        
        // Extract the ID from the URL
        let components = originalUrl.components(separatedBy: "/")
        guard let lastComponent = components.last else {
            addLog("❌ Could not extract ID from URL")
            return fallbackVideoURL
        }
        
        // Remove any query parameters
        let id = lastComponent.components(separatedBy: "?").first ?? lastComponent
        
        // Create the player URL
        let playerUrl = "https://player.vimeo.com/video/\(id)"
        addLog("✅ Converted URL: \(playerUrl)")
        
        return playerUrl
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
            
            // Log raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                addLog("📄 Raw API response: \(responseString)")
            }
            
            do {
                let response = try JSONDecoder().decode(VideoResponse.self, from: data)
                addLog("✅ API response decoded: \(response.url)")
                
                if response.executed {
                    DispatchQueue.main.async {
                        if !response.url.isEmpty {
                            // Convert the URL from the API response to the player format
                            let convertedUrl = convertVimeoUrl(response.url)
                            addLog("🔄 Using converted URL: \(convertedUrl)")
                            self.videoUrl = convertedUrl
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

// Video controls view
struct VideoControlsView: View {
    @Binding var isPlaying: Bool
    @Binding var progress: Double
    @Binding var duration: Double
    @State private var isDragging = false
    
    // Format seconds to MM:SS
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // Progress track
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: max(0, min(CGFloat(progress) * geometry.size.width, geometry.size.width)), height: 4)
                        .cornerRadius(2)
                    
                    // Draggable thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .offset(x: max(0, min(CGFloat(progress) * geometry.size.width - 6, geometry.size.width - 12)))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    let newProgress = max(0, min(value.location.x / geometry.size.width, 1.0))
                                    progress = Double(newProgress)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                }
                .frame(height: 12) // Make the hit area larger
            }
            .frame(height: 12)
            .padding(.vertical, 8)
            
            // Time and controls
            HStack {
                // Current time
                Text(formatTime(progress * duration))
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 24) {
                    // Rewind 10 seconds
                    Button(action: {
                        progress = max(0, progress - (10 / duration))
                    }) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    // Play/Pause
                    Button(action: {
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    
                    // Forward 10 seconds
                    Button(action: {
                        progress = min(1.0, progress + (10 / duration))
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Duration
                Text(formatTime(duration))
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
        }
    }
}

// Super simple video player - just load the URL directly
struct SuperSimpleVideoPlayer: UIViewRepresentable {
    let urlString: String
    @Binding var isPlaying: Bool
    @Binding var videoProgress: Double
    @Binding var videoDuration: Double
    
    func makeUIView(context: Context) -> WKWebView {
        print("Creating super simple video player with URL: \(urlString)")
        
        // Basic configuration
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Create the WebView with minimal settings
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        
        // Add a navigation delegate to log loading errors
        webView.navigationDelegate = context.coordinator
        
        // Setup observer for isPlaying changes
        context.coordinator.webView = webView
        context.coordinator.parent = self
        
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SuperSimpleVideoPlayer
        var webView: WKWebView?
        var progressUpdateTimer: Timer?
        var isDragging: Bool = false
        var tempProgress: Double = 0
        var tempDuration: Double = 0
        var tempIsPlaying: Bool = false
        var needsUpdate: Bool = false
        
        init(_ parent: SuperSimpleVideoPlayer) {
            self.parent = parent
            self.tempIsPlaying = parent.isPlaying
            super.init()
            
            // Start a timer to update progress
            progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.updateVideoProgress()
            }
        }
        
        deinit {
            progressUpdateTimer?.invalidate()
        }
        
        func updateVideoProgress() {
            guard let webView = webView else { return }
            
            let script = """
            (function() {
                var iframe = document.querySelector('iframe');
                if (iframe && iframe.contentWindow) {
                    try {
                        // Try to get current time and duration
                        var message = { method: 'getCurrentTime' };
                        iframe.contentWindow.postMessage(JSON.stringify(message), '*');
                        
                        message = { method: 'getDuration' };
                        iframe.contentWindow.postMessage(JSON.stringify(message), '*');
                        
                        // Return placeholder values
                        return { currentTime: 0, duration: 0 };
                    } catch (e) {
                        console.error('Error getting video progress:', e);
                        return { error: e.toString() };
                    }
                }
                return { error: 'No iframe found' };
            })();
            """
            
            webView.evaluateJavaScript(script) { _, _ in
                // We don't use the result here as we rely on the message handler
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView provisional navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView navigation finished")
            
            // Setup message handler for video events
            let script = """
            window.addEventListener('message', function(event) {
                try {
                    var data = JSON.parse(event.data);
                    if (data.event === 'ready') {
                        console.log('Vimeo player is ready');
                    } else if (data.event === 'playProgress') {
                        window.videoProgress = data.data.seconds / data.data.duration;
                        window.videoDuration = data.data.duration;
                    } else if (data.event === 'play') {
                        window.isPlaying = true;
                    } else if (data.event === 'pause') {
                        window.isPlaying = false;
                    }
                } catch (e) {
                    // Not JSON or other error
                }
            });
            """
            
            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("Error setting up message handler: \(error.localizedDescription)")
                }
            }
        }
        
        func updateBindings() {
            guard needsUpdate else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if abs(self.parent.videoProgress - self.tempProgress) > 0.01 && !self.isDragging {
                    self.parent.videoProgress = self.tempProgress
                }
                
                if self.tempDuration > 0 && abs(self.parent.videoDuration - self.tempDuration) > 0.1 {
                    self.parent.videoDuration = self.tempDuration
                }
                
                if self.parent.isPlaying != self.tempIsPlaying {
                    self.parent.isPlaying = self.tempIsPlaying
                }
                
                self.needsUpdate = false
            }
        }
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("Loading video with URL: \(urlString)")
        
        // Check if isPlaying changed and update the video
        if context.coordinator.tempIsPlaying != isPlaying {
            context.coordinator.tempIsPlaying = isPlaying
            
            let playPauseScript = isPlaying ? 
                "var iframe = document.querySelector('iframe'); if (iframe && iframe.contentWindow) { iframe.contentWindow.postMessage('{\"method\":\"play\"}', '*'); }" :
                "var iframe = document.querySelector('iframe'); if (iframe && iframe.contentWindow) { iframe.contentWindow.postMessage('{\"method\":\"pause\"}', '*'); }"
            
            webView.evaluateJavaScript(playPauseScript) { _, error in
                if let error = error {
                    print("Error controlling playback: \(error.localizedDescription)")
                }
            }
        }
        
        // Use the direct embed code from Vimeo with API support
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    height: 100%;
                    width: 100%;
                    background-color: #000000;
                    overflow: hidden;
                }
                div {
                    position: relative;
                    padding: 177.78% 0 0 0;
                }
                iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: none;
                }
            </style>
        </head>
        <body>
            <div>
                <iframe src="\(urlString)?badge=0&autopause=0&player_id=0&app_id=58479&autoplay=1&muted=0&controls=0&title=0&byline=0&portrait=0&api=1"
                        frameborder="0"
                        allow="autoplay; fullscreen; picture-in-picture"
                        allowfullscreen>
                </iframe>
            </div>
            
            <script src="https://player.vimeo.com/api/player.js"></script>
            <script>
                // Log when the page loads
                window.onload = function() {
                    console.log('HTML page loaded');
                    setupVimeoPlayer();
                };
                
                // Setup Vimeo player with API
                function setupVimeoPlayer() {
                    try {
                        var iframe = document.querySelector('iframe');
                        if (iframe) {
                            console.log('Iframe found with src: ' + iframe.src);
                            
                            // Initialize Vimeo player
                            var player = new Vimeo.Player(iframe);
                            
                            // Set up event listeners
                            player.on('play', function() {
                                console.log('Video is playing');
                                window.isPlaying = true;
                            });
                            
                            player.on('pause', function() {
                                console.log('Video is paused');
                                window.isPlaying = false;
                            });
                            
                            player.on('timeupdate', function(data) {
                                window.videoProgress = data.percent;
                                window.videoDuration = data.duration;
                            });
                            
                            player.on('loaded', function() {
                                console.log('Video loaded');
                                player.getDuration().then(function(duration) {
                                    console.log('Video duration: ' + duration);
                                    window.videoDuration = duration;
                                });
                            });
                            
                            // Store player in window for external access
                            window.vimeoPlayer = player;
                        }
                    } catch (e) {
                        console.error('Error setting up Vimeo player:', e);
                    }
                }
                
                // Log any errors
                window.onerror = function(message, source, lineno, colno, error) {
                    console.log('Error: ' + message);
                    return true;
                };
                
                // Function to seek to a specific time
                window.seekTo = function(seconds) {
                    if (window.vimeoPlayer) {
                        window.vimeoPlayer.setCurrentTime(seconds);
                    }
                };
                
                // Function to play/pause
                window.togglePlayPause = function(shouldPlay) {
                    if (window.vimeoPlayer) {
                        if (shouldPlay) {
                            window.vimeoPlayer.play();
                        } else {
                            window.vimeoPlayer.pause();
                        }
                    }
                };
            </script>
        </body>
        </html>
        """
        
        // Only load the HTML if it's not already loaded
        if webView.url == nil {
            webView.loadHTMLString(html, baseURL: URL(string: "https://player.vimeo.com"))
        }
        
        // Check if progress was changed by user (through the slider)
        if context.coordinator.tempProgress != videoProgress {
            context.coordinator.tempProgress = videoProgress
            let seekScript = "window.seekTo(\(videoProgress * videoDuration));"
            webView.evaluateJavaScript(seekScript) { _, error in
                if let error = error {
                    print("Error seeking video: \(error.localizedDescription)")
                }
            }
        }
        
        // Periodically update progress
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let progressScript = """
            (function() {
                if (window.vimeoPlayer) {
                    var progress = { currentTime: 0, duration: 0 };
                    window.vimeoPlayer.getCurrentTime().then(function(seconds) {
                        progress.currentTime = seconds;
                        window.vimeoPlayer.getDuration().then(function(duration) {
                            progress.duration = duration;
                            window.videoProgress = progress.currentTime / progress.duration;
                            window.videoDuration = progress.duration;
                        });
                    });
                }
                return { 
                    progress: window.videoProgress || 0, 
                    duration: window.videoDuration || 0,
                    isPlaying: window.isPlaying === true
                };
            })();
            """
            
            webView.evaluateJavaScript(progressScript) { result, error in
                if let error = error {
                    print("Error getting progress: \(error.localizedDescription)")
                    return
                }
                
                if let result = result as? [String: Any],
                   let progress = result["progress"] as? Double,
                   let duration = result["duration"] as? Double,
                   let isPlaying = result["isPlaying"] as? Bool {
                    
                    context.coordinator.tempProgress = progress
                    context.coordinator.tempDuration = duration
                    context.coordinator.tempIsPlaying = isPlaying
                    context.coordinator.needsUpdate = true
                    
                    context.coordinator.updateBindings()
                }
            }
        }
    }
}

// Preview
#Preview {
    VideoPlayerView(videoId: "cosmedbeauty-desember2024")
} 