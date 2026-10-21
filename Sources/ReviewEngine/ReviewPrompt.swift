import Foundation

/// Spaces a host app's calls to the system review request.
///
/// The system call returns nothing: the app cannot know whether the sheet showed, was
/// dismissed or led to a rating. So the spacing is counted from each *request*: at most one
/// per app version, and none sooner than `minimumInterval` after the previous one. The host
/// app decides when a player qualifies and passes the system call in as `request`.
public struct ReviewPrompt {
    private let defaults: UserDefaults
    private let minimumInterval: TimeInterval
    private let suppressed: Bool
    private let now: () -> Date

    /// - Parameters:
    ///   - defaults: where the last request's date and app version are kept.
    ///   - minimumInterval: the least time between two requests. Seven days by default.
    ///   - suppressed: `true` turns every call into a no-op, e.g. under UI tests.
    ///   - now: the clock.
    public init(
        defaults: UserDefaults = .standard,
        minimumInterval: TimeInterval = 7 * 24 * 60 * 60,
        suppressed: Bool = false,
        now: @escaping () -> Date = Date.init
    ) {
        self.defaults = defaults
        self.minimumInterval = minimumInterval
        self.suppressed = suppressed
        self.now = now
    }

    /// Calls `request` when it is due and records it.
    /// - Returns: `true` when `request` was called.
    @discardableResult
    public func requestIfDue(
        appVersion: String,
        request: () -> Void
    ) -> Bool {
        guard !suppressed else { return false }
        if defaults.string(forKey: Key.lastVersion) == appVersion { return false }
        if let last = defaults.object(forKey: Key.lastDate) as? Date,
           now().timeIntervalSince(last) < minimumInterval {
            return false
        }
        request()
        defaults.set(
            now(),
            forKey: Key.lastDate
        )
        defaults.set(
            appVersion,
            forKey: Key.lastVersion
        )
        return true
    }

    /// The App Store page that opens straight on "Write a Review", for a row the player taps.
    /// The system's request limit does not apply to it.
    public static func writeReviewURL(appID: String) -> URL {
        URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review")!
    }

    private enum Key {
        static let lastDate = "ReviewEngine.lastRequestDate"
        static let lastVersion = "ReviewEngine.lastRequestVersion"
    }
}
