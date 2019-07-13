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
    var levelType : SelectLevelScene.LevelType?
    var offset : Int = 0
    var difficulty : Difficulty?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            view.ignoresSiblingOrder = true
        }
        offset = 0
        difficulty = nil
        levelType = nil

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
            backToMenu()
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
    func backToMenu() {
        if offset > 0 && levelType != nil {
            switch levelType! {
            case .Predefined:
                selectedDifficulty(difficulty: difficulty!)
            case .Completed:
                viewDidLoad()
            case .InProgress:
                viewDidLoad()
            }
        }else {
            viewDidLoad()
        }
    }
    
    func restartGame() {
        viewDidLoad()
    }
    func selectedDifficulty(difficulty: Difficulty) {
        self.difficulty = difficulty
        if levelType != SelectLevelScene.LevelType.Predefined {
            self.levelType = SelectLevelScene.LevelType.Predefined
            offset = 0
        }
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectLevelScene") as? SelectLevelScene {
                scene.setup(delegate: self, difficulty: difficulty, type: .Predefined, offset: offset)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }
    }
    
    func selectedCompletedLevels() {
        if levelType != SelectLevelScene.LevelType.Completed {
            self.levelType = SelectLevelScene.LevelType.Completed
            difficulty = nil
            offset = 0
        }
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectLevelScene") as? SelectLevelScene {
                scene.setup(delegate: self, difficulty: nil, type: .Completed, offset: offset)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }

    }
    
    func selectedInProgressLevels() {
        if levelType != SelectLevelScene.LevelType.InProgress {
            self.levelType = SelectLevelScene.LevelType.InProgress
            difficulty = nil
            offset = 0
        }
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SelectLevelScene") as? SelectLevelScene {
                scene.setup(delegate: self, difficulty: nil, type: .InProgress, offset: offset)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }

    }
    
    func selectedLevel(board: Board, startTime: Int, moves: Int, offset: Int) {
        self.offset = offset
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
