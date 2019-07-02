//
//  Caculations.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/26.
//

import Foundation

/**
 逆时针计算一个四周
 布局开始方向 = start，相反 = end
 从start逆时针到end的边为forwarding，相反 = backwarding
 */

public struct CalAligment: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public typealias RawValue = Int
    public let rawValue: Int
    
    public static let center = CalAligment(rawValue: 1)
    public static let forward = CalAligment(rawValue: 2)
    public static let backward = CalAligment(rawValue: 4)
}

public struct CalEdges {
    public private(set) var direction: Direction = .x
    public var start: CGFloat = 0
    public var forward: CGFloat = 0
    public var backward: CGFloat = 0
    public var end: CGFloat = 0
    
    public init(start: CGFloat = 0, forward: CGFloat = 0, end: CGFloat = 0, backward: CGFloat = 0, direction: Direction = .x) {
        self.start = start
        self.forward = forward
        self.end = end
        self.backward = backward
        self.direction = direction
    }
    
    public init(insets: UIEdgeInsets = .zero, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            start = insets.left
            forward = insets.bottom
            end = insets.right
            backward = insets.top
        } else {
            start = insets.top
            forward = insets.left
            end = insets.bottom
            backward = insets.right
        }
    }
    
    public func getInsets() -> UIEdgeInsets {
        if case .x = direction {
            return UIEdgeInsets(top: backward, left: start, bottom: forward, right: end)
        }
        return UIEdgeInsets(top: start, left: forward, bottom: end, right: backward)
    }
}

extension UIEdgeInsets {
    public func getCalEdges(by direction: Direction) -> CalEdges {
        return CalEdges(insets: self, direction: direction)
    }
}

public struct CalCenter {
    
    public var main: CGFloat = 0
    public var cross: CGFloat = 0
    
    public init(main: CGFloat = 0, cross: CGFloat = 0) {
        self.main = main
        self.cross = cross
    }
    
}

public struct CalSize {
    public private(set) var direction: Direction = .x
    
    public var main: SizeDescription
    public var cross: SizeDescription
    public init(main: SizeDescription, cross: SizeDescription, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }
    public init(size: Size, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            main = size.width
            cross = size.height
        } else {
            main = size.height
            cross = size.width
        }
    }
    
    public func getSize() -> Size {
        if case .x = direction {
            return Size(width: main, height: cross)
        } else {
            return Size(width: cross, height: main)
        }
    }
    
}

extension Size {
    public func getCalSize(by direction: Direction) -> CalSize {
        return CalSize(size: self, direction: direction)
    }
}

public struct CalFixedSize {
    
    public private(set) var direction: Direction = .x
    
    public var main: CGFloat
    public var cross: CGFloat
    public init(main: CGFloat, cross: CGFloat, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }
    public init(cgSize: CGSize, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            main = cgSize.width
            cross = cgSize.height
        } else {
            main = cgSize.height
            cross = cgSize.width
        }
    }
    
    public func getSize() -> CGSize {
        if case .x = direction {
            return CGSize(width: main, height: cross)
        } else {
            return CGSize(width: cross, height: main)
        }
    }
}

extension CGSize {
    public func getCalFixedSize(by direction: Direction) -> CalFixedSize {
        return CalFixedSize(cgSize: self, direction: direction)
    }
}