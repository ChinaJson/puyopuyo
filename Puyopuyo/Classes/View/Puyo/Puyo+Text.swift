//
//  Puyo+Textable.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/17.
//

import Foundation

public protocol PuyoTextable {
    func py_setText(_ text: String?)
    func py_setAttrText(_ text: NSAttributedString?)
    func py_setTextColor(_ color: UIColor?)
    func py_setTextFont(_ font: UIFont?)
    func py_setTextAligment(_ aligment: NSTextAlignment)
    func py_setNumberOfLine(_ line: Int)
}

extension Puyo where T: PuyoTextable & UIView {
    @discardableResult
    public func text<S: Outputing>(_ text: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == String {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.py_setText(a.puyoWrapValue)
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func attrText<S: Outputing>(_ text: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == NSAttributedString {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.py_setAttrText(a.puyoWrapValue)
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textColor<S: Outputing>(_ color: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIColor {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.py_setTextColor(a.puyoWrapValue)
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font<S: Outputing>(_ font: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIFont {
        view.py_setUnbinder(font.safeBind(view, { (v, a) in
            v.py_setTextFont(a.puyoWrapValue)
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
    
    @available(iOS 8.2, *)
    @discardableResult
    public func fontSize<S: Outputing>(_ font: S, weight: UIFont.Weight = .regular) -> Self where S.OutputType: CGFloatable {
        view.py_setUnbinder(font.safeBind(view, { (v, a) in
            v.py_setTextFont(UIFont.systemFont(ofSize: a.cgFloatValue, weight: weight))
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textAligment<S: Outputing>(_ aligment: S) -> Self where S.OutputType == NSTextAlignment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.py_setTextAligment(a)
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textAligment(_ aligment: NSTextAlignment) -> Self {
        view.py_setTextAligment(aligment)
        return self
    }
    
    @discardableResult
    public func numberOfLines<S: Outputing>(_ lines: S) -> Self where S.OutputType == Int {
        view.py_setUnbinder(lines.safeBind(view, { (v, a) in
            v.py_setNumberOfLine(a)
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
}

extension UILabel: PuyoTextable {
    public func py_setText(_ text: String?) {
        self.text = text
    }
    
    public func py_setTextColor(_ color: UIColor?) {
        textColor = color
    }
    
    public func py_setTextFont(_ font: UIFont?) {
        self.font = font
    }
    
    public func py_setTextAligment(_ aligment: NSTextAlignment) {
        self.textAlignment = aligment
    }
    
    public func py_setAttrText(_ text: NSAttributedString?) {
        self.attributedText = text
    }
    
    public func py_setNumberOfLine(_ line: Int) {
        self.numberOfLines = line
    }
}

extension UITextField: PuyoTextable {
    public func py_setText(_ text: String?) {
        self.text = text
    }
    
    public func py_setTextColor(_ color: UIColor?) {
        self.textColor = color
    }
    
    public func py_setTextFont(_ font: UIFont?) {
        self.font = font
    }
    
    public func py_setTextAligment(_ aligment: NSTextAlignment) {
        self.textAlignment = aligment
    }
    public func py_setAttrText(_ text: NSAttributedString?) {
        self.attributedText = text
    }
    
    public func py_setNumberOfLine(_ line: Int) {
    }
}

extension UITextView: PuyoTextable {
    public func py_setText(_ text: String?) {
        self.text = text
    }
    
    public func py_setTextColor(_ color: UIColor?) {
        self.textColor = color
    }
    
    public func py_setTextFont(_ font: UIFont?) {
        self.font = font
    }
    
    public func py_setTextAligment(_ aligment: NSTextAlignment) {
        self.textAlignment = aligment
    }
    public func py_setAttrText(_ text: NSAttributedString?) {
        self.attributedText = text
    }
    
    public func py_setNumberOfLine(_ line: Int) {
    }
}

extension UIButton: PuyoTextable {
    public func py_setText(_ text: String?) {
        self.titleLabel?.text = text
    }
    
    public func py_setTextColor(_ color: UIColor?) {
        self.titleLabel?.textColor = color
    }
    
    public func py_setTextFont(_ font: UIFont?) {
        self.titleLabel?.font = font
    }
    
    public func py_setTextAligment(_ aligment: NSTextAlignment) {
        self.titleLabel?.textAlignment = aligment
    }
    
    public func py_setAttrText(_ text: NSAttributedString?) {
        self.titleLabel?.attributedText = text
    }
    
    public func py_setNumberOfLine(_ line: Int) {
        self.titleLabel?.numberOfLines = line
    }
}