import SwiftUI

/// This file provides integration points between the Apollo implementation and the existing Reachu app
/// It's designed to be a bridge that allows gradual migration without disrupting existing functionality

// MARK: - Apollo Integration
struct ApolloIntegration {
    
    // MARK: - Navigation Helper
    /// Adds Apollo example view to the app's navigation
    static func addToNavigation() -> some View {
        NavigationLink(destination: ApolloExampleView()) {
            HStack {
                Image(systemName: "atom")
                    .foregroundColor(.blue)
                Text("Apollo GraphQL Demo")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Data Conversion
    /// Converts Apollo products to Reachu product format if needed
    /// This is useful for gradually migrating the app to use Apollo
    static func convertToReachuFormat(apolloProducts: [ApolloProduct]) -> [Any] {
        // This would convert Apollo products to whatever format Reachu uses
        // Implementation depends on Reachu's product model
        return []
    }
    
    // MARK: - Feature Flag
    /// Determines if Apollo features should be enabled
    static var isEnabled: Bool {
        // This could be controlled by a remote config or local setting
        return true
    }
}

// MARK: - Apollo Demo View
/// A simple view that can be added to the app to demonstrate Apollo integration
struct ApolloIntegrationDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Apollo GraphQL Integration")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This is a demonstration of Apollo GraphQL integration with Reachu.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
            
            if ApolloIntegration.isEnabled {
                ApolloIntegration.addToNavigation()
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            } else {
                Text("Apollo integration is currently disabled.")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Apollo Demo")
    }
}

// MARK: - Preview
struct ApolloIntegrationDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ApolloIntegrationDemoView()
        }
    }
} 