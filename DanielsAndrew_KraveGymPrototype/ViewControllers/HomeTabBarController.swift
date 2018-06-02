//
//  HomeTabBarController.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/13/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {

    var account: AccountWork!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navControllers = self.viewControllers as? [UINavigationController] {
            for navController in navControllers {
                if let navController = navController as? HomeNavigationController {
                    navController.account = account
                }
                if let navController = navController as? ScheduleNavigationController {
                    navController.account = account
                }
            }
        }
//        let navigationController = self.viewControllers?.first as! HomeNavigationController
//        navigationController.account = account
        

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
