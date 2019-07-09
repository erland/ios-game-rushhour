//
//  GameScene.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class SingleGameScene: SKScene, BoardObserver {
    var boardView: BoardView?
    var gameDelegate: GameDelegate?
    var selectedCar : Car?
    var selectedOffsetX : Int?
    var selectedOffsetY : Int?
    var timeText : SKLabelNode?
    var recordLabel : SKLabelNode?
    var recordTime : SKLabelNode?
    var timeCounter : Int = 0
    var record : Int?
    var restartButton : SKLabelNode?
    var quitButton : SKLabelNode?
    var movesText : SKLabelNode?
    var moveCounter : Int = 0
    var lastTouchX : Int?
    var lastTouchY : Int?

    func setup(delegate: GameDelegate, board: Board, startTime: Int, moves: Int) {
        self.gameDelegate = delegate
        
        self.boardView = childNode(withName: "board") as? BoardView
        let boardNameLabel = childNode(withName: "boardName") as? SKLabelNode
        boardNameLabel?.text = board.name
        self.boardView?.setup(board: board)
        self.restartButton = childNode(withName: "restart") as? SKLabelNode
        self.quitButton = childNode(withName: "quit") as? SKLabelNode
        self.movesText = childNode(withName: "moves") as? SKLabelNode

        self.timeText = childNode(withName: "time") as? SKLabelNode
        self.recordLabel = childNode(withName: "record") as? SKLabelNode
        self.recordTime = childNode(withName: "recordTime") as? SKLabelNode
        let recordState = LevelStorage().getRecord(board: board)
        if recordState != nil {
            record = recordState!.seconds
            recordTime?.text = timeAsString(recordState!.seconds)
        }else {
            record = nil
            recordLabel?.isHidden = true
            recordTime?.isHidden = true
        }
        timeCounter = startTime
        displayTime()

        moveCounter = moves
        displayMoves()
        
        boardView?.board?.attachObserver(self)
    }
    deinit {
        boardView?.board?.detachObserver(self)
    }
    
    override func didMove(to view: SKView) {
        print("Moved to game scene")
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTimer() {
        timeCounter = timeCounter + 1
        displayTime()
    }
    
    func timeAsString(_ seconds: Int) -> String {
        let hours = Int(seconds/3600)
        let minutes = String(format: "%02d",Int((seconds%3600)/60))
        let seconds = String(format: "%02d",Int(seconds%60))
        if hours == 0 {
            return  "\(minutes):\(seconds)"
        }else {
            return "\(hours):\(minutes):\(seconds)"
        }
    }
    
    func displayTime() {
        if record != nil && timeCounter>record! {
            timeText?.fontColor = .red
        }
        timeText?.text = "\(timeAsString(timeCounter))"
    }

    func displayMoves() {
        if let maxMoves = boardView!.board?.moves {
            movesText?.text = "Moves: \(moveCounter)/\(maxMoves)"
            if moveCounter>maxMoves {
                movesText?.fontColor = .red
            }else {
                movesText?.fontColor = .white
            }
        }else {
            movesText?.text = "Moves: \(moveCounter)"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)

        if boardView!.contains(touchLocation) {
            selectCar(position: touchLocation)
            lastTouchX = Int((touchLocation.x-boardView!.position.x)/boardView!.cellSize!)
            lastTouchY = Int((boardView!.position.y-touchLocation.y)/boardView!.cellSize!)
        }else if quitButton!.contains(touchLocation) {
            gameDelegate?.gameCompleted(board: boardView!.board!, seconds: timeCounter, moves: moveCounter)
        }else if restartButton!.contains(touchLocation) {
            boardView?.board?.reset()
            moveCounter = 0
            displayMoves()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if let selectedCar = selectedCar {
            moveCar(car: selectedCar, position: touchLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if let selectedCar = selectedCar {
            let releaseX = Int((touchLocation.x-boardView!.position.x)/boardView!.cellSize!)
            let releaseY = Int((boardView!.position.y-touchLocation.y)/boardView!.cellSize!)
            if lastTouchX != releaseX || lastTouchY != releaseY {
                moveCounter = moveCounter + 1
                displayMoves()
            }
            moveCar(car: selectedCar, position: touchLocation)
        }

        if let selectedCar = selectedCar {
            selectedCar.selected = false
        }
        selectedCar = nil
    }
    
    func selectCar(position: CGPoint) {
        let cellX = Int((position.x-boardView!.position.x)/boardView!.cellSize!)
        let cellY = Int((boardView!.position.y-position.y)/boardView!.cellSize!)
        selectedCar = boardView?.board?[cellX, cellY]
        if let selectedCar = selectedCar {
            if selectedCar.color != "x" {
                selectedCar.selected = true
                selectedOffsetX = cellX-selectedCar.x
                selectedOffsetY = cellY-selectedCar.y
            }else {
                self.selectedCar = nil
            }
        }else {
            selectedOffsetX = nil
            selectedOffsetY = nil
        }
    }

    func moveCar(car: Car, position: CGPoint) {
        if let selectedOffsetX = selectedOffsetX {
            if let selectedOffsetY = selectedOffsetY {
                let cellX = Int((position.x-boardView!.position.x)/boardView!.cellSize!)
                let cellY = Int((boardView!.position.y-position.y)/boardView!.cellSize!)
                boardView?.board?.moveCar(car: car, x: cellX-selectedOffsetX, y: cellY-selectedOffsetY)
                if boardView!.board!.isExitPosition(car: car) {
                    let completionMoves = moveCounter + 1
                    displayMoves()
                    selectedCar = nil
                    car.selected = false
                    let carView = boardView?.viewForCar(car: car)
                    carView?.run(SKAction.sequence([
                        SKAction.move(by: CGVector(dx: boardView!.cellSize!*3, dy: 0.0), duration: 0.5),
                        SKAction.run( {
                            self.gameDelegate?.gameCompleted(board: self.boardView!.board!, seconds: self.timeCounter, moves: completionMoves)
                        })])
                    )
                }
            }
        }
    }
    

    
    func carAdded(_ car: Car) {
        // Do nothing
    }
    
    func carRemoved(_ car: Car) {
        // Do nothing
    }
}
