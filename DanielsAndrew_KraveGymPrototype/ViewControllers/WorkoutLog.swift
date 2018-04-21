//
//  WorkoutLog.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/16/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit

private var workoutLogHeaderIdentifier = "WorkoutLogTVHeader"
private var workoutLogTVSetCellIdentifier = "SetCell"
private var workoutLogTVAddASetCellIdentifier = "AddASetCell"
private var workoutLogTVSaveSetCellIdentifier = "SaveCell"

class WorkoutLog: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var workoutSelectorPickerView: UIPickerView!
    var selectedAthlete: User!
    var account: AccountSettings!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var workoutLogTV: UITableView!
    var isSaved = false
    var isSavedRowVisible = false
    var sets: [Int] = []
    var firstTextField: UITextField!
    var defaultRep = "10"
    var cells = [WorkoutLogTVCell]()
    var workouts = [String: [String:String]]()
    var sortedArrayOfWorkoutTypes = [WorkoutType]()
    var sortedArrayOfWorkoutCategories = [String]()
    var workoutLabels = [UILabel]()
    var date: String!
    
    //MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let numberOfReps = Int(textField.text!) {
            sets[textField.tag] = numberOfReps
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let numberOfReps = Int(textField.text!) {
            sets[textField.tag] = numberOfReps
            firstTextField = textField
        }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSaved {
            let cell = tableView.dequeueReusableCell(withIdentifier: workoutLogTVSaveSetCellIdentifier, for: indexPath) as! WorkoutLogTVCell
            isSavedRowVisible = true
            return cell
        }
        if indexPath.row == sets.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: workoutLogTVAddASetCellIdentifier, for: indexPath) as! WorkoutLogTVCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: workoutLogTVSetCellIdentifier) as! WorkoutLogTVCell
        cell.setNumberLabel.text = String(indexPath.row + 1)
        workoutLabels.append(cell.workoutTypeLabel)
        cell.repNumberTextField.text = defaultRep
        firstTextField = cell.repNumberTextField
        cell.repNumberTextField.tag = indexPath.row
        cell.workoutTypeLabel.text = sortedArrayOfWorkoutTypes[workoutSelectorPickerView.selectedRow(inComponent: 1)].name
        if !cells.contains(cell) {
            cells.append(cell)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        sets.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        var newIndexPath = IndexPath(row: indexPath.row, section: 0)
        while tableView.cellForRow(at: newIndexPath) != nil {
            if tableView.cellForRow(at: newIndexPath)?.reuseIdentifier == workoutLogTVSetCellIdentifier {
                let cell = tableView.cellForRow(at: newIndexPath) as! WorkoutLogTVCell
                cell.setNumberLabel.text = String(newIndexPath.row + 1)
                cell.repNumberTextField.tag = newIndexPath.row
                if let numberOfReps = Int(cell.repNumberTextField.text!) {
                    sets[cell.repNumberTextField.tag] = numberOfReps
                }
            }
            newIndexPath.row += 1
        }
        cells.remove(at: indexPath.row)
    }
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let firstTextField = firstTextField {
            firstTextField.resignFirstResponder()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if !isSaved {
            if tableView.cellForRow(at: indexPath)?.reuseIdentifier != workoutLogTVAddASetCellIdentifier,
                tableView.cellForRow(at: indexPath)?.reuseIdentifier != workoutLogTVSaveSetCellIdentifier {
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: workoutLogHeaderIdentifier) as! WorkoutLogTVHeader
        return header
    }
    
    
    //MARK: - UIPickerViewDataSource
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            sortWorkoutTypes(category: sortedArrayOfWorkoutCategories[row])
            pickerView.reloadComponent(component + 1)
        }
        if !isSaved {
            for label in workoutLabels {
                label.text = sortedArrayOfWorkoutTypes[pickerView.selectedRow(inComponent: 1)].name
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return workouts.count
        }
        return sortedArrayOfWorkoutTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return sortedArrayOfWorkoutCategories[row]
        }
        sortWorkoutTypes(category: sortedArrayOfWorkoutCategories[pickerView.selectedRow(inComponent: 0)])
        return sortedArrayOfWorkoutTypes[row].name
    }
    
    func sortWorkoutCategories() {
        for category in workouts.keys {
            sortedArrayOfWorkoutCategories.append(category)
        }
        sortedArrayOfWorkoutCategories = sortedArrayOfWorkoutCategories.sorted { (a, b) -> Bool in
            if a < b {
                return true
            }
            return false
        }
    }
    
    func sortWorkoutTypes(category: String) {
        guard let workoutTypes = workouts[category] else {return}
        sortedArrayOfWorkoutTypes = [WorkoutType]()
        for (workoutID, workoutName) in workoutTypes {
            let workoutType = WorkoutType(name: workoutName, ID: workoutID)
            sortedArrayOfWorkoutTypes.append(workoutType)
        }
        sortedArrayOfWorkoutTypes = sortedArrayOfWorkoutTypes.sorted(by: { (first, second) -> Bool in
            if first.name > second.name {
                return true
            }
            return false
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldTextDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        workoutLogTV.register(UINib(nibName: "WorkoutLogTVHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: workoutLogHeaderIdentifier)
        // Do any additional setup after loading the view.
        workoutLogTV.layer.cornerRadius = 15
        self.navigationItem.title = selectedAthlete.fullName
        profilePicture(user: selectedAthlete)
        account.getWorkoutCategories { (completion, workoutCategories) in
            if completion {
                self.workouts = workoutCategories
                if self.workouts.count == 0 {return}
                self.sortWorkoutCategories()
                self.sortWorkoutTypes(category: self.sortedArrayOfWorkoutCategories[0])
                self.workoutSelectorPickerView.reloadAllComponents()
            }
        }
    }
    
    @objc func textFieldTextDidChange() {
        if let numberOfReps = Int(firstTextField.text!) {
            sets[firstTextField.tag] = numberOfReps
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func profilePicture(user: User) {
        profileImageView.image = user.image
        initialsLabel.isHidden = user.isInitialsHidden()
        initialsLabel.text = user.initials
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = user.borderColor
        profileImageView.layer.borderWidth = user.borderWidth
        profileImageView.layer.masksToBounds = true
    }
    
   
    @IBAction func addSetBtnPress(_ sender: UIButton) {
        if !isSavedRowVisible {
            let path = IndexPath(row: sets.count, section: 0)
            sets.append(0)
            workoutLogTV.insertRows(at: [path], with: .right)
            firstTextField.becomeFirstResponder()
            firstTextField.selectAll(nil)
        }
    }
    @IBAction func undoBtnPress(_ sender: UIButton) {
        let path = IndexPath(row: sets.count, section: 0)
        sets.removeLast()
        workoutLogTV.deleteRows(at: [path], with: .fade)
        enableOrDisableTableCells()
        isSavedRowVisible = false
        isSaved = false
        account.undoSavedWorkout(username: selectedAthlete.username, date: date, workoutID: sortedArrayOfWorkoutTypes[workoutSelectorPickerView.selectedRow(inComponent: 1)].ID)
    }
    @IBAction func saveBtnPress(_ sender: UIButton) {
        if !isSavedRowVisible && sets.count != 0 {
            let path = IndexPath(row: sets.count + 1, section: 0)
            sets.append(0)
            isSaved = true
            workoutLogTV.insertRows(at: [path], with: .right)
            enableOrDisableTableCells()
            saveAthleteSets()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func enableOrDisableTableCells() {
        for cell in cells {
            cell.repNumberTextField.isUserInteractionEnabled = !cell.isUserInteractionEnabled
            cell.isUserInteractionEnabled = !cell.isUserInteractionEnabled
        }
    }
    
    func saveAthleteSets() {
        let actualDate = NSDate()
        let format = DateFormatter()
        format.dateFormat = "MMddyyyyhhmm"
        date = format.string(from: actualDate as Date)
        var workoutData = [String: String]()
        for set in 1...sets.count - 1 {
            workoutData[String(set)] = String(sets[set - 1])
        }
        account.saveWorkout(username: selectedAthlete.username, date: date, workoutID: sortedArrayOfWorkoutTypes[workoutSelectorPickerView.selectedRow(inComponent: 1)].ID, workoutData: workoutData)
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
