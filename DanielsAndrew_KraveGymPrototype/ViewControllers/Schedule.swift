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
private let tVAssignCellIdentifier = "TVAssignCell"
private let tVAssignedCellIdentifier = "TVAssignedCell"
private var scheduleTVHeaderIdentifier = "ScheduleTVHeader"

class Schedule: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIAlertToVC {
    
    //MARK: - UIAlertToVC
    func presentAlert(title: String, message: String, date: String, time: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "I'm sure", style: .default) { (_) in
            self.account.assignClass(date: date, time: time)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Variables and Outlets
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let monthAsNumber = ["Jan": "01", "Feb": "02", "Mar": "03", "Apr": "04", "May": "05", "Jun": "06", "Jul": "07", "Aug": "08", "Sep": "09", "Oct": "10", "Nov": "11", "Dec": "12"]
    var scheduleAsArray = ["5:00 AM": "", "6:00 AM": "", "7:00 AM": "", "8:00 AM": "", "9:00 AM": "", "10:00 AM": "", "11:00 AM": "", "1:00 PM": "", "2:00 PM": ""]
    var filteredSchedule = [(time: String, username: String)]()
    var currentDay: String!
    var selectedDateCellIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var selectedDate: String!
    var account: AccountSettings!
    var viewJustLoaded = true
    var isAllClasses = true
    
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
        cell.date = (scheduleCV.cellForItem(at: selectedDateCellIndexPath) as! ScheduleCVCell).date
        cell.timeLabel.text = scheduleObject.time
        
        cell.alerts = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: scheduleTVHeaderIdentifier) as! ScheduleTVHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var rowIndex = indexPath.row
        let dayOfWeekTuple = determineTheDayOfTheWeekNumberMonthAndYear(row: rowIndex)
        let date = getDateForCollectionViewSchedule(dayOfWeekTuple: dayOfWeekTuple)
        let indexOfCurrentDay = daysOfWeek.index(of: currentDay)!.hashValue
        
        //Create the right cell type depending on whether the date is selected or not
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cVCellIdentifier, for: indexPath) as! ScheduleCVCell
        if selectedDateCellIndexPath == indexPath {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cVSelectedCellIdentifier, for: indexPath) as! ScheduleCVCell
            selectedDate = date
            if viewJustLoaded {
                viewJustLoaded = false
                account.getAllClasses(date: date, completion: { (completion, scheduleAsArray) in
                    for (time, _) in self.scheduleAsArray {
                        self.scheduleAsArray[time] = ""
                    }
                    if completion {
                        for (time, username) in scheduleAsArray {
                            self.scheduleAsArray[time] = username
                        }
                        self.filterForClassesScheduleForTableView()
                    } else {
                        self.filterForClassesScheduleForTableView()
                    }
                })
            }
        }
        cell.dayAsNumberLabel.text = String(dayOfWeekTuple.day)
        cell.cellSelectedView.layer.cornerRadius = cell.cellSelectedView.frame.height / 2
        cell.date = date
        if rowIndex + indexOfCurrentDay > 6 {
            rowIndex = (rowIndex + indexOfCurrentDay) % 7
            cell.dayOfWeekLabel.text = daysOfWeek[rowIndex]
        } else {
            cell.dayOfWeekLabel.text = daysOfWeek[indexOfCurrentDay + rowIndex]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ScheduleCVCell {
            selectedDate = cell.date
        }
        let oldSelection = selectedDateCellIndexPath
        selectedDateCellIndexPath = indexPath
        if oldSelection != selectedDateCellIndexPath {
            collectionView.reloadItems(at: [oldSelection, selectedDateCellIndexPath])
            //reload tableview here
            account.getAllClasses(date: selectedDate, completion: { (completion, scheduleAsArray) in
                for (time, _) in self.scheduleAsArray {
                    self.scheduleAsArray[time] = ""
                }
                if completion {
                    for (time, username) in scheduleAsArray {
                        self.scheduleAsArray[time] = username
                    }
                    self.filterForClassesScheduleForTableView()
                } else {
                    self.filterForClassesScheduleForTableView()
                }
            })
        }
    }
    
    
    //MARK: - Custom Functions
    func getDateForCollectionViewSchedule(dayOfWeekTuple: (month: String, day: Int, year: Int)) -> String {
        let day = dayOfWeekTuple.day
        let month = dayOfWeekTuple.month
        let year = dayOfWeekTuple.year
        if day < 10 {
            let dayString = "0" + String(day)
            return monthAsNumber[month]! + dayString + String(year)
        }
        return monthAsNumber[month]! + String(day) + String(year)
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
        scheduleTV.reloadData()
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
    }
    
    func determineTheDayOfTheWeekNumberMonthAndYear(row: Int) -> (month: String, day: Int, year: Int) {
        var year: Int = Date().year()
        let day: Int = Date().day()
        var month: String = Date().month()
        var thisDay = day + row
        var isLeapYear = false
        //check for leapYear here
        if year % 4 == 0 && year % 100 != 0 {
            isLeapYear = true
        } else if year % 400 == 0 {
            isLeapYear = true
        }
        
        while thisDay > 31  {
            if month == "Apr" {
                month = "May"
                thisDay = thisDay - 30
                continue
            }
            if month == "Jun" {
                month = "Jul"
                thisDay = thisDay - 30
                continue
            }
            if month == "Sep" {
                month = "Oct"
                thisDay = thisDay - 30
                continue
            }
            if month == "Nov" {
                month = "Dec"
                thisDay = thisDay - 30
                continue
            }
            if month == "Jan" {
                month = "Feb"
                thisDay = thisDay - 31
                continue
            }
            if month == "Mar" {
                month = "Apr"
                thisDay = thisDay - 31
                continue
            }
            if month == "May" {
                month = "Jun"
                thisDay = thisDay - 31
                continue
            }
            if month == "Jul" {
                month = "Aug"
                thisDay = thisDay - 31
                continue
            }
            if month == "Aug" {
                month = "Sep"
                thisDay = thisDay - 31
                continue
            }
            if month == "Oct" {
                month = "Nov"
                thisDay = thisDay - 31
                continue
            }
            if month == "Dec" {
                month = "Jan"
                year = year + 1
                thisDay = thisDay - 31
                continue
            }
        }
        if month == "Feb" && thisDay == 29 {
            if !isLeapYear {
                month = "Mar"
                thisDay = 1
                return (month, thisDay, year)
            } else {
                return (month, thisDay, year)
            }
        }
        if month == "Apr" && thisDay == 31 {
            month = "May"
            thisDay = 1
            return (month, thisDay, year)
        }
        if month == "Jun" && thisDay == 31 {
            month = "Jul"
            thisDay = 1
            return (month, thisDay, year)
        }
        if month == "Sep" && thisDay == 31 {
            month = "Oct"
            thisDay = 1
            return (month, thisDay, year)
        }
        if month == "Nov" && thisDay == 31 {
            month = "Dec"
            thisDay = 1
            return (month, thisDay, year)
        } else if thisDay <= 31 {
            return (month, thisDay, year)
        }
        return(month, thisDay, year)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentDay = Date().dayOfWeek()
        scheduleTV.register(UINib(nibName: "ScheduleTVHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: scheduleTVHeaderIdentifier)
        myClassesBtn.layer.borderWidth = 2
        myClassesBtn.layer.borderColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1).cgColor
        myClassesBtn.layer.cornerRadius = 10
        allClassesBtn.layer.cornerRadius = 10
        allClassesBtn.layer.borderColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1).cgColor
        allClassesBtn.layer.borderWidth = 2
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
        dateFormatter.dateFormat = "MMM"
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
}
