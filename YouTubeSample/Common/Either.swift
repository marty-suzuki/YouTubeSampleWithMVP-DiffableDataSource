//
//  Either.swift
//  YouTubeSample
//
//  Created by marty-suzuki on 2020/10/29.
//

import Foundation

enum Either<L, R> {
    case left(L)
    case right(R)
}

extension Either: Error where L: Error {}
