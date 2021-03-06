//
//  Register.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/10/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit
import FirebaseAuth

private let registeredIdentifier = "Registered"

class Register: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var modalWindowOne: ModalWindowWithOne!
    @IBOutlet var modalWindowTwo: ModalWindowWithTwo!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var rememberMeBtn: UIButton!
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    let textFieldErrorMessages = [0: "Type in a correct phone number", 1: "Type in your first name", 2: "Type in your last name", 3: "Type in a valid password", 4: "Your passwords do not match"]
    var rememberMe = false
    var username: Int!
    var firstRespondingTextField: UITextField!
    var account: AccountWork!
    var successfullyLoggedIn = false
    var portraitY: CGFloat = 1000
    var landscapeY: CGFloat = 1000
    var accountWorkDelegate: AccountWorkDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(Register.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Register.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Register.keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        let settings = ActionCodeSettings()
        settings.url = URL(string: "https://kravegym.com/")
        settings.handleCodeInApp = true
        settings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        for textField in textFields {
            textField.useUnderline()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
                let orientation = UIApplication.shared.statusBarOrientation
                setYCoords(orientation: orientation)
                if orientation == .portrait {
                    self.view.frame.origin.y = portraitY
                } else if orientation == .landscapeRight || orientation == .landscapeLeft {
                    self.view.frame.origin.y = landscapeY
                }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
                let orientation = UIApplication.shared.statusBarOrientation
                setYCoords(orientation: orientation)
                if orientation.isLandscape {
                    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                        if self.view.frame.origin.y == landscapeY {
                            self.view.frame.origin.y -= keyboardSize.height
                        }
                    }
                } else if orientation.isPortrait {
                    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                        if self.view.frame.origin.y == portraitY {
                            self.view.frame.origin.y -= keyboardSize.height/2
                        }
                    }
                }
    }
    
    func setYCoords(orientation: UIInterfaceOrientation) {
        if orientation == .portrait {
            if portraitY == 1000 {
                portraitY = self.view.frame.origin.y
            }
        } else if orientation == .landscapeLeft || orientation == .landscapeRight {
            if landscapeY == 1000 {
                landscapeY = self.view.frame.origin.y
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rememberMeBtn(_ sender: Any) {
        rememberMe = !rememberMe
        if rememberMe {
            rememberMeBtn.setImage(#imageLiteral(resourceName: "ic_check_box_3x"), for: .normal)
        } else {
            rememberMeBtn.setImage(#imageLiteral(resourceName: "ic_check_box_outline_blank_3x"), for: .normal)
            account.deleteRememberedAccount()
        }
    }
    @IBAction func clickHereToLoginBtn(_ sender: Any) {
    }
    @IBAction func createAccountBtn(_ sender: Any) {
        //Check against database for an account already created with this email address.
        var textFieldTagsThatAreEmpty: [Int] = []
        //Iterate over all textFields
        //Check if textField is empty
        for textField in textFields {
            if textField.text != "" {
                //If textfield isn't empty, continue
                continue
            } else {
                //Don't display the same error message twice.
                if !textFieldTagsThatAreEmpty.contains(textField.tag) {
                    textFieldTagsThatAreEmpty.append(textField.tag)
                }
            }
        }
        //Check if "password" and "confirm password" fields aren't the same
        if passwordTextField.text != confirmPasswordTextField.text {
            if !textFieldTagsThatAreEmpty.contains(4) {
                textFieldTagsThatAreEmpty.append(4)
                while textFieldTagsThatAreEmpty.index(of: 3) != nil {
                    let indexToRemove = textFieldTagsThatAreEmpty.index(of: 3)
                    let index = indexToRemove?.description
                    if let intIndex = Int(index!) {
                        textFieldTagsThatAreEmpty.remove(at: intIndex)
                    }
                }
            }
        }
        //
        if let username = Int(usernameTextField.text!.trimmingCharacters(in: .whitespaces)) {
            self.username = username
        }
        
        if textFieldTagsThatAreEmpty.count > 0 || username == nil ? true : false {
            //Give an error message and do not proceed.
            var alertMessage = ""
            if username == nil {
                alertMessage = alertMessage + "\n" + "A valid phone number does NOT contain special characters or spaces"
            }
            for tag in textFieldTagsThatAreEmpty {
                if let message = textFieldErrorMessages[tag] {
                    alertMessage = alertMessage + "\n" + message
                }
            }
            let alert = UIAlertController(title: "Oops", message: alertMessage, preferredStyle: .alert)
            let alertButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertButton)
            present(alert, animated: true, completion: {
                self.passwordTextField.text = ""
                self.confirmPasswordTextField.text = ""
            })
        } else {
            account.checkForExistingAccount(username: String(username), view: self, completionHandler: { (response) in
                if response {
                    self.successfullyLoggedIn = true
                    self.accountWorkDelegate.createTrainerAccount(username: String(self.username).trimmingCharacters(in: .whitespaces), password: self.passwordTextField.text!, firstname: self.firstNameTextField.text!.trimmingCharacters(in: .whitespaces), lastname: self.lastNameTextField.text!.trimmingCharacters(in: .whitespaces), rememberMe: self.rememberMe)
                    if self.rememberMe {
                        self.account.saveRememberedAccount(username: String(self.username).trimmingCharacters(in: .whitespaces), password: self.passwordTextField.text!)
                    }
                    for textField in self.textFields {
                        textField.text = ""
                    }
                    self.performSegue(withIdentifier: registeredIdentifier, sender: sender)
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let next = textFields.index(of: textField)
        let nextIndex = next?.hashValue
        if nextIndex! + 1 < textFields.count {
            textFields[nextIndex! + 1].becomeFirstResponder()
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        firstRespondingTextField = textField
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == registeredIdentifier && successfullyLoggedIn {
            return true
        }
        if let button = sender as? UIButton {
            if button.tag == 15 {
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == registeredIdentifier {
            let homeTabVC = segue.destination as! HomeTabBarController
            homeTabVC.accountWorkDelegate = accountWorkDelegate
            homeTabVC.account = account
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

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}
