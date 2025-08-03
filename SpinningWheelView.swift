import SwiftUI

struct SpinningWheelView: View {
    let names: [String]
    @Binding var isSpinning: Bool
    @Binding var currentName: String
    @Binding var spinAngle: Double
    
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 30) {
            // Spinning Wheel
            ZStack {
                // Outer Ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.yellow, .orange, .red, .purple, .blue, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(spinAngle))
                    .shadow(color: .white, radius: 10)
                
                // Inner Circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.9), .black.opacity(0.3)],
                            center: .center,
                            startRadius: 5,
                            endRadius: 120
                        )
                    )
                    .frame(width: 230, height: 230)
                    .rotationEffect(.degrees(spinAngle * 0.8))
                
                // Current Name Display
                VStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow, radius: 5)
                    
                    Text(currentName.isEmpty ? "🎲" : currentName)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .frame(width: 150)
                }
                .scaleEffect(isSpinning ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: isSpinning)
            }
            
            // Speed Indicator
            HStack {
                Text("SPEED:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < 3 ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 15, height: 15)
                        .scaleEffect(isSpinning && index < 3 ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: isSpinning
                        )
                }
            }
        }
        .onAppear {
            startSpinning()
        }
        .onDisappear {
            stopSpinning()
        }
    }
    
    private func startSpinning() {
        guard !names.isEmpty else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                spinAngle += 30
                currentIndex = (currentIndex + 1) % names.count
                currentName = names[currentIndex]
            }
        }
    }
    
    private func stopSpinning() {
        timer?.invalidate()
        timer = nil
    }
}