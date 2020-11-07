//
//  ReusableResult.swift
//  Reusable
//
//  Created by marty-suzuki on 2020/11/07.
//

public struct ReusableResult<T: ReusableView, U> {
    public let view: T
    let container: U
}
