//
//  Home.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/12/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit
import FirebaseStorage

private let workoutLogIdentifier = "WorkoutLog"
private let athleteCVCellIdentifier = "AthleteCVCell"


class Home: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var searchBarBackview: UIView!
    @IBOutlet weak var topAthleteContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topAthleteBackview: UIView!
    @IBOutlet weak var topAthletePageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var allAthletes: [User] = []
    var account: AccountSettings!
    var classAthletes: [User] = []
    var classAndAllAthletes: [Int: [User]] = [:]
    var scopeIndexSelected = 0
    var filter = false
    var filteredAthletes: [Int: [User]] = [:]
    var selectedAthlete: User!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !filter {
            if let total = classAndAllAthletes[scopeIndexSelected]?.count {
                return total
            }
        } else {
            if let total = filteredAthletes[scopeIndexSelected]?.count {
                return total
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: athleteCVCellIdentifier, for: indexPath) as! AthleteListCVCell
        if !filter {
            if let athlete = classAndAllAthletes[scopeIndexSelected]?[indexPath.row] {
                cell.profilePicture(user: athlete)
            }
        } else {
            if let athlete = filteredAthletes[scopeIndexSelected]?[indexPath.row] {
                cell.profilePicture(user: athlete)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //perform segue
        //send athlete to workoutVC
        if !filter {
            if let selectedUser = classAndAllAthletes[scopeIndexSelected]?[indexPath.row] {
                selectedAthlete = selectedUser
                performSegue(withIdentifier: workoutLogIdentifier, sender: collectionView.cellForItem(at: indexPath))
            }
        } else {
            if let selectedUser = filteredAthletes[scopeIndexSelected]?[indexPath.row] {
                selectedAthlete = selectedUser
                performSegue(withIdentifier: workoutLogIdentifier, sender: collectionView.cellForItem(at: indexPath))
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllAthletes()
        getCurrentClassAthletes()
        let navBar = navigationController!.navigationBar
        let tabBar = tabBarController!.tabBar
        tabBar.clipsToBounds = true
        navBar.clipsToBounds = true
        collectionView.layer.cornerRadius = 15
        topAthleteBackview.layer.cornerRadius = 15
        topAthleteBackview.clipsToBounds = true
        searchBarBackview.layer.cornerRadius = 15
        searchBarBackview.clipsToBounds = true
    }
    
    
    @IBAction func noFeatureYet(_ sender: Any) {
        let alert = UIAlertController(title: "Uh oh", message: "This feature is not implemented yet", preferredStyle: .alert)
        let button = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(button)
        present(alert, animated: true, completion: nil)
    }
    
    private func getAllAthletes() {
        account.getAllAthletes { (completion, athletes) in
            if completion {
                self.allAthletes = athletes
                self.classAndAllAthletes[1] = self.allAthletes
                self.collectionView.reloadData()
                self.account.getAllAthletePhotos { (completion, athleteImages) in
                    if completion {
                        for username in athleteImages.keys {
                            if let index = self.allAthletes.index(where: { (user) -> Bool in
                                user.username == username
                            }) {
                                self.allAthletes[index].image = athleteImages[username]!
                                if self.scopeIndexSelected == 1 {
                                    let indexPath = IndexPath(row: index, section: 0)
                                    self.collectionView.reloadItems(at: [indexPath])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getCurrentClassAthletes() {
        account.getCurrentClassAthletes { (completion, athletes) in
            if completion {
                self.classAthletes = athletes
                self.classAndAllAthletes[0] = self.classAthletes
                self.collectionView.reloadData()
                self.account.getClassAthletePhotos(completion: { (completion, athleteImages) in
                    if completion {
                        for username in athleteImages.keys {
                            if let index = self.classAthletes.index(where: { (user) -> Bool in
                                user.username == username
                            }) {
                                self.classAthletes[index].image = athleteImages[username]!
                                if self.scopeIndexSelected == 0 {
                                    let indexPath = IndexPath(row: index, section: 0)
                                    self.collectionView.reloadItems(at: [indexPath])
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scopeIndexSelected = selectedScope
        collectionView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //Push up views here
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filter = true
            var secondIndex: Int!
            let filteredAth = classAndAllAthletes[scopeIndexSelected]?.filter({ (theAthlete) -> Bool in
                let stringMatch = theAthlete.fullName.lowercased().range(of: searchText.lowercased())
                return stringMatch != nil ? true : false
            })
            if classAndAllAthletes[scopeIndexSelected - 1] != nil ? true : false {
                secondIndex = scopeIndexSelected - 1
                let secondFilteredAth = classAndAllAthletes[secondIndex]?.filter({ (theAthlete) -> Bool in
                    let stringMatch = theAthlete.fullName.lowercased().range(of: searchText.lowercased())
                    return stringMatch != nil ? true : false
                })
                filteredAthletes[secondIndex] = secondFilteredAth
            } else if classAndAllAthletes[scopeIndexSelected + 1] != nil ? true : false {
                secondIndex = scopeIndexSelected + 1
                let secondFilteredAth = classAndAllAthletes[secondIndex]?.filter({ (theAthlete) -> Bool in
                    let stringMatch = theAthlete.fullName.lowercased().range(of: searchText.lowercased())
                    return stringMatch != nil ? true : false
                })
                filteredAthletes[secondIndex] = secondFilteredAth
            }
            filteredAthletes[scopeIndexSelected] = filteredAth
            collectionView.reloadData()
        } else {
            filter = false
            collectionView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        filter = false
        collectionView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == workoutLogIdentifier {
            let workoutLogVC = segue.destination as! WorkoutLog
            workoutLogVC.selectedAthlete = selectedAthlete
            workoutLogVC.account = account
        }
        if let topAthletePVC = segue.destination as? TopAthletePageViewController {
            topAthletePVC.pageControl = topAthletePageControl
            topAthletePVC.account = account
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
