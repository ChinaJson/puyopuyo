//
//  CollectionBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/23.
//

import UIKit

public protocol CollectionBoxSection: class {
    var collectionBox: CollectionBox? { get set }
    func cellIdentifier() -> String
    func cellType() -> AnyClass
    func supplementaryType(for kind: String) -> AnyClass
    func numberOfItems() -> Int
    func didSelect(item: Int)
    func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
    func view(for collectionView: UICollectionView, supplementary kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func size(for collectionView: UICollectionView, layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize
    func headerSize(for collectionView: UICollectionView, layout: UICollectionViewLayout, at section: Int) -> CGSize
    func footerSize(for collectionView: UICollectionView, layout: UICollectionViewLayout, at section: Int) -> CGSize
}

public extension CollectionBoxSection {
    func supplementaryIdentifier(for kind: String) -> String {
        return cellIdentifier() + kind
    }
}

public class CollectionBox: UICollectionView,
    Stateful,
    Delegatable,
    DataSourceable,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource {
    public let viewState = State<[CollectionBoxSection]>([])

    private var delegateProxy: DelegateProxy<UICollectionViewDelegateFlowLayout>! {
        didSet {
            delegate = delegateProxy
        }
    }

    private var dataSourceProxy: DelegateProxy<UICollectionViewDataSource>! {
        didSet {
            dataSource = dataSourceProxy
        }
    }
    
    public private(set) var layout: UICollectionViewFlowLayout = CollectionBoxFlowLayout()

    fileprivate var sizeCache = [IndexPath: CGSize]()

    public init(
        direction: UICollectionView.ScrollDirection = .vertical,
        minimumLineSpacing: CGFloat = 0,
        minimumInteritemSpacing: CGFloat = 0,
        pinHeader: Bool = false,
        sections: [CollectionBoxSection] = []
    ) {
        layout.scrollDirection = direction
        layout.minimumLineSpacing = minimumLineSpacing
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.setSectionHeaderPin(pinHeader)
        super.init(frame: .zero, collectionViewLayout: layout)

        viewState.value = sections

        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)

        backgroundColor = .clear
        delegate = delegateProxy
        dataSource = dataSourceProxy

        viewState.safeBind(to: self) { this, sections in
            sections.forEach { section in
                section.collectionBox = this
                this.register(section.cellType(), forCellWithReuseIdentifier: section.cellIdentifier())
                [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter].forEach { type in
                    this.register(section.supplementaryType(for: type),
                                  forSupplementaryViewOfKind: type,
                                  withReuseIdentifier: section.supplementaryIdentifier(for: type))
                }
            }
            this.reloadData()
        }
    }

    public override func reloadData() {
        sizeCache.removeAll()
        super.reloadData()
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: - Delegatable, DataSourceable

    public func setDelegate(_ delegate: UICollectionViewDelegateFlowLayout, retained: Bool) {
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: delegate, retained: retained))
    }

    public func setDataSource(_ dataSource: UICollectionViewDataSource, retained: Bool) {
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: dataSource, retained: retained))
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource

    public func numberOfSections(in _: UICollectionView) -> Int {
        return viewState.value.count
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewState.value[section].numberOfItems()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewState.value[indexPath.section].cell(for: collectionView, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewState.value[indexPath.section].didSelect(item: indexPath.row)
        delegateProxy.backup?.value?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return viewState.value[indexPath.section].view(for: collectionView, supplementary: kind, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = sizeCache[indexPath] {
            return size
        }
        let size = viewState.value[indexPath.section].size(for: collectionView, layout: collectionViewLayout, at: indexPath)
        sizeCache[indexPath] = size
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewState.value[section].headerSize(for: collectionView, layout: collectionViewLayout, at: section)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return viewState.value[section].footerSize(for: collectionView, layout: collectionViewLayout, at: section)
    }
}

public struct RecycleContext<T, View: UIView> {
    public var index: Int = 0
    public var size: CGSize = .zero
    public var data: T
    public weak var view: View?
}

public class CollectionSection<Data, Cell: UIView, CellEvent>: CollectionBoxSection {
    public weak var collectionBox: CollectionBox?

    public let dataSource = State<[Data]>([])

    public typealias HeaderFooterGenerator<Data, CellEvent> = (SimpleOutput<Data>, SimpleInput<CellEvent>) -> UIView?
    var headerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent>
    var footerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent>

    public typealias CellGenerator<Data, Cell, CellEvent> = (SimpleOutput<RecycleContext<Data, UICollectionView>>, SimpleInput<CellEvent>) -> Cell
    var cellGenerator: CellGenerator<Data, Cell, CellEvent>

    public typealias OnCellEvent<Event> = (Event) -> Void
    var onCellEvent: OnCellEvent<Event>

    public var identifier: String
    private var diffIdentifier: ((Data) -> String)?
    public init(identifier: String,
                dataSource: SimpleOutput<[Data]>,
                _diffIdentifier: ((Data) -> String)? = nil,
                _cell: @escaping CellGenerator<Data, Cell, CellEvent>,
                _header: @escaping HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent> = { _, _ in EmptyView() },
                _footer: @escaping HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent> = { _, _ in EmptyView() },
                _event: @escaping OnCellEvent<Event> = { _ in }) {
        self.identifier = identifier
        cellGenerator = _cell
        onCellEvent = _event
        headerGenerator = _header
        footerGenerator = _footer
        diffIdentifier = _diffIdentifier
        _ = dataSource.outputing({ [weak self] data in
            self?.reload(with: data)
        })
    }

    public enum Event {
        case didSelect(Int, Data)
        case headerEvent(Int, [Data], CellEvent)
        case footerEvent(Int, [Data], CellEvent)
        case itemEvent(Int, Data, CellEvent)
    }

    public func cellIdentifier() -> String {
        return identifier
    }

    public func cellType() -> AnyClass {
        return CollectionBoxCell<Data, CellEvent>.self
    }

    public func supplementaryType(for _: String) -> AnyClass {
        return CollectionBoxSupplementaryView<[Data], CellEvent>.self
    }

    public func numberOfItems() -> Int {
        return dataSource.value.count
    }

    public func didSelect(item: Int) {
        onCellEvent(.didSelect(item, dataSource.value[item]))
    }

    public func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier(), for: indexPath) as? CollectionBoxCell<Data, CellEvent> else {
            fatalError()
        }
        cell.targetSize = getLayoutableContentSize(collectionView)
        let data = dataSource.value[indexPath.row]
        if cell.root == nil {
            let state = State(RecycleContext(index: indexPath.row, size: cell.targetSize, data: data, view: collectionView))
            let event = SimpleIO<CellEvent>()
            let root = cellGenerator(state.asOutput(), event.asInput())
            cell.root = root
            cell.state = state
            cell.event = event
            cell.contentView.addSubview(root)
            _ = event.outputing { [weak cell, weak self] event in
                guard let self = self, let cell = cell else { return }
                let idx = cell.state.value.index
                let data = cell.state.value.data
                self.onCellEvent(.itemEvent(idx, data, event))
            }
        } else {
//            cell.state.value = (indexPath.row, collectionView.bounds.size, data)
            cell.state.value = RecycleContext(index: indexPath.row, size: cell.targetSize, data: data, view: collectionView)
        }
        return cell
    }

    public func view(for collectionView: UICollectionView, supplementary kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: supplementaryIdentifier(for: kind), for: indexPath) as! CollectionBoxSupplementaryView<[Data], CellEvent>
//        view.targetSize = collectionView.bounds.size
        view.targetSize = getLayoutableContentSize(collectionView)
        if view.root == nil {
//            let state = State((indexPath.section, dataSource.value))
            let state = State(RecycleContext(index: indexPath.section, size: view.targetSize, data: dataSource.value, view: collectionView))
            let event = SimpleIO<CellEvent>()
            var root: UIView
            if kind == UICollectionView.elementKindSectionHeader {
                root = headerGenerator(state.asOutput(), event.asInput()) ?? EmptyView()
            } else {
                root = footerGenerator(state.asOutput(), event.asInput()) ?? EmptyView()
            }
            view.root = root
            view.state = state
            view.event = event
            view.addSubview(root)
            _ = event.outputing { [weak self, weak view] e in
                guard let self = self, let view = view else { return }
                if kind == UICollectionView.elementKindSectionHeader {
                    self.onCellEvent(.headerEvent(view.state.value.index, view.state.value.data, e))
                } else {
                    self.onCellEvent(.footerEvent(view.state.value.index, view.state.value.data, e))
                }
            }
        } else {
//            view.state.value = (indexPath.section, dataSource.value)
            view.state.value = RecycleContext(index: indexPath.section, size: view.targetSize, data: dataSource.value, view: collectionView)
        }
        return view
    }

    private let dummyItemState = State<RecycleContext<Data, UICollectionView>>.unstable()
    private lazy var dummyItem: UIView = { self.cellGenerator(self.dummyItemState.asOutput(), SimpleIO<CellEvent>().asInput()) }()

    private let dummyHeaderState = State<RecycleContext<[Data], UICollectionView>>.unstable()
    private lazy var dummyHeader: UIView = { self.headerGenerator(self.dummyHeaderState.asOutput(), SimpleIO<CellEvent>().asInput()) ?? EmptyView() }()
    private let dummyFooterState = State<RecycleContext<[Data], UICollectionView>>.unstable()
    private lazy var dummyFooter: UIView = { self.footerGenerator(self.dummyFooterState.asOutput(), SimpleIO<CellEvent>().asInput()) ?? EmptyView() }()
    
    private func getLayoutableContentSize(_ cv: UICollectionView) -> CGSize {
        let width = cv.bounds.size.width - cv.contentInset.left - cv.contentInset.right
        let height = cv.bounds.size.height - cv.contentInset.top - cv.contentInset.bottom
        return CGSize(width: width, height: height)
    }

    public func size(for collectionView: UICollectionView, layout _: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        dummyItemState.value = RecycleContext(index: indexPath.row, size: getLayoutableContentSize(collectionView), data: dataSource.value[indexPath.row], view: collectionView)
        var size = dummyItem.sizeThatFits(collectionView.bounds.size)
        size.width += (dummyItem.py_measure.margin.left + dummyItem.py_measure.margin.right)
        size.height += (dummyItem.py_measure.margin.top + dummyItem.py_measure.margin.bottom)
        return size
    }

    public func headerSize(for collectionView: UICollectionView, layout _: UICollectionViewLayout, at section: Int) -> CGSize {
        dummyHeaderState.value = RecycleContext(index: section, size: getLayoutableContentSize(collectionView), data: dataSource.value, view: collectionView)
        return dummyHeader.sizeThatFits(collectionView.bounds.size)
    }

    public func footerSize(for collectionView: UICollectionView, layout _: UICollectionViewLayout, at section: Int) -> CGSize {
        dummyFooterState.value = RecycleContext(index: section, size: getLayoutableContentSize(collectionView), data: dataSource.value, view: collectionView)
        return dummyFooter.sizeThatFits(collectionView.bounds.size)
    }

    private func reload(with data: [Data]) {
        guard let box = collectionBox else {
            dataSource.value = data
            return
        }
        // 不做diff运算
        guard let diffIdentifier = self.diffIdentifier else {
            dataSource.value = data
            box.reloadData()
            return
        }
        // 需要做diff运算
        // 清空cache
        box.sizeCache.removeAll()

        let diff = Diff(src: dataSource.value, dest: data, identifier: diffIdentifier)
        diff.check()
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            dataSource.value = data
            box.performBatchUpdates({
                diff.move.forEach { c in
                    box.moveItem(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
                }
                if !diff.delete.isEmpty {
                    box.deleteItems(at: diff.delete.map({ IndexPath(row: $0.from, section: section) }))
                }
                if !diff.insert.isEmpty {
                    box.insertItems(at: diff.insert.map({ IndexPath(row: $0.to, section: section) }))
                }
            }, completion: {
                // 完成编辑后，刷新不动的item
                if $0, !diff.stay.isEmpty {
                    box.reloadItems(at: diff.stay.map({ IndexPath(row: $0.from, section: section) }))
                }
            })
        }
    }

    public class EmptyView: UIView {
        public override func sizeThatFits(_: CGSize) -> CGSize {
            return CGSize(width: 0.1, height: 0.1)
        }
    }
    
    deinit {
        print("CollectionSection deinit!!!")
    }
}

private class CollectionBoxCell<D, E>: UICollectionViewCell {
    var root: UIView?
    var state: State<RecycleContext<D, UICollectionView>>!
    var event: SimpleIO<E>!

    var targetSize: CGSize = .zero

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        return root?.sizeThatFits(size) ?? .zero
    }
}

private class CollectionBoxSupplementaryView<D, E>: UICollectionReusableView {
    var root: UIView?
    var state: State<RecycleContext<D, UICollectionView>>!
    var event: SimpleIO<E>!

    var targetSize: CGSize = .zero

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        return root?.sizeThatFits(size) ?? .zero
    }
}

extension PYProxyChain: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let target = target(with: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) as? UICollectionViewDataSource else {
            return 0
        }
        return target.collectionView(collectionView, numberOfItemsInSection: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let target = target(with: #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:))) as? UICollectionViewDataSource else {
            return UICollectionViewCell()
        }
        return target.collectionView(collectionView, cellForItemAt: indexPath)
    }
}
