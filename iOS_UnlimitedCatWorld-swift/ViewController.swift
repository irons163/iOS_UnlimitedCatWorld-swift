//
//  ViewController.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/4/9.
//

import UIKit
import SpriteKit
import GoogleMobileAds

// MARK: - Game Delegate Protocol
// Renamed to follow Swift naming conventions (UpperCamelCase)
// Restricted to classes using AnyObject
protocol GameDelegate: AnyObject {
    func showGameOver()
    func showRankView()
    func restartGame()
    func showGameMenu()
}

// MARK: - ViewController Class
// Conforms to UIViewController, ADBannerViewDelegate, and GameDelegate
class ViewController: UIViewController, BannerViewDelegate, GameDelegate {

    // MARK: Properties

    // Use implicitly unwrapped optionals as they are initialized in viewDidLoad
    var adBannerView: BannerView!
    var scene: MyScene! // Assuming MyScene is also converted/bridged to Swift

    // Reference to GameCenterUtil singleton (assuming Swift version exists)
    // Adjust if your singleton access is different (e.g., GameCenterUtil.shared)
    let gameCenterUtil = GameCenterUtil.shared

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAdBanner()
        setupSpriteKitScene()
        setupGameCenter()
    }

    // MARK: - Setup Methods

    func setupAdBanner() {
        let bannerHeight: CGFloat = 50
        let bannerWidth = view.bounds.width
        adBannerView = BannerView(frame: CGRect(x: 0, y: -bannerHeight, width: bannerWidth, height: bannerHeight))
        adBannerView.delegate = self

        view.addSubview(adBannerView)
    }

    func setupSpriteKitScene() {
        // Configure the view (ensure the root view is an SKView).
        // If using Storyboards, set the ViewController's view class to SKView.
        guard let skView = self.view as? SKView else {
            print("Error: ViewController's view is not an SKView!")
            // Handle error appropriately - maybe create an SKView programmatically
            // let skView = SKView(frame: self.view.bounds)
            // self.view = skView
            return
        }

        // Create and configure the scene.
        // Assuming MyScene has a Swift initializer `init(size:)`
        scene = MyScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self // Set the delegate

        // Present the scene.
        skView.presentScene(scene)

        // Optional: Configure SKView properties
        // skView.showsFPS = true
        // skView.showsNodeCount = true
        // skView.ignoresSiblingOrder = true // For performance
    }

    func setupGameCenter() {
        // Check availability and authenticate user
        if gameCenterUtil.isGameCenterAvailable() {
             // Assuming authenticateLocalUser takes the presenting view controller
            gameCenterUtil.authenticateLocalUser(presentingViewController: self) { success, error in
                 if success {
                     print("Game Center: User authenticated.")
                     // Submit scores upon successful authentication
                     self.gameCenterUtil.submitAllSavedScores()
                 } else if let error = error {
                     print("Game Center: Authentication failed - \(error.localizedDescription)")
                 } else {
                     print("Game Center: Authentication failed (unknown reason).")
                 }
             }
        } else {
             print("Game Center: Not available on this device.")
        }
    }

    // MARK: - GameDelegate Conformance

    func showRankView() {
        print("Showing Rank View...")
        if gameCenterUtil.isGameCenterAvailable() {
            // Assuming showGameCenter takes the presenting view controller
            gameCenterUtil.showGameCenter(presentingViewController: self)
            // Consider if submitting scores here is needed again, or only on game end/auth.
            // gameCenterUtil.submitAllSavedScores()
        }
    }

    func showGameMenu() {
        print("Showing Game Menu...")
        // Instantiate from storyboard
        // Ensure "GameMenuViewController" identifier exists in your Storyboard
        guard let gameMenuVC = storyboard?.instantiateViewController(withIdentifier: "GameMenuViewController") as? GameMenuViewController else {
            print("Error: Could not instantiate GameMenuViewController from storyboard.")
            return
        }

        // Configure the Game Menu View Controller
        // Assuming GameMenuViewController properties are accessible
        gameMenuVC.gameDelegate = self
        gameMenuVC.scene = scene // Pass scene reference if needed by menu
        // Assuming MyScene Swift methods exist
        gameMenuVC.gameType = scene.getClearType()
        gameMenuVC.gameScore = scene.getGameScore()

        // Configure presentation style for modal overlay
        gameMenuVC.modalPresentationStyle = .overCurrentContext
        gameMenuVC.modalTransitionStyle = .crossDissolve // Or your preferred transition

        // The following lines from Obj-C are less common in modern Swift for this type of presentation.
        // Setting the modalPresentationStyle on the presented VC usually suffices.
        // self.navigationController?.providesPresentationContextTransitionStyle = true
        // self.navigationController?.definesPresentationContext = true

        // Present the view controller
        present(gameMenuVC, animated: true, completion: nil) // nil for empty completion handler
    }

    // --- Methods required by GameDelegate protocol ---
    // You need to provide the actual implementation for these based on your game logic

    func showGameOver() {
        // TODO: Implement game over logic (e.g., show score, navigate to menu)
        print("Game Over! Implement logic here.")
        // Often, you might call showGameMenu() here after some delay or animation
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
              self?.showGameMenu()
         }
    }

    func restartGame() {
        // TODO: Implement game restart logic (e.g., create/present new scene)
        print("Restarting Game! Implement logic here.")
         guard let skView = self.view as? SKView else { return }

         // Create and configure a new scene instance
         scene = MyScene(size: skView.bounds.size)
         scene.scaleMode = .aspectFill
         scene.gameDelegate = self

         // Present the new scene with a transition
         let transition = SKTransition.crossFade(withDuration: 0.5)
         skView.presentScene(scene, transition: transition)
    }


    // MARK: - BannerViewDelegate Methods
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("Ad Banner: Loaded Ad")
        layoutBanner(loaded: true, animated: true)
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
        print("Ad Banner: Failed to load ad - \(error.localizedDescription)")
        layoutBanner(loaded: false, animated: true)
    }

    // MARK: - Ad Layout Method

    func layoutBanner(loaded: Bool, animated: Bool) {
        var bannerFrame = adBannerView.frame
        let bannerHeight = bannerFrame.size.height

        // Determine target Y position based on whether the banner is loaded
        let targetY: CGFloat
        if loaded {
             targetY = 0 // Show banner at the top
        } else {
             targetY = -bannerHeight // Hide banner offscreen above
        }

        // Animate the banner frame change if needed
        if bannerFrame.origin.y != targetY {
             bannerFrame.origin.y = targetY
             UIView.animate(withDuration: animated ? 0.25 : 0.0) {
                 self.adBannerView.frame = bannerFrame
            }
        }
    }


    // MARK: - Orientation Handling

    override var shouldAutorotate: Bool {
        return true // Allow autorotation
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            // On iPhone, allow all orientations except upside down
            return .allButUpsideDown
        } else {
            // On iPad, allow all orientations
            return .all
        }
    }

    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Warning: Memory warning received!")
        // Example: Clear caches, release large objects not currently needed
    }
}

// MARK: - Helper Extensions (Optional)
// You might need extensions if GameCenterUtil methods have changed signatures

// Example extension if authenticateLocalUser signature changed in Swift
/*
extension GameCenterUtil {
    func authenticateLocalUser(presentingVC: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        // Implementation of your Swift authentication method
        // Call the completion handler with success/failure
        print("Called updated authenticateLocalUser")
        // Placeholder:
        completion(true, nil)
    }

     func showGameCenter(presentingVC: UIViewController) {
         // Implementation
         print("Called updated showGameCenter")
     }
}

// Assuming MyScene, GameMenuViewController, GameCenterUtil are defined elsewhere
// either as Swift classes or bridged Objective-C classes.
class MyScene: SKScene {
     weak var gameDelegate: GameDelegate?
     func getClearType() -> Int { return 0 } // Placeholder
     func getGameScore() -> Int { return 0 } // Placeholder
 }
 class GameMenuViewController: UIViewController {
     weak var gameDelegate: GameDelegate?
     var scene: MyScene?
     var gameType: Int = 0
     var gameScore: Int = 0
 }
 class GameCenterUtil {
     static let shared = GameCenterUtil() // Example Swift singleton
     func isGameCenterAvailable() -> Bool { return true } // Placeholder
     func submitAllSavedScores() {} // Placeholder
     // Add the authenticate and show methods matching the calls above
     func authenticateLocalUser(presentingVC: UIViewController, completion: @escaping (Bool, Error?) -> Void) { /* ... */ }
     func showGameCenter(presentingVC: UIViewController) { /* ... */ }

     // Keep original if bridging Obj-C
     static func sharedInstance() -> GameCenterUtil { return shared }
}
*/

