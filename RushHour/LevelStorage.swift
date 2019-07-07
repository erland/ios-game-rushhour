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
    let hints : Int
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case seconds = "seconds"
        case original = "original"
        case current = "current"
        case hints = "hints"
    }
    
    init(name: String, seconds: Int, original: String, current: String?, hints: Int) {
        self.name = name
        self.seconds = seconds
        self.original = original
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
        hints = try values.decodeIfPresent(Int.self, forKey: .hints) ?? 0
    }
    
}

struct LevelRecord : Codable {
    let original : String
    let seconds : Int
}

class LevelStorage {

    func initializeBoard(_ storedLevel: StoredLevel) -> Board {
        let board = Board(name: storedLevel.name, boardString: storedLevel.original)
        return board

    }
    func getCompletedBoards() -> [StoredLevel] {
        return loadData(StoredLevel.self, forKey: "completed")
    }
    
    func getBoardsInProgress() -> [StoredLevel] {
        return loadData(StoredLevel.self, forKey: "inProgress")
    }
    
    func storeBoardInProgress(board: Board, seconds: Int, hints: Int) {
        let storedLevel = serializeBoard(board: board, seconds: seconds, hints: hints)
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
    
    func storeCompletedBoard(board: Board, seconds: Int, hints: Int) {
        let storedLevel = serializeBoard(board: board, seconds: seconds, hints: hints, onlyPermanent: true)
        if hints==0 {
            registerRecord(boardNumbers: storedLevel.original, seconds: seconds)
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
    
    func serializeBoard(board: Board, seconds: Int, hints: Int, onlyPermanent: Bool = false) -> StoredLevel {
        let original = board.originalBoardString
        let current = board.asString()
        if onlyPermanent {
            return StoredLevel.init(name: board.name, seconds: seconds, original: original, current: "", hints: hints)
        }else {
            return StoredLevel.init(name: board.name, seconds: seconds, original: original, current: current, hints: hints)
        }
    }
    func registerRecord(boardNumbers: String, seconds: Int) {
        
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
            records.append(LevelRecord.init(original: boardNumbers, seconds: seconds))
        }
        storeData(records, forKey: "records")
    }

    func getRecord(boardNumbers: String) -> Int? {
        
        let records = loadData(LevelRecord.self, forKey: "records")
        for r in records {
            if r.original == boardNumbers {
                return r.seconds
            }
        }
        return nil
    }

    func getRecord(board: Board) -> Int? {
        let serializedBoard = serializeBoard(board: board, seconds: 0, hints: 0, onlyPermanent: true)
        let records = loadData(LevelRecord.self, forKey: "records")
        for r in records {
            if r.original == serializedBoard.original {
                return r.seconds
            }
        }
        return nil
    }

    func getInProgress(boardNumbers: String) -> Int? {
        
        let started = loadData(LevelRecord.self, forKey: "inProgress")
        for b in started {
            if b.original == boardNumbers {
                return b.seconds
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
