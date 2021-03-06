//
//  StatefulVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import RxSwift
import UIKit

class StatefulVC: BaseVC, UITextFieldDelegate {
    var text = "text".asOutput().someState()
    var textColor = State<UIColor>(.black)
    lazy var backgroundColor = State<UIColor>(Util.randomColor())
    var width = State<SizeDescription>(.fix(100))
    var height = State<SizeDescription>(.fix(100))
    
    override func configView() {
        UIScrollView().attach(vRoot) {
            VBox().attach($0) {
                UISwitch().attach($0)
                    .bind(to: self, event: .valueChanged, binding: { StatefulVC.valueChanged($0) })
                
                UIButton(type: .contactAdd).attach($0)
                    .bind(to: self, event: .touchDragInside) { this, _ in
                        this.valueChanged(UISwitch())
                    }
                
                UITextField().attach($0)
                    .placeholder(State("this is a textfiled"))
                    .width(.wrap(min: 100, max: 200))
                    .height(50)
                    .onText(self.text)
                
                Label("").attach($0)
                    .numberOfLines(State(0))
                    .text(self.text)
                    .width(.wrap(min: 50, max: 100))
                    .height(.wrap(min: 40, max: 150))
                
                Label("").attach($0)
                    .text(self.text)
                    .textColor(self.textColor.asOutput().some())
                    .size(self.width, self.height)
                
                Label("").attach($0)
                    .text(self.text)
                    .backgroundColor(self.backgroundColor.asOutput().some())
                    .size(self.width, self.height)
            }
            .space(10)
            .size(.fill, .wrap)
            .padding(all: 10)
            .justifyContent(.center)
            .animator(Animators.default)
        }
        .size(.fill, .fill)
    }
    
    private func valueChanged(_ view: UISwitch) {
        self.change(value: view.isOn)
    }
    
    private func change(value: Bool) {
//        UIView.animate(withDuration: 0.2) {
        self.text.value = "A random string: \(arc4random_uniform(10))"
        self.width.value = self.randomSize()
        self.height.value = self.randomSize()
        self.textColor.value = Util.randomColor()
        self.backgroundColor.value = Util.randomColor()
        self.vRoot.layoutIfNeeded()
//        }
    }
    
    private func randomSize() -> SizeDescription {
        return Util.random(array: [.fill, .wrap, .fix(100)])
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        return true
    }
}
