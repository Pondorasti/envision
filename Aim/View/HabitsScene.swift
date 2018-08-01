//
//  HabitsScene.swift
//  Aim
//
//  Created by Alexandru Turcanu on 23/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit

class HabitsScene: SKScene {
    
    var ballShape: SKHabitNode?
    var ballSize: CGSize?
    
    var startTime: Double?
    
    var animationState = SKHabitNode.BeautyAnimation.none
    var targetWidth = CGFloat()
    var normalWidth = CGFloat()
    let animationDuration: CGFloat = 0.5

    var duration = Double()
    
    override func didMove(to view: SKView) {
        let middleNode = SKShapeNode(circleOfRadius: 1)
        middleNode.position = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        middleNode.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        middleNode.physicsBody?.collisionBitMask = 10
        
        middleNode.physicsBody?.isDynamic = false
        
        middleNode.name = "helper"
        
        addChild(middleNode)
        
        let viewBorder = SKPhysicsBody(edgeLoopFrom: view.bounds)
        viewBorder.friction = 0
        self.physicsBody = viewBorder
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
//        self.view?.showsPhysics = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        ballShape?.updateHabit(for: &animationState, in: currentTime)
//        if let parent = ballShape?.parent as? SKHabitNode {
//            parent.updateHabit(for: &animationState, in: currentTime)
//        }
        
    }
    
    func calculateDuration(_ expand: Bool) -> Double {
        let widthToExpand = targetWidth - (ballShape?.frame.width)!
        let progress = widthToExpand / (targetWidth - normalWidth)
        if expand {
            return Double((1 - progress) * animationDuration)
        }
        return Double(progress * animationDuration)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let body = physicsWorld.body(at: location) {
            if let ball = body.node as? SKHabitNode {
                ballShape = ball
                animationState = .startingToExpand
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let body = physicsWorld.body(at: location) {
            if ballShape != body.node as? SKHabitNode {
                animationState = .startingToShrink
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        animationState = .startingToShrink
    }
    
    public func createHabitBubble(_ habit: Habit, in skview: SKView, at position: CGPoint) {
        let habit = SKHabitNode(for: habit, in: skview)
        addChild(habit)
    }
}


extension HabitsScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
}



