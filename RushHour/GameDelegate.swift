//
//  GameDelegate.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol GameDelegate {
    func gameCompleted(board: Board, seconds: Int)
    func finishedGame()
    func selectedDifficulty(difficulty: Difficulty)
    func selectedCompletedLevels()
    func selectedInProgressLevels()
    func selectedRandomLevels()
    func selectedLevel(board: Board, startTime: Int)
}
