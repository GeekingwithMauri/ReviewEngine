import XCTest
@testable import ReviewEngine

final class ReviewPromptTests: XCTestCase {
    private let day: TimeInterval = 24 * 60 * 60
    private var defaults: UserDefaults!
    private var clock = Date(timeIntervalSince1970: 1_000_000)
    private var requests = 0

    override func setUp() {
        super.setUp()
        let suite = "ReviewPromptTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    private func makeSUT(
        suppressed: Bool = false
    ) -> ReviewPrompt {
        ReviewPrompt(
            defaults: defaults,
            suppressed: suppressed,
            now: { [unowned self] in clock }
        )
    }

    private func ask(
        _ sut: ReviewPrompt,
        version: String
    ) -> Bool {
        sut.requestIfDue(appVersion: version) { requests += 1 }
    }

    func test_firstCall_requests() {
        XCTAssertTrue(ask(
            makeSUT(),
            version: "1.0"
        ))
        XCTAssertEqual(
            requests,
            1
        )
    }

    func test_sameVersion_neverRequestsTwice() {
        let sut = makeSUT()
        _ = ask(
            sut,
            version: "1.0"
        )
        clock += 30 * day

        XCTAssertFalse(ask(
            sut,
            version: "1.0"
        ))
        XCTAssertEqual(
            requests,
            1
        )
    }

    func test_newVersion_withinTheInterval_waits() {
        let sut = makeSUT()
        _ = ask(
            sut,
            version: "1.0"
        )
        clock += 7 * day - 1

        XCTAssertFalse(ask(
            sut,
            version: "1.1"
        ))
        XCTAssertEqual(
            requests,
            1
        )
    }

    func test_newVersion_afterTheInterval_requests() {
        let sut = makeSUT()
        _ = ask(
            sut,
            version: "1.0"
        )
        clock += 7 * day

        XCTAssertTrue(ask(
            sut,
            version: "1.1"
        ))
        XCTAssertEqual(
            requests,
            2
        )
    }

    func test_suppressed_neverRequestsAndRecordsNothing() {
        XCTAssertFalse(ask(
            makeSUT(suppressed: true),
            version: "1.0"
        ))
        XCTAssertEqual(
            requests,
            0
        )

        XCTAssertTrue(ask(
            makeSUT(),
            version: "1.0"
        ))
    }

    func test_stateSurvivesANewInstance() {
        _ = ask(
            makeSUT(),
            version: "1.0"
        )

        XCTAssertFalse(ask(
            makeSUT(),
            version: "1.0"
        ))
    }

    func test_writeReviewURL() {
        XCTAssertEqual(
            ReviewPrompt.writeReviewURL(appID: "123").absoluteString,
            "https://apps.apple.com/app/id123?action=write-review"
        )
    }
}
