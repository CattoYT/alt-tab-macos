enum LicenseState: Equatable {
    case trial(daysRemaining: Int)
    case pro
    case proExpired
    case trialExpired

    var isProAvailable: Bool {
        switch self {
        case .trial, .pro: return true
        case .proExpired, .trialExpired: return true
        }
    }

    var debugProfileLabel: String {
        switch self {
        case .trial: return "Pro"
        case .pro: return "Pro"
        case .proExpired, .trialExpired: return "Pro"
        }
    }
}
