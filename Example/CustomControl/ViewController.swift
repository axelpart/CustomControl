//
//  ViewController.swift
//  CustomControl
//
//  Created by Alexandros Partonas on 03/07/2017.
//  Copyright (c) 2017 Alexandros Partonas. All rights reserved.
//

import UIKit
import CustomControl

class ViewController: UIViewController, CustomControlDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(customControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func controlSelected(_ index: Int) {
        print("Selected index: \(index)")
    }
    
    func controlSelectedButton(_ text: String) {
        print("Button text: \(text)")
    }
    
    func test() {
        print("text)")
    }
    
    lazy var customControl: CustomControl = {
        let customControl = CustomControl(frame: CGRect(x: 0, y: 20, width: self.view.bounds.width, height: 40))
        customControl.titles = ["one", "two", "three", "four"]
        customControl.selectedTextColor = .green
        customControl.delegate = self
        return customControl
    }()
}

