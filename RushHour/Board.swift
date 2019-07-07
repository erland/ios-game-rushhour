//
//  Board.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BoardObserver : class {
    func carAdded(_ car: Car)
    func carRemoved(_ car: Car)
}
class Board {
    let name: String
    let width: Int = 6
    let height: Int = 6
    let board: Array2D<Car>
    var cars: Set<Car> = Set()
    var observers: [BoardObserver] = []
    let debug = false
    let exitRow: Int
    var originalBoardString: String = ""
    
    init(name: String, board: Array2D<Car>) {
        self.name = name
        self.board = board
        self.exitRow = Int(height/2)-1
    }
    
    init(name: String) {
        self.name = name
        self.board = Array2D<Car>(columns: self.width, rows: self.height)
        self.exitRow = Int(height/2)-1
    }
    
    convenience init(name: String, boardString: String) {
        self.init(name: name)
        originalBoardString = boardString
        initializeFromString(boardString: boardString)
    }
    
    
    func attachObserver(_ observer: BoardObserver) {
        for car in cars {
            observer.carAdded(car)
        }
        observers.append(observer)
    }
    
    func detachObserver(_ observer: BoardObserver) {
        if let index = (self.observers.firstIndex(where: { $0 === observer })) {
            self.observers.remove(at: index)
        }
    }
    
    func initializeFromString(boardString: String) {
        for car in cars {
            removeCarFromBoard(car)
            for observer in observers {
                observer.carRemoved(car)
            }
        }
        cars.removeAll()

        for y in 0..<height {
            for x in 0..<width {
                let i = width*y+x
                if boardString.count > i {
                    let ch = boardString[boardString.index(boardString.startIndex, offsetBy: i)]
                    if ch != "o" && ch != "." {
                        if board[x,y] == nil {
                            var length = 1
                            var orientation = Orientation.Horizontal
                            for offset in 1..<width {
                                if x+offset<width {
                                    let ch2 = boardString[boardString.index(boardString.startIndex, offsetBy: i+offset)]
                                    if ch2 == ch {
                                        length = length + 1
                                    }else {
                                        break
                                    }
                                }else {
                                    break
                                }
                            }
                            if length == 1 {
                                orientation = .Vertical
                                for offset in 1..<height {
                                    if y+offset<height {
                                        let ch2 = boardString[boardString.index(boardString.startIndex, offsetBy: i+offset*width)]
                                        if ch2 == ch {
                                            length = length + 1
                                        }else {
                                            break
                                        }
                                    }else {
                                        break
                                    }
                                }
                            }
                            addCar(color: ch, orientation: orientation, length: length, x: x, y: y)
                        }
                    }
                }
            }
        }
    }
    subscript(x: Int, y: Int) -> Car? {
        get {
            return board[x,y]
        }
    }

    private func isInsideBoard(x: Int, y: Int, orientation: Orientation, length: Int) -> Bool {
        if orientation == .Vertical {
            if x<0 || x >= width || y<0 || y+length > height {
                // Outside board
                if debug {
                    print("Outside board")
                }
                return false
            }
        }else {
            if x<0 || x+length > width || y<0 || y >= height {
                // Outside board
                if debug {
                    print("Outside board")
                }
                return false
            }
        }
        return true
    }
    
    func isCompleted() -> Bool {
        if let car = board[width-1,exitRow] {
            return isExitPosition(car: car)
        }
        return false
    }
    
    func isExitPosition(car: Car) -> Bool {
        if car.orientation == .Horizontal && car.color == "A" && car.x+car.length >= width && car.y == exitRow {
            return true
        }
        return false
    }
    private func isMovePossible(car: Car, x: Int, y: Int) -> Bool {
        if !isInsideBoard(x: x, y: y, orientation: car.orientation, length: car.length) {
            return false
        }
        if car.color == "x" {
            return false
        }
        if car.orientation == .Vertical {
            if car.x != x {
                return false
            }
            var posY = car.y
            while posY != y && (board[x,posY] == nil || board[x,posY] === car) {
                if car.y<y {
                    posY = posY + 1
                }else {
                    posY = posY - 1
                }
            }
            if posY != y {
                return false
            }
            for offset in 0..<car.length {
                if board[x,y+offset] != nil && board[x,y+offset] !== car {
                    return false
                }
            }
        }else {
            if car.y != y {
                return false
            }
            var posX = car.x
            while posX != x && (board[posX,y] == nil || board[posX,y] === car) {
                if car.x<x {
                    posX = posX + 1
                }else {
                    posX = posX - 1
                }
            }
            if posX != x {
                return false
            }

            for offset in 0..<car.length {
                if board[x+offset,y] != nil && board[x+offset,y] !== car {
                    return false
                }
            }
        }
        return true
    }

    func addCar(color: Character, orientation: Orientation, length: Int, x: Int, y: Int) {
        if !isInsideBoard(x: x, y: y, orientation: orientation, length: length) {
            return
        }
        if board[x,y] != nil {
            // Already occupied
            if debug {
                print("Already occupied")
            }
            return
        }
        
        let car = Car(color: color, orientation: orientation, length: length, x: x, y: y)
        addCarToBoard(car)
        cars.insert(car)
        for observer in observers {
            observer.carAdded(car)
        }
        
        if debug {
            print("Board(\(name)): Added \(orientation),\(length),\(color) at: \(x),\(y)")
            debugBoard()
        }
    }
    
    private func addCarToBoard(_ car: Car) {
        if car.orientation == .Vertical {
            for offset in 0..<car.length {
                board[car.x,car.y+offset] = car
            }
        }else {
            for offset in 0..<car.length {
                board[car.x+offset,car.y] = car
            }
        }
    }
    
    private func removeCarFromBoard(_ car: Car) {
        if car.orientation == .Vertical {
            for offset in 0..<car.length {
                board[car.x,car.y+offset] = nil
            }
        }else {
            for offset in 0..<car.length {
                board[car.x+offset,car.y] = nil
            }
        }
    }

    func moveCar(car: Car, x: Int, y: Int) {
        if !isMovePossible(car: car, x: x, y: y) {
            return
        }
        
        removeCarFromBoard(car)
        car.x = x
        car.y = y
        addCarToBoard(car)
        
        if debug {
            print("Board(\(name)): Moved to \(car.orientation),\(car.length),\(car.color) at: \(x),\(y)")
            debugBoard()
        }
    }

    func asString() -> String {
        var result = ""
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] != nil {
                    let n = board[x,y]
                    result = result + "\(n!.color)"
                }else {
                    result = result + "o"
                }
            }
        }
        return result
    }
    
    func debugBoard(debug: Bool? = nil) {
        if self.debug || (debug != nil && debug!) {
            
            print("Board contents")
            for y in 0..<height {
                for x in 0..<width {
                    if board[x,y] != nil {
                        let n = board[x,y]
                        print("\(n!.color)", terminator: "")
                    }else {
                        print("o", terminator: "")
                    }
                }
                print()
            }
        }
    }
    
}
