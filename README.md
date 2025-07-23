<p align="center">
  <a href="https://apps.apple.com/gb/app/echo-auditory-scanning/id6451412975">
    <img src="https://raw.githubusercontent.com/AceCentre/Echo/main/readme-header.png" alt="Echo Logo and Download App Icon" width="300" />
  </a>
</p>
<p align="center"><i>Every Character Speaks Volumes</i></p>

- [Releasing a new version](#releasing-a-new-version)
- [Prediction](#prediction)
- [Developer Tools](#developer-tools)

## Releasing a new version

To release a new version, make sure your commit message includes `[PATCH]`, `[MINOR]` or `[MAJOR]` depending on what changes you have made. This will automatically trigger an xcode cloud build which will then release that version to TestFlight for testing. To then make the new version publicly available you have to release it via AppStoreConnect.

## Prediction

[Click here to view the prediction measurement results](./PREDICTION.md)

## Developer Tools

### Logging Control

Echo uses a custom `EchoLogger` system for debugging and diagnostics. By default, only warnings and errors are shown to maintain performance. Developers can control logging verbosity:

**Quick disable all logging** (for performance testing):
```swift
EchoLogger.loggingEnabled = false
```

**Change log level at runtime**:
```swift
EchoLogger.setLogLevel(.debug)    // Show everything (verbose)
EchoLogger.setLogLevel(.info)     // Show info and above
EchoLogger.setLogLevel(.warning)  // Show warnings and errors only (default)
EchoLogger.setLogLevel(.error)    // Show only errors
```

**Toggle detailed source info**:
```swift
EchoLogger.setSourceInfoEnabled(true)  // Show [File.swift:123 function()]
```

Log categories include: `.voice`, `.facialGesture`, `.eyeTracking`, `.gameController`, `.database`, `.ui`, and `.general`.

## Issues

See our issue queue. All welcome