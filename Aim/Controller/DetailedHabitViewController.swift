//
//  DetailedHabitViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 02/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import JTAppleCalendar
import TapticEngine

class DetailedHabitViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    
    var habit: Habit!

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarTitleLabel: UILabel!
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let ac = UIAlertController(title: habit.name, message: "Are you sure you want to delete this habit?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.performSegue(withIdentifier: Constant.Segue.destoryHabit, sender: self)
            
            CoreDataHelper.deleteHabit(self.habit)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        
        ac.addAction(cancelAction)
        ac.addAction(deleteAction)
        
        present(ac, animated: true)
    }
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
        guard let id = segue.identifier,
            let mainVC = segue.destination as? HabitsViewController else { return }
        switch id {
        case Constant.Segue.goBack:
            mainVC.reloadBubbles()
        case Constant.Segue.destoryHabit:
            if let habitToDelete = mainVC.habitsScene.childNode(withName: habit.name) as? SKHabitNode {
                habitToDelete.removeFromParent()
                CoreDataHelper.deleteHabit(habit)
            } else {
                fatalError("trying to delete unknown habit")
            }
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
        let parameters = ConfigurationParameters(startDate: habit.creationDate, endDate: endDate!, numberOfRows: nil, calendar: nil, generateInDates: nil, generateOutDates: nil, firstDayOfWeek: DaysOfWeek.monday, hasStrictBoundaries: nil)
//        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
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
        TapticEngine.impact.feedback(.light)
    }

    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        let selectedDateStringFormat = date.format(with: Constant.Calendar.format)
        let currentDateStringFormat = Date().format(with: Constant.Calendar.format)
        let creationDateStringFormat = habit.creationDate.format(with: Constant.Calendar.format)
        
        if creationDateStringFormat > selectedDateStringFormat {
            let ac = UIAlertController(title: "Error", message: "You cannot complete habits before the creation date.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            
            present(ac, animated: true)
            
            return false
        }
        
        if selectedDateStringFormat > currentDateStringFormat {
            let ac = UIAlertController(title: "Error", message: "You cannot complete habits in the future.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            
            present(ac, animated: true)
            
            return false
        }

        return true
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
