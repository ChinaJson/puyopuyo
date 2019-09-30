//
//  GestureStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

public protocol GestureStyleable: Styleable {
    var gestureStyleView: UIView { get }
}

public protocol GestureStyle: Style {
    func apply(to gestureStyle: GestureStyleable)
}

public protocol IdentifiableStyle {
    var styleIdentifier: String { get }
}

open class BaseGestureStyle: GestureStyle, IdentifiableStyle {
    
    public var styleIdentifier: String
    
    public init(identifier: String) {
        self.styleIdentifier = identifier
    }
    
    public func apply(to styleable: Styleable) {
        if let s = StyleUtil.convert(styleable, GestureStyleable.self) {
            apply(to: s)
        }
    }
    
    public func apply(to gestureStyleable: GestureStyleable) {
        let v = gestureStyleable.gestureStyleView
        _removeSpecifyGesture(view: v)
        v.addGestureRecognizer(getGesture())
    }
    
    private func _removeSpecifyGesture(view: UIView) {
        if let gs = view.gestureRecognizers, let target = gs.first(where: { $0.styleIdentifier == self.styleIdentifier }) {
            view.removeGestureRecognizer(target)
        }
    }
    
    open func getGesture() -> UIGestureRecognizer {
        fatalError("impl in subclass")
    }
    
}

extension UIView: GestureStyleable {
    public var gestureStyleView: UIView {
        return self
    }
}

fileprivate var gestureStyleIdentifierKey = "gestureStyleIdentifierKey"
extension UIGestureRecognizer {
    public var styleIdentifier: String? {
        set {
            objc_setAssociatedObject(self, &gestureStyleIdentifierKey, newValue as NSString?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &gestureStyleIdentifierKey) as? String
        }
    }
}

// MARK: - Delegate
class ShouldSimulateOtherGestureDelegate: NSObject, UIGestureRecognizerDelegate, Unbinder {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == otherGestureRecognizer.view {
            return true
        }
        return false
    }
    func py_unbind() {
    }
}

// MARK: - TapGestureStyle

open class TapGestureStyle: BaseGestureStyle {
    public init(identifier: String, _ action: @escaping (UITapGestureRecognizer) -> Void) {
        super.init(identifier: identifier)
        self.action = action
    }
    var action = { (_: UITapGestureRecognizer) -> Void in }
    override open func getGesture() -> UIGestureRecognizer {
        let tap = UIGestureRecognizer()
        tap.py_addAction { (g) in
            self.action(g as! UITapGestureRecognizer)
        }
        return tap
    }
}
// MARK: - LongPress
open class LongPressGestureStyle: BaseGestureStyle {
    public init(identifier: String, _ action: @escaping (UILongPressGestureRecognizer) -> Void) {
        super.init(identifier: identifier)
        self.action = action
    }
    var action = { (_: UILongPressGestureRecognizer) -> Void in }
    override open func getGesture() -> UIGestureRecognizer {
        let tap = UILongPressGestureRecognizer()
        tap.py_addAction { (g) in
            self.action(g as! UILongPressGestureRecognizer)
        }
        return tap
    }
}

// MARK: -
public class LayerGesture: UIGestureRecognizer {
    public var layer = CAShapeLayer()
    public var color = UIColor.lightGray.withAlphaComponent(0.6)
    public init(color: UIColor? = nil) {
        super.init(target: nil, action: nil)
        if let color = color {
            self.color = color
        }
    }
}