//
//  PopViewController.swift
//  StackMenu
//
//  Created by Sanjay Mali on 12/01/17.
//  Copyright © 2017 Sanjay. All rights reserved.
//

import UIKit

class PopViewController: UIViewController {

    @IBOutlet weak var popView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popView.layer.cornerRadius = 10
        self.popView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismissVc(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
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
