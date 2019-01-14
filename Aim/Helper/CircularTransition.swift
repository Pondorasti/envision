//
//  CircularTransition.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class CircularTransition: NSObject {
    
    enum CircularTransitionMode: Int {
        case present, dismiss
    }
    
    var circle = UIView()
    var transitionMode: CircularTransitionMode = .present
    public var circleColor = UIColor.blue
    public var duration = 0.3
    
    var startingPoint = CGPoint.zero {
        didSet {
            circle.center = startingPoint
        }
    }
}

extension CircularTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if transitionMode == .present, let presentedView = transitionContext.view(forKey: .to) {
            let viewCenter = presentedView.center
            let viewSize = presentedView.frame.size
            
            circle = UIView()
            circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
            
            circle.layer.cornerRadius = circle.frame.size.height / 2
            circle.center = startingPoint
            circle.backgroundColor = circleColor
            circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            containerView.addSubview(circle)
            
            presentedView.center = startingPoint
            presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            presentedView.alpha = 0
            containerView.addSubview(presentedView)
            
            UIView.animate(withDuration: duration, animations: {
                self.circle.transform = CGAffineTransform.identity
                presentedView.transform = CGAffineTransform.identity
                presentedView.alpha = 1
                presentedView.center = viewCenter
                
            }, completion: { (success: Bool) in
                transitionContext.completeTransition(success)
            })
            
        } else if let returningView = transitionContext.view(forKey: .from) {
            let viewCenter = returningView.center
            let viewSize = returningView.frame.size
            
            circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
            circle.layer.cornerRadius = circle.frame.size.height / 2
            circle.center = startingPoint
            
            UIView.animate(withDuration: duration, animations: {
                self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningView.center = self.startingPoint
                returningView.alpha = 0
                
            }, completion: { (success:Bool) in
                returningView.center = viewCenter
                returningView.removeFromSuperview()
                
                self.circle.removeFromSuperview()
                
                transitionContext.completeTransition(success)
            })
        }
    }
    
    func frameForCircle (withViewCenter viewCenter: CGPoint, size viewSize: CGSize, startPoint: CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
        
        let offestVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offestVector, height: offestVector)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
}
