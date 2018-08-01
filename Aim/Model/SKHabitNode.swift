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
    
    var temporaryShapeNode: SKShapeNode? = nil
    var animationStartingTime: TimeInterval?
    var animationEndTime: TimeInterval?
    
    var counter = 0 {
        didSet {
            label.text = (habit.isGood ? "" : "🚫") + habit.name! + "\nStreak: \(counter)"
        }
    }
    
    let animationDuration: TimeInterval = 0.45
    
    let maxWidth: CGFloat
    let minWidth: CGFloat
    let increment: CGFloat
    let habit: Habit
    
    var nextWidth: CGFloat {
        return self.frame.width + increment
    }
    
    public enum BeautyAnimation {
        case expand, shrink, none, startingToShrink, startingToExpand
    }
    
    init(for habit: Habit, in skView: SKView) {
        maxWidth = 0.45 * skView.frame.width
        minWidth = 0.407 * maxWidth
        increment = (maxWidth - minWidth) / 50
        self.habit = habit
        
        super.init()
        
        self.path = SKShapeNode(circleOfRadius: minWidth / 2).path
        
        lineWidth = 0.1
        strokeColor = habit.color ?? UIColor.purple
        fillColor = habit.color ?? UIColor.purple
        name = habit.name
        
        label = SKLabelNode(fontNamed: "Avenir")
        label.name = "Label"
        label.text = (habit.isGood ? "" : "🚫") + habit.name! + "\nStreak: \(counter)"
        label.position = self.position
        label.fontColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
        label.fontSize = 12
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
    
    public func updateHabit(for state: inout BeautyAnimation, in currentTime: TimeInterval) {
//        print(state)
        switch state {
        case .expand:
            if let endTime = animationEndTime {
                if endTime <= currentTime {
                    state = .none
                    animationStartingTime = nil
                    counter += 1
                    
                    self.removeAllActions()
                    self.run(SKAction.scale(by: nextWidth / self.frame.width, duration: 0))
                    
                    temporaryShapeNode?.removeFromParent()
                }
            }
            
//            print("expanding")
        case .shrink:
            if let endTime = animationEndTime {
                if endTime <= currentTime {
                    state = .none
                    animationStartingTime = nil
                    
                    self.removeAllActions()
                    temporaryShapeNode?.removeFromParent()
                }
            }
            
//            print("shrinking")
        case .none:
//            print("standby")
            animationStartingTime = nil
        case .startingToShrink:
            state = .shrink
            
            if let startingTime = animationStartingTime {
                let duration = currentTime - startingTime
                animationStartingTime = currentTime
                animationEndTime = currentTime + duration
                
                self.removeAllActions()
                let scaleAction = SKAction.scale(to: 0.2, duration: duration)
                scaleAction.timingMode = .easeIn
                temporaryShapeNode?.run(scaleAction)
            }
            
        case .startingToExpand:
            var duration = animationDuration
            if let startingtime = animationStartingTime {
                duration = animationDuration - (currentTime - startingtime)
                self.removeAllActions()
            } else {
                duration = animationDuration
                
                temporaryShapeNode = SKShapeNode(circleOfRadius: 0.1)
                temporaryShapeNode?.lineWidth = 0.1
                temporaryShapeNode?.strokeColor = #colorLiteral(red: 0.1568627451, green: 0.368627451, blue: 0.5137254902, alpha: 0)
                temporaryShapeNode?.fillColor = #colorLiteral(red: 0.6705882353, green: 0.8509803922, blue: 0.9725490196, alpha: 0.5)
                temporaryShapeNode?.alpha = 0.5
                temporaryShapeNode?.name = "temp"
                temporaryShapeNode?.zPosition = 2
                
                self.addChild(temporaryShapeNode!)
            }
            
            state = .expand
            animationStartingTime = currentTime
            animationEndTime = duration + currentTime
            
            temporaryShapeNode?.run(SKAction.scale(to: (self.frame.width + increment) / 0.2, duration: duration))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//        ballSprite.physicsBody?.restitution = 0.5
//        ballSprite.physicsBody?.friction = 0.2
//        ballSprite.physicsBody?.angularDamping = 0
//        ballSprite.physicsBody?.mass = 0.5
