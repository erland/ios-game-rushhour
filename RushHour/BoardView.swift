//
//  BoardView.swift
//  RushHour
//
//  Created by Erland Isaksson on 2019-07-07.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BoardView : SKSpriteNode, BoardObserver {
    
    var board: Board?
    var cellSize: CGFloat?
    var scale: CGFloat?
    
    func setup(board: Board) {
        self.cellSize = size.width/CGFloat(board.width)
        print("\(size.width) with \(board.width) gives cellSize=\(cellSize!)")
        self.board = board
        self.scale = cellSize!/50.0
        let texture = BoardView.createBoardTexture(x: board.width, y: board.height, cellSize: cellSize!)
        let gridTexture = BoardView.createBoardGridTexture(x: board.width, y: board.height, frameSize: cellSize!/10, cellSize: cellSize!, exitRow: board.exitRow)
        
        
        self.texture = texture
        self.color = UIColor.black
        let gridSprite = SKSpriteNode(texture: gridTexture)
        gridSprite.anchorPoint = CGPoint(x: 0.0,y: 1.0)
        gridSprite.position = CGPoint(x: -cellSize!/10-1, y: cellSize!/10+1)
        gridSprite.zPosition = 1
        addChild(gridSprite)
        
        board.attachObserver(self)
    }
    
    private class func createBoardTexture(x: Int, y: Int, cellSize: CGFloat) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize

        let shape = SKShapeNode.init(rectOf: CGSize(width: boardWidth, height: boardHeight))
        shape.fillColor = UIColor.darkGray
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight))
        return view.texture(from: shape)
    }
    
    private class func createBoardGridTexture(x: Int, y: Int, frameSize: CGFloat, cellSize: CGFloat, exitRow: Int) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize
        let border = SKShapeNode.init(rectOf: CGSize(width: boardWidth+frameSize,
                                                     height: boardHeight+frameSize))
        border.strokeColor = UIColor.white
        border.lineWidth = frameSize
        for row in 1..<(y) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: 0.0, y: CGFloat(row)*cellSize),
                                            to: CGPoint(x: boardWidth, y: CGFloat(row)*cellSize))
            line.strokeColor = .white
            border.addChild(line)
        }
        for column in 1..<(x) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                            from: CGPoint(x: CGFloat(column)*cellSize, y: 0),
                                            to: CGPoint(x: CGFloat(column)*cellSize, y: boardHeight))
            line.strokeColor = .white
            border.addChild(line)
        }
        let opening = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                           from: CGPoint(x: CGFloat(x)*cellSize+frameSize/2,
                                                         y: CGFloat(exitRow+1)*cellSize),
                                           to: CGPoint(x: CGFloat(x)*cellSize+frameSize/2,
                                                       y: CGFloat(exitRow+2)*cellSize))
        opening.lineWidth = frameSize
        opening.strokeColor = .black
        opening.alpha = 0.001
        opening.blendMode = .replace
        border.addChild(opening)
        
        let arrow = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: boardWidth/2+frameSize*2,y: -boardHeight/2+CGFloat(exitRow+1)*cellSize+cellSize/4))
        path.addLine(to: CGPoint(x: boardWidth/2+frameSize*2, y: -boardHeight/2+CGFloat(exitRow+2)*cellSize-cellSize/4))
        path.addLine(to: CGPoint(x: boardWidth/2+frameSize*2+cellSize/2, y: -boardHeight/2+CGFloat(exitRow+2)*cellSize-cellSize/2))
        path.addLine(to: CGPoint(x: boardWidth/2+frameSize*2,y: -boardHeight/2+CGFloat(exitRow+1)*cellSize+cellSize/4))
        arrow.path = path
        arrow.fillColor = .white
        arrow.strokeColor = .white
        border.addChild(arrow)
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth+frameSize, height: boardHeight+frameSize))
        return view.texture(from: border)
    }
    
    private class func createLine(anchor: CGPoint, from:CGPoint, to: CGPoint) -> SKShapeNode {
        let lineShape = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: anchor.x+from.x, y: anchor.y+from.y))
        path.addLine(to: CGPoint(x: anchor.x+to.x, y: anchor.y+to.y))
        lineShape.path = path
        return lineShape
    }
    
    func carAdded(_ car: Car) {
        let carView = CarView(car: car, cellSize: cellSize!)
        carView.anchorPoint = CGPoint(x: 1.0/(CGFloat(car.length)*2.0), y: 0.5)
        carView.name = "car"
        carView.zPosition = 10
        addChild(carView)
    }
    
    func carRemoved(_ car: Car) {
        if let carView = viewForCar(car: car) {
            carView.removeFromParent()
        }
    }
    
    func viewForCar(car: Car) -> CarView? {
        var result: CarView?
        enumerateChildNodes(withName: "car") {
            (node, stop) in
            if node is CarView {
                let carView  = node as! CarView
                if carView.car === car {
                    result = carView
                }
            }
        }
        return result
    }
}

