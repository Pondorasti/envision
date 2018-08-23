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
    
    var middleNode = SKShapeNode()
    
    var habitsDelegate: HabitsSceneDelegate?
    var selectedHabitNode: SKHabitNode?
    var touchJoint: SKPhysicsJointLimit?
    var animationState = SKHabitNode.BeautyAnimation.none
    var lastTouchLocation: CGPoint?
    var touchOffset: CGPoint?
    
    override func didMove(to view: SKView) {
        setUpMiddleNode(in: view)
        addChild(middleNode)
        
        let viewBorder = SKPhysicsBody(edgeLoopFrom: view.bounds)
        viewBorder.collisionBitMask = 1
        viewBorder.friction = 0
        self.physicsBody = viewBorder
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        showDebugger()
        
        let doubleTapGesture = UITapGestureRecognizer()
        
        doubleTapGesture.numberOfTapsRequired = 1
        doubleTapGesture.numberOfTouchesRequired = 2
        doubleTapGesture.cancelsTouchesInView = true
        
        doubleTapGesture.addTarget(self, action: #selector(handleDoubleTap))
        
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTap(_ sender: UIGestureRecognizer) {
        let location = sender.location(in: view)
        deselectHabitNode()
        
        if let height = view?.frame.height {
            let x = location.x
            let y = (location.y - height) < 0 ? (location.y - height) * (-1) : (location.y - height)
            let doubleTouchedPoint = CGPoint(x: x, y: y)
            
            animationState = .startingToShrink
            if let body = physicsWorld.body(at: doubleTouchedPoint) {
                if let habitNode = body.node as? SKHabitNode {
                    habitsDelegate?.didDoubleTapHabit(habitNode)
                    animationState = .startingToShrink
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if let selectedHabitNode = selectedHabitNode {
            if !selectedHabitNode.habit.wasCompletedToday {
                selectedHabitNode.updateHabit(for: &animationState, in: currentTime)
            } else if let touchOffset = touchOffset, let touchLocation = lastTouchLocation {
                selectedHabitNode.position = touchLocation + touchOffset
            }

        }
        
        if animationState == .startingToShrink || animationState == .none {
            deselectHabitNode()
        }
    }
    
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
        guard let touch = touches.first else { return }
        
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
    
    public func createHabitBubble(_ habit: Habit, in skview: SKView) {
        let habit = SKHabitNode(for: habit, in: skview)
        habit.delegate = self
        habit.delegate?.didHabitNodeExpand(habit)
        addChild(habit)
        habit.connectSpringJoint(to: middleNode)
    }
}

extension HabitsScene: SKHabitNodeDelegate {
    func didHabitNodeExpand(_ habitNode: SKHabitNode) {
        
        TapticEngine.notification.feedback(.success)
        for child in self.children {
            if let nodeToPush = child as? SKHabitNode, nodeToPush.name != habitNode.name, let mass = nodeToPush.physicsBody?.mass {
                let offset = nodeToPush.position - habitNode.position
                let direction = offset.normalized()
                
                nodeToPush.physicsBody?.applyImpulse(CGVector(dx: direction.x * mass * Constant.SpriteKit.expandForce, dy: direction.y * mass * Constant.SpriteKit.expandForce))
            }
        }
    }
}


extension HabitsScene: SKPhysicsContactDelegate {
    
    //TODO: Fix this junk
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let wasCompleted = selectedHabitNode?.habit.wasCompletedToday, !wasCompleted {
            return
        }
        
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.node?.name == selectedHabitNode?.name {
            firstBody = contact.bodyA
            secondBody = contact.bodyB

            if let bodyAPosition = firstBody.node?.position, let bodyBPosition = secondBody.node?.position {
                let offset = bodyBPosition - bodyAPosition
                let direction = offset.normalized()

                secondBody.applyImpulse(CGVector(dx: direction.x * Constant.SpriteKit.expandForce * secondBody.mass, dy: direction.y * Constant.SpriteKit.expandForce * secondBody.mass))
            }
        } else if contact.bodyB.node?.name == selectedHabitNode?.name {
            firstBody = contact.bodyB
            secondBody = contact.bodyA

            if let bodyAPosition = firstBody.node?.position, let bodyBPosition = secondBody.node?.position {
                let offset = bodyBPosition - bodyAPosition
                let direction = offset.normalized()
                
                secondBody.applyImpulse(CGVector(dx: direction.x * Constant.SpriteKit.expandForce * secondBody.mass, dy: direction.y * Constant.SpriteKit.expandForce * secondBody.mass))
            }
        }
    }
}

extension HabitsScene {
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

protocol HabitsSceneDelegate: class {
    func didDoubleTapHabit(_ habitNode: SKHabitNode)
}

