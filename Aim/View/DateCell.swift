//
//  DateCell.swift
//  Aim
//
//  Created by Alexandru Turcanu on 02/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedDayView: UIView!
    
    override func awakeFromNib() {
        completedDayView.backgroundColor = Constant.Calendar.insideMonthSelectedViewColor
        completedDayView.layer.cornerRadius = completedDayView.frame.width / 2
        completedDayView.isHidden = true
    }
}
