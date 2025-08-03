import SwiftUI

struct WinnerView: View {
    let winner: String
    let onReset: () -> Void
    
    @State private var celebrationScale: CGFloat = 0.5
    @State private var sparkleOpacity: Double = 0
    @State private var titleOffset: CGFloat = -100
    @State private var winnerOffset: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 40) {
            // Celebration Title
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    
                    Text("WINNER!")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                }
                .offset(y: titleOffset)
                .animation(.bouncy(duration: 1.0).delay(0.2), value: titleOffset)
                
                // Sparkle Line
                HStack(spacing: 10) {
                    ForEach(0..<7, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .opacity(sparkleOpacity)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .delay(Double(index) * 0.1)
                                .repeatForever(autoreverses: true),
                                value: sparkleOpacity
                            )
                    }
                }
            }
            
            // Winner Display
            VStack(spacing: 20) {
                // Crown
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow, radius: 15)
                    .scaleEffect(celebrationScale)
                    .animation(.bouncy(duration: 1.2).delay(0.5), value: celebrationScale)
                
                // Winner Name
                Text(winner)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .white.opacity(0.5), radius: 20)
                    )
                    .scaleEffect(celebrationScale)
                    .offset(y: winnerOffset)
                    .animation(.bouncy(duration: 1.0).delay(0.8), value: winnerOffset)
                
                // Celebration Message
                Text("🎉 CONGRATULATIONS! 🎉")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.yellow)
                    .opacity(sparkleOpacity)
                    .animation(.easeInOut(duration: 0.8).delay(1.2), value: sparkleOpacity)
            }
            
            // Action Buttons
            VStack(spacing: 15) {
                // Share Button
                Button(action: shareWinner) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                        Text("SHARE")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .scaleEffect(celebrationScale)
                .animation(.bouncy(duration: 0.8).delay(1.5), value: celebrationScale)
                
                // Reset Button
                Button(action: onReset) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                        Text("NEW DRAW")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .scaleEffect(celebrationScale)
                .animation(.bouncy(duration: 0.8).delay(1.7), value: celebrationScale)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            startCelebrationAnimation()
        }
    }
    
    private func startCelebrationAnimation() {
        // Animate everything in sequence
        withAnimation(.easeOut(duration: 0.1)) {
            titleOffset = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.bouncy(duration: 1.0)) {
                celebrationScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.5)) {
                winnerOffset = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                sparkleOpacity = 1.0
            }
        }
    }
    
    private func shareWinner() {
        let shareText = "🎉 Mixora Lottery Winner: \(winner)! 🏆"
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

#Preview {
    WinnerView(winner: "Ahmet") {
        print("Reset")
    }
    .background(Color.black)
}