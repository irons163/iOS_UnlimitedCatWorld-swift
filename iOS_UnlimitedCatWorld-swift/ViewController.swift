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
        let bannerHeight: CGFloat = 30
        adBannerView = BannerView(frame: CGRect(x: 0, y: -50, width: 200, height: bannerHeight))
        adBannerView.delegate = self
        adBannerView.alpha = 1.0
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
        _ = gameCenterUtil.isGameCenterAvailable()
        gameCenterUtil.authenticateLocalUser(presentingViewController: self)
        gameCenterUtil.submitAllSavedScores()
    }

    // MARK: - GameDelegate Conformance

    func showRankView() {
        _ = gameCenterUtil.isGameCenterAvailable()
        gameCenterUtil.showGameCenter(presentingViewController: self)
        gameCenterUtil.submitAllSavedScores()
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

        if let navigationController = self.navigationController {
            navigationController.providesPresentationContextTransitionStyle = true
            navigationController.definesPresentationContext = true
        }

        gameMenuVC.modalPresentationStyle = .overCurrentContext

        // Present the view controller
        present(gameMenuVC, animated: true, completion: nil) // nil for empty completion handler
    }

    // --- Methods required by GameDelegate protocol ---
    // You need to provide the actual implementation for these based on your game logic

    func showGameOver() {
    }

    func restartGame() {
    }


    // MARK: - BannerViewDelegate Methods
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        layoutBanner(loaded: true, animated: true)
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
        layoutBanner(loaded: false, animated: true)
    }

    // MARK: - Ad Layout Method

    func layoutBanner(loaded: Bool, animated: Bool) {
        var contentFrame = view.bounds
        var bannerFrame = adBannerView.frame

        if loaded {
            contentFrame.size.height = 0
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            bannerFrame.origin.y = contentFrame.size.height
        }

        UIView.animate(withDuration: animated ? 0.25 : 0.0) {
            self.adBannerView.frame = contentFrame
            self.adBannerView.layoutIfNeeded()
            self.adBannerView.frame = bannerFrame
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
    }
}

