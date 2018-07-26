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
        if !isGoodHabit {
            let temporaryView = UIView(frame: badTypeButton.frame)
            temporaryView.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1))
            temporaryView.frame.origin = badTypeButton.frame.origin
            habitTypeStackView.addSubview(temporaryView)
            badTypeButton.backgroundColor = nil
            self.goodTypeButton.isUserInteractionEnabled = false
            self.badTypeButton.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.25, animations: {
                temporaryView.frame = self.goodTypeButton.frame
                self.goodTypeButton.isUserInteractionEnabled = false
                self.badTypeButton.isUserInteractionEnabled = false
            }) { (_) in
                self.isGoodHabit = true
                self.goodTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Create")
                self.goodTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
                self.goodTypeButton.isUserInteractionEnabled = true
                self.badTypeButton.isUserInteractionEnabled = true
                
                temporaryView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func badTypeButtonPressed(_ sender: Any) {
        if isGoodHabit {
            let temporaryView = UIView(frame: goodTypeButton.frame)
            temporaryView.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1))
            temporaryView.frame.origin = goodTypeButton.frame.origin
            habitTypeStackView.addSubview(temporaryView)
            goodTypeButton.backgroundColor = nil
            
            UIView.animate(withDuration: 0.25, animations: {
                temporaryView.frame = self.badTypeButton.frame
                self.goodTypeButton.isUserInteractionEnabled = false
                self.badTypeButton.isUserInteractionEnabled = false
            }) { (_) in
                self.isGoodHabit = false
                self.badTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Destroy")
                self.badTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
                self.goodTypeButton.isUserInteractionEnabled = true
                self.badTypeButton.isUserInteractionEnabled = true
                
                temporaryView.removeFromSuperview()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var colorArray = [UIEntryPickerView.Entry]()
    
        colorArray.append(UIEntryPickerView.Entry.major(with: .red))
        colorArray.append(UIEntryPickerView.Entry.major(with: .green))
        colorArray.append(UIEntryPickerView.Entry.major(with: .red))
        colorArray.append(UIEntryPickerView.Entry.major(with: .green))
        colorArray.append(UIEntryPickerView.Entry.major(with: .red))
        colorArray.append(UIEntryPickerView.Entry.major(with: .red))
        colorArray.append(UIEntryPickerView.Entry.major(with: .red))
        
        colorPicker.focusSize = CGSize(width: 44, height: 44)
        colorPicker.entries = colorArray
        
        colorPicker.reloadData()
        
        
        habitNameTextField.delegate = self
        setup()
    }
    
    private func setup() {
        habitNameView.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1))
        
        badTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Destroy")
        goodTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Create")
        badTypeButton.layer.zPosition = 5
        goodTypeButton.layer.zPosition = 5
        
        badTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
        goodTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
        
        badTypeButton.backgroundColor = nil
        
        cancelButton.configure(with: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), andTitle: "Cancel")
        createButton.configure(with: #colorLiteral(red: 0.2039215686, green: 0.8039215686, blue: 0.3215686275, alpha: 1), andTitle: "Create")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension CreateHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text?.count)
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
}
