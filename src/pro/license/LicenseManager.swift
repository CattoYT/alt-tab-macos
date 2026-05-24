import Foundation

class LicenseManager {


    static let shared: LicenseManager = {
        return LicenseManager(
            clock: SystemClock()
        )
    }()

    static let trialDuration = 14
    private static let revalidationInterval: TimeInterval = 30 * 24 * 60 * 60 // 30 days
    static let customerEmailKey = "customerEmail"
    /// Variant slugs that grant a Lifetime license (no version cutoff, ever).
    /// Everything else is regular Pro and may appear in `versionLimitedVariants`.
    static let lifetimeVariants: Set<String> = ["pro_lifetime"]
    /// Maps version-limited variant slugs to their max supported version.
    /// When a Pro variant needs a cutoff, add: "variant_slug": "X.Y.Z".
    static let versionLimitedVariants: [String: String] = [:]

    let clock: Clock

    /// Called whenever `state` changes (including the initial `initialize()` assignment).
    /// Production wires this up in App.swift to refresh Menubar, sync Sparkle cookie, and notify ProTransitionManager.
    /// Tests leave it unset to avoid side effects.
    var onStateChanged: ((LicenseState) -> Void)?

    /// Provides the current app version for version-limited variant checks. Defaults to the bundle's version;
    /// tests override to simulate upgrades across cutoffs.
    var currentAppVersion: () -> String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }


    private(set) var state: LicenseState = .pro

    var customerEmail: String? = "foss@hikari.dev"

    var isLifetimeVariant: Bool = true

    var isProAvailable: Bool { state.isProAvailable }

    /// Pro features are locked out as soon as the license is no longer valid. Degradable Pro
    /// preferences are downgraded to their Free equivalents immediately via
    /// `ProTransitionManager.onProLockEngaged()`, wired to the state-change hook in App.swift.
    var isProLocked: Bool = false
    

    var trialStartDate: Date? {
        return Date(timeIntervalSince1970: Date.init().timeIntervalSince1970)
    }

    var daysSinceTrialStart: Int {
        guard let start = trialStartDate else { return 0 }
        return Int(clock.now.timeIntervalSince(start) / 86400)
    }

    init(clock: Clock) {
        self.clock = clock
    }

    func initialize() {
        state = computeState()
    }

    /// Trial `daysRemaining` is baked into the `state` enum, so it stays frozen until something
    /// reassigns `state`. Call this from UI surfaces before they read `state` so the day count
    /// reflects the current clock. `didSet` only fires when the value actually changed.
    func refreshState() {
        let newState = computeState()
        if newState != state { state = newState }
    }

    func activate(_ licenseKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.state = .pro
    }

    func computeState() -> LicenseState {
        return .pro

    }

    private func computeTrialState() -> LicenseState {
        return .pro
    }


    #if DEBUG
    func mockTrialUser() {
        state = .trial(daysRemaining: Self.trialDuration)
    }

    func mockTrialExpired() {
        state = .trialExpired
    }

    func mockTrialDay(_ day: Int) {
        let trialStart = clock.now.addingTimeInterval(-Double(day - 1) * 86400)

        let daysRemaining = Self.trialDuration - (day - 1)
        state = daysRemaining > 0 ? .trial(daysRemaining: daysRemaining) : .trialExpired
    }

    func mockProUser() {

        state = .pro
    }
    #endif
}
