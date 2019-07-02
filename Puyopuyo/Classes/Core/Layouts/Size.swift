//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

public protocol SizeDescriptible {
    var sizeDescription: SizeDescription { get }
}

extension CGFloat: SizeDescriptible {
    public var sizeDescription: SizeDescription { return .fixed(self) }
}
extension Double: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension Float: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension Float80: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension Int: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension UInt: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension Int32: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension UInt32: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension Int64: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }
extension UInt64: SizeDescriptible { public var sizeDescription: SizeDescription { return .fixed(CGFloat(self)) } }

public struct SizeDescription {
    
    public enum SizeType {
        // 固有尺寸
        case fixed
        // 依赖父视图
        case ratio
        // 依赖子视图
        case wrap
    }
    
    public let sizeType: SizeType
    
    public let fixedValue: CGFloat
    
    public let ratio: CGFloat
    public let add: CGFloat
    public let min: CGFloat
    public let max: CGFloat
    
    public static func fixed(_ value: CGFloat) -> SizeDescription {
        return SizeDescription(sizeType: .fixed, fixedValue: value, ratio: 0, add: 0, min: 0, max: 0)
    }
    
    public static func ratio(_ value: CGFloat) -> SizeDescription {
        return SizeDescription(sizeType: .ratio, fixedValue: 0, ratio: value, add: 0, min: 0, max: .infinity)
    }
    
    public static func wrap(add: CGFloat = 0, min: CGFloat = 0, max: CGFloat = .infinity) -> SizeDescription {
        return SizeDescription(sizeType: .wrap, fixedValue: 0, ratio: 0, add: add, min: min, max: max)
    }
    
    public static var wrap: SizeDescription {
        return .wrap()
    }
    
    public static var zero: SizeDescription {
        return .fixed(0)
    }
    
    public static var fill: SizeDescription {
        return .ratio(1)
    }
    
    public var isWrap: Bool {
        if case .wrap = sizeType {
            return true
        }
        return false
    }
    
    public var isFixed: Bool {
        if case .fixed = sizeType {
            return true
        }
        return false
    }
    
    public var isRatio: Bool {
        if case .ratio = sizeType {
            return true
        }
        return false
    }
    
    public func getWrapSize(by wrappedValue: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(wrappedValue + add, min), max)
    }
    
}

public struct Size {
    
    public var width: SizeDescription
    public var height: SizeDescription
    
    public init(width: SizeDescription = .zero, height: SizeDescription = .zero) {
        self.width = width
        self.height = height
    }
    
    public func isFixed() -> Bool {
        return width.isFixed && height.isFixed
    }
    
    public func isWrap() -> Bool {
        return width.isWrap && height.isWrap
    }
    
    public func getMain(parent direction: Direction) -> SizeDescription {
        if case .x = direction {
            return width
        }
        return height
    }
    
    public func getCross(parent direction: Direction) -> SizeDescription {
        if case .x = direction {
            return height
        }
        return width
    }
    
    public func bothNotWrap() -> Bool {
        return !(width.isWrap || height.isWrap)
    }
    
    public func maybeWrap() -> Bool {
        return width.isWrap || height.isWrap
    }
    
}