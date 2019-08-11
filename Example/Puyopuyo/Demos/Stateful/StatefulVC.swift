//
//  StatefulVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import Puyopuyo

class StatefulVC: BaseVC {
    
    var text = State("text")
    var textColor = State<UIColor>(.black)
    lazy var backgroundColor = State<UIColor>(self.randomColor())
    var width = State<SizeDescription>(.fixed(100))
    var height = State<SizeDescription>(.fixed(100))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIScrollView().attach(vRoot) {
            
            VBox().attach($0) {
                
                UISwitch().attach($0)
                    .addWeakBind(to: self, for: .valueChanged, { (self) in return self.valueChanged(_:) })
                
                UIButton(type: .contactAdd).attach($0)
                    .addWeakAction(to: self, for: .touchUpInside, { (self, _) in self.valueChanged(UISwitch())})
                
                Label("").attach($0)
                    .text(self.text.optional())
                    .textColor(self.textColor.optional())
                    .size(self.width, self.height)
                
                Spacer().attach($0)
                
                Label("").attach($0)
                    .text(self.text.optional())
                    .backgroundColor(self.backgroundColor.optional())
                    .size(self.width, self.height)
            }
            .space(10)
            .size(.fill, .wrap)
            .padding(all: 10)
            .justifyContent(.center)
        }
        .size(.fill, .fill)
        
        randomViewColor(view: view)
    }
    
    private func valueChanged(_ view: UISwitch) -> Void {
        change(value: view.isOn)
    }
    
    private func change(value: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.text.value = "A random string: \(arc4random_uniform(10))"
            self.width.value = self.randomSize()
            self.height.value = self.randomSize()
            self.textColor.value = self.randomColor()
            self.backgroundColor.value = self.randomColor()
            self.vRoot.layoutIfNeeded()
        }
    }
    
    private func randomSize() -> SizeDescription {
        return random(array: [.fill, .wrap, .fixed(100)])
    }
}