//
//  TextureHelper.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/5/4.
//

import SpriteKit
import UIKit

class TextureHelper {

    private static var hand1Textures: [SKTexture] = []
    private static var hand2Textures: [SKTexture] = []
    private static var hand3Textures: [SKTexture] = []

    static var cat1Textures: [SKTexture] = []
    static var cat2Textures: [SKTexture] = []
    static var cat3Textures: [SKTexture] = []
    static var cat4Textures: [SKTexture] = []
    static var cat5Textures: [SKTexture] = []

    private static var hamsterInjure: SKTexture = SKTexture(imageNamed: "hamster_injure")
    private static var bgTexturesArray: [SKTexture] = (1...15).map { SKTexture(imageNamed: "bg\($0 < 10 ? "0\($0)" : "\($0)").jpg") }
    private static var timeTexturesArray: [SKTexture] = [
        SKTexture(imageNamed: "score0"),
        SKTexture(imageNamed: "score1"),
        SKTexture(imageNamed: "score2"),
        SKTexture(imageNamed: "score3"),
        SKTexture(imageNamed: "score4"),
        SKTexture(imageNamed: "score5"),
        SKTexture(imageNamed: "score6"),
        SKTexture(imageNamed: "score7"),
        SKTexture(imageNamed: "score8"),
        SKTexture(imageNamed: "score9"),
        SKTexture(imageNamed: "dot")
    ]

    private static var timeImagesArray: [UIImage] = [
        UIImage(named: "score0"), UIImage(named: "score1"), UIImage(named: "score2"),
        UIImage(named: "score3"), UIImage(named: "score4"), UIImage(named: "score5"),
        UIImage(named: "score6"), UIImage(named: "score7"), UIImage(named: "score8"),
        UIImage(named: "score9")
    ].compactMap { $0 }

    static func initCatTextures() {
        cat1Textures = (1...4).map { SKTexture(imageNamed: "cat01_\($0)") }
        cat2Textures = (1...4).map { SKTexture(imageNamed: "cat02_\($0)") }
        cat3Textures = (1...4).map { SKTexture(imageNamed: "cat03_\($0)") }
        cat4Textures = (1...4).map { SKTexture(imageNamed: "cat04_\($0)") }
        cat5Textures = (1...4).map { SKTexture(imageNamed: "cat05_\($0)") }
    }

    static func initHandTextures(sourceRect: CGRect, rows: Int, cols: Int) {
        hand1Textures = getTextures(from: "hand1", sourceRect: sourceRect, rows: rows, cols: cols)
        hand2Textures = getTextures(from: "hand2", sourceRect: sourceRect, rows: rows, cols: cols)
        hand3Textures = getTextures(from: "hand3", sourceRect: sourceRect, rows: rows, cols: cols)
    }

    static func getTextures(from spriteSheet: String, sourceRect: CGRect, rows: Int, cols: Int) -> [SKTexture] {
        guard let image = UIImage(named: spriteSheet), let cgImage = image.cgImage else { return [] }
        let ssTexture = SKTexture(image: UIImage(cgImage: cgImage))
        ssTexture.filteringMode = .nearest

        var frames: [SKTexture] = []
        var sx = sourceRect.origin.x
        var sy = sourceRect.origin.y
        let sWidth = sourceRect.size.width
        let sHeight = sourceRect.size.height

        for i in 0..<(rows * cols) {
            let rect = CGRect(x: sx, y: sy, width: sWidth / ssTexture.size().width, height: sHeight / ssTexture.size().height)
            let texture = SKTexture(rect: rect, in: ssTexture)
            frames.append(texture)

            sx += sWidth / ssTexture.size().width
            if (i + 1) % cols == 0 {
                sx = sourceRect.origin.x
                sy += sHeight / ssTexture.size().height
            }
        }
        return frames
    }

    static func getTextures(from spriteSheet: String, sourceRect: CGRect, rows: Int, cols: Int, sequence: [Int]) -> [SKTexture] {
        let allFrames = getTextures(from: spriteSheet, sourceRect: sourceRect, rows: rows, cols: cols)
        return sequence.compactMap { allFrames[safe: $0] }
    }

    static func hand1() -> [SKTexture] { hand1Textures }
    static func hand2() -> [SKTexture] { hand2Textures }
    static func hand3() -> [SKTexture] { hand3Textures }

    static func cat1() -> [SKTexture] { cat1Textures }
    static func cat2() -> [SKTexture] { cat2Textures }
    static func cat3() -> [SKTexture] { cat3Textures }
    static func cat4() -> [SKTexture] { cat4Textures }
    static func cat5() -> [SKTexture] { cat5Textures }

    static func backgrounds() -> [SKTexture] { bgTexturesArray }
    static func hamsterInjureTexture() -> SKTexture? { hamsterInjure }
    static func timeTextures() -> [SKTexture] { timeTexturesArray }
    static func timeImages() -> [UIImage] { timeImagesArray }
}

extension TextureHelper {
    /**
     Extracts an array of textures from a sprite sheet based on given dimensions and layout.

     - Parameters:
       - spriteSheet: The name of the image file containing the sprite sheet.
       - sourceRect: The starting rectangle (CGRect) within the sprite sheet to begin cutting textures.
                     This should be in the coordinate system of the original image (pixels).
       - rowNumberOfSprites: The number of rows of sprites in the sprite sheet.
       - colNumberOfSprites: The number of columns of sprites in the sprite sheet.
     - Returns: An array of `SKTexture` objects representing the individual sprites.
     */
    static func getTextures(
        withSpriteSheetNamed spriteSheet: String,
        sourceRect: CGRect,
        rowNumberOfSprites: Int,
        colNumberOfSprites: Int
    ) -> [SKTexture] {

        var animatingFrames: [SKTexture] = []

        let ssTexture = SKTexture(imageNamed: spriteSheet)
        // Makes the sprite (ssTexture) stay pixelated:
        ssTexture.filteringMode = .nearest

        var currentX = sourceRect.origin.x
        var currentY = sourceRect.origin.y
        let spriteWidth = sourceRect.size.width
        let spriteHeight = sourceRect.size.height

        // IMPORTANT: textureWithRect: uses a normalized coordinate system (0.0 to 1.0),
        // where 1.0 represents 100% of the texture's width or height.
        // This is why division by the original texture's size is necessary for the cutter rect.

        let normalizedSpriteWidth = spriteWidth / ssTexture.size().width
        let normalizedSpriteHeight = spriteHeight / ssTexture.size().height
        
        let normalizedStartX = currentX / ssTexture.size().width
        var normalizedCurrentY = currentY / ssTexture.size().height
        
        // Store the initial normalized X to reset for each row
        let initialNormalizedX = normalizedStartX

        for i in 0..<rowNumberOfSprites * colNumberOfSprites {
            let cutter = CGRect(
                x: currentX / ssTexture.size().width, // Convert pixel x to normalized x
                y: currentY / ssTexture.size().height, // Convert pixel y to normalized y
                width: normalizedSpriteWidth,
                height: normalizedSpriteHeight
            )
            
            let tempTexture = SKTexture(rect: cutter, in: ssTexture)
            animatingFrames.append(tempTexture)

            // Move to the next column's starting X
            currentX += spriteWidth

            // Check if we've completed a row
            if (i + 1) % colNumberOfSprites == 0 {
                // Reset X to the beginning of the source rectangle
                currentX = sourceRect.origin.x
                // Move Y down to the next row
                currentY += spriteHeight
            }
        }
        
        return animatingFrames
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
