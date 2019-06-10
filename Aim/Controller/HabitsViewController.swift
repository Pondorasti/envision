//
//  HabitsViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 23/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit
import TapticEngine

// MARK: - HabitsViewController
class HabitsViewController: UIViewController {
    // MARK: - Properties
    private let transition = CircularTransition()
    
    var habits = [Habit]()
    var habitsScene: HabitsScene!
    var skView: SKView { return view as! SKView }
    
    var habitNodeToShow: SKHabitNode?
    var colorOfHabitNodeToShow: UIColor?
    var transitionMode = TransitionMode.createHabit

    enum TransitionMode {
        case createHabit, showHabit, showSettings
    }

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var createHabitButton: UIButton!
    
    @IBAction func createHabitButtonPressed(_ sender: Any) {
        TapticEngine.impact.feedback(.light)
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        reloadBubbles()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        switch id {
        case Constant.Segue.createHabit:
            guard let createHabitVC = segue.destination as? CreateHabitViewController else { return }
            
            createHabitVC.habits = habits
            
            TapticEngine.impact.feedback(.light)
            transitionMode = .createHabit
            createHabitVC.transitioningDelegate = self
            createHabitVC.modalPresentationStyle = .custom
            
        case Constant.Segue.showSettings:
            TapticEngine.impact.feedback(.light)

            transitionMode = .showSettings
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
        default:
            assertionFailure("somebody is dumb")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appBecomeActive),
                                       name: .UIApplicationDidBecomeActive,
                                       object: nil
        )
        
        habitsScene = HabitsScene(size: view.bounds.size)
        habitsScene.scaleMode = .aspectFill
        habitsScene.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.07058823529, blue: 0.2509803922, alpha: 1)
        habitsScene.habitsDelegate = self

        skView.presentScene(habitsScene)
        
        reloadBubbles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: Constant.UserDefaults.notFirstInApp) == nil {
            let tutorialVC = UIStoryboard.initialViewController(for: .onboarding)
            present(tutorialVC, animated: true)
            
            defaults.set("No", forKey: Constant.UserDefaults.notFirstInApp)
            defaults.synchronize()
        }
    }
    
    @objc func appBecomeActive() {
        reloadBubbles()
    }
    
    func reloadBubbles() {
        // CPU Connsuming task, app becomes laggy with 5+ year old habits
        // optimize needed
        habits = CoreDataHelper.retrieveHabits()
        
        for habit in habits {
            habit.wasCompletedToday = habit.wasCompleted(for: Date())
            if let habitNode = habitsScene.childNode(withName: habit.name) as? SKHabitNode {
                habitNode.updateLabelAttributedString()
            } else {
                habitsScene.createHabitBubble(habit, in: skView)
            }
        }
    }
}

// MARK: - UIViewControllerTransitionDelegate
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

// MARK: - HabitsSceneDelegate
extension HabitsViewController: HabitsSceneDelegate {
    func didDoubleTapHabit(_ habitNode: SKHabitNode) {
        if let detailedHabitVC = storyboard?.instantiateViewController(withIdentifier: Constant.Storyboard.detailedHabit) as? DetailedHabitViewController {
            habitNodeToShow = habitNode
            
            colorOfHabitNodeToShow = habitNode.habit.color

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
        case .createHabit, .showSettings:
            return #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        case .showHabit:
            guard let color = colorOfHabitNodeToShow else { fatalError("somebody is dumb") }
            return color
        }
    }
    
    private func getStartingPoint() -> CGPoint {
        switch transitionMode {
        case .createHabit:
            return createHabitButton.center
        case .showSettings:
            return settingsButton.center
        case .showHabit:
            guard let position = habitNodeToShow?.position else { fatalError("somebody is dumb") }
            let y = (position.y - view.frame.height) < 0 ? (position.y - view.frame.height) * (-1) : (position.y - view.frame.height)
            return CGPoint(x: position.x, y: y)
        }
    }
}


