//
//  MyADView.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/5/3.
//

import SpriteKit
import UIKit

class MyADView: SKSpriteNode {

    private var ads: [SKTexture] = []
    private var adsUrl: [String] = []
    private var adIndex: Int = 0
    private var button: SKSpriteNode?
    private var adTimer: Timer?

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true // Enable touches
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // If initialized from scene file, ensure interaction is enabled
        self.isUserInteractionEnabled = true
        // Note: startAd() might need to be called manually if created via scene editor
    }

    func startAd() {
        ads = [
            SKTexture(imageNamed: "ad1.jpg"),
            SKTexture(imageNamed: NSLocalizedString("cat_shoot_ad", comment: "")),
            SKTexture(imageNamed: "2048_ad"),
            SKTexture(imageNamed: "Shoot_Learning_ad"),
            SKTexture(imageNamed: "cute_dudge_ad")
        ]

        adsUrl = [
            "http://itunes.apple.com/us/app/good-sleeper-counting-sheep/id998186214?l=zh&ls=1&mt=8",
            "http://itunes.apple.com/us/app/attack-on-giant-cat/id1000152033?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/2048-chinese-zodiac/id1024333772?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/shoot-learning-math/id1025414483?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/cute-dodge/id1018590182?l=zh&ls=1&mt=8"
        ]

        adIndex = 0
        self.texture = ads[adIndex]

        adTimer?.invalidate()
        adTimer = Timer.scheduledTimer(timeInterval: 2.0,
                                       target: self,
                                       selector: #selector(changeAd),
                                       userInfo: nil,
                                       repeats: true)

        button = SKSpriteNode(imageNamed: "btn_Close-hd")
        button?.size = CGSize(width: 30, height: 30)
        button?.position = CGPoint(x: self.size.width / 2 - (button?.size.width ?? 0), y: self.size.height - (button?.size.height ?? 0))
        button?.anchorPoint = CGPoint(x: 0, y: 0)
        if let btn = button { addChild(btn) }
    }

    @objc func changeAd() {
        adIndex += 1

        if adIndex >= ads.count { adIndex = 0 }
        self.texture = ads[adIndex]
    }

    func doClick() {
        let urlString = adsUrl[adIndex]
        UIApplication.shared.open(URL(string: urlString)!)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isHidden else { return }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let btn = button, btn.contains(location) {
            self.isHidden = true
        } else if location.y < self.size.height {
            doClick()
        }
    }

    deinit {
        // Ensure timer is invalidated when the view is deallocated
        adTimer?.invalidate()
    }
}
