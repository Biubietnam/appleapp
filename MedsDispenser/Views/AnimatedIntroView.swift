import SwiftUI

struct AnimatedIntroView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 30
    @State private var subtitleOpacity: Double = 0
    @State private var showContent = false
    @Binding var showIntro: Bool
    
    var body: some View {
        ZStack {
            // Professional gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.086, green: 0.306, blue: 0.388), // #164e63
                    Color(red: 0.545, green: 0.361, blue: 0.965)  // #8b5cf6
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Animated logo with medical cross
                ZStack {
                    // Outer circle with pulse effect
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(logoScale * 1.2)
                        .opacity(logoOpacity * 0.6)
                    
                    // Inner circle
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    // Medical cross icon
                    Image(systemName: "cross.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(red: 0.086, green: 0.306, blue: 0.388))
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
                
                // App title with animation
                VStack(spacing: 12) {
                    Text("MediDispense")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)
                    
                    Text("Professional Medication Management")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .offset(y: subtitleOffset)
                        .opacity(subtitleOpacity)
                }
                
                Spacer()
                
                // Loading indicator
                if showContent {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("Initializing Healthcare Protocols...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo animation
        withAnimation(.easeOut(duration: 0.8)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.6)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }
        
        // Subtitle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.6)) {
                subtitleOffset = 0
                subtitleOpacity = 1.0
            }
        }
        
        // Show loading content
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showContent = true
            }
        }
        
        // Dismiss intro
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showIntro = false
            }
        }
    }
}
