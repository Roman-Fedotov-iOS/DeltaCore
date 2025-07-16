import Foundation
import notify

public class DLTAMuteSwitchMonitor {
    public private(set) var isMonitoring = false
    public private(set) var isMuted = true
    
    private var notifyToken: Int32 = 0
    private var muteHandler: ((Bool) -> Void)?

    public init() {}

    public func startMonitoring(_ handler: @escaping (Bool) -> Void) {
        guard !isMonitoring else { return }
        isMonitoring = true
        self.muteHandler = handler

        let queue = DispatchQueue.global(qos: .default)
        let name = "com.apple.springboard.ringerstate"

        notify_register_dispatch(name, &notifyToken, queue) { [weak self] token in
            self?.updateMuteState()
        }

        updateMuteState()
    }

    public func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false

        notify_cancel(notifyToken)
        muteHandler = nil
    }

    private func updateMuteState() {
        var state: UInt64 = 0
        let result = notify_get_state(notifyToken, &state)
        if result == 0 {
            let isNowMuted = (state == 0)
            isMuted = isNowMuted
            muteHandler?(isNowMuted)
        } else {
            print("Failed to get mute state. Error: \(result)")
        }
    }
}
