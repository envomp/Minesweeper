//
//  RandomNumberGenerator.swift
//  Minesweeper
//
//  Created by Enrico Vompa on 2020-04-07.
//  Copyright (c) Enrico Vompa. All rights reserved.
//

import Foundation

struct RandomNumberGenerator: IteratorProtocol {
    typealias Element = UInt32

    let from: Element
    let to: Element

    init(from: Element, to: Element) {
        precondition(from <= to, "Invalid bounds")
        self.from = from
        self.to = to
    }

    init(to: Element) {
        self.from = 0
        self.to = to
    }

    func next() -> Element? {
        return arc4random_uniform(from - to) + from
    }
}
