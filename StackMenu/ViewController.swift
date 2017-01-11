//
//  ViewController.swift
//  StackMenu
//
//  Created by Sanjay Mali on 11/01/17.
//  Copyright © 2017 Sanjay. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollisionBehaviorDelegate{
    let data = ["Steve Jobs","Steve Wozniak","Ronald Wayne","Tim Cook"]
    var views = [UIView]()
    var animator:UIDynamicAnimator!
    var gravity:UIGravityBehavior!
    var snap:UISnapBehavior!
    var pretouchPoint:CGPoint!
    var viewDrag = false
    var viewPinned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        animator = UIDynamicAnimator(referenceView:self.view)
        gravity = UIGravityBehavior()
        
        animator.addBehavior(gravity)
        gravity.magnitude = 4
        var offset:CGFloat = 300
        for i in 0...data.count - 1 {
            if let view = addViewController(atOffset: offset, dataforVC: data[i] as AnyObject?){
                views.append(view)
                offset -= 65
            }
     }
}

    func addViewController(atOffset offset:CGFloat,dataforVC data:AnyObject?) -> UIView? {
        let frame = self.view.bounds.offsetBy(dx: 0, dy:self.view.bounds.size.height - offset)
        let storyboard = UIStoryboard(name:"Main",bundle:nil)
        let stackMenu = storyboard.instantiateViewController(withIdentifier: "StackView") as! StackMenuViewController
        if let view  = stackMenu.view{
            view.frame = frame
            view.layer.cornerRadius = 8
            view.layer.shadowOffset = CGSize(width:2,height:2)
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 0.5
            print("headerStr:\(data )")

            if let headerStr = data as? String {
                stackMenu.headerString  = headerStr
                print("headerStr:\(headerStr)")
            }
            self.addChildViewController(stackMenu)
            self.view.addSubview(view)
            stackMenu.didMove(toParentViewController: self)
            
            let panGes = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handlePan(gest:)))
            view.addGestureRecognizer(panGes)
            
            let collision = UICollisionBehavior(items:[view])
            collision.collisionDelegate = self
            animator.addBehavior(collision)
            
            //Lower boundary
            let boundary = view.frame.origin.y + view.frame.size.height
            var boundaryStart = CGPoint(x:0,y:boundary)
            var boundaryEnd = CGPoint(x:self.view.bounds.size.width,y:boundary)
            collision.addBoundary(withIdentifier: 1 as NSCopying, from: boundaryStart, to: boundaryEnd)
            //Upper boundary
            boundaryStart = CGPoint(x:0,y:0)
            boundaryEnd = CGPoint(x:self.view.bounds.size.width,y:0)
            collision.addBoundary(withIdentifier: 2 as NSCopying, from: boundaryStart, to: boundaryEnd)
            gravity.addItem(view)
            
            let itemBehavior = UIDynamicItemBehavior(items:[view])
            animator.addBehavior(itemBehavior)
            return view
        }
        return nil
    }
    
    func handlePan(gest:UIPanGestureRecognizer){
        
        print("handlePan")
        let touchPoint = gest.location(in: self.view)
        let dragedView = gest.view!
        if gest.state == .began {
            let  dragStartPoint = gest.location(in: dragedView)
            if dragStartPoint.y < 200{
                viewDrag = true
                pretouchPoint = touchPoint
            }
        } else if gest.state == .changed  &&  viewDrag {
            let yOffset = pretouchPoint.y - touchPoint.y
            dragedView.center = CGPoint(x:dragedView.center.x,y:dragedView.center.y - yOffset)
            pretouchPoint = touchPoint
        } else if gest.state == .ended && viewDrag{
            
            // pin
            pin(view: dragedView)
            //add Velocity
            addVelocity(toView:dragedView, fromGestRec: gest)
            animator.updateItem(usingCurrentState: dragedView)
            viewDrag = false
        }
    }
    
    func pin(view:UIView){
        let viewHasReachedPin = view.frame.origin.y < 100
        if viewHasReachedPin {
            if !viewPinned{
                var snapPos = self.view.center
                snapPos.y += 30
                snap = UISnapBehavior(item:view,snapTo:snapPos)
                animator.addBehavior(snap)
                setVisibility(view: view, alpha: 0)
                viewPinned = true
            }
        }
        else {
            if viewPinned{
                animator.removeBehavior(snap)
                setVisibility(view: view, alpha: 1)
                viewPinned = false
            }
        }
    }
    
    func setVisibility(view:UIView,alpha:CGFloat){
        
        for aView in views {
            if aView != view{
                aView.alpha = alpha
                
            }
            
        }
    }
    func addVelocity(toView view:UIView,fromGestRec  panGes:UIPanGestureRecognizer){
        
        var v = panGes.velocity(in: self.view)
        v.x = 0
        if let b = itemBehavior(forView: view){
            b.addLinearVelocity(v, for: view)
        }
        
    }
    func itemBehavior(forView view:UIView) -> UIDynamicItemBehavior?{
        
        for b in animator.behaviors {
             if let itemb = b as? UIDynamicItemBehavior{
             if let possibleView  = itemb.items.first as? UIView, possibleView == view {
             return itemb
            }
            
        }
    }
        return nil
}
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if NSNumber(integerLiteral:2).isEqual(identifier){
            let v = item as? UIView
            pin(view: v!)
        }
    }
}
