//
//  ViewController.swift
//  IOS_Senin_8_Arkanoid
//
//  Created by Jenya on 15.02.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func viewDidAppear(_ animated: Bool) {
        addRocket()
        addBall()
        
        
        start()
    }
    
    var viewRocket: UIView!
    func addRocket() {
        
        viewRocket = UIView(frame: CGRect(x: 30, y: UIScreen.main.bounds.size.height - 100, width: 150, height: 30))
        viewRocket.layer.cornerRadius = 5
        viewRocket.backgroundColor = UIColor.orange
        view.addSubview(viewRocket)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
        viewRocket.gestureRecognizers = [pan]
    }
    
    var centerRocket: CGPoint!
    @objc func pan(pgr: UIPanGestureRecognizer) {
        
        if pgr.state == .began {
            centerRocket = viewRocket.center
        }
        
        let x = pgr.translation(in: view).x
        let newCenter = CGPoint(x: centerRocket.x+x, y: centerRocket.y)
        
        viewRocket.center = newCenter
    }
    
    struct Vector {
        var a: CGPoint
        var b: CGPoint
        var dx: CGFloat {
            return b.x - a.x
        }
        var dy: CGFloat {
            return b.y - a.y
        }
    }
    
    struct Game {
        
        var center: CGPoint
        var vector: Vector
        
        var viewBall: UIView
        var viewParent: UIView
        
        var viewRocket: UIView
        
        var viewBlocks: [UIView] = []
        
            
        
        init(in viewParent: UIView, viewRocket: UIView) {
            self.viewParent = viewParent
            self.viewRocket = viewRocket
            
            center = viewParent.center
            vector = Vector(a: CGPoint(x: 0, y: 0), b: CGPoint(x: 5, y: 5))
            viewBall = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            viewBall.layer.cornerRadius = 5
            viewBall.backgroundColor = UIColor.red
            viewBall.center = center
            viewParent.addSubview(viewBall)
            
            
            for _ in 0...20 {
                let block = UIView(frame: CGRect(x: CGFloat.random(in: 0...viewParent.frame.width), y: CGFloat.random(in:  0...400), width: 100, height: 33))
                    block.layer.cornerRadius = 7
                    block.layer.borderColor = UIColor.gray.cgColor
                    block.layer.borderWidth = 1
                    block.backgroundColor = UIColor.green
                    viewParent.addSubview(block)
                    viewBlocks.append(block)
            }
            
        }
        
        mutating func tic() {
            
            let newCenter = CGPoint(x: center.x + vector.dx, y: center.y + vector.dy)
            
            let isHitResult = isHit(oldPosition: center, newPosition: newCenter, rect: viewRocket.frame)
            
            if isHitResult == .x {
                vector.b.x = -vector.b.x
                vector.b.y = vector.b.y + CGFloat.random(in: -3...3)
            }
            if isHitResult == .y {
                vector.b.y = -vector.b.y
                vector.b.x = vector.b.x + CGFloat.random(in: -5...5)
            }
        
            var indexBlock: Int?
            for (index, b) in viewBlocks.enumerated() {
                
                let isHitResult = isHit(oldPosition: center, newPosition: newCenter, rect: b.frame)
                
                if isHitResult ==  .x {
                    vector.b.x = -vector.b.x
                    vector.b.y = vector.b.y + CGFloat.random(in: -3...3)
                    indexBlock = index
                }
                if isHitResult == .y {
                    vector.b.y = -vector.b.y
                    vector.b.x = vector.b.x + CGFloat.random(in: -5...5)
                    indexBlock = index
                    
                }
            }
            
            if let indexBlock = indexBlock {
                let block = viewBlocks[indexBlock]
                
                UIView.animate(withDuration: 0.2) {
                    block.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                } completion: { (Bool) in
                    block.removeFromSuperview()
                }
                
                viewBlocks.remove(at: indexBlock)
            }
            
            center = newCenter
            viewBall.center = newCenter
            
            if newCenter.x >= viewParent.frame.size.width  || newCenter.x <= 0 {
                vector.b.x = -vector.b.x
            }
            if newCenter.y >= viewParent.frame.size.height  || newCenter.y <= 0 {
                vector.b.y = -vector.b.y
            }
            
            
            
        }
        
        
        enum HitTarget {
            case x
            case y
        }
        
        func isHit(oldPosition: CGPoint, newPosition: CGPoint, rect: CGRect) -> HitTarget?
        {
            if oldPosition.x < rect.origin.x && newPosition.x >= rect.origin.x && newPosition.y >= viewRocket.frame.origin.y && newPosition.y <= rect.origin.y + rect.size.height
            {
                return .x
            }
            
            if oldPosition.x > rect.origin.x + rect.size.width && newPosition.x <= rect.origin.x + rect.size.width && newPosition.y >= rect.origin.y && newPosition.y <= rect.origin.y + rect.size.height
            {
                return .x
            }
            
            if oldPosition.y < rect.origin.y && newPosition.y >= rect.origin.y && newPosition.x >= rect.origin.x && newPosition.x <= rect.origin.x + rect.size.width
            {
                return .y
            }
            
            if oldPosition.y > rect.origin.y + rect.size.height && newPosition.y <= rect.origin.y + rect.size.height && newPosition.x >= rect.origin.x && newPosition.x <= rect.origin.x + rect.size.width
            {
                return .y
            }
            
            return nil
        }
        
    }
    
    var game: Game!
    func addBall() {
        
        game = Game(in: self.view, viewRocket: viewRocket)
        
    }
    
    
    func start() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            self.game.tic()
        }
    }
}

