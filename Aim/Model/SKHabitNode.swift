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
    
    private let labelNode: SKLabelNode = {
        let label = SKLabelNode()
        label.name = "Label"

        label.numberOfLines = 2
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 5

        return label
    }()
    
    var mainShapeNode = SKShapeNode()
    var springJoint = SKPhysicsJointSpring()
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
        
//        isUserInteractionEnabled = true
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
                    
                    habit.wasCompletedToday = true
                    temporaryShapeNode?.removeFromParent()
                    delegate?.didHabitNodeExpand(self, withFeedback: true)
                    updateLabelAttributedString()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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

        labelNode.preferredMaxLayoutWidth = frame.width * 0.75
        labelNode.position = self.position

        updateLabelAttributedString()
    }

    private func setUpMainNode() {
        mainShapeNode = SKShapeNode(circleOfRadius: (minWidth + increment * CGFloat(habit.iteration)) / 2)

        mainShapeNode.position = CGPoint(x: 0, y: 0)
        mainShapeNode.lineWidth = 0.1
        mainShapeNode.alpha = 1
        mainShapeNode.zPosition = 2

        mainShapeNode.strokeColor = habit.color
        mainShapeNode.fillColor = habit.color
        mainShapeNode.name = habit.name
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
    
    public func updateLabelAttributedString() {
        let italicsFont = UIFont.italicSystemFont(ofSize: 12)
        let boldFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)

        let foregroundColor = habit.wasCompletedToday ? Constant.Layer.habitTextColor : Constant.Layer.backgroundColor
        let headlineAttributes = [NSAttributedStringKey.foregroundColor: foregroundColor,
                                  NSAttributedStringKey.font: boldFont]
        let subheadlineAttributes = [NSAttributedStringKey.foregroundColor: foregroundColor,
                                     NSAttributedStringKey.font: italicsFont]

        let headlineAttributedString = NSAttributedString(
            string: (habit.isGood ? "" : "🚫") + habit.name, attributes: headlineAttributes)
        let subheadlineAttributedString = NSAttributedString(
            string: "\nStreak: \(habit.retrieveStreakInfo().current)", attributes: subheadlineAttributes)

        let result = NSMutableAttributedString()
        result.append(headlineAttributedString)
        result.append(subheadlineAttributedString)

        labelNode.attributedText = result
    }
    
    public func connectSpringJoint(to node: SKShapeNode) {
        nodeToConnect = node
        createSpringJoint()
    }
    
    private func createSpringJoint() {
        guard let myPhysicsBody = physicsBody,
            let nodePhysicsBody = nodeToConnect?.physicsBody,
            let nodePosition = nodeToConnect?.position else { return }
        
        springJoint = SKPhysicsJointSpring.joint(withBodyA: myPhysicsBody,
                                                 bodyB: nodePhysicsBody,
                                                 anchorA: position,
                                                 anchorB: nodePosition)
        
        springJoint.frequency = Constant.SpriteKit.magicFrequency
        springJoint.damping = Constant.SpriteKit.magicDamping
        
        scene?.physicsWorld.add(springJoint)
    }
}

// MARK: - SKHabitNodeDelegate
protocol SKHabitNodeDelegate {
    func didHabitNodeExpand(_ habitNode: SKHabitNode, withFeedback useFeedback: Bool)
}
