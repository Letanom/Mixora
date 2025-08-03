import SwiftUI
import GoogleMobileAds

@main
struct MixoraApp: App {
    
    init() {
        // Initialize Google AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}