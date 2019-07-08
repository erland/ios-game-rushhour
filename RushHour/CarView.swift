//
//  CarView.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class CarView : SKSpriteNode, CarObserver {
    let cellSize: CGFloat
    let car : Car
    
    init(car: Car, cellSize: CGFloat) {
        self.cellSize = cellSize
        self.car = car
        let texture = CarView.textureForCar(color: car.color, length: car.length)
        super.init(texture: texture, color: UIColor.black, size: CGSize(width: CGFloat(car.length)*cellSize, height: cellSize))
        car.attachObserver(observer: self)
        anchorPoint = CGPoint(x: 0, y: 1)
        carUpdated(car: car)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func textureForCar(color: Character, length: Int) -> SKTexture {
        switch(color) {
        case "A":
            return SKTexture(imageNamed: "car\(length)red")
        case "B":
            return SKTexture(imageNamed: "car\(length)lightgreen")
        case "C":
            return SKTexture(imageNamed: "car\(length)lightred")
        case "D":
            return SKTexture(imageNamed: "car\(length)lightcyan")
        case "E":
            return SKTexture(imageNamed: "car\(length)lightpurple")
        case "F":
            return SKTexture(imageNamed: "car\(length)darkpurple")
        case "G":
            return SKTexture(imageNamed: "car\(length)darkgreen")
        case "H":
            return SKTexture(imageNamed: "car\(length)lightred")
        case "I":
            return SKTexture(imageNamed: "car\(length)darkyellow")
        case "J":
            return SKTexture(imageNamed: "car\(length)yellow")
        case "K":
            return SKTexture(imageNamed: "car\(length)darkblue")
        case "L":
            return SKTexture(imageNamed: "car\(length)blue")
        case "M":
            return SKTexture(imageNamed: "car\(length)green")
        case "N":
            return SKTexture(imageNamed: "car\(length)cyan")
        case "O":
            return SKTexture(imageNamed: "car\(length)darkred")
        case "P":
            return SKTexture(imageNamed: "car\(length)darkcyan")
        case "x":
            return SKTexture(imageNamed: "blocked\(length)")
        default:
            return SKTexture(imageNamed: "car\(length)yellow")
        }
    }
    private class func createCarTexture(length: Int, cellSize: CGFloat, borderColor: UIColor, fillColor: UIColor, alpha: CGFloat) -> SKTexture? {
        var cornerRadius = cellSize/4
        
        if fillColor == .white {
            cornerRadius = 0
        }
        let shape = SKShapeNode.init(rectOf: CGSize(width: CGFloat(length)*cellSize,
                                                    height: cellSize), cornerRadius: cornerRadius)
        shape.fillColor = fillColor
        if fillColor == .white {
            shape.strokeColor = fillColor
        }else {
            shape.strokeColor = borderColor
        }
        shape.alpha = alpha
        let view = SKView(frame: CGRect(x: 0, y: 0, width: CGFloat(length)*cellSize, height: cellSize))
        return view.texture(from: shape)
    }
    
    func carUpdated(car: Car) {
        let positionX = CGFloat(car.x)*cellSize+cellSize/2.0
        let positionY = -CGFloat(car.y)*cellSize-cellSize/2.0
        self.position = CGPoint(x: positionX, y: positionY)
        if car.orientation == .Horizontal {
            self.zRotation = 0
        }else {
            self.zRotation = -CGFloat.pi/2
        }
        if car.selected {
            alpha = 0.5
        }else {
            alpha = 1.0
        }
    }
    
    
}

