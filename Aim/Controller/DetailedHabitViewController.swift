//
//  DetailedHabitViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 02/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DetailedHabitViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    
    var habit: Habit!

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self

        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        calendarView.backgroundColor = .clear
        
        calendarView.scrollToDate(Date())

        view.backgroundColor = habit?.color
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case Constant.Segue.goBack:
            guard let mainVC = segue.destination as? HabitsViewController else { return }
            mainVC.reloadBubbles()
            print("going back")
        default:
            fatalError("unknown segue identifier")
        }
    }
}

extension DetailedHabitViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "2018 1 1")
        let endDate = dateFormatter.date(from: "2019 1 1")
        
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
    
    
}

extension DetailedHabitViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: Constant.Cell.dateCell, for: indexPath) as? DateCell else {
            return JTAppleCell()
        }
        
        cell.dateLabel.text = cellState.text
        handleCellColors(for: cell, inCellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? DateCell else { return }
        
        let dateStringFormat = cellState.date.format(with: Constant.Calendar.format)

        if let state = habit?.completedDays[dateStringFormat], state {
            habit?.removeLog(for: dateStringFormat)
        } else {
            let newLog = CoreDataHelper.newLog()
            newLog.day = cellState.date
            CoreDataHelper.linkLog(newLog, to: habit)
        }
        
        handleCellColors(for: cell, inCellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        let selectedDateStringFormat = date.format(with: Constant.Calendar.format)
        let currentDateStringFormat = Date().format(with: Constant.Calendar.format)
        let creationDateStringFormat = habit.creationDate.format(with: Constant.Calendar.format)
        
        
        if creationDateStringFormat <= selectedDateStringFormat && selectedDateStringFormat <= currentDateStringFormat {
            return true
        }
        //TODO: show error message
        return false
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        dateFormatter.dateFormat = "MMMM yyyy"
        calendarTitleLabel.text = dateFormatter.string(from: date)
    }
    
    
    
    
}

extension DetailedHabitViewController {
    private func handleCellColors(for cell: DateCell, inCellState cellState: CellState) {
        let dateStringFormat = cellState.date.format(with: Constant.Calendar.format)
        cell.dateLabel.alpha = 1
        
        if cellState.dateBelongsTo == .thisMonth {
            if let state = habit?.completedDays[dateStringFormat], state {
                cell.dateLabel.textColor = habit?.color
                
                cell.completedDayView.isHidden = false
                cell.completedDayView.backgroundColor = Constant.Calendar.insideMonthSelectedViewColor
            } else {
                cell.dateLabel.textColor = Constant.Calendar.insideMonthDateColor
                
                cell.completedDayView.isHidden = true
            }
        } else {
            if let state = habit?.completedDays[dateStringFormat], state {
                cell.dateLabel.textColor = habit?.color
                cell.dateLabel.alpha = 0.5
                
                cell.completedDayView.isHidden = false
                cell.completedDayView.backgroundColor = Constant.Calendar.outsideMonthSelectedViewColor
            } else {
                cell.dateLabel.textColor = Constant.Calendar.outsideMonthDateColor
                
                cell.completedDayView.isHidden = true
            }
        }
    }
}
