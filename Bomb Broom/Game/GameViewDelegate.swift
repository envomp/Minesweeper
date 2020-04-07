//
//  GameViewDelegate.swift
//  Minesweeper
//
//  Created by Enrico Vompa on 2020-04-07.
//  Copyright (c) Enrico Vompa. All rights reserved.
//

import Foundation

protocol GameViewDelegate {
    func tileAt(_ location: Location) -> Tile
    func bombsNear(_ location: Location) -> UInt

    func tilePressed(_ location: Location)
}
