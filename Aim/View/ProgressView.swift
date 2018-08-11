//
//  ProgressView.swift
//  Aim
//
//  Created by Alexandru Turcanu on 10/08/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SACountingLabel


class ProgressView: UIView {

    let dateFormatter = DateFormatter()
    let shapeLayer = CAShapeLayer()
    
    let percentageLabel: SACountingLabel = {
        let label = SACountingLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = #colorLiteral(red: 0.9921568627, green: 0.9921568627, blue: 0.9921568627, alpha: 1)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor =  .red //habit.color
        
//        percentageLabel.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.addSubview(percentageLabel)
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        percentageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let trackLayer = CAShapeLayer()

        let circularPath = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: -0.5 * .pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath

        trackLayer.strokeColor = Constant.Calendar.outsideMonthDateColor.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = kCALineCapRound
        
        let rect = CGRect(x: self.bounds.width / 2 - 27, y: self.bounds.height / 2, width: 100, height: 100)
        trackLayer.frame = rect

        self.layer.addSublayer(trackLayer)

        shapeLayer.path = circularPath.cgPath

        shapeLayer.strokeColor = Constant.Calendar.insideMonthDateColor.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.frame = rect

        shapeLayer.strokeEnd = 0
        self.layer.addSublayer(shapeLayer)
    }
}
