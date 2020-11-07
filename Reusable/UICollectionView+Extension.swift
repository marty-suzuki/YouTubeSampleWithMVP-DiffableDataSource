//
//  UICollectionView+Extension.swift
//  Reusable
//
//  Created by marty-suzuki on 2020/11/08.
//

import UIKit

extension UICollectionView: ReusableComponent {}

extension ReusableExtension where Base: UICollectionView {
    public func registerCell<T: ReusableView>(_: T.Type) {
        base.register(ReusableCollectionViewCell<T>.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    public func registerSupplementaryView<T: ReusableView>(_: T.Type, ofKind kind: String) {
        base.register(ReusableCollectionReusableView<T>.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }

    public func dequeueCell<T: ReusableView>(_: T.Type, for indexPath: IndexPath) -> ReusableResult<T, UICollectionViewCell> {
        let cell = base.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! ReusableCollectionViewCell<T>
        return ReusableResult(view: cell.view, container: cell)
    }

    public func dequeueSupplementaryView<T: ReusableView>(_: T.Type, ofKind kind: String, for indexPath: IndexPath) -> ReusableResult<T, UICollectionReusableView> {
        let view = base.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! ReusableCollectionReusableView<T>
        return ReusableResult(view: view.view, container: view)
    }
}

final class ReusableCollectionViewCell<T: ReusableView>: UICollectionViewCell {
    let view = T.make(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
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

extension ReusableResult where U: UICollectionViewCell {
    public func cell() -> UICollectionViewCell {
        container
    }
}

final class ReusableCollectionReusableView<T: ReusableView>: UICollectionReusableView {
    let view = T.make(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
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

extension ReusableResult where U: UICollectionReusableView {
    public func supplementaryView() -> UICollectionReusableView {
        container
    }
}
