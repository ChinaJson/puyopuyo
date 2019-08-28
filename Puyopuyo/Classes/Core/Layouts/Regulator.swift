//
//  BaseLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public enum Format: CaseIterable {
    case leading
    case center
    case sides
    case avg
    case trailing
}

/// 描述一个布局具备控制子节点的属性
public class Regulator: Measure {
    
    public var justifyContent: Aligment = .center
    
    public var padding = UIEdgeInsets.zero
    
    public var autoJudgeScroll = false
    
    public func enumerateChild(_ block: (Int, Measure) -> Void) {
        py_enumerateChild(block)
    }
    
    public func getCalPadding() -> CalEdges {
        return CalEdges(insets: padding, direction: direction)
    }
}