//
//  Game.swift
//  Minesweeper
//
//  Created by Enrico Vompa on 2020-04-07.
//  Copyright (c) Enrico Vompa. All rights reserved.
//

import Foundation

typealias Dimension = UInt32

struct Tile {
    enum Content {
        case empty
        case bomb
    }

    enum Status {
        case unknown
        case flagged
        case revealed
        case exploded
    }

    let content: Content
    var status = Status.unknown

    init(content: Content) {
        self.content = content
    }
}

struct Location: Equatable, CustomStringConvertible {
    let x: Dimension
    let y: Dimension

    init(x: Dimension, y: Dimension) {
        self.x = x
        self.y = y
    }

    var description: String {
        return "(\(x), \(y))"
    }
}

func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

protocol GameObserver: class {

    func tileStatusChanged(_ game: Game, tile: Tile, location: Location)

    func gameWon(_ game: Game)

    func gameLost(_ game: Game)
}

class Game {
    enum State {
        case initialized
        case running
        case won
        case lost
    }

    let total_width: Dimension
    let total_height: Dimension
    let width: Dimension
    let height: Dimension
    let bombs: UInt
    let tile_size: Int;
    var state: State = .initialized

    private var tiles = Array<Tile>();
    private var observers = Array<GameObserver>()

    init?(width: Dimension, height: Dimension, bombs: UInt, total_width: Dimension, total_height: Dimension, tile_size: Int) {
        self.width = width
        self.height = height
        self.total_width = total_width
        self.total_height = total_height
        self.bombs = bombs
        self.tile_size = tile_size;

        if width <= 0 || height <= 0 || bombs >= UInt(width * height) {
            return nil
        }
    }

    var flagCount: UInt {
        return UInt(tiles.filter { $0.status == .flagged }.count)
    }

    var revealedCount: UInt {
        return UInt(tiles.filter { $0.status == .revealed && $0.content == .empty }.count)
    }

    private func meetsWinCondition() -> Bool {
        return self.revealedCount + bombs == UInt(width * height)
    }

    func addObserver(_ observer: GameObserver) {
        if !observers.contains(where: { $0 === observer }) {
            observers.append(observer)
        }
    }

    func removeObserver(_ observer: GameObserver) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }

    func tileAt(_ location: Location) -> Tile {
        precondition(location.x >= 0 && location.x < width, "Location x coordinate out of bounds")
        precondition(location.y >= 0 && location.y < height, "Location y coordinate out of bounds")
        return tiles.count == 0 ? Tile(content: .empty) : tiles[toIndex(location: location)]
    }

    func toggleFlag(_ location: Location) {
        if state == .won || state == .lost {
            return
        }

        generateIfNecessary(excluding: nil)

        if state == .initialized {
            state = .running
        }

        let index = toIndex(location: location)
        var tile = tiles[index]
        tile.status = tile.status == .flagged ? .unknown : .flagged
        tiles[index] = tile
        for observer in observers {
            observer.tileStatusChanged(self, tile: tile, location: location)
        }
    }

    func reveal(_ location: Location) {
        if state == .won || state == .lost {
            return
        }

        generateIfNecessary(excluding: location)

        if state == .initialized {
            state = .running
        }

        let index = toIndex(location: location)
        var tile = tiles[index]

        // Don't process already revealed tiles
        if tile.status == .revealed {
            return
        }
        
        // Don't process flags
        if tile.status == .flagged {
            return
        }

        tile.status = tile.content == .bomb ? .exploded : .revealed
        tiles[index] = tile

        for observer in observers {
            observer.tileStatusChanged(self, tile: tile, location: location)
        }

        if tile.content == .bomb {
            state = .lost
            for observer in observers {
                observer.gameLost(self)
            }
        } else if meetsWinCondition() {
            state = .won
            for observer in observers {
                observer.gameWon(self)
            }
        } else {
            let neighbours = neighbourhood(location: location)
            if neighbours.filter({ self.tiles[self.toIndex(location: $0)].content == .bomb }).count == 0 {
                for neighbour in neighbours {
                    reveal(neighbour)
                }
            }
        }
    }

    func revealSafeNeighbours(_ location: Location) {
        if state == .won || state == .lost {
            return
        }

        generateIfNecessary(excluding: location)

        if state == .initialized {
            state = .running
        }

        let neighbours = neighbourhood(location: location)
        let flagged = neighbours.filter {
            self.tiles[self.toIndex(location: $0)].status == .flagged
        }.count
        let bombs = neighbours.filter {
            self.tiles[self.toIndex(location: $0)].content == .bomb
        }.count
        if flagged != bombs { return }
        let safeNeighbours = neighbourhood(location: location).filter {
            self.tiles[self.toIndex(location: $0)].status == .unknown
        }
        for neighbour in safeNeighbours {
            reveal(neighbour)
        }
    }

    private func neighbourhood(location: Location, radius: UInt = 1) -> Array<Location> {
        let r = Dimension(radius)
        let left = location.x >= r ? location.x - r : 0
        let right = min(location.x + r, width - 1)
        let top = location.y >= r ? location.y - r : 0
        let bottom = min(location.y + r, height - 1)

        var neighbourhood = Array<Location>()
        neighbourhood.reserveCapacity(8)
        for y in top...bottom {
            for x in left...right {
                let neighbour = Location(x: x, y: y)
                if neighbour != location {
                    neighbourhood.append(neighbour)
                }
            }
        }
        return neighbourhood
    }

    func bombsNear(_ location: Location) -> UInt {
        guard tiles.count > 0 else {
            return 0
        }

        return UInt(neighbourhood(location: location).filter {
            return self.tiles[self.toIndex(location: $0)].content == .bomb
        }.count)
    }

    private func toIndex(location: Location) -> Int {
        precondition(tiles.count > 0)
        return Int(location.x + width * location.y)
    }

    private func generateIfNecessary(excluding excluded: Location?, radius: UInt = 1) {
        if tiles.count == 0 {
            generate(excluding: excluded, radius: radius)
        }
    }

    func generate(excluding excluded: Location?, radius: UInt = 1) {
        let size = width * height
        tiles = (0..<size).map {
            return Tile(content: UInt($0) < self.bombs ? .bomb : .empty)
        }

        var safeLocations = Array<Location>()
        if let location = excluded {
            safeLocations.append(location)
            safeLocations.append(contentsOf: neighbourhood(location: location, radius: radius))
        }

        let end = size - Dimension(safeLocations.count);
        for i in 0..<end {
            // Fisher-Yates shuffle algorithm
            let j = arc4random_uniform(end - i) + i
            if i != j {
                let a = tiles[Int(i)];
                let b = tiles[Int(j)];
                tiles[Int(i)] = b;
                tiles[Int(j)] = a;
            }
        }

        var index = Int(size - 1)
        for location in safeLocations {
            let a = tiles[toIndex(location: location)];
            let b = tiles[index];
            tiles[toIndex(location: location)] = b;
            tiles[index] = a;
            index -= 1
        }
    }
}
