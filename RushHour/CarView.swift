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
    let selectedTexture: SKTexture?
    let mainTexture: SKTexture?
    let car : Car
    
    init(car: Car, cellSize: CGFloat) {
        self.cellSize = cellSize
        self.car = car
        let color = CarView.colorForCharacter(car.color)
        self.mainTexture = CarView.createCarTexture(length: car.length, cellSize: cellSize, borderColor: UIColor.red, fillColor: color, alpha: 1)
        self.selectedTexture = CarView.createCarTexture(length: car.length, cellSize: cellSize, borderColor: UIColor.red, fillColor: color, alpha: 0.5)
        super.init(texture: mainTexture, color: UIColor.black, size: CGSize(width: CGFloat(car.length)*cellSize, height: cellSize))
        car.attachObserver(observer: self)
        anchorPoint = CGPoint(x: 0, y: 1)
        carUpdated(car: car)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func colorForCharacter(_ color: Character) -> UIColor {
        switch(color) {
        case "A":
            return .red
        case "B":
            return UIColor.init(red: 214/255, green: 255/255, blue: 219/255, alpha: 1.0)
        case "C":
            return .orange
        case "D":
            return UIColor.init(red: 214/255, green: 236/255, blue: 255/255, alpha: 1.0)
        case "E":
            return UIColor.init(red: 255/255, green: 214/255, blue: 250/255, alpha: 1.0)
        case "F":
            return .purple
        case "G":
            return .green
        case "H":
            return .lightGray
        case "I":
            return UIColor.init(red: 252/255, green: 240/255, blue: 192/255, alpha: 1.0)
        case "J":
            return .yellow
        case "K":
            return .brown
        case "L":
            return UIColor.init(red: 218/255, green: 252/255, blue: 43/255, alpha: 1.0)
        case "M":
            return .orange
        case "N":
            return .purple
        case "O":
            return .blue
        case "P":
            return .green
        case "x":
            return .white
        default:
            return .yellow
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
            texture = selectedTexture
        }else {
            texture = mainTexture
        }
    }
    
    
}

