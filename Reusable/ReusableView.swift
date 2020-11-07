//
//  ReusableView.swift
//  Reusable
//
//  Created by marty-suzuki on 2020/11/07.
//

import UIKit

public protocol ReusableView: UIView {
    static var reuseIdentifier: String { get }
    static func make(frame: CGRect) -> Self
    func prepareForReuse()
}

extension ReusableView {
    public static var reuseIdentifier: String {
        String(describing: self)
    }

    public static func make(frame: CGRect) -> Self {
        .init(frame: frame)
    }

    public func prepareForReuse() {}
}

public protocol ReusableNibView: ReusableView {
    static var nibName: String { get }
    static var nib: UINib { get }
    static var bundle: Bundle? { get }
}

extension ReusableNibView {
    public static var nibName: String {
        String(describing: self)
    }

    public static var bundle: Bundle? {
        nil
    }

    public static var nib: UINib {
        UINib(nibName: nibName, bundle: bundle)
    }

    public static func make(frame: CGRect) -> Self {
        nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
}
