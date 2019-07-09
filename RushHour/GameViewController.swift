//
//  GameViewController.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameDelegate {
    var board : Board?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            view.ignoresSiblingOrder = true
        }

        selectDifficulty()
    }

    func selectDifficulty() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectDifficultyScene") as? SelectDifficultyScene {
                scene.setup(delegate: self)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }

    }
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func gameCompleted(board: Board, seconds: Int, moves: Int) {
        var completed = false
        if board.isCompleted() {
            LevelStorage().storeCompletedBoard(board: board, seconds: seconds, moves: moves, hints: 0)
            completed = true
        }else {
            LevelStorage().storeBoardInProgress(board: board, seconds: seconds, moves: moves, hints: 0)
        }
        if !completed {
            finishedGame()
        }else {
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = SKScene(fileNamed: "SingleGameOverScene") as? SingleGameOverScene {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    scene.setup(delegate: self, board: board, seconds: seconds, moves: moves)
                    
                    // Present the scene
                    view.presentScene(scene)
                }
                
                view.ignoresSiblingOrder = true
                
            }
        }
    }
    func finishedGame() {
        viewDidLoad()
    }
    func selectedDifficulty(difficulty: Difficulty) {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectLevelScene") as? SelectLevelScene {
                scene.setup(delegate: self, difficulty: difficulty, type: .Predefined)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }
    }
    
    func selectedCompletedLevels() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectLevelScene") as? SelectLevelScene {
                scene.setup(delegate: self, difficulty: nil, type: .Completed)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }

    }
    
    func selectedInProgressLevels() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectLevelScene") as? SelectLevelScene {
                scene.setup(delegate: self, difficulty: nil, type: .InProgress)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }

    }
    
    func selectedRandomLevels() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectLevelScene") as? SelectLevelScene {
                scene.setup(delegate: self, difficulty: nil, type: .Generated)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }

    }
    
    func selectedLevel(board: Board, startTime: Int, moves: Int) {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SingleGameScene") as? SingleGameScene {
                scene.setup(delegate: self, board: board, startTime: startTime, moves: moves)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }
    }
    
    
}
