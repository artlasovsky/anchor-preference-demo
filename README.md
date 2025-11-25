# Anchor Preference Demo

A SwiftUI demonstration project showcasing the use of `anchorPreference` modifier to create an interactive spotlight effect with an inverted mask overlay.

## Overview

This demo implements a spotlight UI pattern where tapping on a Swift logo reveals a dimmed overlay with a circular cutout around the logo, drawing attention to the selected element. The effect is achieved using SwiftUI's anchor preference system to track view bounds across the view hierarchy.

## Key Concepts Demonstrated

### 1. Anchor PreferenceKey

The demo defines a custom `PreferenceKey` to pass anchor information up the view hierarchy:

```swift
struct BoundsAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>?

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
```

This allows child views to communicate their bounds to ancestor views without tight coupling.

### 2. Setting Anchor Preference

The Swift logo view sets its bounds as an anchor preference (ContentView.swift:31):

```swift
.anchorPreference(key: BoundsAnchorPreferenceKey.self, value: .bounds) { anchor in anchor }
```

### 3. Reading Anchor Preference

The `OverlayModifier` reads the anchor preference using `overlayPreferenceValue` (ContentView.swift:54) to position the spotlight effect correctly.

### 4. Inverted Mask Effect

The spotlight effect is created using a custom inverted mask modifier that cuts out a circular region from the overlay:

```swift
.maskInverted {
    Circle()
        .offset(y: 2)
        .padding(-20) // extending boundaries
}
```

## Features

- **Spotlight Effect**: Tapping the Swift logo reveals a dimmed overlay with a circular cutout
- **Animated Arrow**: An animated arrow indicator points upward from the spotlight
- **Coordinate Space Tracking**: Uses anchor preferences to track view bounds across different coordinate spaces
- **Smooth Transitions**: Includes spring-based animations for showing/hiding the overlay

## Project Structure

- `ContentView.swift`: Main demo implementation
  - `BoundsAnchorPreferenceKey`: Custom preference key for bounds anchors
  - `ContentView`: Main view with the spotlight interaction
  - `OverlayModifier`: Modifier that creates the spotlight overlay effect
  - `AnchorBoundaryView`: Helper view for positioning content relative to anchors
  - Helper views: `SwiftLogo`, `BackgroundImage`, `Arrow`

- `anchor_preference_demoApp.swift`: App entry point

## How It Works

1. The Swift logo sets its bounds as an anchor preference
2. When tapped, the logo triggers the overlay presentation
3. The `OverlayModifier` reads the anchor preference and uses it to position a circular cutout
4. An inverted mask creates the spotlight effect by showing the overlay everywhere except the circular region
5. An animated arrow is positioned at the bottom of the spotlight

## Running the Demo

1. Open `anchor-preference-demo.xcodeproj` in Xcode
2. Select a simulator or device
3. Build and run (⌘R)
4. Tap the Swift logo to see the spotlight effect
5. Tap anywhere on the dimmed overlay to dismiss

## Use Cases

This pattern is useful for:
- Onboarding flows, feature tours and interactive tutorials
- Highlighting UI elements
- Creating focus modes
- Drawing attention to specific interface components

## Additional Notes

The project includes a commented-out alternative implementation (ContentView.swift:114-151) that demonstrates animating the source view (logo) while maintaining the spotlight effect.

---

Presented at Swift Developers Meetup #10 in Aarhus (https://aarhus.dev/swift/meetup-10)
