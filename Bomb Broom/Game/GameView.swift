//
//  GameView.swift
//  Minesweeper
//
//  Created by Enrico Vompa on 2020-04-07.
//  Copyright (c) Enrico Vompa. All rights reserved.
//

import UIKit

class GameView: UIScrollView, GameViewDelegate, GameObserver {
    
    var flagMode = false
    var tileViews = Array<GameTileView>()
    var gameViewDelegate: GameViewDelegate?

    var game: Game? {
        didSet {
            
            if let game = game {
                contentSize = CGSize(width: CGFloat(game.tile_size) * CGFloat(game.width),
                                     height: CGFloat(game.tile_size) * CGFloat(game.height))
            } else {
                contentSize = bounds.size
            }
            for view in tileViews {
                view.removeFromSuperview()
            }
            
            tileViews.removeAll(keepingCapacity: true)
            setNeedsLayout()
        }
    }

    var tileSet: TileSet? {
        didSet {
            for view in tileViews {
                view.tileSet = tileSet
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentSize = bounds.size
        clipsToBounds = true
        bounces = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentSize = bounds.size
        clipsToBounds = true
        bounces = false
    }

    override func layoutSubviews() {
        guard let game = game else {
            return
        }

        if tileViews.count > 0 {
            return
        }
        
        let tile = GameTileView(location: Location(x: 0, y: 0),
                                rows: game.height,
                                columns: game.width,
                                total_width: game.total_width,
                                total_height: game.total_height,
                                tileSize: CGFloat(game.tile_size))
        
        tile.delegate = self
        tile.tileSet = tileSet
        tile.setNeedsDisplay()
        tileViews.append(tile)
        addSubview(tile)
    }

    func tileViewForLocation(_ location: Location) -> GameTileView? {
        for tileView in tileViews {
            let tileLocation = tileView.location
            switch (location.x, location.y) {
            case (tileLocation.x ..< tileLocation.x + tileView.columns,
                tileLocation.y ..< tileLocation.y + tileView.rows):
                return tileView
            default:
                break
            }
        }
        return nil
    }

    func tileAt(_ location: Location) -> Tile {
        return gameViewDelegate?.tileAt(location) ?? Tile(content: .empty)
    }

    func bombsNear(_ location: Location) -> UInt {
        return gameViewDelegate?.bombsNear(location) ?? 0
    }

    func tilePressed(_ location: Location) {
        gameViewDelegate?.tilePressed(location)
    }

    // GameObserver methods

    func tileStatusChanged(_ game: Game, tile: Tile, location: Location) {
        if let tileView = tileViewForLocation(location) {
            tileView.tileStatusChanged(tile, location: location)
        }
    }

    func gameWon(_ game: Game) {

    }

    func gameLost(_ game: Game) {
    }
}
