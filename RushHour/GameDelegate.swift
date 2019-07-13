//
//  GameDelegate.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol GameDelegate {
    func gameCompleted(board: Board, seconds: Int, moves: Int)
    func restartGame()
    func backToMenu()
    func selectedDifficulty(difficulty: Difficulty)
    func selectedCompletedLevels()
    func selectedInProgressLevels()
    func selectedLevel(board: Board, startTime: Int, moves: Int, offset: Int)
}
