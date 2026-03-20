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

        let bladePath = CGMutablePath()
        bladePath.move(to: CGPoint(x: 0, y: -25))
        bladePath.addLine(to: CGPoint(x: 0, y: 25))

        let tip = SKShapeNode(path: bladePath)
        tip.strokeColor = .clear
        tip.lineWidth = 0
        tip.glowWidth = 0
        tip.zPosition = 10
        addChild(tip)

        let emitter = createEmitterNode(color: color)
        emitter.targetNode = targetNode
        emitter.zPosition = 0
        tip.addChild(emitter)


    }

    // Required initializer for decoding (often added by Xcode automatically, good practice to include)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Method to set up physics
    func enablePhysics(categoryBitmask category: UInt32, contactTestBitmask contact: UInt32, collisionBitmask collision: UInt32) {
        physicsBody = SKPhysicsBody(circleOfRadius: 8)
        physicsBody?.categoryBitMask = category
        physicsBody?.contactTestBitMask = contact
        physicsBody?.collisionBitMask = collision
        physicsBody?.isDynamic = false // Use 'isDynamic' and 'false' in Swift
    }

    private func createEmitterNode(color: UIColor) -> SKEmitterNode {
        let emitterNode = SKEmitterNode()

        let sparkTexture = SKTexture(imageNamed: "spark.png")
        emitterNode.particleTexture = sparkTexture

        emitterNode.particleBirthRate = 220

        emitterNode.particleLifetime = 0.12
        emitterNode.particleLifetimeRange = 0.04

        emitterNode.particlePositionRange = CGVector(dx: 2.0, dy: 2.0)

        emitterNode.particleSpeed = 8.0
        emitterNode.particleSpeedRange = 4.0

        emitterNode.particleAlpha = 0.9
        emitterNode.particleAlphaRange = 0.1
        emitterNode.particleAlphaSpeed = -1.8

        emitterNode.particleScale = 0.08
        emitterNode.particleScaleRange = 0.03
        emitterNode.particleScaleSpeed = -0.25

        emitterNode.particleRotation = 0
        emitterNode.particleRotationRange = .pi
        emitterNode.particleRotationSpeed = 1.5

        emitterNode.particleColorBlendFactor = 1
        emitterNode.particleColorBlendFactorRange = 0
        emitterNode.particleColorBlendFactorSpeed = 0

        emitterNode.particleColor = color
        emitterNode.particleBlendMode = .add

        return emitterNode
    }
}
