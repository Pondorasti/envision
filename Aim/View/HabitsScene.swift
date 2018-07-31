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
    
    var ballShape: SKSpriteNode?
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

            ballShape?.removeAllActions()
            ballShape?.run(SKAction.resize(toWidth: 100, height: 100, duration: 0.5))
            
            //            let duration = calculateDuration(false)
        //            ballShape?.run(SKAction.scale(to: CGSize(width: 100, height: 100), duration: 0.5), withKey: "shrink")
        case .startingToExpand:
            animationState = .expand

            ballShape?.removeAllActions()
            ballShape?.run(SKAction.resize(toWidth: 250, height: 250, duration: 0.5))
            
            //            let duration = calculateDuration(true)
            //            ballShape?.run(SKAction.scale(by: 2, duration: 0.5), withKey: "expand")
            //            ballShape?.run(SKAction.scale(to: CGSize(width: 1000, height: 1000), duration: 0.5), withKey: "shrink")
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
            if let ball = body.node as? SKSpriteNode {
                ballShape = ball
                animationState = .startingToExpand
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let body = physicsWorld.body(at: location) {
            if ballShape != body.node as? SKShapeNode {
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
//        let ballSprite = SKShapeNode(circleOfRadius: skview.bounds.width * 0.10)
    
        let ballSprite = SKSpriteNode(imageNamed: "AIMLightBlue")
        
        targetWidth = ballSprite.frame.width * 2
        normalWidth = ballSprite.frame.width
        
//        ballSprite.lineWidth = 0.1
//        ballSprite.strokeColor = habit.color ?? UIColor.purple
//        ballSprite.fillColor = habit.color ?? UIColor.purple
        ballSprite.name = habit.name
        ballSprite.size = CGSize(width: 500, height: 500)
        
        let habitNameLabel = SKLabelNode(fontNamed: "Avenir")
        habitNameLabel.text = habit.name
        habitNameLabel.position = ballSprite.position
        habitNameLabel.fontColor = #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
        habitNameLabel.fontSize = 18
        habitNameLabel.numberOfLines = 2
        habitNameLabel.verticalAlignmentMode = .center
        habitNameLabel.horizontalAlignmentMode = .center
        habitNameLabel.preferredMaxLayoutWidth = ballSprite.frame.width * 0.75
        habitNameLabel.zPosition = 5
        
        ballSprite.zPosition = 1
        ballSprite.position = position
        
        ballSprite.physicsBody = SKPhysicsBody(circleOfRadius: skview.bounds.width * 0.10)
        ballSprite.physicsBody?.allowsRotation = false
        ballSprite.physicsBody?.linearDamping = 0.3
        ballSprite.physicsBody?.categoryBitMask = 1
        ballSprite.physicsBody?.collisionBitMask = 1
        ballSprite.physicsBody?.usesPreciseCollisionDetection = true
        
        ballSprite.addChild(habitNameLabel)
        addChild(ballSprite)
        
        if let middleNode = childNode(withName: "helper") as? SKShapeNode {
            let spring = SKPhysicsJointSpring.joint(withBodyA: ballSprite.physicsBody!, bodyB: middleNode.physicsBody!, anchorA: ballSprite.position, anchorB: middleNode.position)
            spring.frequency = 0.5
            spring.damping = 0.3
            scene?.physicsWorld.add(spring)
        }
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
