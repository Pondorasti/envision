//
//  CreateHabitViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit
import BLTNBoard
import TapticEngine
import FirebaseAnalytics

class CreateHabitViewController: UIViewController {
    // MARK: - Variables
    var isGoodHabit = true
    // TODO: retrieve only habit names
    var habits = [Habit]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var typeHabit: UILabel!
    @IBOutlet weak var colorOfBubbleLabel: UILabel!
    
    @IBOutlet weak var habitNameView: UIView!
    @IBOutlet weak var habitNameTextField: UITextField!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var goodTypeButton: UIButton!
    @IBOutlet weak var badTypeButton: UIButton!
    
    @IBOutlet weak var colorPicker: UIEntryPickerView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var habitTypeStackView: UIStackView!
    
    @IBAction func goodTypeButtonPressed(_ sender: Any) {
        if !isGoodHabit {
            animateTransion(from: badTypeButton, to: goodTypeButton, withDuration: 0.25)
            isGoodHabit = true
        }
    }
    
    @IBAction func badTypeButtonPressed(_ sender: Any) {
        if isGoodHabit {
            animateTransion(from: goodTypeButton, to: badTypeButton, withDuration: 0.25)
            isGoodHabit = false
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureHabitNameView()
        configureHabitTypeViews()
        configureColorPicker()
        configureButtons()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(assetIdentifier: .chevron),
            style: .done,
            target: self,
            action: #selector(dismissVC)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black


        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }

        guard let destination = segue.destination as? HabitsViewController else { return }
        destination.darkStatusBar = false
        destination.setNeedsStatusBarAppearanceUpdate()
        
        switch id {
        case Constant.Segue.actuallyCreateHabit:
            let newHabit = CoreDataHelper.newHabit()
            
            newHabit.colorInHex = colorPicker.entries[colorPicker.selectedPage].color!.hex!
            newHabit.name = habitNameTextField.text ?? ""
            newHabit.isGood = isGoodHabit
            newHabit.wasCompletedToday = false
            newHabit.creationDate = Date()
            
            CoreDataHelper.saveHabit()
            AnalyticsService.logNewHabit(newHabit)

            let newHabitNode = SKHabitNode(for: newHabit, in: SKView())
            destination.habitsScene.selectedHabitNode = newHabitNode
            
        case Constant.Segue.cancelHabit:
            print(Constant.Segue.cancelHabit)
        default:
            fatalError("unknown segue identifier")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case Constant.Segue.actuallyCreateHabit:
            if habitNameTextField.text == nil || habitNameTextField.text == "" {
                habitNameTextField.placeholder = "Required Field"
                habitNameView.addShakeAnimation()
                TapticEngine.notification.feedback(.error)
                return false
            }
            
            if let habitName = habitNameTextField.text {
                if habitName.containsIllegalCharacters() {
                    habitNameTextField.text = ""
                    habitNameTextField.placeholder = "Contains Illegal Characters"
                    habitNameView.addShakeAnimation()
                    TapticEngine.notification.feedback(.error)

                    return false
                }

                let trimmedHabitName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
                habitNameTextField.text = trimmedHabitName
                
                if habitNameExist(trimmedHabitName) {
                    habitNameTextField.text = ""
                    habitNameTextField.placeholder = "No duplicate habit names"
                    habitNameView.addShakeAnimation()
                    TapticEngine.notification.feedback(.error)
                    return false
                }
                
                if trimmedHabitName == "" {
                    return false
                }
                return true
            }
            
            return false
        default:
            return true
        }
    }

    // MARK: - Methods
    private func habitNameExist(_ habitName: String) -> Bool {
        for habit in habits {
            if habit.name == habitName {
                return true
            }
        }
        
        return false
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let percentage = max(gesture.translation(in: view).x, 0) / view.frame.width

        switch gesture.state {
        case .ended:
            let velocity = gesture.velocity(in: view).x

            if percentage > Constant.SwipeGesture.minPercentage ||
                velocity > Constant.SwipeGesture.minVelocity {
                dismissVC()
            }

        default:
            break
        }
    }

    @objc private func dismissVC() {
        TapticEngine.impact.feedback(.light)
        performSegue(withIdentifier: Constant.Segue.cancelHabit, sender: self)
    }

    private func animateTransion(from firstButton: UIButton, to secondButton: UIButton, withDuration duration: Double) {
        let temporaryView = UIView(frame: firstButton.frame)
        temporaryView.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1))
        temporaryView.frame.origin = firstButton.frame.origin

        firstButton.superview?.addSubview(temporaryView)
        firstButton.backgroundColor = nil

        UIView.animate(withDuration: duration, animations: {
            temporaryView.frame = secondButton.frame
            firstButton.isUserInteractionEnabled = false
            secondButton.isUserInteractionEnabled = false
        }) { (_) in
            let buttonName = self.isGoodHabit ? "Positive" : "Negative"
            secondButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: buttonName)
            secondButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
            secondButton.isUserInteractionEnabled = true

            firstButton.isUserInteractionEnabled = true

            temporaryView.removeFromSuperview()
        }
    }

    // MARK: - Configures
    private func configureHabitNameView() {
        habitNameView.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1))
        habitNameTextField.delegate = self
    }

    private func configureHabitTypeViews() {
        badTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Negative")
        goodTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Positive")
        badTypeButton.layer.zPosition = 5
        goodTypeButton.layer.zPosition = 5

        badTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
        goodTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)

        badTypeButton.backgroundColor = nil
    }

    private func configureColorPicker() {
        colorPicker.focusSize = CGSize(width: 44, height: 44)

        var colorPickerEntries = Constant.Color.colorPicker
        colorPickerEntries.sort {
            return $0.color!.hashValue < $1.color!.hashValue
        }

        colorPicker.entries = colorPickerEntries
        colorPicker.clipsToBounds = false
        colorPicker.reloadData()
    }

    private func configureButtons() {
        createButton.setTitle("Create", for: .normal)
        createButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        createButton.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.7803921569, blue: 0.3490196078, alpha: 1)
        createButton.layer.cornerRadius = Constant.Layer.cornerRadius
    }
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    // TODO: fix count
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if var numberOfCharacters = textField.text?.count {
//            numberOfCharacters = numberOfCharacters + string.count - range.length
//            characterCountLabel.text = String(numberOfCharacters)
//            if numberOfCharacters == 15 {
//                characterCountLabel.text = "\(numberOfCharacters)❗️"
//            }
//            return numberOfCharacters <= 14
//        }
//
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.count == 15 {
            characterCountLabel.text = "\(updatedText.count)❗️"
        } else {
            characterCountLabel.text = "\(updatedText.count)"
        }


        return updatedText.count <= 14
    }
}
