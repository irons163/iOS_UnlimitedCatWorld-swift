//
//  SKBlade.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/4/10.
//

import SpriteKit
import UIKit // Needed for UIColor

class SKBlade: SKNode {

    // Initializer
    init(position: CGPoint, targetNode: SKNode, color: UIColor) {
        // Call the superclass's designated initializer FIRST
        super.init()

        // Now set properties and add children
        self.position = position

        let tip = SKSpriteNode(color: color, size: CGSize(width: 25, height: 25))
        tip.zRotation = CGFloat.pi / 4.0 // More readable Swift way for 0.785398163
        tip.zPosition = 10
        addChild(tip)

        let emitter = createEmitterNode(color: color) // Use helper func
        emitter.targetNode = targetNode // Use the parameter name directly
        emitter.zPosition = 0
        tip.addChild(emitter)

        setScale(0.5)
    }

    // Required initializer for decoding (often added by Xcode automatically, good practice to include)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Method to set up physics
    func enablePhysics(categoryBitmask category: UInt32, contactTestBitmask contact: UInt32, collisionBitmask collision: UInt32) {
        physicsBody = SKPhysicsBody(circleOfRadius: 16)
        physicsBody?.categoryBitMask = category
        physicsBody?.contactTestBitMask = contact
        physicsBody?.collisionBitMask = collision
        physicsBody?.isDynamic = false // Use 'isDynamic' and 'false' in Swift
    }

    private func createEmitterNode(color: UIColor) -> SKEmitterNode {
        let emitterNode = SKEmitterNode()

        let sparkTexture = SKTexture(imageNamed: "spark.png")
        emitterNode.particleTexture = sparkTexture

        emitterNode.particleBirthRate = 3000

        emitterNode.particleLifetime = 0.2
        emitterNode.particleLifetimeRange = 0

        // Use CGVector(dx: dy:) initializer in Swift
        emitterNode.particlePositionRange = CGVector(dx: 0.0, dy: 0.0)

        emitterNode.particleSpeed = 0.0
        emitterNode.particleSpeedRange = 0.0

        emitterNode.particleAlpha = 0.8
        emitterNode.particleAlphaRange = 0.2
        emitterNode.particleAlphaSpeed = -0.45

        emitterNode.particleScale = 0.5
        emitterNode.particleScaleRange = 0.001
        emitterNode.particleScaleSpeed = -1

        emitterNode.particleRotation = 0
        emitterNode.particleRotationRange = 0
        emitterNode.particleRotationSpeed = 0

        emitterNode.particleColorBlendFactor = 1
        emitterNode.particleColorBlendFactorRange = 0
        emitterNode.particleColorBlendFactorSpeed = 0

        emitterNode.particleColor = color // Swift UIColor
        emitterNode.particleBlendMode = .add // Swift enum syntax

        return emitterNode
    }
}
