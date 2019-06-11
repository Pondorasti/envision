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
    var transitionMode = TransitionDestination.createHabitVC

    enum TransitionDestination {
        case createHabitVC, detailedHabitVC, settingsVC
    }

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var createHabitButton: UIButton!
    
    @IBAction func createHabitButtonPressed(_ sender: Any) {
        TapticEngine.impact.feedback(.light)
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        reloadBubbles()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        transition.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appBecomeActive),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil
        )
        
        habitsScene = HabitsScene(size: view.bounds.size)
        habitsScene.scaleMode = .aspectFill
        habitsScene.backgroundColor = Constant.Layer.backgroundColor
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }

        switch id {
        case Constant.Segue.createHabit:
            guard let createHabitVC = segue.destination as? CreateHabitViewController else { return }

            createHabitVC.habits = habits

            TapticEngine.impact.feedback(.light)
            transitionMode = .createHabitVC
            createHabitVC.transitioningDelegate = self
            createHabitVC.modalPresentationStyle = .custom

        case Constant.Segue.showSettings:
            TapticEngine.impact.feedback(.light)

            transitionMode = .settingsVC
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
        default:
            assertionFailure("somebody is dumb")
        }
    }

    // MARK: - Methods
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
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        
        return transition
    }
}

// MARK: - HabitsSceneDelegate
extension HabitsViewController: HabitsSceneDelegate {
    func didDoubleTapHabit(_ habitNode: SKHabitNode) {
        guard let detailedHabitVC = storyboard?.instantiateViewController(withIdentifier: Constant.Storyboard.detailedHabit) as? DetailedHabitViewController else {
            fatalError("Could not load DetailedHabitVC")
        }

        habitNodeToShow = habitNode
        colorOfHabitNodeToShow = habitNode.habit.color
        transitionMode = .detailedHabitVC

        detailedHabitVC.habit = habitNode.habit

        let navController = UINavigationController(rootViewController: detailedHabitVC)
        navController.transitioningDelegate = self
        navController.modalPresentationStyle = .custom

        navController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navController.navigationBar.tintColor = UIColor.white

        present(navController, animated: true)
    }
}

// MARK: - CircularTransition
extension HabitsViewController: CircularTransitionDelegate {
    func retrieveCircleColor() -> UIColor {
        switch transitionMode {
        case .createHabitVC, .settingsVC:
            return .white
        case .detailedHabitVC:
            guard let color = colorOfHabitNodeToShow else { fatalError("somebody is dumb") }
            return color
        }
    }
    
    func retrieveStartingPoint() -> CGPoint {
        switch transitionMode {
        case .createHabitVC:
            return createHabitButton.center
        case .settingsVC:
            return settingsButton.center
        case .detailedHabitVC:
            guard let position = habitNodeToShow?.position else { fatalError("somebody is dumb") }
            let y = (position.y - view.frame.height) < 0 ? (position.y - view.frame.height) * (-1) : (position.y - view.frame.height)
            return CGPoint(x: position.x, y: y)
        }
    }
}


