//
//  HabitsViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 23/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit

class HabitsViewController: UIViewController {
    
    @IBAction func createHabitButtonPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createHabitVC = segue.destination as? CreateHabitViewController {
            createHabitVC.transitioningDelegate = self
            createHabitVC.modalPresentationStyle = .custom
        }
        
    }
    
    @IBOutlet weak var createHabitButton: UIButton!
    var skView: SKView {
        return view as! SKView
    }
    
    var habitsScene: HabitsScene!
    let transition = CircularTransition()

    override func viewDidLoad() {
        super.viewDidLoad()
        habitsScene = HabitsScene(size: view.bounds.size)
        habitsScene.scaleMode = .aspectFill
        habitsScene.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        skView.presentScene(habitsScene)
        
        createHabitButton.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        createHabitButton.layer.cornerRadius = createHabitButton.frame.height / 2
        
//        habitsScene.createHabitBubble(with: skView, andName: "ball", color: UIColor.blue, position: CGPoint(x: skView.bounds.width / 2, y: skView.bounds.height / 2))
    }
}

extension HabitsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = createHabitButton.center
        transition.circleColor = createHabitButton.backgroundColor!
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = createHabitButton.center
        transition.circleColor = createHabitButton.backgroundColor!
        
        return transition
    }
}
