//
//  TopAthletePageViewController.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/19/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

class TopAthletePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    //MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = topAthleteViewControllers.index(of: viewController as! TopAthlete) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            pageControl.currentPage = viewControllerIndex
            return topAthleteViewControllers.last
        }
        
        guard topAthleteViewControllers.count > previousIndex else {
            return nil
        }
        
        pageControl.currentPage = viewControllerIndex
        return topAthleteViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = topAthleteViewControllers.index(of: viewController as! TopAthlete) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let topAthleteViewControllersCount = topAthleteViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard topAthleteViewControllersCount != nextIndex else {
            pageControl.currentPage = viewControllerIndex
            return topAthleteViewControllers.first
        }
        
        guard topAthleteViewControllersCount > nextIndex else {
            return nil
        }
        
        pageControl.currentPage = viewControllerIndex
        return topAthleteViewControllers[nextIndex]
    }
    
    var allWorkoutCategories = [String: [String: String]]()
    var pageControl: UIPageControl!
    var account: AccountWork!
    var allAthletesArray = [User]()
    var topAthletesArray = [String : User]() //WorkoutID -> User
    private(set) lazy var topAthleteViewControllers = [TopAthlete]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        getAllAthleteWorkoutData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updatePageControl()
    }
    
    func updatePageControl() {
        for (_, dot) in pageControl.subviews.enumerated() {
                dot.layer.borderColor = UIColor(displayP3Red: 205/255, green: 253/255, blue: 52/255, alpha: 1).cgColor
                dot.layer.borderWidth = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    private func newViewController(user: User, pageControlIndex: Int) -> TopAthlete {
        let topAthleteVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopAthlete") as! TopAthlete
        topAthleteVC.user = user
        topAthleteVC.account = account
        topAthleteVC.allWorkoutCategories = allWorkoutCategories
        topAthleteVC.pageControl = pageControl
        topAthleteVC.pageControlIndex = pageControlIndex
        return topAthleteVC
    }
    
    
    func getAllAthleteWorkoutData() {
        account.getAllAthleteWorkoutData { (completion, allAthletesWorkoutDataArray) in
            if completion {
                self.allAthletesArray = allAthletesWorkoutDataArray
                self.account.getWorkoutCategories(completion: { (completion, allWorkoutCategories) in
                    if completion {
                        self.allWorkoutCategories = allWorkoutCategories
                        self.determineTopAthletes()
                    }
                })
            }
        }
    }
    
    func determineTopAthletes() {
        //Find the best athlete for each workoutID
        let tempArray = topAthletesArray
        topAthletesArray.removeAll()
        for athlete in allAthletesArray {
            if let _ = topAthletesArray[athlete.workoutID] {
                if (topAthletesArray[athlete.workoutID]?.calculateWorkoutScore())! < athlete.calculateWorkoutScore() {
                    topAthletesArray[athlete.workoutID] = athlete
                }
            } else {
                topAthletesArray[athlete.workoutID] = athlete
            }
        }
        for workout in topAthletesArray {
            if !tempArray.contains(where: { (tempWorkout) -> Bool in
                if tempWorkout.key == workout.key {
                    let user = workout.value
                    let tempUser = tempWorkout.value
                    if user.username == tempUser.username && user.workoutDetails == tempUser.workoutDetails {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }) {
                //Do everything here
                topAthleteViewControllers.removeAll()
                for (index, athlete) in topAthletesArray.values.enumerated() {
                    
                    topAthleteViewControllers.append(newViewController(user: athlete, pageControlIndex: index))
                }
                pageControl.numberOfPages = topAthleteViewControllers.count
                if topAthleteViewControllers.count > 0 {
                    self.setViewControllers([self.topAthleteViewControllers[0]], direction: .forward, animated: true, completion: nil)
                    self.updatePageControl()
                    self.pageControl.currentPage = 0
                    break
                }
            }
        }
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
