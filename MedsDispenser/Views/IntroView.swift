import SwiftUI

struct IntroView: View {
    @State private var isLoading = true
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App Icon
                Image(systemName: "pills.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(isLoading ? 1.0 : 1.2)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isLoading)
                
                // App Title
                Text("MedDispenser")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: animationOffset)
                
                // Loading Text
                Text("Initializing...")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .offset(y: animationOffset)
                
                // Loading Indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .offset(y: animationOffset)
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                animationOffset = -10
            }
            
            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    IntroView()
}
