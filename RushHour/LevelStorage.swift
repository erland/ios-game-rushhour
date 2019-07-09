//
//  BoardStorage.swift
//  Sudoku
//
//  Created by Erland Isaksson on 2019-06-23.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

struct StoredLevel : Codable {
    let name : String
    let seconds : Int
    let original : String
    let current : String
    let moves : Int
    let hints : Int
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case seconds = "seconds"
        case original = "original"
        case current = "current"
        case moves = "moves"
        case hints = "hints"
    }
    
    init(name: String, seconds: Int, original: String, current: String?, moves: Int, hints: Int) {
        self.name = name
        self.seconds = seconds
        self.original = original
        self.moves = moves
        if current != nil {
            self.current = current!
        }else {
            self.current = original
        }
        self.hints = hints
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        seconds = try values.decode(Int.self, forKey: .seconds)
        original = try values.decode(String.self, forKey: .original)
        current = try values.decode(String.self, forKey: .current)
        moves = try values.decodeIfPresent(Int.self, forKey: .moves) ?? 0
        hints = try values.decodeIfPresent(Int.self, forKey: .hints) ?? 0
    }
    
}

struct LevelRecord : Codable {
    let original : String
    let current : String
    let seconds : Int
    let moves : Int

    enum CodingKeys: String, CodingKey {
        case original = "original"
        case current = "current"
        case seconds = "seconds"
        case moves = "moves"
    }
    init(original: String, seconds: Int, moves: Int) {
        self.seconds = seconds
        self.current = ""
        self.original = original
        self.moves = moves
    }
    init(original: String, current: String, seconds: Int, moves: Int) {
        self.seconds = seconds
        self.current = current
        self.original = original
        self.moves = moves
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        original = try values.decode(String.self, forKey: .original)
        current = try values.decodeIfPresent(String.self, forKey: .current) ?? ""
        seconds = try values.decode(Int.self, forKey: .seconds)
        moves = try values.decodeIfPresent(Int.self, forKey: .moves) ?? 0
    }
}

class LevelStorage {

    func initializeBoard(_ storedLevel: StoredLevel) -> Board {
        let board = Board(name: storedLevel.name, boardString: storedLevel.original)
        if storedLevel.current.count>0 {
            board.initializeFromString(boardString: storedLevel.current)
        }
        return board

    }
    func getCompletedBoards() -> [StoredLevel] {
        return loadData(StoredLevel.self, forKey: "completed")
    }
    
    func getBoardsInProgress() -> [StoredLevel] {
        return loadData(StoredLevel.self, forKey: "inProgress")
    }
    
    func storeBoardInProgress(board: Board, seconds: Int, moves: Int, hints: Int) {
        let storedLevel = serializeBoard(board: board, seconds: seconds, moves: moves, hints: hints)
        var boards = loadData(StoredLevel.self, forKey: "inProgress")
        for (i,b) in boards.enumerated() {
            if b.original == storedLevel.original {
                boards.remove(at: i)
                break
            }
        }
        boards.insert(storedLevel, at: 0)
        while boards.count>60 {
            boards.remove(at: boards.count-1)
        }
        storeData(boards, forKey: "inProgress")
    }
    
    func removeBoardInProgress(storedLevel: StoredLevel) {
        var boards = loadData(StoredLevel.self, forKey: "inProgress")
        var removed = false
        for (i,b) in boards.enumerated() {
            if b.original == storedLevel.original {
                boards.remove(at: i)
                removed = true
                break
            }
        }
        if removed {
            storeData(boards, forKey: "inProgress")
        }
    }
    
    func storeCompletedBoard(board: Board, seconds: Int, moves: Int, hints: Int) {
        let storedLevel = serializeBoard(board: board, seconds: seconds, moves: moves, hints: hints, onlyPermanent: true)
        if hints==0 {
            registerRecord(boardNumbers: storedLevel.original, seconds: seconds, moves: moves)
        }
        var boards = loadData(StoredLevel.self, forKey: "completed")
        for (i,b) in boards.enumerated() {
            if b.original == storedLevel.original {
                boards.remove(at: i)
                break
            }
        }
        boards.insert(storedLevel, at: 0)
        while boards.count>60 {
            boards.remove(at: boards.count-1)
        }
        storeData(boards, forKey: "completed")
        removeBoardInProgress(storedLevel: storedLevel)
    }
    
    func serializeBoard(board: Board, seconds: Int, moves: Int, hints: Int, onlyPermanent: Bool = false) -> StoredLevel {
        let original = board.originalBoardString
        let current = board.asString()
        if onlyPermanent {
            return StoredLevel.init(name: board.name, seconds: seconds, original: original, current: "", moves: moves, hints: hints)
        }else {
            return StoredLevel.init(name: board.name, seconds: seconds, original: original, current: current, moves: moves, hints: hints)
        }
    }
    func registerRecord(boardNumbers: String, seconds: Int, moves: Int) {
        
        var records = loadData(LevelRecord.self, forKey: "records")
        var shouldBeAdded = true
        for (i,r) in records.enumerated() {
            if r.original == boardNumbers {
                if r.seconds < seconds {
                    shouldBeAdded = false
                }else {
                    records.remove(at: i)
                }
                break
            }
        }
        if shouldBeAdded {
            records.append(LevelRecord.init(original: boardNumbers, seconds: seconds, moves: moves))
        }
        storeData(records, forKey: "records")
    }

    struct LevelState {
        let current : String
        let seconds : Int
        let moves : Int
    }
    
    func getRecord(boardNumbers: String) -> LevelState? {
        
        let records = loadData(LevelRecord.self, forKey: "records")
        for r in records {
            if r.original == boardNumbers {
                return LevelState(current: "", seconds: r.seconds, moves: r.moves)
            }
        }
        return nil
    }

    func getRecord(board: Board) -> LevelState? {
        let serializedBoard = serializeBoard(board: board, seconds: 0, moves: 0, hints: 0, onlyPermanent: true)
        let records = loadData(LevelRecord.self, forKey: "records")
        for r in records {
            if r.original == serializedBoard.original {
                return LevelState(current: "", seconds: r.seconds, moves: r.moves)
            }
        }
        return nil
    }

    func getInProgress(boardNumbers: String) -> LevelState? {
        
        let started = loadData(LevelRecord.self, forKey: "inProgress")
        for b in started {
            if b.original == boardNumbers {
                return LevelState(current: b.current, seconds: b.seconds, moves: b.moves)
            }
        }
        return nil
    }

    func storeData<T: Codable>(_ value: [T], forKey defaultName: String){
        let data = value.map { try? JSONEncoder().encode($0) }
        
        UserDefaults.standard.set(data, forKey: defaultName)
    }
    
    func loadData<T>(_ type: T.Type, forKey defaultName: String) -> [T] where T : Decodable {
        guard let encodedData = UserDefaults.standard.array(forKey: defaultName) as? [Data] else {
            return []
        }
        
        return encodedData.map { try! JSONDecoder().decode(type, from: $0) }
    }
    
}
