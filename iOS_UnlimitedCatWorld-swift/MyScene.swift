//
//  MyScene.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/5/3.
//

import SpriteKit
import UIKit

let TouchClear = 0
let ZoneClear = 1
let BladeClear = 2
let TouchMultiClear = 3

let UnlockTouchMultiClear: Int64 = 1000
let UnlockZoneClear: Int64 = 100000
let UnlockBladeClear: Int64 = 10000

class MyScene: SKScene {

    var backgroundNode: SKSpriteNode!
    weak var gameDelegate: GameDelegate?

    private var myAdView: MyADView?
    private var gameLevel: Int = 0
    private var isTouchAble: Bool = true
    private var gamePointX: CGFloat = 0
    private var gameScore: Int64 = 0
    private var isRandomCatTexturesRepeat: Bool = false
    private var clearType: Int = 0

    private var currentCatTextures: [SKTexture] = []

    private var bugs: [SKSpriteNode] = []
    private var explodePool: [SKSpriteNode] = []

    private var explodeTextures: [SKTexture] = []

    private var zone: SKSpriteNode?
    private var rankBtn: SKSpriteNode?
    private var musicBtn: SKSpriteNode?
    private var menuBtn: SKSpriteNode?

    private var gamePointSingleNode: SKSpriteNode?
    private var gamePointTenNode: SKSpriteNode?
    private var gamePointHunNode: SKSpriteNode?
    private var gamePointTHUNode: SKSpriteNode?
    private var gamePoint10THUNode: SKSpriteNode?
    private var gamePoint100THUNode: SKSpriteNode?
    private var gamePoint1MNode: SKSpriteNode?
    private var gamePoint10MNode: SKSpriteNode?
    private var gamePoint100MNode: SKSpriteNode?
    private var gamePoint1BNode: SKSpriteNode?
    private var gamePoint10BNode: SKSpriteNode?

    private var blade: SKBlade?
    private var delta: CGPoint = .zero

    private var musicBtnTextures: [SKTexture] = []

    private let explodeZPosition: CGFloat = 2

    override init(size: CGSize) {
        super.init(size: size)

        TextureHelper.initCatTextures()

        let tex1 = SKTexture(imageNamed: "btn_Music-hd")
        let tex2 = SKTexture(imageNamed: "btn_Music_Select-hd")
        musicBtnTextures.append(tex1)
        musicBtnTextures.append(tex2)

        bugs = []
        explodePool = []

        checkIsRandomCatTexturesRepeat()
        randomCurrentCatTextures()

        isTouchAble = true

        initKillZone()

        gameScore = Int64(UserDefaults.standard.integer(forKey: "gameScore"))
        self.backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)

        let myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 30
        myLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(myLabel)

        let r = Int.random(in: 0..<15)
        if r < TextureHelper.backgrounds().count {
            self.backgroundNode = SKSpriteNode(texture: TextureHelper.backgrounds()[r])
             let backgroundSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
             self.backgroundNode.size = backgroundSize
             self.backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
             self.backgroundNode.position = CGPoint(x: 0, y: 0)
             self.addChild(self.backgroundNode)
        }


        let gamePointNodeWH: CGFloat = 30

        gamePointX = self.frame.size.width - gamePointNodeWH
        let gamePointY = self.frame.size.height * 6 / 8.0

        gamePointSingleNode = SKSpriteNode(texture: self.getTimeTexture(time: Int(gameScore % 10)))
        gamePointSingleNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointSingleNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointSingleNode?.position = CGPoint(x: gamePointX, y: gamePointY)

        gamePointTenNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 10) % 10)))
        gamePointTenNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointTenNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointTenNode?.position = CGPoint(x: gamePointX - gamePointNodeWH, y: gamePointY)

        gamePointHunNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 100) % 10)))
        gamePointHunNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointHunNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointHunNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 2, y: gamePointY)

        gamePointTHUNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 1000) % 10)))
        gamePointTHUNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointTHUNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointTHUNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 3, y: gamePointY)

        gamePoint10THUNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 10000) % 10)))
        gamePoint10THUNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePoint10THUNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePoint10THUNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 4, y: gamePointY)

        gamePoint100THUNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 100000) % 10)))
        gamePoint100THUNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePoint100THUNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePoint100THUNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 5, y: gamePointY)

        gamePoint1MNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 1000000) % 10)))
        gamePoint1MNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePoint1MNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePoint1MNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 6, y: gamePointY)

        gamePoint10MNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 10000000) % 10)))
        gamePoint10MNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePoint10MNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePoint10MNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 7, y: gamePointY)

        gamePoint100MNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 100000000) % 10)))
        gamePoint100MNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePoint100MNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePoint100MNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 8, y: gamePointY)

        gamePoint1BNode = SKSpriteNode(texture: self.getTimeTexture(time: Int((gameScore / 1000000000) % 10)))
        gamePoint1BNode?.anchorPoint = CGPoint(x: 0, y: 0)
        gamePoint1BNode?.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePoint1BNode?.position = CGPoint(x: gamePointX - gamePointNodeWH * 9, y: gamePointY)

        if let node = gamePointSingleNode { addChild(node) }
        if let node = gamePointTenNode { addChild(node) }
        if let node = gamePointHunNode { addChild(node) }
        if let node = gamePointTHUNode { addChild(node) }
        if let node = gamePoint10THUNode { addChild(node) }
        if let node = gamePoint100THUNode { addChild(node) }
        if let node = gamePoint1MNode { addChild(node) }
        if let node = gamePoint10MNode { addChild(node) }
        if let node = gamePoint100MNode { addChild(node) }
        if let node = gamePoint1BNode { addChild(node) }


        rankBtn = SKSpriteNode(imageNamed: "btnL_GameCenter-hd")
        rankBtn?.size = CGSize(width: 42, height: 42)
        rankBtn?.anchorPoint = CGPoint(x: 0, y: 0)
        if let btn = rankBtn {
             btn.position = CGPoint(x: self.frame.size.width - btn.size.width, y: self.frame.size.height / 2)
             addChild(btn)
        }


        autoCreateBugs()

        initExplodeTextures()

        musicBtn = SKSpriteNode(imageNamed: "btn_Music-hd")
        musicBtn?.size = CGSize(width: 42, height: 42)
        musicBtn?.anchorPoint = CGPoint(x: 0, y: 0)
        if let btn = musicBtn {
             btn.position = CGPoint(x: self.frame.size.width - btn.size.width, y: self.frame.size.height / 2 - 42)
             addChild(btn)
        }

        menuBtn = SKSpriteNode(imageNamed: "btn_Menu-hd")
        menuBtn?.size = CGSize(width: 42, height: 42)
        menuBtn?.anchorPoint = CGPoint(x: 0, y: 0)
         if let btn = menuBtn {
             btn.position = CGPoint(x: self.frame.size.width - btn.size.width, y: self.frame.size.height / 2 - 42 * 2)
             addChild(btn)
        }

        clearType = UserDefaults.standard.integer(forKey: "clearType")

        let musics = ["am_white.mp3", "biai.mp3", "cafe.mp3", "deformation.mp3"]
        let index = Int.random(in: 0..<musics.count)
        MyUtils.preparePlayBackgroundMusic(musics[index])

        let isPlayMusicObject = UserDefaults.standard.object(forKey: "isPlayMusic")
        var isPlayMusic = true
        if let boolValue = isPlayMusicObject as? Bool {
            isPlayMusic = boolValue
        } else {
            isPlayMusic = true // Default if not set
            UserDefaults.standard.set(isPlayMusic, forKey: "isPlayMusic")
        }


        if isPlayMusic {
            MyUtils.backgroundMusicPlayerPlay()
            if !musicBtnTextures.isEmpty { musicBtn?.texture = musicBtnTextures[0] }
        } else {
            MyUtils.backgroundMusicPlayerPause()
             if musicBtnTextures.count > 1 { musicBtn?.texture = musicBtnTextures[1] }
        }

        myAdView = MyADView(texture: nil) // Assuming MyADView is available
        if let adView = myAdView {
             adView.size = CGSize(width: self.frame.size.width, height: self.frame.size.width / 5.0)
             adView.position = CGPoint(x: self.frame.size.width / 2, y: 0)
             adView.startAd()
             adView.zPosition = 1
             adView.anchorPoint = CGPoint(x: 0.5, y: 0)
             addChild(adView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initExplodeTextures() {
        explodeTextures = TextureHelper.getTexturesWithSpriteSheetNamed("explode", withinNode: nil, sourceRect: CGRect(x: 0, y: 0, width: 500, height: 500), andRowNumberOfSprites: 1, andColNumberOfSprites: 5) ?? []
    }

    func skill() {

    }

    func initKillZone() {
        zone = SKSpriteNode(color: .blue, size: CGSize(width: 120, height: 120))
        zone?.alpha = 0.5
        zone?.position = CGPoint(x: -500, y: -500)
        zone?.zPosition = 1
        if let z = zone { addChild(z) }
    }

    func hideKillZone() {
        zone?.position = CGPoint(x: -500, y: -500)
    }

    func killZone() {
        guard let zoneNode = zone else { return }
        let zoneFrame = zoneNode.calculateAccumulatedFrame()

        for i in (0..<bugs.count).reversed() {
             let bug = bugs[i]
             if zoneFrame.contains(bug.calculateAccumulatedFrame()) {
                 doKill(targetBug: bug)
                 // Since doKill removes the bug, no need to increment i
             }
        }
    }


    func checkIsRandomCatTexturesRepeat() {
        isRandomCatTexturesRepeat = Bool.random()
    }

    func randomCurrentCatTextures() {
        let r = Int.random(in: 0..<5)
        switch r {
        case 0: currentCatTextures = TextureHelper.cat1Textures
        case 1: currentCatTextures = TextureHelper.cat2Textures
        case 2: currentCatTextures = TextureHelper.cat3Textures
        case 3: currentCatTextures = TextureHelper.cat4Textures
        case 4: currentCatTextures = TextureHelper.cat5Textures
        default: break
        }
    }

    func autoCreateBugs() {
        let createTimer = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.bugs.count < 50 {
                self.createBugs()
                self.createBugs()
            } else if self.bugs.count < 100 {
                self.createBugs()
            }

            if self.gameScore >= UnlockTouchMultiClear {
                self.createBugs()
            }
            if self.gameScore >= UnlockBladeClear {
                self.createBugs()
            }
            if self.gameScore >= UnlockZoneClear {
                self.createBugs()
            }
        }

        let wait = SKAction.wait(forDuration: 0.5)
        self.run(SKAction.repeatForever(SKAction.sequence([createTimer, wait])))
    }

    func createBugs() {
        if isRandomCatTexturesRepeat {
            randomCurrentCatTextures()
        }

        guard !currentCatTextures.isEmpty else { return }

        let bug = SKSpriteNode(texture: currentCatTextures[0])
        bug.size = CGSize(width: 60, height: 60)
        let randomX = CGFloat.random(in: bug.size.width / 2...(self.size.width - bug.size.width / 2))
        let randomY = CGFloat.random(in: bug.size.height / 2...(self.size.height - bug.size.height / 2))
        bug.position = CGPoint(x: randomX, y: randomY)

        self.addChild(bug)
        bugs.append(bug)

        move(bug: bug)
        runMovementAction(bug: bug)
    }


    func move(bug: SKSpriteNode) {
        let radians = CGFloat.random(in: 0..<(2 * .pi))
        let r: CGFloat = 40
        var dx = r * cos(radians)
        var dy = r * sin(radians)

        let nextX = bug.position.x + dx
        let nextY = bug.position.y + dy

        if (nextX - bug.size.width / 2.0) < 0 || (nextX + bug.size.width / 2.0) > self.size.width {
            dx = -dx
        }

        if (nextY - bug.size.height / 2.0) < 0 || (nextY + bug.size.height / 2.0) > self.size.height {
            dy = -dy
        }

        let action = SKAction.moveBy(x: dx, y: dy, duration: 1.0)
        let wait = SKAction.wait(forDuration: 2.0)
        let end = SKAction.run { [weak self, weak bug] in
            guard let self = self, let bug = bug else { return }
            self.move(bug: bug)
        }

        bug.run(SKAction.sequence([action, wait, end]), withKey: "movement")
    }


    func runMovementAction(bug: SKSpriteNode) {
        guard currentCatTextures.count >= 2 else { return }
        let movementAction = SKAction.animate(with: [currentCatTextures[0], currentCatTextures[1]], timePerFrame: 0.2)
        bug.run(SKAction.repeatForever(movementAction), withKey: "animation")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        myAdView?.touchesBegan(touches, with: event)

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        var isTouchOnBugOrButton = false

        if clearType == BladeClear {
            presentBladeAtPosition(location)
             isTouchOnBugOrButton = true // Blade interaction handled in update
        } else if clearType == ZoneClear {
             if let zoneNode = zone {
                  zoneNode.position = location
                  isTouchOnBugOrButton = true // Zone interaction handled in update or here
                  for i in (0..<bugs.count).reversed() {
                       let bug = bugs[i]
                       if zoneNode.calculateAccumulatedFrame().contains(bug.position) {
                            doKill(targetBug: bug)
                       }
                  }
             }
        } else if clearType == TouchMultiClear {
            for i in (0..<bugs.count).reversed() {
                 let bug = bugs[i]
                 if bug.calculateAccumulatedFrame().contains(location) {
                     isTouchOnBugOrButton = true
                     doKill(targetBug: bug)
                 }
            }
        } else { // Default: TouchClear
            for i in (0..<bugs.count).reversed() {
                 let bug = bugs[i]
                 if bug.calculateAccumulatedFrame().contains(location) {
                     isTouchOnBugOrButton = true
                     doKill(targetBug: bug)
                     break // Only kill one in single touch mode
                 }
            }
        }

        if !isTouchOnBugOrButton {
             if let btn = rankBtn, btn.calculateAccumulatedFrame().contains(location) {
                  isTouchOnBugOrButton = true
                  self.gameDelegate?.showRankView()
             } else if let btn = musicBtn, btn.calculateAccumulatedFrame().contains(location) {
                  isTouchOnBugOrButton = true
                  if MyUtils.isBackgroundMusicPlayerPlaying() {
                       MyUtils.backgroundMusicPlayerPause()
                       if musicBtnTextures.count > 1 { btn.texture = musicBtnTextures[1] }
                       UserDefaults.standard.set(false, forKey: "isPlayMusic")
                  } else {
                       MyUtils.backgroundMusicPlayerPlay()
                       if !musicBtnTextures.isEmpty { btn.texture = musicBtnTextures[0] }
                       UserDefaults.standard.set(true, forKey: "isPlayMusic")
                  }
             } else if let btn = menuBtn, btn.calculateAccumulatedFrame().contains(location) {
                 isTouchOnBugOrButton = true
                 self.gameDelegate?.showGameMenu()
             }
        }
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let touch = touches.first, blade != nil else { return }
         let currentPoint = touch.location(in: self)
         let previousPoint = touch.previousLocation(in: self)
         delta = CGPoint(x: currentPoint.x - previousPoint.x, y: currentPoint.y - previousPoint.y)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeBlade()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeBlade()
    }

    func runHitAction(bug: SKSpriteNode) {
        bug.removeAllActions()
        if let index = bugs.firstIndex(of: bug) {
            bugs.remove(at: index)
        }

        if currentCatTextures.count > 3 {
             bug.texture = currentCatTextures[3]
        }

        let wait = SKAction.wait(forDuration: 0.5)
        let end = SKAction.run {
            bug.removeFromParent()
        }

        bug.run(SKAction.sequence([wait, end]))
    }

    func checkPool() -> SKSpriteNode? {
        for explodeNode in explodePool {
            if explodeNode.isHidden {
                explodeNode.isHidden = false
                return explodeNode
            }
        }
        return nil
    }

    func runExplodeAction(explode: SKSpriteNode) {
        guard !explodeTextures.isEmpty else {
             explode.isHidden = true
             self.isTouchAble = true
             return
        }

        let explodeAction = SKAction.animate(with: explodeTextures, timePerFrame: 0.2)
        let end = SKAction.run { [weak self] in
            explode.isHidden = true
            self?.isTouchAble = true
        }

        explode.run(SKAction.sequence([explodeAction, end]))
    }


    func changeGamePoint() {
        gameScore += 1

        UserDefaults.standard.set(Int(gameScore), forKey: "gameScore") // Store as Int if it fits, otherwise needs different handling

        gamePointSingleNode?.texture = self.getTimeTexture(time: Int(gameScore % 10))
        gamePointTenNode?.texture = self.getTimeTexture(time: Int((gameScore / 10) % 10))
        gamePointHunNode?.texture = self.getTimeTexture(time: Int((gameScore / 100) % 10))
        gamePointTHUNode?.texture = self.getTimeTexture(time: Int((gameScore / 1000) % 10))
        gamePoint10THUNode?.texture = self.getTimeTexture(time: Int((gameScore / 10000) % 10))
        gamePoint100THUNode?.texture = self.getTimeTexture(time: Int((gameScore / 100000) % 10))
        gamePoint1MNode?.texture = self.getTimeTexture(time: Int((gameScore / 1000000) % 10))
        gamePoint10MNode?.texture = self.getTimeTexture(time: Int((gameScore / 10000000) % 10))
        gamePoint100MNode?.texture = self.getTimeTexture(time: Int((gameScore / 100000000) % 10))
        gamePoint1BNode?.texture = self.getTimeTexture(time: Int((gameScore / 1000000000) % 10))
    }


    func presentBladeAtPosition(_ position: CGPoint) {
        blade = SKBlade(position: position, targetNode: self, color: .red) // Assuming SKBlade exists
        if let b = blade { addChild(b) }
    }

    func removeBlade() {
        delta = .zero
        blade?.removeFromParent()
        blade = nil
    }

    func getTimeTexture(time: Int) -> SKTexture? {
        guard time >= 0 && time < TextureHelper.timeTextures.count else {
            return TextureHelper.timeTextures.first // Default or handle error
        }
        return TextureHelper.timeTextures[time]
    }


    func doKill(targetBug: SKSpriteNode) {
        runHitAction(bug: targetBug)

        var explodeNode = checkPool()
        if explodeNode == nil {
            explodeNode = SKSpriteNode(texture: nil)
            explodeNode?.zPosition = explodeZPosition
            explodeNode?.size = targetBug.size
            explodeNode?.anchorPoint = CGPoint(x: 0.5, y: 1)
            if let node = explodeNode {
                addChild(node)
                explodePool.append(node)
            }
        }

        if let node = explodeNode {
             node.position = CGPoint(x: targetBug.position.x, y: targetBug.position.y + targetBug.size.height)
             runExplodeAction(explode: node)
        }

        changeGamePoint()
    }


    override func update(_ currentTime: TimeInterval) {
        if clearType == ZoneClear {
            killZone()
        }

        if let currentBlade = blade {
             currentBlade.position = CGPoint(x: currentBlade.position.x + delta.x, y: currentBlade.position.y + delta.y)

             for i in (0..<bugs.count).reversed() {
                  let bug = bugs[i]
                  if bug.calculateAccumulatedFrame().contains(currentBlade.position) {
                       doKill(targetBug: bug)
                       // Blade can hit multiple bugs in one frame? Original breaks.
                       // If multiple hits desired, remove the break.
                       // break
                  }
             }
        }

        delta = .zero
    }


    func setClearType(_ _clearType: Int) {
        clearType = _clearType
        if clearType != ZoneClear {
            hideKillZone()
        }
        UserDefaults.standard.set(clearType, forKey: "clearType")
    }

    func getClearType() -> Int {
        return clearType
    }

    func getGameScore() -> Int64 {
        return gameScore
    }

    func circle() {

    }
}


// Stubs for required external classes/helpers if not defined elsewhere
// Remove these if the actual classes exist in your project.
/*
protocol GameDelegate: AnyObject {
    func showGameOver()
    func showRankView()
    func restartGame()
    func showGameMenu()
}

class TextureHelper {
    static var bgTextures: [SKTexture] = []
    static var cat1Textures: [SKTexture] = []
    static var cat2Textures: [SKTexture] = []
    static var cat3Textures: [SKTexture] = []
    static var cat4Textures: [SKTexture] = []
    static var cat5Textures: [SKTexture] = []
    static var timeTextures: [SKTexture] = []

    static func initTextures() {}
    static func initCatTextures() {}
    static func getTexturesWithSpriteSheetNamed(_ name: String, withinNode: SKNode?, sourceRect: CGRect, andRowNumberOfSprites: Int, andColNumberOfSprites: Int) -> [SKTexture]? { return [] }
}

class SKBlade: SKNode {
     init(position: CGPoint, targetNode: SKNode, color: UIColor) { super.init() }
     required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class GameMenuViewController: UIViewController {
     weak var gameDelegate: GameDelegate?
     var scene: MyScene?
     var gameType: Int = 0
     var gameScore: Int64 = 0
}

class MyUtils {
    static func preparePlayBackgroundMusic(_ filename: String) {}
    static func backgroundMusicPlayerPlay() {}
    static func backgroundMusicPlayerPause() {}
    static func isBackgroundMusicPlayerPlaying() -> Bool { return false }
}

class MyADView: SKSpriteNode {
     func startAd() {}
}
*/
