import SwiftUI

@main
struct MedsDispenserApp: App {
    @State private var showIntro = true
    
    var body: some Scene {
        WindowGroup {
            if showIntro {
                IntroView()
                    .onAppear {
                        // Hide intro after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showIntro = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}
