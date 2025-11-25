import SwiftUI

/// # Spotlight Effect using AnchorPreference

/// # #0 Anchor PreferenceKey
struct BoundsAnchorPreferenceKey: PreferenceKey {
	static var defaultValue: Anchor<CGRect>?
	
	static func reduce(value: inout Value, nextValue: () -> Value) {
		value = nextValue()
	}
}

struct ContentView: View {
	@State private var overlayIsPresented: Bool = false
	
	var body: some View {
		BackgroundImage()
			.overlay {
				SwiftLogo { overlayIsPresented = true }
					.background {
						GeometryReader { proxy in
							let boundary = proxy.frame(in: .global)
							Color.clear
								.onChange(of: boundary) {
									
								}
						}
					}
					/// # #1 Anchor Preference
					.anchorPreference(key: BoundsAnchorPreferenceKey.self, value: .bounds) { anchor in anchor }
			}
			/// # #2 "Catch" Anchor Preference
			.modifier(
				OverlayModifier(
					isPresented: $overlayIsPresented,
					fill: {
						Color.black.opacity(0.6)
							.onTapGesture {
								overlayIsPresented = false
							}
					})
			)
	}
}

/// # #2 "Catch" Anchor Preference
struct OverlayModifier<Fill: View>: ViewModifier {
	@Binding var isPresented: Bool
	let fill: () -> Fill
	
	func body(content: Content) -> some View {
		content
			.overlayPreferenceValue(BoundsAnchorPreferenceKey.self) { anchor in
				if isPresented {
					fill()
						/// # #3 Circle Mask
						.maskInverted {
							if let anchor {
								AnchorBoundaryView(anchor: anchor) { _ in
									Circle()
										.offset(y: 2)
										.padding(-20) // extending boundaries
										.overlay(alignment: .bottom) {
											Arrow()
												.alignmentGuide(.bottom, computeValue: { $0[.top] })
												.offset(y: 20)
										}
								}
							}
						}
						/// # #4 Arrow
						.overlay {
							if let anchor {
								AnchorBoundaryView(anchor: anchor) { _ in
									Color.clear
										.overlay(alignment: .bottom) {
											Arrow()
												.alignmentGuide(.bottom, computeValue: { $0[.top] })
										}
										.padding(-20) // extending boundaries
								}
							}
						}
						.ignoresSafeArea()
						.transition(.opacity.animation(.interpolatingSpring))
				} else {
					EmptyView()
				}
			}
	}
	
	struct AnchorBoundaryView<Content: View>: View {
		let anchor: Anchor<CGRect>
		let content: (CGRect) -> Content
		
		var body: some View {
			GeometryReader { proxy in
				let bounds = proxy[anchor]
				
				Color.clear
					.overlay {
						content(bounds)
					}
					.position(x: bounds.midX, y: bounds.midY)
					.frame(width: bounds.width, height: bounds.height)
			}
		}
	}
}

// MARK: - Extra (animated source)

//struct ContentView: View {
//	@State private var overlayIsPresented: Bool = false
//
//	@State private var moveLogo: Bool = false
//
//	var body: some View {
//		BackgroundImage()
//			.overlay {
//				SwiftLogo { overlayIsPresented = true }
//					/// # #1 Anchor Preference
//					.anchorPreference(key: BoundsAnchorPreferenceKey.self, value: .bounds) { anchor in anchor }
//					.phaseAnimator(
//						[0, -50, 50],
//						trigger: moveLogo,
//						content: { content, phase in
//							content.offset(y: phase)
//						},
//						animation: { _ in .interactiveSpring(duration: 2) }
//					)
//			}
//			/// # #2 "Catch" Anchor Preference
//			.modifier(
//				OverlayModifier(
//					isPresented: $overlayIsPresented,
//					fill: {
//						Color.black.opacity(0.6)
//							.onTapGesture {
//								overlayIsPresented = false
//							}
//					})
//			)
//			.environment(\.animateArrow, false)
//			.overlay(alignment: .topTrailing) {
//				Button("Move", action: { moveLogo.toggle() })
//					.offset(x: -50)
//			}
//	}
//}

// MARK: - Preview

#Preview {
    ContentView()
}

// MARK: - Helpers

extension EnvironmentValues {
	@Entry var animateArrow: Bool = true
}

struct Arrow: View {
	@Environment(\.animateArrow) private var animateArrow
	
	@State private var animate: Bool = false
	
	var body: some View {
		Image(systemName: "arrow.up")
			.foregroundStyle(.white)
			.font(.largeTitle)
			.bold()
			.phaseAnimator(
				[10, 0],
				trigger: animate,
				content: { content, phase in content.offset(y: phase) },
				animation: { _ in .interactiveSpring(duration: 2).repeatForever() }
			)
			.onAppear {
				if animateArrow {
					animate = true
				}
			}
	}
}

struct InvertedMask<Cutout: View>: ViewModifier {
	@ViewBuilder
	let cutout: () -> Cutout
	
	func body(content: Content) -> some View {
		content.mask {
			Color.black.overlay {
				cutout().blendMode(.destinationOut)
			}
		}
	}
}

extension View {
	func maskInverted(@ViewBuilder _ cutoutView: @escaping () -> some View) -> some View {
		modifier(InvertedMask(cutout: cutoutView))
	}
}

struct SwiftLogo: View {
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			Image(systemName: "swift")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.aspectRatio(1, contentMode: .fit)
				.frame(height: 80)
				.foregroundStyle(.white)
				.contentShape(.rect)
		}
	}
}

struct BackgroundImage: View {
	var body: some View {
		Image(.image)
			.resizable()
			.scaledToFill()
			.ignoresSafeArea()
			.offset(x: -25)
	}
}
