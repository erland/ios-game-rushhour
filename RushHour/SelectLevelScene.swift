//
//  SelectLevelScene.swift
//  Sudoku
//
//  Created by Erland Isaksson on 2019-06-22.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class SelectLevelScene: SKScene {
    var gameDelegate: GameDelegate?
    
    var boards : [BoardView] = []
    var boardTexts : [SKLabelNode] = []
    var timeTexts : [SKLabelNode] = []
    var minMoves : [SKLabelNode] = []
    var times : [Int] = []
    var moves: [Int] = []
    var loadingText : SKLabelNode?
    var backButton : SKLabelNode?
    var nextButton : SKLabelNode?
    var difficulty : Difficulty?
    var offset : Int = 0
    var levelType : LevelType?
    
    enum LevelType {
        case Completed
        case InProgress
        case Generated
        case Predefined
    }
    func setup(delegate: GameDelegate, difficulty: Difficulty?, type: LevelType) {
        self.gameDelegate = delegate
        self.difficulty = difficulty
        self.levelType = type
        
        loadingText = childNode(withName:"loading") as? SKLabelNode
        backButton = childNode(withName:"back") as? SKLabelNode
        nextButton = childNode(withName:"next") as? SKLabelNode

        for i in 1...12 {
            let boardView = childNode(withName:"board\(i)") as? BoardView
            if let boardView = boardView {
                boardView.isHidden = true
                boards.append(boardView)
            }
            let boardText = childNode(withName:"boardText\(i)") as? SKLabelNode
            if let boardText = boardText {
                boardText.isHidden = true
                boardTexts.append(boardText)
            }
            let timeText = childNode(withName:"timeText\(i)") as? SKLabelNode
            if let timeText = timeText {
                timeText.isHidden = true
                timeTexts.append(timeText)
            }
            let minMoves = childNode(withName:"minMoves\(i)") as? SKLabelNode
            if let minMoves = minMoves {
                minMoves.isHidden = true
                self.minMoves.append(minMoves)
            }
            times.append(0)
            moves.append(0)
        }
        fillContent(withOffset: 0)
    }
    
    func fillContent(withOffset offset: Int) {
        self.offset = offset
        for i in 0..<12 {
            boards[i].isHidden = true
            boardTexts[i].isHidden = true
            timeTexts[i].isHidden = true
            minMoves[i].isHidden = true
            times[i] = 0
            moves[i] = 0
        }
        loadingText?.isHidden = false

        let storage = LevelStorage()
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: {
            if self.levelType == .Completed {
                let storedBoards = storage.getCompletedBoards()
                for i in 1...12 {
                    if storedBoards.count>(offset+i-1) {
                        let storedBoard = storedBoards[offset+i-1]
                        let record = storage.getRecord(boardNumbers: storedBoard.original)
                        if record != nil {
                            self.times[i-1] = record!.seconds
                            self.moves[i-1] = record!.moves
                        }
                        DispatchQueue.main.async {
                            let board = storage.initializeBoard(storedBoard)
                            if record != nil && board.moves != nil && record!.moves <= board.moves! {
                                self.minMoves[i-1].isHidden = false
                            }
                            self.boards[i-1].setup(board: board)
                            self.boards[i-1].alpha = 0.3
                            self.boards[i-1].isHidden = false
                            self.boardTexts[i-1].text = "\(storedBoard.name)"
                            self.boardTexts[i-1].alpha = 0.3
                            self.boardTexts[i-1].isHidden = false
                            if self.times[i-1] > 0 {
                                self.timeTexts[i-1].text = "\(self.timeAsString(self.times[i-1]))"
                                self.timeTexts[i-1].isHidden = false
                                self.timeTexts[i-1].alpha = 0.3
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    if storedBoards.count>12 {
                        self.nextButton?.isHidden = false
                    }else {
                        self.nextButton?.isHidden = true
                    }
                    for i in 0..<12 {
                        if self.boards[i].alpha > 0.1 {
                            self.boards[i].alpha = 1.0
                            self.boardTexts[i].alpha = 1.0
                            if self.times[i]>0 {
                                self.timeTexts[i].alpha = 1.0
                            }
                        }
                    }
                    self.loadingText?.isHidden = true
                }
            }else if self.levelType == .InProgress {
                let storedBoards = storage.getBoardsInProgress()
                for i in 1...12 {
                    if storedBoards.count>(offset+i-1) {
                        let storedBoard = storedBoards[offset+i-1]
                        let record = storage.getRecord(boardNumbers: storedBoard.original)
                        DispatchQueue.main.async {
                            let board = storage.initializeBoard(storedBoard)
                            if record != nil && board.moves != nil && record!.moves <= board.moves! {
                                self.minMoves[i-1].isHidden = false
                            }
                            self.boards[i-1].setup(board: board)
                            self.boards[i-1].alpha = 0.3
                            self.boards[i-1].isHidden = false
                            self.boardTexts[i-1].text = "\(storedBoard.name)"
                            self.boardTexts[i-1].alpha = 0.3
                            self.boardTexts[i-1].isHidden = false
                            self.times[i-1] = storedBoard.seconds
                            self.moves[i-1] = storedBoard.moves
                            if self.times[i-1] > 0 {
                                self.timeTexts[i-1].text = "\(self.timeAsString(self.times[i-1]))..."
                                self.timeTexts[i-1].isHidden = false
                                self.timeTexts[i-1].alpha = 0.3
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    if storedBoards.count>12 {
                        self.nextButton?.isHidden = false
                    }else {
                        self.nextButton?.isHidden = true
                    }
                    for i in 0..<12 {
                        if self.boards[i].alpha > 0.1 {
                            self.boards[i].alpha = 1.0
                            self.boardTexts[i].alpha = 1.0
                            if self.times[i]>0 {
                                self.timeTexts[i].alpha = 1.0
                            }
                        }
                    }
                    self.loadingText?.isHidden = true
                }
            }else {
                let repository = LevelRepository()
                if let difficulty = self.difficulty {
                    for i in 1...12 {
                        let boardNumbers = repository.getLevel(difficulty: difficulty, level: offset+i)
                        if boardNumbers != nil {
                            let record = storage.getRecord(boardNumbers: boardNumbers!)
                            let inProgress = storage.getInProgress(boardNumbers: boardNumbers!)
                            if inProgress != nil {
                                self.times[i-1] = inProgress!.seconds
                                self.moves[i-1] = inProgress!.moves
                            }else {
                                if record != nil {
                                    self.times[i-1] = record!.seconds
                                    self.moves[i-1] = record!.moves
                                }
                            }
                            DispatchQueue.main.async {
                                let board = Board.init(name: "\(self.difficultyAsString(difficulty)) \(i+offset)", boardString: boardNumbers!)
                                if inProgress != nil && inProgress!.current.count>0 {
                                    board.initializeFromString(boardString: inProgress!.current)
                                }
                                if record != nil && board.moves != nil && record!.moves <= board.moves! {
                                    self.minMoves[i-1].isHidden = false
                                }
                                self.boards[i-1].setup(board: board)
                                self.boards[i-1].alpha = 0.3
                                self.boards[i-1].isHidden = false
                                self.boardTexts[i-1].text = "\(self.difficultyAsString(difficulty)) \(i+offset)"
                                self.boardTexts[i-1].alpha = 0.3
                                self.boardTexts[i-1].isHidden = false
                                if self.times[i-1] > 0 {
                                    if inProgress != nil {
                                        self.timeTexts[i-1].text = "\(self.timeAsString(self.times[i-1]))..."
                                    }else {
                                        self.timeTexts[i-1].text = "\(self.timeAsString(self.times[i-1]))"
                                    }
                                    self.timeTexts[i-1].isHidden = false
                                    self.timeTexts[i-1].alpha = 0.3
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if repository.getLevel(difficulty: difficulty, level: offset+13) != nil {
                            self.nextButton?.isHidden = false
                        }else {
                            self.nextButton?.isHidden = true
                        }

                        for i in 0..<12 {
                            if self.boards[i].alpha > 0.1 {
                                self.boards[i].alpha = 1.0
                                self.boardTexts[i].alpha = 1.0
                                if self.times[i]>0 {
                                    self.timeTexts[i].alpha = 1.0
                                }
                            }
                        }
                        self.loadingText?.isHidden = true
                    }
                }
            }
        })
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
    

    func difficultyAsString(_ difficulty: Difficulty) -> String {
        switch difficulty {
        case .Easy:
            return "Easy"
        case .Medium:
            return "Medium"
        case .Hard:
            return "Hard"
        case .VeryHard:
            return "Very hard"
        }
    }
    
    override func didMove(to view: SKView) {
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if backButton!.contains(touchLocation) {
            if offset == 0 || levelType == .Generated {
                gameDelegate?.finishedGame()
            }else {
                fillContent(withOffset: offset-12)
            }
        }else if nextButton!.contains(touchLocation) {
            fillContent(withOffset: offset+12)
        }else {
            for i in 0..<12 {
                if boards[i].contains(touchLocation) {
                    if boards[i].board != nil {
                        if timeTexts[i].text == nil || !timeTexts[i].text!.hasSuffix("...") {
                            gameDelegate?.selectedLevel(board: boards[i].board!, startTime: 0, moves: 0)
                        }else {
                            gameDelegate?.selectedLevel(board: boards[i].board!, startTime: times[i], moves: moves[i])
                        }
                        break
                    }
                }
            }
        }
    }
}
