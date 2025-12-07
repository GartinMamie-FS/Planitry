//
//  LandingPageView.swift
//  Planitry
//
//  Created by Mamie Gartin on 11/26/25.
//

import SwiftUI
import AVFoundation // 1. Import AVFoundation

// MARK: - Custom Zoom/Telescope Transition Modifier (Unchanged)
struct ZoomOutModifier: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 1.0 : 5.0)
            .opacity(active ? 1.0 : 0.0)
            .clipShape(Circle().scale(active ? 5.0 : 0.0))
            .animation(.easeInOut(duration: 0.7), value: active)
    }
}

// MARK: - LandingPageView (with Sound)
struct LandingPageView: View {
    @Binding var showLandingPage: Bool
    @State private var isZoomedIn: Bool = true
    
    // 2. Audio Player Instance
    @State private var audioPlayer: AVAudioPlayer?

    // 3. Function to Load and Play Sound
    private func playSound() {
        // Replace "telescope_zoom" with the actual name of your sound file
        guard let url = Bundle.main.url(forResource: "glitter", withExtension: "mp3") else {
            print("Sound file not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not load or play audio file: \(error)")
        }
    }

    var body: some View {
        ZStack {
            // Background and Overlay (Unchanged)
            Image("splash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Foreground Content (Unchanged)
            VStack {
                Spacer()
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                Text("Planitry")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 8)
                Text("Your Meal Planning Companion")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                
                Spacer()

                // Refactored Circular Button
                Button(action: {
                    // 4. Play the sound immediately
                    playSound()
                    
                    // Trigger the zoom-out animation
                    withAnimation(.easeInOut(duration: 0.7)) {
                        isZoomedIn = false
                    }
                    
                    // Delay the dismissal until after the animation finishes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showLandingPage = false
                    }
                }) {
                    Image(systemName: "arrow.right")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 8)
                }
                .padding(.bottom, 70)
            }
        }
        .modifier(ZoomOutModifier(active: isZoomedIn))
    }
}
