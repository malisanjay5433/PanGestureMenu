//
//  StackMenuViewController.swift
//  StackMenu
//
//  Created by Sanjay Mali on 11/01/17.
//  Copyright © 2017 Sanjay. All rights reserved.
//

import UIKit

class StackMenuViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descrptionLabel: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var headerString:String!{
        didSet{
            configViewTitle()
        }
        
    }
    
    var descString:String!{
        didSet{
            configViewDescrption()
        }
        
    }
    
    func configViewTitle(){
        headerLabel.text = headerString
    }
    func configViewDescrption(){
        descrptionLabel.text = descString
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
