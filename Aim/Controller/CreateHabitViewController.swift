//
//  CreateHabitViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 25/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit

class CreateHabitViewController: UIViewController {

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
        
        habitNameView.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1))
        
        badTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Destroy")
        goodTypeButton.configure(with: #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1), andTitle: "Create")
        
        badTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
        goodTypeButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
        
        cancelButton.configure(with: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), andTitle: "Cancel")
        createButton.configure(with: #colorLiteral(red: 0.2039215686, green: 0.8039215686, blue: 0.3215686275, alpha: 1), andTitle: "Create")
    }



}
