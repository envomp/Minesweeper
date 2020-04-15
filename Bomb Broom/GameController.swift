//
//  ViewController.swift
//  Minesweeper
//
//  Created by Enrico Vompa on 2020-04-07.
//  Copyright (c) Enrico Vompa. All rights reserved.
//

import UIKit

private enum FlagMode: Int {
    case disabled = 0
    case enabled = 1
}

class GameController: UIViewController, GameViewDelegate, GameObserver {

    @IBOutlet var gameView: GameView!
    @IBOutlet var bombsLeftLabel: UILabel!
	@IBOutlet var timeSpentLabel: UILabel!
	@IBOutlet var flagModeSelector: UISegmentedControl!
	var gameOn = false;
	var timeSpent = 0.0;
	
	static var bombIcon = "💣";
	static var explosionIcon = "💥";
	static var flagIcon = "🚩";
	
	var tileSize: CGFloat = 44.0;
	var amountOfBombs = 0.20;
	var curWidth: CGFloat = 0.0;
	var curHeight: CGFloat = 0.0;
	

    var game: Game? {
        didSet {
            updateBombsLeftLabel()
        }
    }

    private func updateBombsLeftLabel() {
        guard let game = game else {
            bombsLeftLabel.text = ""
            return
        }

        switch game.state {
        case .initialized: fallthrough
        case .running:
            bombsLeftLabel.text = "B: \(game.bombs - game.flagCount)"
        default:
            bombsLeftLabel.text = ""
        }
    }

    fileprivate func startNewGame(bombs: Double) {
		
		tileSize = max(min(tileSize, min(gameView.bounds.width, gameView.bounds.height) - 20), 1)
		
		curWidth = gameView.bounds.width;
		curHeight = gameView.bounds.height;
		
		let game_width = Dimension(gameView.bounds.width / tileSize)
		let game_height = Dimension((gameView.bounds.height) / tileSize)
		
		print(UIDevice.current.name)
		print("Tile \(tileSize)")
		print(gameView.bounds.width)
		print(gameView.bounds.height)
		
		
        game = Game(width: game_width,
                    height: game_height,
					bombs: UInt(max(Int(bombs * Double(game_width) * Double(game_height)) - 1, 0)),
					total_width: Dimension(gameView.bounds.width),
					total_height: Dimension(gameView.bounds.height),
					tile_size: Int(tileSize))
		
        game?.addObserver(self)
        gameView.game = game

		gameOn = true;
		timeSpent = 0;
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gameView.tileSet = DefaultTileSet()
        gameView.gameViewDelegate = self

        startNewGame(bombs: amountOfBombs)
		NotificationCenter.default.addObserver(self, selector: #selector(GameController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
		updateTime();
	}
	
	func updateTime() {
		
		if (curHeight != gameView.bounds.height || curWidth != gameView.bounds.width) {
			startNewGame(bombs: amountOfBombs);
			updateTime()
		} else if (self.gameOn) {
			self.timeSpent += 0.01;
			timeSpentLabel.text = "Time: " + String(round(self.timeSpent * 100) / 100);
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
				self.updateTime();
			}
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
	}

	@objc func rotated() {
		startNewGame(bombs: amountOfBombs)
	}

    @IBAction func flagModeChanged(_ sender: AnyObject?) {
        if flagModeSelector.selectedSegmentIndex == FlagMode.enabled.rawValue {
            gameView.flagMode = true
        } else {
            gameView.flagMode = false
        }
    }

    // GameViewDelegate methods

    func tileAt(_ location: Location) -> Tile {
        return game?.tileAt(location) ?? Tile(content: .empty)
    }

    func bombsNear(_ location: Location) -> UInt {
        return game?.bombsNear(location) ?? 0
    }

    func tilePressed(_ location: Location) {
        guard let game = game else {
            return
        }

        // Tapping on a revealed tile will reveal its unflagged neighbours,
        // so long as all the neighbouring bombs have been flagged.
        let tile = game.tileAt(location)
        if tile.status == .revealed && tile.content == .empty {
            game.revealSafeNeighbours(location)
        } else if gameView.flagMode {
            game.toggleFlag(location)
        } else {
            game.reveal(location)
        }
    }

    // GameObserver methods

    func tileStatusChanged(_ game: Game, tile: Tile, location: Location) {
        gameView.tileStatusChanged(game, tile: tile, location: location)
        updateBombsLeftLabel()
    }

    func gameLost(_ game: Game) {
		bombsLeftLabel.text = "You lost!"
        gameView.gameLost(game)
		gameOn = false;
	}

    func gameWon(_ game: Game) {
		bombsLeftLabel.text = "You won!"
        gameView.gameWon(game)
		gameOn = false;
    }
}
