import SwiftUI
import GoogleMobileAds
import UIKit

struct AdBannerView: UIViewRepresentable {
    // Your AdMob App ID: ca-app-pub-3104321858083722~9177837582
    // Banner Ad Unit ID (test for now, replace with your actual banner unit ID)
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test ID
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 50)))
        
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        
        // Configure for responsive design
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // Load ad with request
        let request = GADRequest()
        uiView.load(request)
    }
}

// Responsive AdMob Banner that adapts to screen size
struct ResponsiveAdBannerView: UIViewRepresentable {
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test ID
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView()
        
        // Get the current window to determine safe area
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return bannerView
        }
        
        // Calculate adaptive banner size based on screen width
        let frame = window.frame.inset(by: window.safeAreaInsets)
        let viewWidth = frame.size.width
        
        // Use adaptive banner size for better responsiveness
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = window.rootViewController
        
        // Load the ad
        let request = GADRequest()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // Ad is already loaded in makeUIView
    }
}

// Interstitial Ad Manager
class InterstitialAdManager: NSObject, ObservableObject {
    private var interstitialAd: GADInterstitialAd?
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ID
    
    override init() {
        super.init()
        loadInterstitialAd()
    }
    
    func loadInterstitialAd() {
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    func showInterstitialAd() {
        guard let interstitialAd = interstitialAd,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Interstitial ad not ready or no root view controller")
            return
        }
        
        interstitialAd.present(fromRootViewController: rootViewController)
    }
}

// MARK: - GADFullScreenContentDelegate
extension InterstitialAdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Load a new ad when the current one is dismissed
        loadInterstitialAd()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Failed to present interstitial ad: \(error.localizedDescription)")
        loadInterstitialAd()
    }
}