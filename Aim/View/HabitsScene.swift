//
//  HabitsScene.swift
//  Aim
//
//  Created by Alexandru Turcanu on 23/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit
import TapticEngine

class HabitsScene: SKScene {
    // MARK: - Properties
    private(set) var middleNode: SKShapeNode!

    private var ignoreNextDoubleTap = false
    var viewBorder = SKPhysicsBody()
    
    var habitsDelegate: HabitsSceneDelegate?
    var selectedHabitNode: SKHabitNode?
    var touchJoint: SKPhysicsJointLimit?
    var animationState = SKHabitNode.BeautyAnimation.none
    var lastTouchLocation: CGPoint?
    var touchOffset: CGPoint?

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setUpMiddleNode(in: view)
        if let node = middleNode {
            addChild(node)
        } else {
            fatalError("Could not find middleNode")
        }

        viewBorder = SKPhysicsBody(edgeLoopFrom: view.bounds)
        viewBorder.collisionBitMask = 1
        viewBorder.friction = 0
        viewBorder.usesPreciseCollisionDetection = true

        name = "borderView"
        physicsBody = viewBorder
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
//        showDebugger()

        configureGestureRecognizers(in: view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let selectedHabitNode = selectedHabitNode {
            if !selectedHabitNode.habit.wasCompletedToday {
                selectedHabitNode.updateHabit(for: &animationState, in: currentTime)
            } else if let touchOffset = touchOffset,
                let touchLocation = lastTouchLocation,
                let viewFrame = view?.frame,
                viewFrame.contains(touchOffset + touchLocation) {
                selectedHabitNode.position = touchLocation + touchOffset
            }
        }
        
        if animationState == .startingToShrink || animationState == .none {
            deselectHabitNode()
        }
    }

    // MARK: - Input Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touches.count == 1 else { return }
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        
        if let body = physicsWorld.body(at: touchLocation) {
            if let habitNode = body.node as? SKHabitNode {
                selectedHabitNode = habitNode
                animationState = .startingToExpand
                
                if let status = selectedHabitNode?.habit.wasCompletedToday, status {
                    selectedHabitNode?.springJoint.damping = 0
                    selectedHabitNode?.springJoint.frequency = 0.00001
            
                    touchOffset = selectedHabitNode!.position - touchLocation
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touches.count == 1 else { return }
        
        if let status = selectedHabitNode?.habit.wasCompletedToday, status {
            for touch in touches {
                let touchLocation = touch.location(in: self)
                lastTouchLocation = touchLocation
            }
            return
        }
        
        let touchLocation = touch.location(in: self)
        if let body = physicsWorld.body(at: touchLocation) {
            if selectedHabitNode != body.node as? SKHabitNode {
                animationState = .startingToShrink
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        animationState = .startingToShrink
        
        selectedHabitNode?.springJoint.damping = Constant.SpriteKit.magicDamping
        selectedHabitNode?.springJoint.frequency = Constant.SpriteKit.magicFrequency
    }

    // MARK: - Methods
    public func createHabitBubble(_ habit: Habit, in skview: SKView) {
        let habit = SKHabitNode(for: habit, in: skview)
        habit.delegate = self
        habit.delegate?.shakeHabitNodes(from: habit, withFeedback: false)
        
        addChild(habit)
        habit.connectSpringJoint(to: middleNode)
    }

    @objc private func handleDoubleTap(_ sender: UIGestureRecognizer) {
        guard !ignoreNextDoubleTap else {
            ignoreNextDoubleTap = false
            return
        }

        let location = sender.location(in: view)
        if let height = view?.frame.height {
            let doubleTouchedPoint = location.normalizeFromSpriteKitToUIKit(frameHeight: height)

            animationState = .startingToShrink
            if let body = physicsWorld.body(at: doubleTouchedPoint) {
                if let habitNode = body.node as? SKHabitNode {
                    habitsDelegate?.didDoubleTapHabit(habitNode)
                    animationState = .startingToShrink
                }
            }
        }
    }

    private func configureGestureRecognizers(in view: SKView) {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTouchesRequired = 2

        view.addGestureRecognizer(singleTapGesture)
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(doubleTapGesture)
    }
}

// MARK: - SKHabitNodeDelegate
extension HabitsScene: SKHabitNodeDelegate {
    func shakeHabitNodes(from mainNode: SKNode, withFeedback useFeedback: Bool) {

        if useFeedback {
            TapticEngine.notification.feedback(.success)
        }
        
        for child in self.children {
            if let nodeToPush = child as? SKHabitNode, nodeToPush.name != mainNode.name, let mass = nodeToPush.physicsBody?.mass {
                let offset = nodeToPush.position - mainNode.position
                let direction = offset.normalized()
                
                nodeToPush.physicsBody?.applyImpulse(CGVector(dx: direction.x * mass * Constant.SpriteKit.expandForce, dy: direction.y * mass * Constant.SpriteKit.expandForce))
            }
        }
    }

    func nodeDidExpand() {
        ignoreNextDoubleTap = true
    }
}

extension HabitsScene: SKPhysicsContactDelegate {
    
    //TODO: Fix this junk
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let wasCompleted = selectedHabitNode?.habit.wasCompletedToday, !wasCompleted {
            return
        }
        
        if let middleNodePhysicsBody = middleNode.physicsBody,
            contact.bodyA.node?.name == "borderView" {
            
            nodeTouched(middleNodePhysicsBody, withSecondBody: contact.bodyB, pushWithForce: Constant.SpriteKit.wallForce)
            
        } else if let middleNodePhysicsBody = middleNode.physicsBody,
            contact.bodyB.node?.name == "borderView" {

            nodeTouched(middleNodePhysicsBody, withSecondBody: contact.bodyA, pushWithForce: Constant.SpriteKit.wallForce)

        } else if contact.bodyA.node?.name == selectedHabitNode?.name {
            
            nodeTouched(contact.bodyA, withSecondBody: contact.bodyB, pushWithForce: Constant.SpriteKit.expandForce)
            
        } else if contact.bodyB.node?.name == selectedHabitNode?.name {
            
            nodeTouched(contact.bodyB, withSecondBody: contact.bodyA, pushWithForce: Constant.SpriteKit.expandForce)
            
        }
    }
}

extension HabitsScene {
    private func nodeTouched(_ firstBody: SKPhysicsBody, withSecondBody secondBody: SKPhysicsBody, pushWithForce force: CGFloat) {
        if let bodyAPosition = firstBody.node?.position, let bodyBPosition = secondBody.node?.position {
            let offset = bodyBPosition - bodyAPosition
            let direction = offset.normalized()
            
            secondBody.applyImpulse(CGVector(dx: direction.x * force * secondBody.mass, dy: direction.y * force * secondBody.mass))
        }
    }
    
    private func setUpMiddleNode(in view: SKView) {
        middleNode = SKShapeNode(circleOfRadius: 1)
        middleNode.position = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        middleNode.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        middleNode.physicsBody?.collisionBitMask = 10
        middleNode.fillColor = Constant.Layer.backgroundColor
        middleNode.strokeColor = Constant.Layer.backgroundColor
        
        middleNode.physicsBody?.isDynamic = false
        
        middleNode.name = "helper"
    }
    
    private func showDebugger() {
        self.view?.showsPhysics = true
        self.view?.showsNodeCount = true
        self.view?.showsFPS = true
    }
    
    private func deselectHabitNode() {
        selectedHabitNode?.springJoint.damping = Constant.SpriteKit.magicDamping
        selectedHabitNode?.springJoint.frequency = Constant.SpriteKit.magicFrequency
        selectedHabitNode = nil
    }
}

// MARK: - HabitsSceneDelegate
protocol HabitsSceneDelegate: class {
    func didDoubleTapHabit(_ habitNode: SKHabitNode)
}

