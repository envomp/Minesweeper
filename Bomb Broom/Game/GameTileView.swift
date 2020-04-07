//
//  GameTileView.swift
//  Minesweeper
//
//  Created by Enrico Vompa on 2020-04-07.
//  Copyright (c) Enrico Vompa. All rights reserved.
//

import UIKit

protocol GameTileViewDelegate {
    func tileAt(_ location: Location) -> Tile
    func bombsNear(_ location: Location) -> UInt

    func tilePressed(_ location: Location)
}

class GameTileView: UIView {

    static let tileSize: CGFloat = 44.0

    var location: Location
    var rows: Dimension
    var columns: Dimension

    var delegate: GameViewDelegate?
    var tileSet: TileSet?

    var pressingLocation: Location?
    var pressingInside = false

    init(location: Location, rows: Dimension, columns: Dimension) {
        precondition(rows > 0, "Rows must be non-zero")
        precondition(columns > 0, "Columns must be non-zero")
        self.location = location
        self.rows = rows
        self.columns = columns

        super.init(frame: CGRect(x: 0.0, y: 0.0, width: CGFloat(columns) * GameTileView.tileSize, height: CGFloat(rows) * GameTileView.tileSize))

        self.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func locationForPoint(_ point: CGPoint) -> Location? {
        let viewSize = bounds.size
        let tileSize = GameTileView.tileSize
        switch (point.x, point.y) {
        case (0.0..<viewSize.width, 0.0..<viewSize.height):
            return Location(x: location.x + Dimension(floor(point.x / tileSize)),
                y: location.y + Dimension(floor(point.y / tileSize)))
        default:
            return nil
        }
    }

    func rectForLocation(_ location: Location) -> CGRect? {
        switch (location.x, location.y) {
        case (self.location.x..<self.location.x + columns, self.location.y..<self.location.y + rows):
            let tileSize = GameTileView.tileSize
            return CGRect(x: CGFloat(location.x) * tileSize,
                y: CGFloat(location.y) * tileSize,
                width: tileSize,
                height: tileSize)
        default:
            return nil
        }
    }

    func tileStatusChanged(_ tile: Tile, location: Location) {
        if let rect = rectForLocation(location) {
            if rect.intersects(self.bounds) {
                self.setNeedsDisplay(rect)
            }
        }
    }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()

        for y in 0..<rows {
            for x in 0..<columns {
                let location = Location(x: x, y: y)
                if let tileRect = rectForLocation(location) {
                    if tileRect.intersects(rect) {
                        drawTileAt(location, inRect: tileRect, inContext: ctx!)
                    }
                }
            }
        }
    }

    func drawTileAt(_ location: Location, inRect rect: CGRect, inContext ctx: CGContext) {
        ctx.saveGState()
        if let tile = delegate?.tileAt(location) {
            switch tile.status {
            case .unknown:
                if location == pressingLocation && pressingInside {
                    tileSet?.drawPressedTile(rect, context: ctx)
                } else {
                    tileSet?.drawUnknownTile(rect, context: ctx)
                }
            case .flagged:
                tileSet?.drawFlaggedTile(rect, context: ctx)
            case .revealed:
                let count = delegate?.bombsNear(location) ?? 0
                tileSet?.drawRevealedTile(rect, context: ctx, count: count)
            case .exploded:
                tileSet?.drawExplodedTile(rect, context: ctx)
            }
        } else {
            ctx.setFillColor(gray: 0.75, alpha: 1.0)
            ctx.fill(rect)
            ctx.setFillColor(gray: 0.5, alpha: 1.0)
            ctx.fill(rect.insetBy(dx: 4.0, dy: 4.0))
        }
        ctx.restoreGState()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            pressingLocation = locationForPoint(touch.location(in: self))
            if let location = pressingLocation {
                pressingInside = true
                if let rect = rectForLocation(location) {
                    setNeedsDisplay(rect)
                }
                return
            }
        }
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if let location = locationForPoint(touch.location(in: self)) {
                let isInside = location == pressingLocation
                if isInside == pressingInside {
                    return
                }
                if let rect = rectForLocation(location) {
                    setNeedsDisplay(rect)
                }
                pressingInside = isInside
                return
            }
        }
        super.touchesMoved(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = pressingLocation {
            if let rect = rectForLocation(location) {
                setNeedsDisplay(rect)
            }
            pressingLocation = nil
            return
        }
        super.touchesCancelled(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = pressingLocation {
            if let rect = rectForLocation(location) {
                setNeedsDisplay(rect)
            }
            if pressingInside {
                delegate?.tilePressed(location)
            }
            pressingLocation = nil
            return
        }
        super.touchesEnded(touches, with: event)
    }
}
