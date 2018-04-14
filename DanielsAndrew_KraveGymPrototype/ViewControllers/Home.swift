//
//  Home.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/12/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit
import FirebaseStorage

class Home: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var images: [UIImage] = []
    var usernames: [String] = ["421342341", "987455019", "4123590221", "5152521422"]
    var allAthletes: [User] = []
    var account: AccountSettings!
    var classAthletes: [User] = []
    var classAndAllAthletes: [Int: [User]] = [:]
    var scopeIndexSelected = 0
    var filter = false
    var filteredAthletes: [Int: [User]] = [:]
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AthleteListCVCell
        if !filter {
        if let athlete = classAndAllAthletes[scopeIndexSelected] {
            if let athleteImage = athlete[indexPath.row].image {
                cell.profilePicture(pp: ProfilePicture(image: athleteImage))
            } else if let athleteInitials = athlete[indexPath.row].initials {
                cell.profilePicture(pp: ProfilePicture(initials: athleteInitials))
                cell.initialsLabel.isHidden = false
            }
        }
        } else {
            if let athlete = filteredAthletes[scopeIndexSelected] {
                if let athleteImage = athlete[indexPath.row].image {
                    cell.profilePicture(pp: ProfilePicture(image: athleteImage))
                } else if let athleteInitials = athlete[indexPath.row].initials {
                    cell.profilePicture(pp: ProfilePicture(initials: athleteInitials))
                    cell.initialsLabel.isHidden = false
                }
            }
        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
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
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
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
                                self.collectionView.reloadData()
                            }
                        }
                    }
                })
            }
        }
        
        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
