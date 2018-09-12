//
//  Home.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/12/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit
import FirebaseStorage
import WatchConnectivity
import CoreBluetooth

private let workoutLogIdentifier = "WorkoutLog"
private let athleteCVCellIdentifier = "AthleteCVCell"
private let athleteTVCellIdentifier = "AthleteTVCell"


class Home: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, WCSessionDelegate, CBPeripheralManagerDelegate {
    

    @IBOutlet var centerActivityConstraints: [NSLayoutConstraint]!
    @IBOutlet var cornerActivityConstraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var nextWorkoutBtn: UIButton!
    @IBOutlet weak var previousWorkoutBtn: UIButton!
    @IBOutlet weak var currentWorkoutLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var gridImageView: UIImageView!
    @IBOutlet var athleteListTopConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var searchBarBackView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarBackview: UIView!
    @IBOutlet weak var topAthleteContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var topAthleteBackview: UIView!
    @IBOutlet weak var topAthletePageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var allAthletes: [User] = []
    var account: AccountWork!
    var classAthletes: [User] = []
    var classAndAllAthletes: [Int: [User]] = [:]
    var scopeIndexSelected = 0
    var filter = false
    var filteredAthletes: [Int: [User]] = [:]
    var selectedAthlete: User!
    var numberOfPhotosLoaded = 0
    var accountWorkDelegate: AccountWorkDelegate!
    var animator: UIViewPropertyAnimator!
    var watchSession: WCSession!
    var workoutRoutine = [Int: [Int: String]]()
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var advertisementData: [String: Any]?
    var subscribedCentrals = [CBCentral]()
    
    var servCBUUID = "06B280C1-419D-4D87-810E-00D88B506717"
    var charCBUUID = "CD570797-087C-4008-B692-7835A1246377"
    
    
    //MARK: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            self.startAdvertisingPeripheralManager()
        }
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        subscribedCentrals.append(central)
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
//        for request in requests {
//            var data = request.value
//            var characteristic = request.characteristic
//        }
        
    }
    //This method runs whenever the peripheral starts advertising, lets us know of any errors.
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
    }
    
    func startAdvertisingPeripheralManager() {
        transferCharacteristic = CBMutableCharacteristic.init(type: CBUUID.init(string: charCBUUID), properties: [.read, .write, .indicate, .notify], value: nil, permissions: .readable)
            
        let transferService = CBMutableService.init(type: CBUUID.init(string: servCBUUID), primary: true)
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.add(transferService)
        advertisementData = [CBAdvertisementDataLocalNameKey: "KraveGymPeripheral", CBAdvertisementDataServiceUUIDsKey: [CBUUID.init(string: servCBUUID)], "WorkoutRoutine": workoutRoutine]
        peripheralManager.startAdvertising(advertisementData)
    }
    
    //MARK: WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            self.watchSession.sendMessage(["username": account.username], replyHandler: { (data) in
                print(data)
            }) { (error) in
                print(error)
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfUsers()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: athleteCVCellIdentifier, for: indexPath) as! AthleteListCVCell
        let athlete = getAthleteForRowOrItemAt(indexPath: indexPath)
        if let athlete = athlete {
            cell.profilePicture(user: athlete)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userSelected(indexPath: indexPath)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        if WCSession.isSupported() {
            self.watchSession = WCSession.default
            self.watchSession.delegate = self
            self.watchSession.activate()
        }
        account.getClassWorkoutRoutine { (completed, workoutRoutine) in
            if completed,
                let workoutRoutine = workoutRoutine {
                self.workoutRoutine = workoutRoutine
                print(self.workoutRoutine)
//                DispatchQueue.main.async {
//                    self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
//                    self.startAdvertisingPeripheralManager()
//                }
            }
        }
        activityIndicator.startAnimating()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panFunction(recognizer:)))
        searchBarBackView.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        getAllAthletes()
        getCurrentClassAthletes()
        let navBar = navigationController!.navigationBar
        let tabBar = tabBarController!.tabBar
        tabBar.clipsToBounds = true
        navBar.clipsToBounds = true
        collectionView.layer.cornerRadius = 15
        tableView.layer.cornerRadius = 15
        topAthleteBackview.layer.cornerRadius = 15
        topAthleteBackview.clipsToBounds = true
        searchBarBackview.layer.cornerRadius = 15
        searchBarBackview.clipsToBounds = true
    }
    
    
//    @IBAction func noFeatureYet(_ sender: Any) {
//        let alert = UIAlertController(title: "Uh oh", message: "This feature is not implemented yet", preferredStyle: .alert)
//        let button = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(button)
//        present(alert, animated: true, completion: nil)
//    }
    
    
    
    private func getAllAthletes() {
        for constraint in centerActivityConstraints {
            constraint.priority = .defaultLow
        }
        for constraint in cornerActivityConstraints {
            constraint.priority = .required
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        account.getAllAthletes { (completion, athletes) in
            if completion {
                self.allAthletes = athletes
                self.classAndAllAthletes[1] = self.allAthletes
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.tableView.reloadData()
                }
                DispatchQueue.main.async {
                    self.getAthletesPhotos(athleteArray: self.allAthletes, scopeIndex: 1)
                }
            }
        }
    }
    
    private func getAthletesPhotos(athleteArray: [User], scopeIndex: Int) {
        for user in athleteArray {
            if let username = user.username {
                account.newGetAthletePhoto(username: username) { (completion, image) in
                    if completion {
                        user.image = image
                        if let athletes = self.classAndAllAthletes[self.scopeIndexSelected] {
                            if let indexOfImagesUser = athletes.index(where: { (athlete) -> Bool in
                                athlete.username == user.username
                            }) {
                                let indexPathItem = IndexPath(item: Int(indexOfImagesUser), section: 0)
                                let indexPathRow = IndexPath(row: Int(indexOfImagesUser), section: 0)
                                self.tableView.reloadRows(at: [indexPathRow], with: .none)
                                self.collectionView.reloadItems(at: [indexPathItem])
                                self.numberOfPhotosLoaded += 1
                                print(self.numberOfPhotosLoaded)
                                if self.numberOfPhotosLoaded == (self.classAndAllAthletes[1]?.count)! + (self.classAndAllAthletes[0]?.count)! - 1 {
                                    self.activityIndicator.stopAnimating()
                                }
                            }
                        }
                    } else {
                        self.numberOfPhotosLoaded += 1
                        print(self.numberOfPhotosLoaded)
                        if self.numberOfPhotosLoaded == (self.classAndAllAthletes[1]?.count)! + (self.classAndAllAthletes[0]?.count)! - 1 {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    
    private func getCurrentClassAthletes() {
        accountWorkDelegate.getCurrentClassAthletes { (completion, athletes) in
            if completion {
                self.classAthletes = athletes
                self.classAndAllAthletes[0] = self.classAthletes
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.tableView.reloadData()
                }
                DispatchQueue.main.async {
                     self.getAthletesPhotos(athleteArray: self.classAthletes, scopeIndex: 0)
                }
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
        tableView.reloadData()
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
        } else {
            filter = false
        }
        collectionView.reloadData()
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        filter = false
        collectionView.reloadData()
        tableView.reloadData()
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
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfUsers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: athleteTVCellIdentifier, for: indexPath) as! AthleteListTVCell
        let athlete = getAthleteForRowOrItemAt(indexPath: indexPath)
        if let athlete = athlete {
            cell.profilePicture(user: athlete)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userSelected(indexPath: indexPath)
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    @objc func panFunction(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            //do something
            animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
                let velocity = recognizer.velocity(in: self.searchBarBackView)
                var constant: CGFloat
                if velocity.y > 0 {
                    constant = -50
                } else {
                    constant = -100
                }
                for topConstraint in self.athleteListTopConstraints {
                    topConstraint.constant = constant
                }
                self.view.layoutIfNeeded()
            })
        case .changed:
            //do something
            let translation = recognizer.translation(in: collectionView)
            print("translation y: \(translation.y / 100)")
            if translation.y < 0 {
                animator.fractionComplete = (translation.y * -1) / 100
            } else {
                animator.fractionComplete = translation.y / 100
            }
        case .ended:
            //do something
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            //do nothing
            print("Default switch ran instead")
        }
        
        
//        if recognizer.view == nil {
//            return
//        }
//        if recognizer.state == .began {
//            //Take note of original location here
//        } else if recognizer.state == .changed {
//            //Take note of new location here
//        } else if recognizer.state == .ended {
//
//        }
//
//        let velocity = recognizer.velocity(in: collectionView)
//        if velocity.y > 100 {
//            for topConstraint in athleteListTopConstraints {
//                topConstraint.constant = -50
//            }
//
//            UIView.animate(withDuration: 0.5, animations: {
//                self.view.layoutIfNeeded()
//            })
//        } else if velocity.y < -100 {
//            self.view.layoutIfNeeded()
//
//            for topConstraint in athleteListTopConstraints {
//                topConstraint.constant = -100
//            }
//
//            UIView.animate(withDuration: 0.5, animations: {
//                self.view.layoutIfNeeded()
//            })
//        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - UIButton Actions
    
    @IBAction func collectionSwitchBtnClicked(_ sender: UIButton) {
        tableView.isHidden = true
        collectionView.isHidden = false
        gridImageView.image = #imageLiteral(resourceName: "gridSelected")
        listImageView.image = #imageLiteral(resourceName: "list")
        
    }
    
    @IBAction func tableSwitchBtnClicked(_ sender: UIButton) {
        tableView.isHidden = false
        collectionView.isHidden = true
        gridImageView.image = #imageLiteral(resourceName: "grid")
        listImageView.image = #imageLiteral(resourceName: "listSelected")
    }
    
    
    func userSelected(indexPath: IndexPath) {
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
    
    func numberOfUsers() -> Int {
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
    
    func getAthleteForRowOrItemAt(indexPath: IndexPath) -> User? {
        if !filter {
            if let athlete = classAndAllAthletes[scopeIndexSelected]?[indexPath.row] {
                return athlete
            }
        } else {
        
            if let athlete = filteredAthletes[scopeIndexSelected]?[indexPath.row] {
                return athlete
            }
        }
        return nil
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
