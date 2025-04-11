//
//  GameMenuViewController.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/5/3.
//

import UIKit
import SpriteKit

class GameMenuViewController: UIViewController {

    @IBOutlet weak var touchMultiImage: UIImageView!
    @IBOutlet weak var zoneImage: UIImageView!
    @IBOutlet weak var BladeImage: UIImageView! // Note: Swift convention usually starts properties lowercased (bladeImage)
    @IBOutlet weak var touchBtn: UIButton!
    @IBOutlet weak var touchMultiBtn: UIButton!
    @IBOutlet weak var zoneBtn: UIButton!
    @IBOutlet weak var bladeBtn: UIButton!
    @IBOutlet weak var gameTimeLabel: UILabel! // This outlet exists but isn't used in the provided code

    weak var gameDelegate: GameDelegate?
    var gameType: Int = 0
    var gameScore: Int64 = 0
    weak var scene: MyScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureButton(touchBtn, titleKey: "touchMode")

        configureUnlockableButton(
            button: touchMultiBtn,
            imageView: touchMultiImage,
            unlockScore: UnlockTouchMultiClear,
            unlockedImageName: "touch_multi_btn",
            unlockedTitleKey: "touchMultiMode"
        )

        configureUnlockableButton(
            button: zoneBtn,
            imageView: zoneImage,
            unlockScore: UnlockZoneClear,
            unlockedImageName: "zone_btn",
            unlockedTitleKey: "zoneMode"
        )

        configureUnlockableButton(
            button: bladeBtn,
            imageView: BladeImage, // Using the outlet name as is
            unlockScore: UnlockBladeClear,
            unlockedImageName: "blade_btn",
            unlockedTitleKey: "bladeMode"
        )
    }

    // Helper to configure basic button properties
    private func configureButton(_ button: UIButton, titleKey: String) {
        button.setTitle(NSLocalizedString(titleKey, comment: ""), for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        // button.titleLabel?.sizeToFit() // sizeToFit might not be needed with AutoLayout
    }

    // Helper to configure buttons that depend on score unlock
    private func configureUnlockableButton(button: UIButton, imageView: UIImageView, unlockScore: Int64, unlockedImageName: String, unlockedTitleKey: String) {
        if self.gameScore < unlockScore {
            imageView.image = UIImage(named: "question_mark_horizental_btn")
            let unlockTextFormat = NSLocalizedString("modeUnlock", comment: "") // e.g., "%lld Points to Unlock"
            let title = String(format: unlockTextFormat, unlockScore) // Use format specifier if needed, or simple interpolation
            // let title = "\(unlockScore) \(NSLocalizedString("modeUnlock", comment: ""))" // Simpler interpolation if format is just score + text
            button.setTitle(title, for: .normal)
            button.isEnabled = false // Optionally disable button if locked
            button.alpha = 0.6 // Optionally dim button if locked
        } else {
            imageView.image = UIImage(named: unlockedImageName)
            button.setTitle(NSLocalizedString(unlockedTitleKey, comment: ""), for: .normal)
            button.isEnabled = true
            button.alpha = 1.0
        }
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        // button.titleLabel?.sizeToFit()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // This IBAction was in the Obj-C implementation but not the header
    @IBAction func restartClick(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.gameDelegate?.restartGame()
        }
    }

    @IBAction func changeToTouchClick(_ sender: Any) {
        scene?.setClearType(TouchClear)
        backClick(self)
    }

    @IBAction func changeToTouchMultiClick(_ sender: Any) {
        guard gameScore >= UnlockTouchMultiClear else { return }
        scene?.setClearType(TouchMultiClear)
        backClick(self)
    }

    @IBAction func changeToZoneClick(_ sender: Any) {
        guard gameScore >= UnlockZoneClear else { return }
        scene?.setClearType(ZoneClear)
        backClick(self)
    }

    @IBAction func changeToBladeClick(_ sender: Any) {
        guard gameScore >= UnlockBladeClear else { return }
        scene?.setClearType(BladeClear)
        backClick(self)
    }

    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
