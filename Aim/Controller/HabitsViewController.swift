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
    
    let transition = CircularTransition()
    
    var habits = [Habit]()
    var habitsScene: HabitsScene!
    var skView: SKView { return view as! SKView }

    @IBOutlet weak var createHabitButton: UIButton!
    
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        reloadBubbles()
    }
    
    @IBAction func testButtonPressed(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createHabitVC = segue.destination as? CreateHabitViewController {
            createHabitVC.transitioningDelegate = self
            createHabitVC.modalPresentationStyle = .custom
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        habitsScene = HabitsScene(size: view.bounds.size)
        habitsScene.scaleMode = .aspectFill
        habitsScene.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.07058823529, blue: 0.2509803922, alpha: 1)

        skView.presentScene(habitsScene)
        reloadBubbles()
    }
    
    private func reloadBubbles() {
        habits = CoreDataHelper.retrieveHabits()
        
        for habit in habits {
            if let name = habit.name, habitsScene.childNode(withName: name) == nil {
                habitsScene.createHabitBubble(habit, in: skView, at: CGPoint(x: skView.frame.width / 2, y: skView.frame.height / 2))
            }
        }
    }
}

extension HabitsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = createHabitButton.center
        transition.circleColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = createHabitButton.center
        transition.circleColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        
        return transition
    }
}
