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
    var touchNode = SKSpriteNode()
    
    var habitsDelegate: HabitsSceneDelegate?
    var selectedHabitNode: SKHabitNode?
    var touchJoint: SKPhysicsJointLimit?
    var animationState = SKHabitNode.BeautyAnimation.none
    
    override func didMove(to view: SKView) {
        setUpMiddleNode(in: view)
        addChild(middleNode)
        
        touchNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 25, height: 25))
        touchNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: 25))
        touchNode.physicsBody?.collisionBitMask = 11
        
        addChild(touchNode)
        
        
        let viewBorder = SKPhysicsBody(edgeLoopFrom: view.bounds)
        viewBorder.collisionBitMask = 1
        viewBorder.friction = 0
        self.physicsBody = viewBorder
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
//        showDebugger()
        
        let doubleTapGesture = UITapGestureRecognizer()
        
        doubleTapGesture.numberOfTapsRequired = 1
        doubleTapGesture.numberOfTouchesRequired = 2
        doubleTapGesture.cancelsTouchesInView = true
        
        doubleTapGesture.addTarget(self, action: #selector(handleDoubleTap))
        
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTap(_ sender: UIGestureRecognizer) {
        let location = sender.location(in: view)
        
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
        if let status = selectedHabitNode?.habit.isDoneToday, !status {
            selectedHabitNode?.updateHabit(for: &animationState, in: currentTime)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touches.count == 1 else { return }
        let location = touch.location(in: self)
        
        if let body = physicsWorld.body(at: location) {
            if let habitNode = body.node as? SKHabitNode {
                selectedHabitNode = habitNode
                animationState = .startingToExpand
                
                if let status = selectedHabitNode?.habit.isDoneToday, status {
                    selectedHabitNode?.springJoint.damping = 0
                    selectedHabitNode?.springJoint.frequency = 0.00001
                    touchNode.position = location
                    
                    touchJoint = SKPhysicsJointLimit.joint(withBodyA: touchNode.physicsBody!, bodyB: habitNode.physicsBody!, anchorA: location, anchorB: location)
                    
                    
                    touchJoint?.maxLength = 0
                    physicsWorld.add(touchJoint!)
                }
                
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let status = selectedHabitNode?.habit.isDoneToday, status {
            for touch in touches {
                let location = touch.location(in: self)
                touchNode.position = location
            }
            return
        }

        if let body = physicsWorld.body(at: location) {
            if selectedHabitNode != body.node as? SKHabitNode {
                animationState = .startingToShrink
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        animationState = .startingToShrink
        
        if let touchJoint = touchJoint {
            selectedHabitNode?.springJoint.damping = 0.3
            selectedHabitNode?.springJoint.frequency = 0.5
            physicsWorld.remove(touchJoint)
        }
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
                
                nodeToPush.physicsBody?.applyImpulse(CGVector(dx: direction.x * mass * Constant.SpriteKit.force, dy: direction.y * mass * Constant.SpriteKit.force))
            }
        }
    }
}


extension HabitsScene: SKPhysicsContactDelegate {
//    func didBegin(_ contact: SKPhysicsContact) {
//        var firstBody: SKPhysicsBody
//        var secondBody: SKPhysicsBody
//
//        if contact.bodyA.node?.name == selectedHabitNode?.name {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//
//            if let bodyAPosition = firstBody.node?.position, let bodyBPosition = secondBody.node?.position {
//                let offset = bodyBPosition - bodyAPosition
//                let direction = offset.normalized()
//
//                secondBody.applyImpulse(CGVector(dx: direction.x * 50, dy: direction.y * 50))
//            }
//        } else if contact.bodyB.node?.name == selectedHabitNode?.name {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//
//            if let bodyAPosition = firstBody.node?.position, let bodyBPosition = secondBody.node?.position {
//                let offset = bodyBPosition - bodyAPosition
//                let direction = offset.normalized()
//
//                secondBody.applyImpulse(CGVector(dx: direction.x * 50, dy: direction.y * 50))
//            }
//        }
//    }
}

extension HabitsScene {
    private func setUpMiddleNode(in view: SKView) {
        middleNode = SKShapeNode(circleOfRadius: 1)
        middleNode.position = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        middleNode.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        middleNode.physicsBody?.collisionBitMask = 10
        
        middleNode.physicsBody?.isDynamic = false
        
        middleNode.name = "helper"
    }
    
    private func showDebugger() {
        self.view?.showsPhysics = true
        self.view?.showsNodeCount = true
        self.view?.showsFPS = true
    }
}

protocol HabitsSceneDelegate: class {
    func didDoubleTapHabit(_ habitNode: SKHabitNode)
}


