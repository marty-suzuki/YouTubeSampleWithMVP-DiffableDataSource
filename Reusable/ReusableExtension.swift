//
//  ReusableExtension.swift
//  Reusable
//
//  Created by marty-suzuki on 2020/11/07.
//

public struct ReusableExtension<Base> {
    let base: Base
}

public protocol ReusableComponent {
    associatedtype ReusableCompatible
    var reusable: ReusableExtension<ReusableCompatible> { get }
}

extension ReusableComponent {
    public var reusable: ReusableExtension<Self> {
        ReusableExtension(base: self)
    }
}
