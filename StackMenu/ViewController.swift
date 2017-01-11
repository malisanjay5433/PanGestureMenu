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
    let desc = ["Steven Paul Jobs February 24, 1955 – October 5, 2011) was an American businessman, inventor, and industrial designer. He was the co-founder, chairman, and chief executive officer (CEO) of Apple Inc.; CEO and majority shareholder of Pixar;[2] a member of The Walt Disney Company's board of directors following its acquisition of Pixar; and founder, chairman, and CEO of NeXT.","Stephen (or Stephan) Gary Wozniak[1]:18 (/ˈwɒzniæk/, born August 11, 1950) is an American inventor, electronics engineer, programmer, and technology entrepreneur who co-founded Apple Inc. He is known as a pioneer of the personal computer revolution of the 1970s and 1980s, along with Apple co-founder Steve Jobs.","Ronald Gerald Wayne (born May 17, 1934) is a retired American electronics industry worker. He co-founded Apple Computer (now Apple Inc.) with Steve Wozniak and Steve Jobs, providing administrative oversight for the new venture. He soon, however, sold his share of the new company for $800 US dollars, and later accepted $1,500 to forfeit any claims against Apple (in total, equivalent to $9,296 in 2016). As of April 2016, if Wayne had kept his 10% stake in Apple Inc.[1] it would have been worth almost $60 billion.","Tim Donald Cook (born November 1, 1960) is an American business executive, industrial engineer and developer. Cook is the current and seventh Chief Executive Officer of Apple Inc., previously serving as the company's Chief Operating Officer, under its founder Steve Jobs."]
    var views = [UIView]()
    var animator:UIDynamicAnimator!
    var gravity:UIGravityBehavior!
    var snap:UISnapBehavior!
    var pretouchPoint:CGPoint!
    var viewDrag = false
    var viewPinned = false
    override func viewDidLoad() {
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView:self.view)
        gravity = UIGravityBehavior()
        animator.addBehavior(gravity)
        gravity.magnitude = 4
        var offset:CGFloat = 300
        for i in 0...data.count - 1 {
            if let view = addViewController(atOffset: offset, dataforVC: data[i] as AnyObject?,descForVC: desc[i] as AnyObject){
                views.append(view)
                offset -= 65
            }
        }
    }
    
    func addViewController(atOffset offset:CGFloat,dataforVC data:AnyObject?,descForVC desc:AnyObject) -> UIView? {
        let frame = self.view.bounds.offsetBy(dx: 0, dy:self.view.bounds.size.height - offset)
        let storyboard = UIStoryboard(name:"Main",bundle:nil)
        let stackMenu = storyboard.instantiateViewController(withIdentifier: "StackView") as! StackMenuViewController
        if let view  = stackMenu.view{
            view.frame = frame
            view.layer.cornerRadius = 10
            view.layer.shadowOffset = CGSize(width:5,height:3)
            view.layer.shadowColor = UIColor.darkGray.cgColor
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 1.5
            if let headerStr = data as? String {
                stackMenu.headerString  = headerStr
            }
            if let descStr = desc as? String {
                stackMenu.descString  = descStr
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
        }else {
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
