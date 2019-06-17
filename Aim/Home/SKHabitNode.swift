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
import NotificationBannerSwift

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
    // MARK: - Properties
    private let labelNode: SKLabelNode = {
        let label = SKLabelNode()
        label.name = "Label"

        label.numberOfLines = 3
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 5

        return label
    }()
    
    private let mainShapeNode: SKShapeNode = {
        let shapeNode = SKShapeNode()

        shapeNode.position = CGPoint(x: 0, y: 0)
        shapeNode.lineWidth = 0.1
        shapeNode.alpha = 1
        shapeNode.zPosition = 2

        return shapeNode
    }()

    private lazy var negativeLine: SKShapeNode = {
        let line = SKShapeNode(rectOf: CGSize(width: negativeWidth, height: diameter))

        line.fillColor = color
        line.lineWidth = 0
        line.zRotation = CGFloat.pi / 4

        return line
    }()

    private lazy var circularBorder: SKShapeNode = {
        let node = SKShapeNode()

        let path: CGMutablePath = CGMutablePath()
        path.addArc(
            center: CGPoint.zero,
            radius: (diameter - negativeWidth) / 2,
            startAngle: 0.0,
            endAngle: CGFloat(2.0 * Double.pi),
            clockwise: false
        )

        node.path = path
        node.fillColor = UIColor.clear
        node.lineWidth = negativeWidth
        node.strokeColor = color
        node.zPosition = 1

        return node
    }()

    private lazy var temporaryShapeNode: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 0.1)

        node.lineWidth = 0
        node.strokeColor = #colorLiteral(red: 0.1568627451, green: 0.368627451, blue: 0.5137254902, alpha: 0)
        node.fillColor = habit.color.lighter(by: 90) ?? UIColor.white
        node.alpha = 0.5
        node.name = "temp"
        node.zPosition = 2

        return node
    }()

    private var animationStartingTime: TimeInterval?
    private var animationEndTime: TimeInterval?
    private var nodeToConnect: SKShapeNode?

    private let maxWidth: CGFloat
    private let minWidth: CGFloat
    private let increment: CGFloat

    private let negativeWidth: CGFloat = 6
    private let color = #colorLiteral(red: 0.8078431373, green: 0.8274509804, blue: 0.862745098, alpha: 1)

    var delegate: SKHabitNodeDelegate?
    var springJoint = SKPhysicsJointSpring()

    let habit: Habit
    let animationDuration: TimeInterval = 0.45
    
    private var nextWidth: CGFloat {
        return mainShapeNode.frame.width + increment
    }

    private var diameter: CGFloat {
        return minWidth + increment * CGFloat(habit.iteration)
    }
    
    public enum BeautyAnimation {
        case expand, shrink, none, startingToShrink, startingToExpand
    }

    // MARK: - Initializers
    init(for habit: Habit, in skView: SKView) {
        maxWidth = 0.45 * skView.frame.width
        minWidth = 0.475 * maxWidth
        increment = (maxWidth - minWidth) / CGFloat(Constant.Habit.maxIteration)

        self.habit = habit
        
        super.init()
        
        setUpMainNode()
        configureLabel()
        configureNegativeShapeIfNeeded(!habit.isGood)
        updateLabelAttributedString()

        configurePhysicsBody()

        name = habit.name
        zPosition = 1
        
        let center = skView.center
        let startX = Int(center.x - 50)
        let endX = Int(center.x + 50)
        let startY = Int(center.y - 50)
        let endY = Int(center.y + 50)
        position = CGPoint.randomPoint(inXRange: startX...endX, andYRange: startY...endY)

        addChild(mainShapeNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Updates
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
                    
                    if habit.iteration <= Constant.Habit.maxIteration - 1 {
                        mainShapeNode.run(SKAction.scale(by: nextWidth / mainShapeNode.frame.width, duration: 0))
                        configurePhysicsBody()
                        createSpringJoint()
                    }
                    
                    habit.wasCompletedToday = true
                    temporaryShapeNode.removeFromParent()
                    delegate?.shakeHabitNodes(from: self, withFeedback: true)
                    updateLabelAttributedString()

                    let title: String
                    let subtitle: String
                    if habit.isGood {
                        title = "Positive habit completed!"
                        subtitle = "Great job, streak increased."
                    } else {
                        title = "Negative habit completed..."
                        subtitle = "Better luck tomorrow, streak lost."
                    }

                    let banner = NotificationBanner(customView: NotificationView(title: title, subtitle: subtitle))
                    banner.show()

                    delegate?.nodeDidExpand()
                }
            }
        case .shrink:
            if let endTime = animationEndTime {
                if endTime <= currentTime {
                    state = .none
                    animationStartingTime = nil
                    
                    self.removeAllActions()
                    temporaryShapeNode.removeFromParent()
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
                temporaryShapeNode.run(scaleAction)
            }
        case .startingToExpand:
            var duration = animationDuration
            if let startingtime = animationStartingTime {
                duration = animationDuration - (currentTime - startingtime)
                self.removeAllActions()
            } else {
                duration = animationDuration

                //reset node
                temporaryShapeNode.run(SKAction.scale(to: 1, duration: 0))

                self.addChild(temporaryShapeNode)
            }
            
            state = .expand
            animationStartingTime = currentTime
            animationEndTime = duration + currentTime
            
            temporaryShapeNode.run(SKAction.scale(to: (mainShapeNode.frame.width + increment) / 0.2, duration: duration))
        }
    }

    public func updateLabelAttributedString() {
        let italicsFont = UIFont.italicSystemFont(ofSize: 12)
        let boldFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)

        let foregroundColor = habit.wasCompletedToday ? Constant.Layer.habitTextColor : Constant.Layer.backgroundColor
        let headlineAttributes = [NSAttributedString.Key.foregroundColor: foregroundColor,
                                  NSAttributedString.Key.font: boldFont]
        let subheadlineAttributes = [NSAttributedString.Key.foregroundColor: foregroundColor,
                                     NSAttributedString.Key.font: italicsFont]

        let headlineAttributedString = NSAttributedString(
            string: habit.name,
            attributes: headlineAttributes
        )

        // retrieveStreakInfo when increasing the streak by 1, ex: just completed habit not effiecient, and creates lag
        let subheadlineAttributedString = NSAttributedString(
            string: "\nStreak: \(habit.retrieveStreakInfo().current)",
            attributes: subheadlineAttributes
        )

        let result = NSMutableAttributedString()
        result.append(headlineAttributedString)
        result.append(subheadlineAttributedString)

        labelNode.attributedText = result
    }

    // MARK: - Configures
    private func configurePhysicsBody() {
        physicsBody = SKPhysicsBody(circleOfRadius:  mainShapeNode.frame.width / 2 + 0.1)
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.3
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 1
        physicsBody?.contactTestBitMask = 1
    }

    private func configureLabel() {
        labelNode.preferredMaxLayoutWidth = diameter
        labelNode.position = self.position

        addChild(labelNode)
    }

    private func configureNegativeShapeIfNeeded(_ ifNeeded: Bool) {
        guard ifNeeded else {
            mainShapeNode.lineWidth = 0.1
            circularBorder.removeFromParent()
            return
        }

        mainShapeNode.lineWidth = 0.001
        mainShapeNode.strokeColor = color

        mainShapeNode.addChild(circularBorder)
        circularBorder.addChild(negativeLine)
    }

    private func setUpMainNode() {
        let path: CGMutablePath = CGMutablePath()
        path.addArc(
            center: CGPoint.zero,
            radius: diameter / 2,
            startAngle: 0.0,
            endAngle: CGFloat(2.0 * Double.pi),
            clockwise: false
        )

        mainShapeNode.path = path

        mainShapeNode.strokeColor = habit.color
        mainShapeNode.fillColor = habit.color
        mainShapeNode.name = habit.name
    }
}

extension SKHabitNode {
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
    func shakeHabitNodes(from mainNode: SKNode, withFeedback useFeedback: Bool)
    func nodeDidExpand()
}
