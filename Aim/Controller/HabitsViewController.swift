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

    private(set) var habitsScene: HabitsScene!
    private var habits = [Habit]()
    private var skView: SKView { return view as! SKView }

    private var transitionMode = TransitionDestination.createHabitVC
    private var lastActiveHabitNode: SKHabitNode?

    enum TransitionDestination {
        case createHabitVC, detailedHabitVC, settingsVC
    }

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var createHabitButton: UIButton!
    
    @IBAction func createHabitButtonPressed(_ sender: Any) {
        TapticEngine.impact.feedback(.light)
    }

    /// Makes unwinding from createHabit and settings possible
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
        guard let id = segue.identifier else {
            fatalError("Could not unwrap segue identifier")
        }

        switch id {
        case Constant.Segue.createHabit:
            guard let createHabitVC = segue.destination as? CreateHabitViewController else {
                fatalError("Could not type cast destination into a CreateHabitVC")
            }

            transitionMode = .createHabitVC
            createHabitVC.habits = habits

            createHabitVC.transitioningDelegate = self
            createHabitVC.modalPresentationStyle = .custom

            TapticEngine.impact.feedback(.light)
        case Constant.Segue.presentSettingsVC:
            transitionMode = .settingsVC
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom

            TapticEngine.impact.feedback(.light)
        default:
            assertionFailure("Unknown segue identifier found")
        }
    }

    // MARK: - Methods
    @objc func appBecomeActive() {
        habitsScene.shakeHabitNodes(from: habitsScene.middleNode, withFeedback: true)
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

        lastActiveHabitNode = habitNode
        transitionMode = .detailedHabitVC

        detailedHabitVC.habit = habitNode.habit

        let navController = UINavigationController(rootViewController: detailedHabitVC)

        navController.transitioningDelegate = self
        navController.modalPresentationStyle = .custom
        navController.navigationBar.removeBackround()

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
            guard let color = lastActiveHabitNode?.habit.color else {
                fatalError("Missing Habit Node")
            }
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
            guard let position = lastActiveHabitNode?.position else {
                fatalError("Missing Habit Node")
            }
            return position.normalizeFromSpriteKitToUIKit(frameHeight: view.frame.height)
        }
    }
}


