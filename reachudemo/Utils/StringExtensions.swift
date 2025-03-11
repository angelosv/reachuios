import Foundation

extension String {
    func toTitleCase() -> String {
        return self.components(separatedBy: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
} 