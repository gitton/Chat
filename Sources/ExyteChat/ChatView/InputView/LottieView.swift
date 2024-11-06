//
//  LottieView.swift
//  Daybook
//
//  Created by GITTO NICLAVOSE on 31/08/23.
//

import SwiftUI
import Lottie

/// A SwiftUI view that displays a Lottie animation.
struct LottieView: UIViewRepresentable {
    var name: String                // The name of the Lottie animation file (without the .json extension)
    var loopMode: LottieLoopMode = .loop  // The loop mode for the animation (default is loop)
    var bundle: Bundle = .current   // The bundle where the animation file is located (default is the current bundle)

    /// Creates the UIView that will be displayed in SwiftUI.
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero) // Create a UIView to hold the animation

        // Initialize the LottieAnimationView with the specified name and bundle
        let animationView = LottieAnimationView(name: name, bundle: bundle)
        animationView.loopMode = loopMode // Set the loop mode for the animation
        animationView.contentMode = .scaleAspectFill // Set the content mode to scale the animation

        view.addSubview(animationView) // Add the animation view to the parent view

        // Set up Auto Layout constraints for the animation view
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor), // Match height to parent view
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),   // Match width to parent view
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center horizontally
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)  // Center vertically
        ])

        // Play the animation
        animationView.play()

        return view // Return the configured UIView
    }

    /// Updates the UIView when the SwiftUI view's state changes.
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed for the animation view in this implementation
    }
}
