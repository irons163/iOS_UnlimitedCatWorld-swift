//
//  GameCenterUtil.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/5/3.
//

import GameKit
import UIKit

class GameCenterUtil: NSObject, GKGameCenterControllerDelegate {
    
    static let shared = GameCenterUtil()
    
    private var isGameCenterAvailableState: Bool = false
    private let savedScoresKey = "savedScores" // UserDefaults key
    
    // Make init private for singleton pattern
    private override init() {
        super.init()
        checkGameCenterAvailability()
    }
    
    private func checkGameCenterAvailability() {
        // Basic check: GKLocalPlayer should exist on supported OS
        // Availability is primarily determined by authentication status.
        isGameCenterAvailableState = true // Assume available initially
        
        if isGameCenterAvailableState {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(authenticationChanged),
                                                   name: .GKPlayerAuthenticationDidChangeNotificationName, // Modern notification name
                                                   object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func isGameCenterAvailable() -> Bool {
        // Return cached state, potentially updated by authenticationChanged
        // A more robust check might involve GKLocalPlayer.local.isAuthenticated
        return isGameCenterAvailableState
    }
    
    // Added completion handler for feedback
    func authenticateLocalUser(presentingViewController: UIViewController, completion: ((Bool, Error?) -> Void)? = nil) {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            if let vc = viewController {
                presentingViewController.present(vc, animated: true, completion: nil)
                completion?(false, error) // Auth UI shown, not yet authenticated
            } else if localPlayer.isAuthenticated {
                print("Game Center Authenticated")
                self?.isGameCenterAvailableState = true
                // Optional: Load default leaderboard ID after authentication
                localPlayer.loadDefaultLeaderboardIdentifier { leaderboardIdentifier, error in
                    if let id = leaderboardIdentifier {
                        print("Default Leaderboard ID: \(id)")
                    } else if let err = error {
                        print("Error loading default leaderboard ID: \(err.localizedDescription)")
                    }
                }
                self?.submitAllSavedScores() // Attempt submitting saved scores on authentication
                completion?(true, nil)
            } else if let err = error {
                print("Game Center Authentication Failed: \(err.localizedDescription)")
                self?.isGameCenterAvailableState = false
                completion?(false, err)
            } else {
                // Player chose not to sign in or cancelled
                print("Game Center Authentication Cancelled or Failed (No Error)")
                self?.isGameCenterAvailableState = false
                completion?(false, nil)
            }
        }
    }
    
    @objc private func authenticationChanged() {
        let isAuthenticated = GKLocalPlayer.local.isAuthenticated
        isGameCenterAvailableState = isAuthenticated // Update availability state
        if isAuthenticated {
            print("Authentication changed: player authenticated.")
            submitAllSavedScores() // Attempt submitting saved scores on auth change
        } else {
            print("Authentication changed: player not authenticated")
        }
        // Post custom notification if needed elsewhere in the app
        // NotificationCenter.default.post(name: .myAppGameCenterAuthDidChange, object: nil)
    }
    
    // Note: category parameter often corresponds to Leaderboard ID
    func reportScore(_ score: Int64, forCategory category: String) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Cannot report score: Player not authenticated.")
            // Optionally save score even if not authenticated, to submit later
            // let scoreReporter = GKScore(leaderboardIdentifier: category)
            // scoreReporter.value = score
            // if let scoreData = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false) {
            //     storeScoreForLater(scoreData)
            // }
            return
        }
        
        // Use modern GKLeaderboardScore instead of GKScore if targeting iOS 14+
        if #available(iOS 14.0, *) {
            GKLeaderboard.submitScore(Int(score), context: 0, player: GKLocalPlayer.local, leaderboardIDs: [category]) { [weak self] error in
                if let err = error {
                    print("Error reporting score (iOS 14+): \(err.localizedDescription)")
                    // Fallback to saving raw data if needed, GKScore archiving is fragile
                    // Consider saving score, category, timestamp instead of GKScore object
                    let scoreReporter = GKScore(leaderboardIdentifier: category) // Need GKScore for archiving
                    scoreReporter.value = score
                    if let scoreData = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false) {
                        self?.storeScoreForLater(scoreData)
                    }
                } else {
                    print("Score reported successfully (iOS 14+)")
                }
            }
        } else {
            // Fallback for older iOS versions using GKScore
            let scoreReporter = GKScore(leaderboardIdentifier: category) // Use modern initializer
            scoreReporter.value = score
            scoreReporter.context = 0 // Context is required for GKScore reporting
            
            GKScore.report([scoreReporter]) { [weak self] error in // Use class method report
                if let err = error {
                    print("Error reporting score (Legacy): \(err.localizedDescription)")
                    // Save score data for later submission attempt
                    if let scoreData = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false) {
                        self?.storeScoreForLater(scoreData)
                    }
                } else {
                    print("Score reported successfully (Legacy)")
                }
            }
        }
    }
    
    
    private func storeScoreForLater(_ scoreData: Data) {
        var savedScoresArray = UserDefaults.standard.array(forKey: savedScoresKey) as? [Data] ?? []
        savedScoresArray.append(scoreData)
        UserDefaults.standard.set(savedScoresArray, forKey: savedScoresKey)
        print("Score saved for later submission.")
    }
    
    
    func submitAllSavedScores() {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Cannot submit saved scores: Player not authenticated.")
            return
        }
        
        let savedScoreArray = UserDefaults.standard.array(forKey: savedScoresKey) as? [Data] ?? []
        guard !savedScoreArray.isEmpty else { return } // Nothing to submit
        
        print("Attempting to submit \(savedScoreArray.count) saved scores...")
        UserDefaults.standard.removeObject(forKey: savedScoresKey) // Remove immediately, re-save on failure
        
        for scoreData in savedScoreArray {
            // Unarchiving GKScore is potentially unsafe and might fail across OS versions.
            // Prefer storing raw score data instead.
            guard let scoreReporter = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scoreData) as? GKScore else {
                print("Error: Could not unarchive saved score data.")
                continue
            }
            
            // Use modern reporting if available
            if #available(iOS 14.0, *) {
                GKLeaderboard.submitScore(Int(scoreReporter.value), context: Int(scoreReporter.context), player: GKLocalPlayer.local, leaderboardIDs: [scoreReporter.leaderboardIdentifier]) { [weak self] error in
                    if let err = error {
                        print("Error re-submitting score (iOS 14+): \(err.localizedDescription)")
                        // Re-save data on failure
                        if let dataToSave = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false) {
                            self?.storeScoreForLater(dataToSave)
                        }
                    } else {
                        print("Saved score submitted successfully (iOS 14+)")
                    }
                }
            } else {
                // Fallback reporting for older iOS
                GKScore.report([scoreReporter]) { [weak self] error in
                    if let err = error {
                        print("Error re-submitting score (Legacy): \(err.localizedDescription)")
                        // Re-save data on failure
                        if let dataToSave = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false) {
                            self?.storeScoreForLater(dataToSave)
                        }
                    } else {
                        print("Saved score submitted successfully (Legacy)")
                    }
                }
            }
        }
    }
    
    // Presenting Game Center UI
    func showGameCenter(presentingViewController: UIViewController, leaderboardID: String? = nil, viewState: GKGameCenterViewControllerState = .leaderboards) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Cannot show Game Center: Player not authenticated.")
            // Optionally, attempt authentication first
            authenticateLocalUser(presentingViewController: presentingViewController) { success, error in
                if success {
                    self.showGameCenter(presentingViewController: presentingViewController, leaderboardID: leaderboardID, viewState: viewState)
                }
            }
            return
        }
        
        let gameView: GKGameCenterViewController
        
        // Optionally specify a leaderboard
        if let id = leaderboardID, viewState == .leaderboards {
            gameView = GKGameCenterViewController(leaderboardID: id, playerScope: .global, timeScope: .allTime)
            // gameView.leaderboardTimeScope = .allTime // Still valid if needed
        } else {
            gameView = GKGameCenterViewController(state: viewState)
        }
        gameView.gameCenterDelegate = self
        
        presentingViewController.present(gameView, animated: true, completion: nil)
    }
    
    // MARK: - GKGameCenterControllerDelegate
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
