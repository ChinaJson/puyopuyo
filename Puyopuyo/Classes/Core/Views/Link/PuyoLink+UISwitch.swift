//
//  PuyoLink+UISwitch.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension PuyoLink where T: UISwitch {
    
    @discardableResult
    public func isOn<S: ValueOutputing & ValueInputing>(_ state: S) -> Self where S.OutputType == Bool, S.InputType == Bool {
        view.py_setUnbinder(state.safeBind(view, { (v, a) in
            v.isOn = a
        }), for: #function)
        
        addWeakAction(to: view, for: .valueChanged, { (_, v) in
            state.input(value: v.isOn)
        })
        
        return self
    }
}
