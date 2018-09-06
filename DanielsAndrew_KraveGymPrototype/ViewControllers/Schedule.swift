//
//  Schedule.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/21/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

private let cVCellIdentifier = "CVCell"
private let cVSelectedCellIdentifier = "CVSelectedCell"
private let cVIndicatedCellIndentifier = "CVIndicatedCell"
private let cVSelectedIndicatedCellIdentifier = "CVSelectedIndicatedCell"
private let tVAssignCellIdentifier = "TVAssignCell"
private let tVAssignedCellIdentifier = "TVAssignedCell"
private var scheduleTVHeaderIdentifier = "ScheduleTVHeader"
private let monthAsNumber = ["January": "01", "February": "02", "March": "03", "April": "04", "May": "05", "June": "06", "July": "07", "August": "08", "September": "09", "October": "10", "November": "11", "December": "12"]

class Schedule: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIAlertToVC {
    
    //MARK: - UIAlertToVC
    
    func presentCustomAlert(message: String, dayOfWeekTuple: (month: String, day: Int, year: Int), time: String, day: String) {
        self.view.addSubview(modalWindowWithDate)
        timeToAssign = time
        
        self.modalWindowWithDate.setModalWindow(topMessage: message, dayOfWeekTuple: dayOfWeekTuple, time: time, day: day, negBtnText: "No", posBtnText: "Yes", centerX: self.view.center.x, centerY: self.view.center.y)
        self.modalWindowWithDate.transform = CGAffineTransform(translationX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.4) {
            self.blurView.isHidden = false
            self.modalWindowWithDate.alpha = 1
            self.modalWindowWithDate.transform = CGAffineTransform.identity
        }
    }
    
    //MARK: - Variables and Outlets
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var scheduleAsArray = ["5:00 AM": "", "6:00 AM": "", "7:00 AM": "", "8:00 AM": "", "9:00 AM": "", "10:00 AM": "", "11:00 AM": "", "1:00 PM": "", "2:00 PM": ""]
    var filteredSchedule = [(time: String, username: String)]()
    var currentDay: String!
    var selectedDateCellIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var selectedDate: String!
    var account: AccountWork!
    var viewJustLoaded = true
    var isAllClasses = true
    var timeToAssign: String!
    var rowIndexIsClassAssigned = [Int: Bool]()
    var selectedDayOfWeekTuple: (month: String, day: Int, year: Int)!
    
    @IBOutlet var modalWindowWithDate: ModalWindowWithDate!
    @IBOutlet var modalWindowOne: ModalWindowWithOne!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var modalWindow: ModalWindowWithTwo!
    @IBOutlet weak var scheduleCV: UICollectionView!
    @IBOutlet weak var scheduleTV: UITableView!
    @IBOutlet var classBtns: [UIButton]!
    @IBOutlet weak var myClassesBtn: UIButton!
    @IBOutlet weak var allClassesBtn: UIButton!
    
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSchedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleObject = filteredSchedule[indexPath.row]
        var cell: ScheduleTVCell!
        if scheduleObject.username == "" {
            cell = tableView.dequeueReusableCell(withIdentifier: tVAssignCellIdentifier, for: indexPath) as! ScheduleTVCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: tVAssignedCellIdentifier, for: indexPath) as! ScheduleTVCell
        }
        cell.assignButton.layer.borderWidth = 2
        cell.assignButton.layer.borderColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1).cgColor
        cell.assignButton.layer.cornerRadius = 10
        cell.account = account
        if let selectedDayOfWeekTuple = selectedDayOfWeekTuple {
            cell.dayOfWeekTuple = selectedDayOfWeekTuple
        } else {
            cell.dayOfWeekTuple = (scheduleCV.cellForItem(at: selectedDateCellIndexPath) as! ScheduleCVCell).dayOfWeekTuple
        }
        cell.timeLabel.text = scheduleObject.time
        var rowIndex = selectedDateCellIndexPath.row
        let indexOfCurrentDay = daysOfWeek.index(of: currentDay)!.hashValue
        
        if rowIndex + indexOfCurrentDay > 6 {
            rowIndex = (rowIndex + indexOfCurrentDay) % 7
            cell.dayOfWeek = daysOfWeek[rowIndex]
        } else {
            cell.dayOfWeek = daysOfWeek[indexOfCurrentDay + rowIndex]
        }
        
        cell.alerts = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: scheduleTVHeaderIdentifier) as! ScheduleTVHeader
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return 14
        } else {
            return 35
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var rowIndex = indexPath.row
        let dayOfWeekTuple = DateExtended.determineTheDayOfTheWeekNumberMonthAndYear(row: rowIndex)
        let date = DateExtended.getDateForCollectionViewSchedule(dayOfWeekTuple: dayOfWeekTuple)
        let indexOfCurrentDay = daysOfWeek.index(of: currentDay)!.hashValue
        
        if collectionView.tag == 0 {
            var cell: ScheduleCVCell!
            let isClassAssigned = rowIndexIsClassAssigned[indexPath.row]
                //dateAndIndex?.rowIndex == indexPath.row ? true : false
            //Create the right cell type depending on whether the date is selected or not
            if let isClassAssigned = isClassAssigned, isClassAssigned {
                if selectedDateCellIndexPath == indexPath {
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: cVSelectedIndicatedCellIdentifier, for: indexPath) as! ScheduleCVCell
                } else {
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: cVIndicatedCellIndentifier, for: indexPath) as! ScheduleCVCell
                }
                cell.classIndicator.layer.cornerRadius = cell.classIndicator.frame.height / 2
            } else if selectedDateCellIndexPath == indexPath {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: cVSelectedCellIdentifier, for: indexPath) as! ScheduleCVCell
            } else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: cVCellIdentifier, for: indexPath) as! ScheduleCVCell
            }
            if viewJustLoaded {
                viewJustLoaded = false
                account.getAllClasses(date: date, completion: { (completion, date, scheduleAsArray) in
                    for (time, _) in self.scheduleAsArray {
                        self.scheduleAsArray[time] = ""
                    }
                    if completion {
                        //if selectedDate isn't equal to date that is being reloaded, then don't continue
                        if self.selectedDate == date {
                            //----------------------------------------//
                            for (time, username) in scheduleAsArray {
                                self.scheduleAsArray[time] = username
                            }
                            self.filterForClassesScheduleForTableView()
                        }
                    } else {
                        if self.selectedDate == date {
                            self.filterForClassesScheduleForTableView()
                        }
                    }
                })
            }
            
            let dateWithCellIndex = (date: date, rowIndex: rowIndex)
            loadClassIndicator(dateWithCellIndex: dateWithCellIndex, cell: cell)
            cell.dayAsNumberLabel.text = String(dayOfWeekTuple.day)
            cell.cellSelectedView.layer.cornerRadius = cell.cellSelectedView.frame.height / 2
            //cell.date = date
            cell.dayOfWeekTuple = dayOfWeekTuple
            if rowIndex + indexOfCurrentDay > 6 {
                rowIndex = (rowIndex + indexOfCurrentDay) % 7
                cell.dayOfWeekLabel.text = daysOfWeek[rowIndex]
            } else {
                cell.dayOfWeekLabel.text = daysOfWeek[indexOfCurrentDay + rowIndex]
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cVCellIdentifier, for: indexPath) as! ScheduleCVCell
        cell.dayAsNumberLabel.text = String(dayOfWeekTuple.day)
        //cell.date = date
        cell.dayOfWeekTuple = dayOfWeekTuple
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ScheduleCVCell {
            //self.selectedDate = cell.date
            self.selectedDate = cell.getDate()
            self.selectedDayOfWeekTuple = cell.dayOfWeekTuple
        }
        let oldSelection = selectedDateCellIndexPath
        selectedDateCellIndexPath = indexPath
        if oldSelection != selectedDateCellIndexPath {
            DispatchQueue.main.async {
                collectionView.reloadItems(at: [oldSelection, self.selectedDateCellIndexPath])
            }
            //reload tableview here
            account.getAllClasses(date: self.selectedDate, completion: { (completion, date, scheduleAsArray) in
                for (time, _) in self.scheduleAsArray {
                    self.scheduleAsArray[time] = ""
                }
                if completion {
                    //To-do don't continue here if date != selectedDate
                    if self.selectedDate == date {
                        for (time, username) in scheduleAsArray {
                            self.scheduleAsArray[time] = username
                        }
                        self.filterForClassesScheduleForTableView()
                    }
                } else {
                    if self.selectedDate == date {
                        self.filterForClassesScheduleForTableView()
                    }
                }
            })
        }
    }
    
    
    //MARK: - Custom Functions
    
    private func assignClassToUser() {
        self.account.assignClass(date: selectedDate, time: timeToAssign) { (completion) in
            if !completion {
                UIView.animate(withDuration: 0.4) {
                    self.modalWindowWithDate.removeFromSuperview()
                    self.blurView.isHidden = true
                }
                self.view.addSubview(self.modalWindowOne)
                self.modalWindowOne.transform = CGAffineTransform(translationX: 0.2, y: 0.2)
                self.modalWindowOne.setModalWindow(message: "This class is no longer available!", btnText: "Darn", centerX: self.view.center.x, centerY: self.view.center.y)
                UIView.animate(withDuration: 0.4, animations: {
                    self.blurView.isHidden = false
                    self.modalWindowOne.alpha = 1
                    self.modalWindowOne.transform = CGAffineTransform.identity
                })
            } else {
                UIView.animate(withDuration: 0.4) {
                    self.modalWindowWithDate.removeFromSuperview()
                    self.blurView.isHidden = true
                }
            }
        }
    }
    
    func loadClassIndicator(dateWithCellIndex: (date: String, rowIndex: Int), cell: ScheduleCVCell) {
        //reload the collectionview item here
        //once call is completed reload collectionview item at selected row
        account.determineClassIndicator(dateAndIndex: dateWithCellIndex) { (completion, isClassAssigned) in
            if completion {
                if isClassAssigned {
                    if self.rowIndexIsClassAssigned[dateWithCellIndex.rowIndex] == true {
                        return
                    }
                    self.rowIndexIsClassAssigned[dateWithCellIndex.rowIndex] = true
                } else {
                    if self.rowIndexIsClassAssigned[dateWithCellIndex.rowIndex] == false {
                        return
                    }
                    self.rowIndexIsClassAssigned[dateWithCellIndex.rowIndex] = false
                }
                DispatchQueue.main.async {
                    self.scheduleCV.reloadItems(at: [IndexPath(item: dateWithCellIndex.rowIndex, section: 0)])
                }
            }
        }
    }
    
    func filterForClassesScheduleForTableView() {
        filteredSchedule.removeAll()
        var tempDict = [String: String]()
        if isAllClasses {
            tempDict = scheduleAsArray.filter { (schedule) -> Bool in
                if schedule.value == self.account.username || schedule.value == "" {
                    return true
                }
                return false
            }
        } else {
            tempDict = scheduleAsArray.filter({ (schedule) -> Bool in
                if schedule.value == self.account.username {
                    return true
                }
                return false
            })
        }
        for (time, username) in tempDict {
            filteredSchedule.append((time: time, username: username))
        }
        sortFilteredClasses()
        DispatchQueue.main.async {
            self.scheduleTV.reloadData()
        }
    }
    
    func sortFilteredClasses() {
        filteredSchedule.sort { (first, second) -> Bool in
            let firstActual = first.time.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            let secondActual = second.time.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            let firstActualNumber = Int(firstActual[0])!
            let secondActualNumber = Int(secondActual[0])!
            if first.time.contains("AM") && second.time.contains("PM") {
                return true
            }
            if first.time.contains("AM") && second.time.contains("AM") {
                if firstActualNumber < secondActualNumber {
                    return true
                }
            }
            if first.time.contains("PM") && second.time.contains("PM") {
                if firstActualNumber < secondActualNumber {
                    return true
                }
            }
            return false
        }
        print(filteredSchedule)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDay = Date().dayOfWeek()
        scheduleTV.register(UINib(nibName: scheduleTVHeaderIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: scheduleTVHeaderIdentifier)
        myClassesBtn.layer.borderWidth = 2
        myClassesBtn.layer.borderColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1).cgColor
        myClassesBtn.layer.cornerRadius = 10
        allClassesBtn.layer.cornerRadius = 10
        allClassesBtn.layer.borderColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1).cgColor
        allClassesBtn.layer.borderWidth = 2
        
        selectedDate = Date().today()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - IBActions
    @IBAction func classBtnClicked(_ sender: UIButton) {
        sender.layer.backgroundColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1).cgColor
        sender.setTitleColor(UIColor(displayP3Red: 246/255, green: 242/255, blue: 247/255, alpha: 1), for: .normal)
        let _ = classBtns.index { (button) -> Bool in
            if button != sender {
                button.layer.backgroundColor = UIColor(displayP3Red: 246/255, green: 242/255, blue: 247/255, alpha: 1).cgColor
                button.setTitleColor(UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1), for: .normal)
                return true
            }
            return false
        }
        if sender.tag == 0 {
            isAllClasses = true
        } else {
            isAllClasses = false
        }
        filterForClassesScheduleForTableView()  
    }
    
    
    //MARK: - ModalWindowWithDate IBActions
    @IBAction func dateNegativeBtnClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.modalWindowWithDate.removeFromSuperview()
            self.blurView.isHidden = true
        }
    }
    
    @IBAction func datePositiveBtnClicked(_ sender: UIButton) {
        assignClassToUser()
    }
    
    //MARK: - ModalWindow IBActions
    
    
    @IBAction func negativeBtnClicked(_ sender: UIButton) {
    }
    
    @IBAction func positiveBtnClicked(_ sender: UIButton) {
    }
    
    //MARK: - ModalWindowOne IBAction
    
    @IBAction func btnClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.blurView.isHidden = true
            self.modalWindowOne.removeFromSuperview()
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

extension Date {
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }
    func month() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    func day() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return Int(dateFormatter.string(from: self))!
    }
    func year() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return Int(dateFormatter.string(from: self))!
    }
    func today() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMddYYYY"
        return dateFormatter.string(from: self)
    }
}
