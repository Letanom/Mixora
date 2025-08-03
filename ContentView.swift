import SwiftUI

struct ContentView: View {
    @StateObject private var interstitialAdManager = InterstitialAdManager()
    @State private var names: [String] = []
    @State private var newName: String = ""
    @State private var isSpinning: Bool = false
    @State private var winner: String = ""
    @State private var showWinner: Bool = false
    @State private var spinAngle: Double = 0
    @State private var currentSpinningName: String = ""
    @State private var showConfetti: Bool = false
    
    let gradientColors = [
        Color(red: 0.2, green: 0.1, blue: 0.8),
        Color(red: 0.8, green: 0.2, blue: 0.6),
        Color(red: 0.9, green: 0.4, blue: 0.1)
    ]
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: showWinner)
            
            // Animated Background Circles
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 50...150))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true),
                        value: showWinner
                    )
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow, radius: 10)
                            .rotationEffect(.degrees(spinAngle * 0.5))
                            .animation(.easeInOut(duration: 2).repeatForever(), value: isSpinning)
                        
                        Text("🎉 MIXORA LOTTERY 🎉")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                            .scaleEffect(showWinner ? 1.1 : 1.0)
                            .animation(.bouncy(duration: 0.6), value: showWinner)
                    }
                    .padding(.top, 20)
                    
                    // Name Input Section
                    if !showWinner {
                        VStack(spacing: 20) {
                            HStack {
                                TextField("Enter name...", text: $newName)
                                    .font(.title2)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                
                                Button(action: addName) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 35))
                                        .foregroundColor(.green)
                                        .shadow(color: .green, radius: 5)
                                }
                                .scaleEffect(newName.isEmpty ? 0.8 : 1.2)
                                .animation(.bouncy(duration: 0.3), value: newName.isEmpty)
                            }
                            .padding(.horizontal)
                            
                            // Names List
                            if !names.isEmpty {
                                LazyVStack(spacing: 12) {
                                    ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                                        HStack {
                                            Text("👤 \(name)")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                            
                                            Button(action: { removeName(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.title3)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.2))
                                                .backdrop(BlurView(style: .systemThinMaterial))
                                        )
                                        .transition(.asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Draw Button
                            if names.count >= 2 {
                                Button(action: startDraw) {
                                    HStack {
                                        if isSpinning {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(1.2)
                                        } else {
                                            Image(systemName: "sparkles")
                                                .font(.title2)
                                        }
                                        
                                        Text(isSpinning ? "DRAWING..." : "DRAW NOW!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.orange, .red, .pink],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 8)
                                    )
                                    .scaleEffect(isSpinning ? 0.95 : 1.0)
                                    .animation(.bouncy(duration: 0.3), value: isSpinning)
                                }
                                .disabled(isSpinning)
                                .padding(.horizontal)
                                .padding(.top, 20)
                            }
                        }
                    }
                    
                    // Spinning Animation
                    if isSpinning && !showWinner {
                        SpinningWheelView(
                            names: names,
                            isSpinning: $isSpinning,
                            currentName: $currentSpinningName,
                            spinAngle: $spinAngle
                        )
                        .frame(height: 300)
                        .padding()
                    }
                    
                    // Winner Announcement
                    if showWinner {
                        WinnerView(winner: winner, onReset: resetApp)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // AdMob Banner (show occasionally)
                    if !names.isEmpty && !isSpinning && !showWinner && shouldShowAd() {
                        ResponsiveAdBannerView()
                            .frame(height: 60)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }
                }
            }
            
            // Confetti Effect
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onSubmit {
            addName()
        }
    }
    
    private func addName() {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        withAnimation(.bouncy(duration: 0.5)) {
            names.append(newName.trimmingCharacters(in: .whitespacesAndNewlines))
            newName = ""
        }
    }
    
    private func removeName(at index: Int) {
        withAnimation(.bouncy(duration: 0.4)) {
            names.remove(at: index)
        }
    }
    
    private func startDraw() {
        guard names.count >= 2 else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            isSpinning = true
        }
        
        // Simulate spinning for 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let randomWinner = names.randomElement() ?? ""
            winner = randomWinner
            
            withAnimation(.bouncy(duration: 0.8)) {
                isSpinning = false
                showWinner = true
                showConfetti = true
            }
            
            // Stop confetti after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    showConfetti = false
                }
            }
            
            // Show interstitial ad occasionally after winner announcement
            if names.count > 5 && names.count % 5 == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    interstitialAdManager.showInterstitialAd()
                }
            }
        }
    }
    
    private func resetApp() {
        withAnimation(.easeInOut(duration: 0.5)) {
            names.removeAll()
            winner = ""
            showWinner = false
            showConfetti = false
            isSpinning = false
            spinAngle = 0
            currentSpinningName = ""
        }
    }
    
    private func shouldShowAd() -> Bool {
        // Show ad based on some conditions (e.g., every 3rd interaction)
        return names.count > 2 && names.count % 3 == 0
    }
}

// Blur View
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    ContentView()
}