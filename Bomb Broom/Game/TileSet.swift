//
//  TileSet.swift
//  Minesweeper
//
//  Created by Enrico Vompa on 2020-04-07.
//  Copyright (c) Enrico Vompa. All rights reserved.
//
import UIKit
import CoreText

protocol TileSet {
    func drawUnknownTile(_ rect: CGRect, context: CGContext)
    func drawFlaggedTile(_ rect: CGRect, context: CGContext)
    func drawPressedTile(_ rect: CGRect, context: CGContext)
    func drawRevealedTile(_ rect: CGRect, context: CGContext, count: UInt)
    func drawExplodedTile(_ rect: CGRect, context: CGContext)
    func drawBombTile(_ rect: CGRect, context: CGContext)
}

class DefaultTileSet: TileSet {
    func drawUnknownTile(_ rect: CGRect, context: CGContext) {
        context.setFillColor(gray: 0.75, alpha: 1.0)
        context.setStrokeColor(gray: 0.5, alpha: 1.0)
        context.fill(rect)
        context.stroke(rect, width: 4.0)
    }

    func drawFlaggedTile(_ rect: CGRect, context: CGContext) {
        drawUnknownTile(rect, context: context)
        context.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fillEllipse(in: rect.insetBy(dx: 8.0, dy: 8.0))
    }

    func drawPressedTile(_ rect: CGRect, context: CGContext) {
        context.setFillColor(gray: 0.5, alpha: 1.0)
        context.setStrokeColor(gray: 0.75, alpha: 1.0)
        context.fill(rect)
        context.stroke(rect, width: 4.0)
    }

    func drawRevealedTile(_ rect: CGRect, context: CGContext, count: UInt) {
        context.setFillColor(gray: 1.0, alpha: 1.0)
        context.fill(rect)
        if count == 0 {
            return
        }
        let string = NSAttributedString(string: "\(count)",
            attributes: [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
                          NSAttributedString.Key.foregroundColor: UIColor.black ])
        let line = CTLineCreateWithAttributedString(string)
        let imageRect = CTLineGetImageBounds(line, context)
        context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)
        context.textPosition = CGPoint(x: rect.origin.x + floor((rect.size.width - imageRect.size.width) / 2.0),
                                       y: rect.origin.y + floor((rect.size.height - imageRect.size.height) / 2.0))
        CTLineDraw(line, context)
        context.flush()
    }

    func drawExplodedTile(_ rect: CGRect, context: CGContext) {
        drawUnknownTile(rect, context: context)
        context.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fill(rect.insetBy(dx: 4.0, dy: 4.0))
    }

    func drawBombTile(_ rect: CGRect, context: CGContext) {
        drawUnknownTile(rect, context: context)
        context.setFillColor(gray: 0.0, alpha: 1.0)
        context.fill(rect.insetBy(dx: 4.0, dy: 4.0))
    }
}
