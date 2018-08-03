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
    
    var habitNodeToShow: SKHabitNode?
    var transitionMode = TransitionMode.createHabit

    enum TransitionMode {
        case createHabit, showHabit
    }
    
    @IBOutlet weak var createHabitButton: UIButton!
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        reloadBubbles()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createHabitVC = segue.destination as? CreateHabitViewController {
            transitionMode = .createHabit
            createHabitVC.transitioningDelegate = self
            createHabitVC.modalPresentationStyle = .custom
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        habitsScene = HabitsScene(size: view.bounds.size)
        habitsScene.scaleMode = .aspectFill
        habitsScene.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.07058823529, blue: 0.2509803922, alpha: 1)
        habitsScene.habitsDelegate = self

        skView.presentScene(habitsScene)
        
        reloadBubbles()
    }
    
    private func reloadBubbles() {
        habits = CoreDataHelper.retrieveHabits()
        
        for habit in habits {
            if habitsScene.childNode(withName: habit.name) == nil {
                habitsScene.createHabitBubble(habit, in: skView)
            }
        }
    }
}

extension HabitsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = getStartingPoint()
        transition.circleColor = getColor()
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = getStartingPoint()
        transition.circleColor = getColor()
        
        return transition
    }
}

extension HabitsViewController: HabitsSceneDelegate {
    func didDoubleTapHabit(_ habitNode: SKHabitNode) {
        if let detailedHabitVC = storyboard?.instantiateViewController(withIdentifier: Constant.Storyboard.detailedHabit) as? DetailedHabitViewController {
            habitNodeToShow = habitNode
            transitionMode = .showHabit
            
            detailedHabitVC.habit = habitNode.habit
            
            detailedHabitVC.transitioningDelegate = self
            detailedHabitVC.modalPresentationStyle = .custom
            present(detailedHabitVC, animated: true)
        }
        
    }
}

extension HabitsViewController {
    private func getColor() -> UIColor {
        switch transitionMode {
        case .createHabit:
            return #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        case .showHabit:
            guard let color = habitNodeToShow?.habit.color else { fatalError("somebody is dumb") }
            return color
        }
    }
    
    private func getStartingPoint() -> CGPoint {
        switch transitionMode {
        case .createHabit:
            return createHabitButton.center
        case .showHabit:
            guard let position = habitNodeToShow?.position else { fatalError("somebody is dumb") }
            let y = (position.y - view.frame.height) < 0 ? (position.y - view.frame.height) * (-1) : (position.y - view.frame.height)
            return CGPoint(x: position.x, y: y)
        }
    }
}

