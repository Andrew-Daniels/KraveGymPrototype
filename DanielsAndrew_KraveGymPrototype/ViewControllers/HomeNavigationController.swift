//
//  HomeNavigationController.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/13/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class HomeNavigationController: UINavigationController {

    var account: AccountSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let homeVC = self.viewControllers.first as! Home
        homeVC.account = account

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
