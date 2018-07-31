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
    var targetTime: Double = 1
    
    var shrinkingAnimation = false
    var holdingAnimation = false
    
    var holding = false
    
    
    var animationState = BeautyAnimation.none
    var targetWidth = CGFloat()
    var normalWidth = CGFloat()
    let animationDuration: CGFloat = 0.5
    
    
    var targetSize = CGSize()
    var duration = Double()
    
    enum BeautyAnimation {
        case expand, shrink, none, startingToShrink, startingToExpand
    }

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
        switch animationState {
        case .expand:
            print("expanding")
        case .shrink:
            print("shrinking")
        case .none:
            print("standby")
        case .startingToShrink:
            animationState = .shrink
            startTime = currentTime
            
            ballShape?.removeAllActions()
            ballShape?.run(SKAction.scale(to: 1, duration: 0.25))
            ballShape?.childNode(withName: "Label")?.run(SKAction.scale(to: 1, duration: 0.25))

        case .startingToExpand:
            animationState = .expand
            startTime = currentTime

            ballShape?.removeAllActions()
            
            let temporarySKShapeNode = SKShapeNode(circleOfRadius: 0.1)
            temporarySKShapeNode.lineWidth = 0.1
            temporarySKShapeNode.strokeColor = #colorLiteral(red: 0.1568627451, green: 0.368627451, blue: 0.5137254902, alpha: 0)
            temporarySKShapeNode.fillColor = #colorLiteral(red: 0.1568627451, green: 0.368627451, blue: 0.5137254902, alpha: 0.5)
            temporarySKShapeNode.alpha = 0.5
            temporarySKShapeNode.name = "temp"
            temporarySKShapeNode.zPosition = 2
            
            ballShape?.addChild(temporarySKShapeNode)
            
            temporarySKShapeNode.run(SKAction.scale(to: 400, duration: 0.5))
            
            

        }
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
                //TODO: start shrink animation
                animationState = .startingToShrink
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        animationState = .startingToShrink
        holdingAnimation = false
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


//        ballSprite.physicsBody?.restitution = 0.5
//        ballSprite.physicsBody?.friction = 0.2
//        ballSprite.physicsBody?.angularDamping = 0
//        ballSprite.physicsBody?.mass = 0.5
