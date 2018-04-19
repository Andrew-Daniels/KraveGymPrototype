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
    
    var selectedAthlete: User!
    
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var workoutLogTV: UITableView!
    var isSaved = false
    var isSavedRowVisible = false
    var sets: [Int] = []
    var firstTextField: UITextField!
    var defaultRep = "10"
    var cells = [WorkoutLogTVCell]()
    
    //MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let numberOfReps = Int(textField.text!) {
            sets[textField.tag] = numberOfReps
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let numberOfReps = Int(textField.text!) {
            sets[textField.tag] = numberOfReps
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
        cell.repNumberTextField.text = defaultRep
        cell.repNumberTextField.tag = indexPath.row
        firstTextField = cell.repNumberTextField
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        workoutLogTV.register(UINib(nibName: "WorkoutLogTVHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: workoutLogHeaderIdentifier)
        // Do any additional setup after loading the view.
        workoutLogTV.layer.cornerRadius = 15
        self.navigationItem.title = selectedAthlete.fullName
        profilePicture(user: selectedAthlete)
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
    }
    @IBAction func saveBtnPress(_ sender: UIButton) {
        if !isSavedRowVisible && sets.count != 0 {
            let path = IndexPath(row: sets.count + 1, section: 0)
            sets.append(0)
            isSaved = true
            workoutLogTV.insertRows(at: [path], with: .right)
            enableOrDisableTableCells()
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
