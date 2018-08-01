//
//  CreateHabitViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class CreateHabitViewController: UIViewController {
    var isGoodHabit = true
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var typeHabit: UILabel!
    @IBOutlet weak var habitDaysLabel: UILabel!
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
        let vc = HabitDaysPicker(headerText: "header", messageText: "message")
        vc.addAction(UIPickerAction(title: "Done", style: .cancel, action: { (_) in
            vc.dismiss(animated: true)
        }))
        vc.present(in: self)
        return
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        switch id {
        case "actuallyCreateHabit":
            let newHabit = CoreDataHelper.newHabit()
            
            newHabit.colorInHex = colorPicker.entries[colorPicker.selectedPage].color?.hex
            newHabit.name = habitNameTextField.text
            newHabit.isGood = isGoodHabit
            newHabit.creationDate = Date()
            newHabit.iteration = 0
            
            CoreDataHelper.saveHabit()
            print("creating new habit")
        case "cancelHabit":
            print("cancel creation")
        default:
            print("unknown segue identifier")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "actuallyCreateHabit":
            if habitNameTextField.text == nil || habitNameTextField.text == "" {
                habitNameTextField.placeholder = "Required Field"
                shakeAnimation(for: habitNameView)
                return false
            }
            return true
        default:
            return true
        }
    }
}

extension CreateHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var numberOfCharacters = textField.text?.count {
            numberOfCharacters = numberOfCharacters + string.count - range.length
            characterCountLabel.text = String(numberOfCharacters)
            if numberOfCharacters == 15 {
                characterCountLabel.text = "\(numberOfCharacters)❗️"
            }
            return numberOfCharacters <= 14
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateHabitViewController {
    private func setup() {
        habitNameView.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1))
        habitNameTextField.delegate = self
        
        badTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Destroy")
        goodTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Create")
        badTypeButton.layer.zPosition = 5
        goodTypeButton.layer.zPosition = 5
        
        badTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
        goodTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
        
        badTypeButton.backgroundColor = nil
        
        cancelButton.configure(with: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), andTitle: "Cancel")
        createButton.configure(with: #colorLiteral(red: 0.2039215686, green: 0.8039215686, blue: 0.3215686275, alpha: 1), andTitle: "Create")
        
        colorPicker.focusSize = CGSize(width: 44, height: 44)
        colorPicker.entries = Constant.Color.colorPicker
        colorPicker.clipsToBounds = false
        colorPicker.reloadData()
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
            let buttonName = self.isGoodHabit ? "Create" : "Destroy"
            secondButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: buttonName)
            secondButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
            secondButton.isUserInteractionEnabled = true
            
            firstButton.isUserInteractionEnabled = true
            
            temporaryView.removeFromSuperview()
        }
    }
    
    private func shakeAnimation(for view: UIView) {
        let shakingAnimation = CABasicAnimation(keyPath: "position")
        
        shakingAnimation.duration = 0.1
        shakingAnimation.repeatCount = 2
        shakingAnimation.autoreverses = true
        
        shakingAnimation.fromValue = CGPoint(x: view.center.x - 5, y: view.center.y)
        shakingAnimation.toValue = CGPoint(x: view.center.x + 5, y: view.center.y)
        
        view.layer.add(shakingAnimation, forKey: "position")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}


