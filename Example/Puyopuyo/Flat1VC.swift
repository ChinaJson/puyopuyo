//
//  Flat1VC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class Flat1VC: BaseVC {
    
    var visible = State(value: Visiblity.visible)
    var margin = State(value: UIEdgeInsets.zero)
    var aligment = State(value: Aligment.center)
    var direction = State(value: Direction.x)
    var subMargin = State(value: UIEdgeInsets.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HBox.attach(vRoot) {
            for idx in 0..<15 {
                self.getView()
                    .attach($0)
//                    .width({idx == 0 ? .ratio(1) : .fixed(10)}())
                    .width(10)
                    .height(10 * (idx + 1))
                    .margin(self.subMargin)
                    .aligment(self.aligment)
            }
        }
        .space(5)
        .size(.ratio(1), .wrap)
        .padding(all: 10)
        .justifyContent(.bottom)
        .margin(margin)
        .direction(direction)
//        .margin(top: 10, left: 10, bottom: 10, right: 10)
        .visible(visible)
        
        randomViewColor(view: vRoot)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.margin.value = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.aligment.value = .top
            self.subMargin.value = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            UIView.animate(withDuration: 0.3, animations: {
                self.vRoot.layoutIfNeeded()
            })
        }
    }
}
