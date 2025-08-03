import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            startConfetti()
        }
        .onDisappear {
            stopConfetti()
        }
    }
    
    private func startConfetti() {
        // Create initial batch of confetti
        createConfettiBatch()
        
        // Timer to create more confetti pieces
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Add new pieces
            createConfettiBatch(count: 3)
            
            // Remove old pieces
            confettiPieces.removeAll { piece in
                piece.position.y > UIScreen.main.bounds.height + 100
            }
        }
    }
    
    private func stopConfetti() {
        animationTimer?.invalidate()
        animationTimer = nil
        confettiPieces.removeAll()
    }
    
    private func createConfettiBatch(count: Int = 20) {
        for _ in 0..<count {
            let piece = ConfettiPiece(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -50
                ),
                velocity: CGPoint(
                    x: CGFloat.random(in: -100...100),
                    y: CGFloat.random(in: 100...300)
                ),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -10...10),
                color: [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement() ?? .red,
                shape: [.circle, .square, .triangle].randomElement() ?? .circle,
                size: CGFloat.random(in: 8...20)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece {
    let id: UUID
    var position: CGPoint
    var velocity: CGPoint
    var rotation: Double
    let rotationSpeed: Double
    let color: Color
    let shape: ConfettiShape
    let size: CGFloat
}

enum ConfettiShape {
    case circle, square, triangle
}

struct ConfettiPieceView: View {
    @State private var piece: ConfettiPiece
    @State private var animationTimer: Timer?
    
    init(piece: ConfettiPiece) {
        self._piece = State(initialValue: piece)
    }
    
    var body: some View {
        shapeView
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size)
            .rotationEffect(.degrees(piece.rotation))
            .position(piece.position)
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
    }
    
    @ViewBuilder
    private var shapeView: some Shape {
        switch piece.shape {
        case .circle:
            Circle()
        case .square:
            Rectangle()
        case .triangle:
            Triangle()
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // Update position
            piece.position.x += piece.velocity.x * 0.016
            piece.position.y += piece.velocity.y * 0.016
            
            // Update rotation
            piece.rotation += piece.rotationSpeed
            
            // Apply gravity
            piece.velocity.y += 500 * 0.016 // gravity
            
            // Apply air resistance
            piece.velocity.x *= 0.995
            piece.velocity.y *= 0.995
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ConfettiView()
        .background(Color.black)
}