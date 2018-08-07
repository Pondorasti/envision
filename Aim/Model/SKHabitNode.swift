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

/*
 
 circle scale = 2
    innerBubble
    label
 
 container
    circle scale = 2
    innerBubble scale = 1
    label
 
 */

class SKHabitNode: SKNode {
    var labelNode: SKLabelNode!
    
    var mainShapeNode = SKShapeNode()
    var temporaryShapeNode: SKShapeNode? = nil
    
    var animationStartingTime: TimeInterval?
    var animationEndTime: TimeInterval?
    var nodeToConnect: SKShapeNode?
    var delegate: SKHabitNodeDelegate?
    
    let animationDuration: TimeInterval = 0.45
    let maxWidth: CGFloat
    let minWidth: CGFloat
    let increment: CGFloat
    let habit: Habit
    
    var nextWidth: CGFloat {
        return mainShapeNode.frame.width + increment
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
        
        setUpMainNode()
        setUpLabel()
        
        name = habit.name
        zPosition = 1
        
        let center = skView.center
        let startX = Int(center.x - 50)
        let endX = Int(center.x + 50)
        let startY = Int(center.y - 50)
        let endY = Int(center.y + 50)
        position = CGPoint.randomPoint(inXRange: startX...endX, andYRange: startY...endY)
        
        setUpPhysicsBody()
        addChild(labelNode)
        addChild(mainShapeNode)
    }
    
    public func updateHabit(for state: inout BeautyAnimation, in currentTime: TimeInterval) {
        switch state {
        case .expand:
            if let endTime = animationEndTime {
                if endTime <= currentTime {
                    state = .none
                    animationStartingTime = nil
                    
                    let newLog = CoreDataHelper.newLog()
                    newLog.day = Date()
                    CoreDataHelper.linkLog(newLog, to: habit)
                    
                    self.removeAllActions()
                    
                    if habit.iteration <= 49 {
                        mainShapeNode.run(SKAction.scale(by: nextWidth / mainShapeNode.frame.width, duration: 0))
                        setUpPhysicsBody()
                        createSpringJoint()
                    }
                    
                    temporaryShapeNode?.removeFromParent()
                    delegate?.didHabitNodeExpand(self)
                    updateLabel()
                }
            }
        case .shrink:
            if let endTime = animationEndTime {
                if endTime <= currentTime {
                    state = .none
                    animationStartingTime = nil
                    
                    self.removeAllActions()
                    temporaryShapeNode?.removeFromParent()
                }
            }
        case .none:
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
                
                setUpTemporaryNode()
                self.addChild(temporaryShapeNode!)
            }
            
            state = .expand
            animationStartingTime = currentTime
            animationEndTime = duration + currentTime
            
            temporaryShapeNode?.run(SKAction.scale(to: (mainShapeNode.frame.width + increment) / 0.2, duration: duration))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SKHabitNode {
    private func setUpPhysicsBody() {
        physicsBody = SKPhysicsBody(circleOfRadius:  mainShapeNode.frame.width / 2 + 0.1)
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.3
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 1
        physicsBody?.contactTestBitMask = 1
    }
    
    private func setUpLabel() {
        labelNode = SKLabelNode(fontNamed: "Avenir")
        labelNode.name = "Label"
        labelNode.text = (habit.isGood ? "" : "🚫") + habit.name + "\nStreak: \(habit.streak)"
        labelNode.position = self.position
        labelNode.fontColor = habit.isDoneToday ? Constant.Layer.habitTextColor : Constant.Layer.backgroundColor
        labelNode.fontSize = 12
        labelNode.numberOfLines = 2
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.preferredMaxLayoutWidth = frame.width * 0.75
        labelNode.zPosition = 5
    }
    
    private func setUpMainNode() {
        mainShapeNode = SKShapeNode(circleOfRadius: (minWidth + increment * CGFloat(habit.iteration)) / 2)
        
        mainShapeNode.lineWidth = 0.1
        mainShapeNode.strokeColor = habit.color
        mainShapeNode.fillColor = habit.color
        mainShapeNode.alpha = 1
        mainShapeNode.name = habit.name
        mainShapeNode.zPosition = 2
        mainShapeNode.position = CGPoint(x: 0, y: 0)
    }
    
    private func setUpTemporaryNode() {
        temporaryShapeNode = SKShapeNode(circleOfRadius: 0.1)
        temporaryShapeNode?.lineWidth = 0
        temporaryShapeNode?.strokeColor = #colorLiteral(red: 0.1568627451, green: 0.368627451, blue: 0.5137254902, alpha: 0)
        temporaryShapeNode?.fillColor = habit.color.lighter(by: 20) ?? UIColor.white
        temporaryShapeNode?.alpha = 0.5
        temporaryShapeNode?.name = "temp"
        temporaryShapeNode?.zPosition = 2
    }
    
    public func updateLabel() {
        labelNode.text = (habit.isGood ? "" : "🚫") + habit.name + "\nStreak: \(habit.streak)"
        labelNode.fontColor = habit.isDoneToday ? Constant.Layer.habitTextColor : Constant.Layer.backgroundColor
    }
    
    public func connectSpringJoint(to node: SKShapeNode) {
        nodeToConnect = node
        createSpringJoint()
    }
    
    private func createSpringJoint() {
        guard let myPhysicsBody = physicsBody,
            let nodePhysicsBody = nodeToConnect?.physicsBody,
            let nodePosition = nodeToConnect?.position else { return }
        
        let springJoint = SKPhysicsJointSpring.joint(withBodyA: myPhysicsBody, bodyB: nodePhysicsBody, anchorA: position, anchorB: nodePosition)
        springJoint.frequency = 0.5
        springJoint.damping = 0.3
        scene?.physicsWorld.add(springJoint)
    }
    
}

protocol SKHabitNodeDelegate {
    func didHabitNodeExpand(_ habitNode: SKHabitNode)
}
