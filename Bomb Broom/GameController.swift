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

class ViewController: UIViewController, GameViewDelegate, GameObserver {

    @IBOutlet var gameView: GameView!
    @IBOutlet var bombsLeftLabel: UILabel!
	@IBOutlet var timeSpentLabel: UILabel!
	@IBOutlet var flagModeSelector: UISegmentedControl!
	var gameOn = false;
	var timeSpent = 0;

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
            bombsLeftLabel.text = "Bombs: \(game.bombs - game.flagCount)"
        default:
            bombsLeftLabel.text = ""
        }
    }

    fileprivate func startNewGame(bombs: UInt) {
		let screenSize = UIScreen.main.bounds
		
		var game_width = Dimension(screenSize.width / GameTileView.tileSize)
		var game_height = Dimension((screenSize.height - self.topLayoutGuide.length) / GameTileView.tileSize)
		var sub1 = 0
		var sub2 = 0
		
		print(UIDevice.current.name)
		if (UIDevice.current.name.hasPrefix("iPhone 11")) {
			if (UIDevice.current.orientation.isLandscape) {
				sub1 = Int(2 * GameTileView.tileSize)
				game_height -= 1
				sub2 = Int(GameTileView.tileSize)
				game_width -= 2
			} else {
				game_height -= 2
				sub2 = Int(2 * GameTileView.tileSize)
			}
			
		}
		
        game = Game(width: game_width,
                    height: game_height,
                    bombs: bombs,
					total_width: Dimension(screenSize.width - CGFloat(sub1)),
					total_height: Dimension(screenSize.height - self.topLayoutGuide.length - CGFloat(sub2)))
        game?.addObserver(self)
        gameView.game = game

		gameOn = true;
		timeSpent = 0;
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gameView.tileSet = DefaultTileSet()
        gameView.gameViewDelegate = self

        startNewGame(bombs: 20)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
		updateTime();
	}
	
	func updateTime() {

		if (self.gameOn) {
			self.timeSpent += 1;
			timeSpentLabel.text = "Time: " + String(self.timeSpent);
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.updateTime();
			}
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
	}

	@objc func rotated() {
			if UIDevice.current.orientation.isLandscape {
				startNewGame(bombs: 20)
			} else {
				startNewGame(bombs: 20)
			}
		}

	@IBAction func L1Pressed(_ sender: Any) {
		startNewGame(bombs: 10)
	}
	
    @IBAction func L2Pressed(_ sender: Any) {
        startNewGame(bombs: 20)
    }
    
    @IBAction func L3Pressed(_ sender: Any) {
        startNewGame(bombs: 30)
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
