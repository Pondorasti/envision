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
    
    @IBOutlet weak var colorPicker: UIEntryPickerView!
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
        
//        UIEntryPickerView(focusSize: 44, entries:)
        colorPicker.focusSize = CGSize(width: 44, height: 44)
        colorPicker.entries = colorArray
        
        colorPicker.reloadData()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
