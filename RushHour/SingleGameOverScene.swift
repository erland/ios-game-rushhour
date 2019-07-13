//
//  SingleGameOverScene.swift
//  Sudoku
//
//  Created by Erland Isaksson on 2019-06-14.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class SingleGameOverScene: SKScene {
    var gameDelegate: GameDelegate?
    var boardView: BoardView?
    var openedTime: TimeInterval?
    var status: SKLabelNode?
    var completedIn: SKLabelNode?
    var movesText: SKLabelNode?
    var boardName: SKLabelNode?
    
    func setup(delegate: GameDelegate, board: Board, seconds: Int, moves: Int) {
        self.gameDelegate = delegate
        
        self.boardView = childNode(withName:"board") as? BoardView
        self.status = childNode(withName:"status") as? SKLabelNode
        self.boardName = childNode(withName:"boardName") as? SKLabelNode
        self.boardName?.text = board.name
        self.completedIn = childNode(withName:"completedIn") as? SKLabelNode
        self.movesText = childNode(withName:"moves") as? SKLabelNode
        self.boardView?.setup(board: board)
        if boardView!.board!.isCompleted() {
            if let car = board[board.width-1,board.exitRow] {
                if let carView = boardView!.viewForCar(car: car) {
                    carView.isHidden = true
                }
            }
            status?.text = "Congratulations!"
            let hours = Int(seconds/3600)
            let minutes = String(format: "%02d",Int((seconds%3600)/60))
            let seconds = String(format: "%02d",Int(seconds%60))
            if hours == 0 {
                completedIn?.text = "Completed in: \(minutes):\(seconds)"
            }else {
                completedIn?.text = "Completed in: \(hours):\(minutes):\(seconds)"
            }
            if let maxMoves = boardView!.board?.moves {
                movesText?.text = "Moves: \(moves)/\(maxMoves)"
            }else {
                movesText?.text = "Moves: \(moves)"
            }
        }else {
            status?.text = "Not completed"
            completedIn?.text = ""
            movesText?.text = ""
        }
        
    }
    
    override func didMove(to view: SKView) {
        openedTime = NSDate().timeIntervalSince1970
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // We need to ensure the sceen is shown for 2 seconds before we allow player to continue
        if openedTime!<NSDate().timeIntervalSince1970-2 {
            gameDelegate?.backToMenu()
        }
    }
}
