//
//  SKHabitNode.swift
//  Aim
//
//  Created by Alexandru Turcanu on 31/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit
import CoreGraphics

class SKHabitNode: SKShapeNode {
    var label: SKLabelNode!
    let temporaryShapeNode: SKShapeNode? = nil
    
    let maxWidth: CGFloat
    let minWidth: CGFloat
    let multiplier: CGFloat
    
    init(for habit: Habit, in skView: SKView) {
        maxWidth = 0.45 * skView.frame.width
        minWidth = 0.407 * maxWidth
        multiplier = (maxWidth - minWidth) / 50
        
        super.init()
        
        self.path = SKShapeNode(circleOfRadius: minWidth / 2).path
        
        lineWidth = 0.1
        strokeColor = habit.color ?? UIColor.purple
        fillColor = habit.color ?? UIColor.purple
        name = habit.name
        
        label = SKLabelNode(fontNamed: "Avenir")
        label.name = "Label"
        label.text = habit.name
        label.position = self.position
        label.fontColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
        label.fontSize = 18
        label.numberOfLines = 2
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.preferredMaxLayoutWidth = frame.width * 0.75
        label.zPosition = 5
        
        zPosition = 1
        position = skView.center
        
        physicsBody = SKPhysicsBody(circleOfRadius: minWidth / 2)
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.3
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 1
        physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(label)
        
        if let middleNode = childNode(withName: "helper") as? SKShapeNode {
            let spring = SKPhysicsJointSpring.joint(withBodyA: self.physicsBody!, bodyB: middleNode.physicsBody!, anchorA: self.position, anchorB: middleNode.position)
            spring.frequency = 0.5
            spring.damping = 0.3
            scene?.physicsWorld.add(spring)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
