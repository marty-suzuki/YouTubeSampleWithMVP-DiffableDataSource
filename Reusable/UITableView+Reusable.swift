//
//  UITableView+Reusable.swift
//  Reusable
//
//  Created by marty-suzuki on 2020/11/07.
//

import UIKit

extension UITableView: ReusableComponent {}

extension ReusableExtension where Base: UITableView {
    public func registerCell<T: ReusableView>(_: T.Type) {
        base.register(ReusableTableViewCell<T>.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    public func registerHeaderFooterView<T: ReusableView>(_: T.Type) {
        base.register(ReusableTableViewHeaderFooterView<T>.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueCell<T: ReusableView>(_: T.Type, for indexPath: IndexPath) -> ReusableResult<T, UITableViewCell> {
        let cell = base.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! ReusableTableViewCell<T>
        return ReusableResult(view: cell.view, container: cell)
    }

    public func dequeueHeaderFooterView<T: ReusableView>(_: T.Type) -> ReusableResult<T, UITableViewHeaderFooterView> {
        let view = base.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! ReusableTableViewHeaderFooterView<T>
        return ReusableResult(view: view.view, container: view)
    }
}

final class ReusableTableViewCell<T: ReusableView>: UITableViewCell {
    let view = T.make(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        view.prepareForReuse()
    }
}

extension ReusableResult where U: UITableViewCell {
    public func cell(selectionStyle: UITableViewCell.SelectionStyle = .default) -> UITableViewCell {
        container.selectionStyle = selectionStyle
        return container
    }
}

final class ReusableTableViewHeaderFooterView<T: ReusableView>: UITableViewHeaderFooterView {
    let view = T.make(frame: .zero)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        view.prepareForReuse()
    }
}

extension ReusableResult where U: UITableViewHeaderFooterView {
    public func headerFooterView() -> UITableViewHeaderFooterView {
        container
    }
}
