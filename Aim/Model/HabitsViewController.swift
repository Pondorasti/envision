//
//  HabitsViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 23/07/2018.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit
import SpriteKit

class HabitsViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }
    var habitsScene: HabitsScene!

    @IBAction func buttonPressed(_ sender: Any) {
        habitsScene.createHabitBubble(with: skView, andName: "ball", color: UIColor.blue, position: CGPoint(x: skView.bounds.width / 2, y: skView.bounds.height / 2))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        habitsScene = HabitsScene(size: view.bounds.size)
        habitsScene.scaleMode = .aspectFill
        habitsScene.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        skView.presentScene(habitsScene)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
