# ReviewEngine

Spaces an iOS app's calls to the system App Store review request.

`AppStore.requestReview(in:)` returns nothing: an app cannot tell whether the sheet showed, was dismissed or led to a rating, and no API says whether the user already rated. iOS shows the sheet at most 3 times per app in 365 days. ReviewEngine adds the app's own spacing on top:

- at most one request per app version;
- none sooner than 7 days (configurable) after the previous request;
- a `suppressed` flag that turns every call into a no-op (UI tests).

The host app decides when a user qualifies and passes the system call in. ReviewEngine imports Foundation only.

## Use

```swift
import ReviewEngine
import StoreKit

let prompt = ReviewPrompt(suppressed: isUITest)

if userQualifies, let scene {
    let requested = prompt.requestIfDue(appVersion: appVersion) {
        AppStore.requestReview(in: scene)
    }
    // log `requested` if you track it
}
```

A row the user taps to rate opens `ReviewPrompt.writeReviewURL(appID:)`, which the system limit does not cover.

Custom pre-prompts ("Enjoying the app?") are out of scope: App Review Guideline 5.6.1 disallows custom review prompts.

## Storage

Two keys in the injected `UserDefaults` (`.standard` by default): `ReviewEngine.lastRequestDate` and `ReviewEngine.lastRequestVersion`.

## Tests

```sh
swift test
```
