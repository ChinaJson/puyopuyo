//
//  LineCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class FlatCaculator {
    let regulator: FlatRegulator
    let parent: Measure
    let remain: CGSize
    init(_ regulator: FlatRegulator, parent: Measure, remain: CGSize) {
        self.regulator = regulator
        self.parent = parent
        self.remain = remain
    }

    lazy var regFixedSize = CalFixedSize(cgSize: self.regulator.py_size, direction: regulator.direction)
    lazy var regCalPadding = CalEdges(insets: regulator.padding, direction: regulator.direction)
    lazy var regCalSize = CalSize(size: regulator.size, direction: regulator.direction)
    lazy var totalFixedMain = regCalPadding.start + regCalPadding.end
    var maxCross: CGFloat = 0

    /// 主轴比例子项目
    var ratioMainMeasures = [Measure]()
    /// 主轴比例分母
    var totalMainRatio: CGFloat = 0
    /// 需要计算的子节点
    var caculateChildren = [Measure]()

    /// 是否可用format，主轴为包裹，或者存在主轴比例的子节点时，则不能使用
    var formattable: Bool = true

    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    func caculate() -> Size {
        if !(parent is Regulator) {
            Caculator.adaptingEstimateSize(measure: regulator, remain: remain)
        }

        // 1.第一次循环，计算正常节点，忽略未激活节点，缓存主轴比例节点
        regulator.enumerateChild { _, m in
            guard m.activated else { return }
            let subSize = m.size.getCalSize(by: regulator.direction)

            if (subSize.main.isRatio && formattable || regCalSize.main.isWrap) && regulator.format != .leading {
                // 校验是否可format
                _setNotFormattable()
            }
            // 初步计算，不会计算主轴比例项目
            appendAndRegulateNormalChild(m)
        }

        // 2.准备信息
        // 2.1 准备总数，插值格式化的比例总额
        var totalCount = caculateChildren.count
        if formattable {
            switch regulator.format {
            case .center:
                totalCount += 2
                totalMainRatio = CGFloat(totalCount - caculateChildren.count)
            case .round:
                totalCount = totalCount * 2 + 1
                totalMainRatio = CGFloat(totalCount - caculateChildren.count)
            case .between:
                totalCount = totalCount * 2 - 1
                totalMainRatio = CGFloat(totalCount - caculateChildren.count)
            default: break
            }
        }

        // 2.2 累加space到totalFixedMain
        totalFixedMain += max(0, CGFloat(caculateChildren.count - 1) * regulator.space)

        // 3. 第二次循环，计算主轴比例节点
        let currentChildren = caculateChildren
        caculateChildren = []
        caculateChildren.reserveCapacity(totalCount)

        // 插入首format
        if formattable, regulator.format == .center || regulator.format == .round {
            let m = getPlaceholder()
            regulateRatioChild(m)
            caculateChildren.append(m)
        }
        if formattable, regulator.format == .between || regulator.format == .round {
            // 需要插值计算
            currentChildren.enumerated().forEach { idx, m in
                caculateChildren.append(m)
                if idx != currentChildren.count - 1 {
                    let m = getPlaceholder()
                    regulateRatioChild(m)
                    caculateChildren.append(m)
                }
            }
        } else {
            // 计算正常主轴比例
            ratioMainMeasures.forEach { regulateRatioChild($0) }
            caculateChildren.append(contentsOf: currentChildren)
        }

        // 插入尾format
        if formattable, regulator.format == .center || regulator.format == .round {
            let m = getPlaceholder()
            regulateRatioChild(m)
            caculateChildren.append(m)
        }

        // 4、第三次循环，计算子节点center，若format == .trailing, 则可能出现第四次循环
        let lastEnd = caculateCenter(measures: caculateChildren)

        // 计算自身大小
        var main = regulator.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == regulator.direction {
                main = .fix(main.getWrapSize(by: lastEnd + regCalPadding.end))
            } else {
                main = .fix(main.getWrapSize(by: maxCross + regCalPadding.crossFixed))
            }
        }
        var cross = regulator.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == regulator.direction {
                cross = .fix(cross.getWrapSize(by: maxCross + regCalPadding.crossFixed))
            } else {
                cross = .fix(cross.getWrapSize(by: lastEnd + regCalPadding.end))
            }
        }

        return CalSize(main: main, cross: cross, direction: parent.direction).getSize()
    }

    private lazy var placeholders = [Measure]()
    private func getPlaceholder() -> Measure {
        let m = MeasureFactory.getPlaceholder()
//        let m = Measure()
        let calSize = CalSize(main: .fill, cross: .fix(0), direction: regulator.direction)
        m.size = calSize.getSize()
        var edges = m.margin.getCalEdges(by: regulator.direction)
        // 占位节点需要抵消间距
        edges.start = -regulator.space
        m.margin = edges.getInsets()
        placeholders.append(m)
        return m
    }

    deinit {
        MeasureFactory.recyclePlaceholders(placeholders)
    }

    private func getCurrentRemainSizeForNormalChildren() -> CalFixedSize {
        var size = CalFixedSize(main: regFixedSize.main - totalFixedMain, cross: regFixedSize.cross - regCalPadding.crossFixed, direction: regulator.direction)
        if size.main <= 0, regCalSize.main.isWrap {
            size.main = .greatestFiniteMagnitude
        }
        if size.cross <= 0, regCalSize.cross.isWrap {
            size.cross = .greatestFiniteMagnitude
        }
        return size
    }

    private func getCurrentRemainSizeForRatioChildren(measure: Measure) -> CalFixedSize {
        let calSize = measure.size.getCalSize(by: regulator.direction)
        let mainMax = max(0, (calSize.main.ratio / totalMainRatio) * (regFixedSize.main - totalFixedMain))
        var size = CalFixedSize(main: mainMax, cross: regFixedSize.cross - regCalPadding.crossFixed, direction: regulator.direction)
        if size.main <= 0, regCalSize.main.isWrap {
            size.main = .greatestFiniteMagnitude
        }
        if size.cross <= 0, regCalSize.cross.isWrap {
            size.cross = .greatestFiniteMagnitude
        }
        return size
    }

    private func appendAndRegulateNormalChild(_ measure: Measure) {
        caculateChildren.append(measure)
        /// 子margin
        let subCalMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
        // 累计margin
        totalFixedMain += subCalMargin.mainFixed
        
//        // 计算size的具体值
//        let subSize = _getEstimateSize(measure: measure, remain: getCurrentRemainSizeForNormalChildren().getSize())
//        if subSize.width.isWrap || subSize.height.isWrap {
//            fatalError("计算后的尺寸不能是包裹")
//        }
//        // main
//        let subCalSize = CalSize(size: subSize, direction: regulator.direction)

        let subCalSize = measure.size.getCalSize(by: regulator.direction)
        if subCalSize.main.isRatio {
            // 需要保存起来，最后计算
            ratioMainMeasures.append(measure)
            totalMainRatio += subCalSize.main.ratio
        } else {
            // 计算size的具体值
            let subSize = _getEstimateSize(measure: measure, remain: getCurrentRemainSizeForNormalChildren().getSize())
            if subSize.width.isWrap || subSize.height.isWrap {
                fatalError("计算后的尺寸不能是包裹")
            }
            // main
            let subCalSize = CalSize(size: subSize, direction: regulator.direction)
            // cross
            var subCrossSize = subCalSize.cross
            if subCalSize.cross.isRatio {
                subCrossSize = .fix((regFixedSize.cross - (regCalPadding.crossFixed + subCalMargin.crossFixed)))
            }
            // 设置具体size
            measure.py_size = CalFixedSize(main: subCalSize.main.fixedValue, cross: subCrossSize.fixedValue, direction: regulator.direction).getSize()
            // 记录最大cross
            maxCross = max(subCrossSize.fixedValue + subCalMargin.crossFixed, maxCross)
            // 累计main长度
            totalFixedMain += subCalSize.main.fixedValue

            if regulator.caculateChildrenImmediately {
                _ = measure.caculate(byParent: regulator, remain: Caculator.remainSize(with: measure.py_size, margin: measure.margin))
            }
        }
    }

    private func regulateRatioChild(_ measure: Measure) {
        let subSize = _getEstimateSize(measure: measure, remain: getCurrentRemainSizeForRatioChildren(measure: measure).getSize())
        let calSize = CalSize(size: subSize, direction: regulator.direction)
        let calMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
        // cross
        var subCrossSize = calSize.cross

        if subCrossSize.isRatio {
//            let ratio = subCrossSize.ratio
//            subCrossSize = .fix(max(0, (regFixedSize.cross - (regCalPadding.crossFixed + calMargin.crossFixed)) * ratio))
            // 次轴的ratio为全部占满，因为只有一个
            subCrossSize = .fix(max(0, regFixedSize.cross - (regCalPadding.crossFixed + calMargin.crossFixed)))
        }
        // main
        let subMainSize = SizeDescription.fix(max(0, (calSize.main.ratio / totalMainRatio) * (regFixedSize.main - totalFixedMain)))
        measure.py_size = CalFixedSize(main: subMainSize.fixedValue, cross: subCrossSize.fixedValue, direction: regulator.direction).getSize()
        maxCross = max(subCrossSize.fixedValue + calMargin.crossFixed, maxCross)
        if regulator.caculateChildrenImmediately {
            _ = measure.caculate(byParent: regulator, remain: Caculator.remainSize(with: measure.py_size, margin: measure.margin))
        }
    }

    /// 这里为measures的大小都计算好，需要计算每个节点的center
    ///
    /// - Parameters:
    ///   - measures: 已经计算好大小的节点
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private func caculateCenter(measures: [Measure]) -> CGFloat {
        var lastEnd: CGFloat = regCalPadding.start

        let reversed = regulator.reverse
        for idx in 0 ..< measures.count {
            var index = idx
            if reversed {
                index = measures.count - index - 1
            }
            lastEnd = _caculateCenter(measure: measures[index], at: idx, from: lastEnd)
        }

        if regulator.format == .trailing {
            // 如果格式化为靠后，则需要最后重排一遍
            // 计算最后一个需要移动的距离
            let delta = regFixedSize.main - regCalPadding.end - lastEnd
            measures.forEach({ m in
                var calCenter = m.py_center.getCalCenter(by: regulator.direction)
                calCenter.main += delta
                m.py_center = calCenter.getPoint()
            })
        }

        return lastEnd
    }

    private func _caculateCenter(measure: Measure, at index: Int, from end: CGFloat) -> CGFloat {
        let calMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
        let calSize = CalFixedSize(cgSize: measure.py_size, direction: regulator.direction)
        let space = (index == 0) ? 0 : regulator.space

        // main = end + 间距 + 自身顶部margin + 自身主轴一半
        let main = end + space + calMargin.start + calSize.main / 2

        // cross
        let cross: CGFloat
        let alignment = measure.alignment.contains(.none) ? regulator.justifyContent : measure.alignment

        var calCrossSize = regFixedSize.cross
        if regCalSize.cross.isWrap {
            // 如果是包裹，则需要使用当前最大cross进行计算
            calCrossSize = maxCross + regCalPadding.crossFixed
        }

        if alignment.isCenter(for: regulator.direction) {
            cross = calCrossSize / 2

        } else if alignment.isBackward(for: regulator.direction) {
            cross = calCrossSize - (regCalPadding.backward + calMargin.backward + calSize.cross / 2)
        } else {
            // 若无设置，则默认forward
            cross = calSize.cross / 2 + regCalPadding.forward + calMargin.forward
        }

        let center = CalCenter(main: main, cross: cross, direction: regulator.direction).getPoint()
        measure.py_center = center

        return main + calSize.main / 2 + calMargin.end
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
//        if measure.size.maybeWrap() {
//            return measure.caculate(byParent: regulator, remain: remain)
//        }
//        return measure.size
        
        if measure.size.bothNotWrap() {
            return measure.size
        }
        
        let calSubSize = measure.size.getCalSize(by: regulator.direction)
        var finalSize = calSubSize
        let remainSize = CalFixedSize(cgSize: remain, direction: regulator.direction)
        let originFixSize = CalFixedSize(cgSize: measure.py_size, direction: regulator.direction)
        let calMargin = CalEdges(insets: measure.margin, direction: regulator.direction)

        if calSubSize.main.isRatio {
            let relay = remainSize.main - calMargin.mainFixed
            finalSize.main = .fix(calSubSize.main.getFixValue(relay: relay, totalRatio: totalMainRatio, ratioFill: false))
        }
        
        if calSubSize.cross.isRatio {
            let relay = remainSize.cross - calMargin.crossFixed
            finalSize.cross = .fix(calSubSize.cross.getFixValue(relay: relay, totalRatio: totalMainRatio, ratioFill: true))
        }
        
        if measure.size.maybeWrap() {
            // 需要往下级计算
            var main: CGFloat = originFixSize.main
            var cross: CGFloat = originFixSize.cross
            if !calSubSize.main.isWrap {
                main = max(0, (calSubSize.main.ratio / totalMainRatio) * (regFixedSize.main - totalFixedMain))
            }
            if !calSubSize.cross.isWrap {
                cross = finalSize.cross.fixedValue
            }
            measure.py_size = CalFixedSize(main: main, cross: cross, direction: regulator.direction).getSize()
            
            return measure.caculate(byParent: regulator, remain: remain)
        }
        return finalSize.getSize()
        
//        let calSize = measure.size.getCalSize(by: regulator.direction)
//        let remainFixSize = CalFixedSize(cgSize: remain, direction: regulator.direction)
//        var finalCalSize = CalSize(size: Size(), direction: regulator.direction)
//
//        if !calSize.main.isWrap {
//            finalCalSize.main = .fix(calSize.main.getFixValue(relay: remainFixSize.main, totalRatio: totalMainRatio, ratioFill: false))
//        }
//
//        if !calSize.cross.isWrap {
//            finalCalSize.cross = .fix(calSize.cross.getFixValue(relay: remainFixSize.cross, totalRatio: totalMainRatio, ratioFill: true))
//        }
//
//        if measure.size.maybeWrap() {
//            return measure.caculate(byParent: regulator, remain: remain)
//        }
//
    }

    private func _setNotFormattable() {
        print("Constraint error!!! Regulator[\(regulator)] Format.\(regulator.format) reset to .leading")
        formattable = false
        regulator.format = .leading
    }
}
