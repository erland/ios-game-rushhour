//
//  SelectDifficultyScene.swift
//  Sudoku
//
//  Created by Erland Isaksson on 2019-06-22.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class SelectDifficultyScene: SKScene {
    var gameDelegate: GameDelegate?
    var easyButton: SKLabelNode?
    var mediumButton: SKLabelNode?
    var hardButton: SKLabelNode?
    var veryHardButton: SKLabelNode?
    var completedButton: SKLabelNode?
    var inProgressButton: SKLabelNode?

    override func sceneDidLoad() {
        localize()
    }

    func setup(delegate: GameDelegate) {
        self.gameDelegate = delegate
        
        self.easyButton = childNode(withName:"easy") as? SKLabelNode
        self.mediumButton = childNode(withName:"medium") as? SKLabelNode
        self.hardButton = childNode(withName:"hard") as? SKLabelNode
        self.veryHardButton = childNode(withName:"veryHard") as? SKLabelNode
        self.completedButton = childNode(withName:"completed") as? SKLabelNode
        self.inProgressButton = childNode(withName:"inProgress") as? SKLabelNode
    }
    
    override func didMove(to view: SKView) {
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if easyButton!.contains(touchLocation) {
            gameDelegate?.selectedDifficulty(difficulty: Difficulty.Easy)
        }else if mediumButton!.contains(touchLocation) {
            gameDelegate?.selectedDifficulty(difficulty: Difficulty.Medium)
        }else if hardButton!.contains(touchLocation) {
            gameDelegate?.selectedDifficulty(difficulty: Difficulty.Hard)
        }else if veryHardButton!.contains(touchLocation) {
            gameDelegate?.selectedDifficulty(difficulty: Difficulty.VeryHard)
        }else if completedButton!.contains(touchLocation) {
            gameDelegate?.selectedCompletedLevels()
        }else if inProgressButton!.contains(touchLocation) {
            gameDelegate?.selectedInProgressLevels()
        }
    }
}
