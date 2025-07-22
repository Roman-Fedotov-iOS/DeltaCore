import UIKit
import AudioToolbox

public extension UIDevice {
    
    enum FeedbackSupportLevel {
        case unsupported
        case basic
        case feedbackGenerator
    }
    
    var feedbackSupportLevel: FeedbackSupportLevel {
        if #available(iOS 10.0, *) {
            return .feedbackGenerator
        } else {
            return .basic
        }
    }
    
    var isVibrationSupported: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return self.model.hasPrefix("iPhone")
        #endif
    }
    
    func vibrate() {
        guard isVibrationSupported else { return }

        switch feedbackSupportLevel {
        case .unsupported:
            // Fallback for very old devices
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        case .basic:
            // Short vibration
            AudioServicesPlaySystemSound(1519)
        case .feedbackGenerator:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
