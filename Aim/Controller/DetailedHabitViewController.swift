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
import SACountingLabel

class DetailedHabitViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    
    var habit: Habit!
    var completedDays = [String: Bool]()
    var lastValue: Double = 0.0
    
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    
    @IBOutlet weak var progressBarViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var progressBarViewHeightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarTitleLabel: UILabel!
    
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var percentageLabel: SACountingLabel!
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let ac = UIAlertController(title: habit.name,
                                   message: "Are you sure you want to delete this habit?",
                                   preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.performSegue(withIdentifier: Constant.Segue.destoryHabit, sender: self)
            CoreDataHelper.deleteHabit(self.habit)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
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
        
        calendarView.scrollToDate(Date(), animateScroll: false)

        progressBarView.backgroundColor = UIColor.clear
        setUpProgressView()
        
        view.backgroundColor = habit.color
        
        completedDays = habit.retrieveCompletedDays()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCircle()
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
        
        //TODO: create DateFormatter extension
        //TODO: creation date as start date
//        let startDate = dateFormatter.date(from: "2018 1 1")
        let endDate = dateFormatter.date(from: "2019 1 1")
        
        let parameters = ConfigurationParameters(startDate: habit.creationDate, endDate: endDate!, numberOfRows: nil, calendar: nil, generateInDates: nil, generateOutDates: nil, firstDayOfWeek: DaysOfWeek.monday, hasStrictBoundaries: nil)
        
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

        if let state = completedDays[dateStringFormat], state {
            habit.removeLog(for: dateStringFormat)
            completedDays[dateStringFormat] = false
        } else {
            habit.createLog(for: cellState.date)
            completedDays[dateStringFormat] = true
        }
        
        handleCellColors(for: cell, inCellState: cellState)
        TapticEngine.impact.feedback(.light)
        
        animateCircle(with: 0.45)
    }

    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        let selectedDateStringFormat = date.format(with: Constant.Calendar.format)
        let currentDateStringFormat = Date().format(with: Constant.Calendar.format)
        let creationDateStringFormat = habit.creationDate.format(with: Constant.Calendar.format)
        
        if creationDateStringFormat > selectedDateStringFormat {
            let ac = UIAlertController(title: "Error",
                                       message: "You cannot complete habits before the creation date.",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            
            present(ac, animated: true)
            return false
        }
        
        if selectedDateStringFormat > currentDateStringFormat {
            let ac = UIAlertController(title: "Error",
                                       message: "You cannot complete habits in the future.",
                                       preferredStyle: .alert)
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
            if let state = completedDays[dateStringFormat], state {
                cell.dateLabel.textColor = habit.color
                
                cell.completedDayView.isHidden = false
                cell.completedDayView.backgroundColor = Constant.Calendar.insideMonthSelectedViewColor
            } else {
                cell.dateLabel.textColor = Constant.Calendar.insideMonthDateColor
                cell.completedDayView.isHidden = true
            }
        } else {
            if let state = completedDays[dateStringFormat], state {
                cell.dateLabel.textColor = habit.color
                cell.dateLabel.alpha = 0.5
                
                cell.completedDayView.isHidden = false
                cell.completedDayView.backgroundColor = Constant.Calendar.outsideMonthSelectedViewColor
            } else {
                cell.dateLabel.textColor = Constant.Calendar.outsideMonthDateColor
                cell.completedDayView.isHidden = true
            }
        }
    }
    
    
    private func animateCircle(with duration: Double = 1) {
        let percentageAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        percentageAnimation.fromValue = lastValue
        percentageAnimation.toValue = habit.percentage
        
        percentageAnimation.duration = duration
        
        percentageAnimation.fillMode = kCAFillModeForwards
        percentageAnimation.isRemovedOnCompletion = false
        
        percentageLabel.countFrom(fromValue: Float(lastValue * 100), to: Float(habit.percentage * 100), withDuration: duration, andAnimationType: .EaseIn, andCountingType: .Int)
        
        lastValue = habit.percentage
        progressLayer.add(percentageAnimation, forKey: "percentageAnimation")
    }
    
    private func setUpProgressView() {
        progressBarViewWidthAnchor.constant = Constant.StatisticsView.percentageDiameter
        progressBarViewHeightAnchor.constant = Constant.StatisticsView.percentageDiameter
        
        let rectFofOval = CGRect(x: Constant.StatisticsView.percentageLineWidth / 2,
                                 y: Constant.StatisticsView.percentageLineWidth / 2,
                                 width: Constant.StatisticsView.percentageDiameter - Constant.StatisticsView.percentageLineWidth,
                                 height: Constant.StatisticsView.percentageDiameter - Constant.StatisticsView.percentageLineWidth)
        
        let circlePath = UIBezierPath(ovalIn: rectFofOval)
        
        trackLayer.path = circlePath.cgPath
        trackLayer.strokeColor = Constant.Calendar.outsideMonthDateColor.cgColor
        trackLayer.lineWidth = Constant.StatisticsView.percentageLineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = kCALineCapRound
        
        progressBarView.layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        
        progressLayer.strokeColor = Constant.Calendar.insideMonthDateColor.cgColor
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = kCALineCapRound
        
        progressLayer.strokeEnd = 0
        
        progressBarView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        percentageLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        
        progressBarView.layer.addSublayer(progressLayer)
    }
}
