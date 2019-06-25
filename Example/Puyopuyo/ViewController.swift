//
//  ViewController.swift
//  Puyopuyo
//
//  Created by Jrwong on 06/22/2019.
//  Copyright (c) 2019 Jrwong. All rights reserved.
//

import UIKit
import Puyopuyo

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        testVLine()
//        testWrap()
//        testLabels()
     
        testLink()
        
        randomViewColor(view: view)
    }
    
    func testLink() {
//        let link =
        var label: UIView?
        VLine().attach(view, wrap: false) {
            
//            $0.backgroundColor = self.randomColor()
            
//            self.getLabel("1")
//                .attach($0)
//
//            self.getLabel("2")
//                .attach($0)
//
//            self.getLabel("333333333333")
//                .attach($0)
            
            HLine().attach($0, wrap: false) {
                
                self.getLabel("1111").attach($0)
                self.getLabel("2222").attach($0)
                self.getLabel("3333").attach($0)
                self.getLabel("4444").attach($0)
                self.getLabel("5555").attach($0)
//                self.getLabel("6666").attach($0)
                
            }
            .size(width: .ratio(1), height: .wrap)
            .padding(forward: 10, backward: 10)
//            .size(main: .wrap, cross: .wrap)
            .formation(.center)
            .crossAxis(.center)
            .space(10)
//            .reverse(true)
            
            VLine().attach($0) {
                label =
                self.getLabel("1111").attach($0)
                    .yMargin(all: 10)
                    .view
                
                self.getLabel("2222").attach($0)
                    .hAligment(.center)
                    .yMargin(all: 10)
                
                self.getLabel("3333").attach($0)
                    .hAligment(.right)
                    .yMargin(all: 10)
            }
            .padding(all: 10)
            .size(width: .ratio(0.5), height: .ratio(0.5))
            /*
            HLine().attach($0, wrap: false) {
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(main: .wrap, cross: .ratio(1))
                .formation(.sides)
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(main: .wrap, cross: .ratio(1))
                .formation(.center)
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(main: .wrap, cross: .ratio(1))
                .formation(.center)
                .reverse(true)
            }
            .crossAxis(.backward)
            .formation(.sides)
            .padding(all: 20)
            .size(main: .fixed(100), cross: .ratio(1))
            */
        }
        .crossAxis(.center)
        .padding(start: 50, forward: 50)
        .space(10)
        .size(width: .ratio(1), height: .ratio(1))
//        .reverse(true)
//        .size(main: .ratio(1), cross: .ratio(1))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            label?.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
            print(label?.frame)
            print(label?.bounds)
            print(label?.center)
        }
    }
    
    func getView() -> UIView {
        let v = UIView()
        v.backgroundColor = randomColor()
        return v
    }
    
    func getLabel(_ text: String = "") -> UILabel {
        let v = UILabel()
        v.text = text
        v.textColor = randomColor()
        v.backgroundColor = randomColor()
        return v
    }
    
    func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        let c = UIColor(red: red, green: green, blue: blue, alpha: 0.7)
        return c
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomViewColor(view: UIView) {
        view.subviews.forEach { (v) in
            v.backgroundColor = self.randomColor()
            self.randomViewColor(view: v)
        }
    }

}

