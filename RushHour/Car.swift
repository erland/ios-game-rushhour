//
//  Car.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol CarObserver {
    func carUpdated(car: Car)
}
enum Orientation {
    case Horizontal
    case Vertical
}
class Car : Hashable, NSCopying {
    var observers: [CarObserver] = []
    
    init(color: Character, orientation: Orientation, length: Int, x: Int, y: Int) {
        self.x = x
        self.y = y
        self.color = color
        self.orientation = orientation
        self.length = length
        self.selected = false
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Car(color: self.color, orientation: self.orientation, length: self.length, x: self.x,y: self.y)
        copy.selected = self.selected
        return copy
    }
    
    func attachObserver(observer: CarObserver) {
        observers.append(observer)
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.carUpdated(car: self)
        }
    }
    var x: Int {
        didSet {
            notifyObservers()
        }
    }
    var y: Int {
        didSet {
            notifyObservers()
        }
    }
    var length: Int {
        didSet {
            notifyObservers()
        }
    }
    var selected: Bool {
        didSet {
            notifyObservers()
        }
    }
    var orientation: Orientation {
        didSet {
            notifyObservers()
        }
    }
    var color: Character {
        didSet {
            notifyObservers()
        }
    }
    
    static func == (lhs: Car, rhs: Car) -> Bool {
        return lhs === rhs
    }
    var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}

