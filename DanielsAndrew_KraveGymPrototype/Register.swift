//
//  Register.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/10/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class Register: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    let textFieldErrorMessages = [0: "Type in a correct phone number", 1: "Type in your first name", 2: "Type in your last name", 3: "Type in a valid password", 4: "Your passwords do not match"]
    var ref: DatabaseReference!
    var rememberMe = false
    var username: Int!
    var firstRespondingTextField: UITextField!
    
    //ManagedObjectContext - Our notepad, we write on the notepad, then save the notepad to the device
    //It's our data middleman, between our code and the harddrive.
    var managedObjectContext: NSManagedObjectContext!
    
    //NSEntityDescription - Used to help build our Entity by describing a specific entity from our .xcdatamodel file.
    private var entityDescription: NSEntityDescription!
    
    //NSManagedObject - Used to represent the entity Type 'rememberMeDetails' that we created in our xcdatamodelid file
    //Use the EntityDescription to help us build the right kind of entity
    //This is where our Data lives, everything else is just setup.
    private var rememberMeDetails: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        //whiteView.roundCorners([.topLeft, .topRight], radius: 10)
        //whiteView.layer.cornerRadius = 10
        entityDescription = NSEntityDescription.entity(forEntityName: "Account", in: managedObjectContext)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rememberMeBtn(_ sender: Any) {
        rememberMe = !rememberMe
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
        if let username = Int(usernameTextField.text!) {
            self.username = username
        }
        
        if textFieldTagsThatAreEmpty.count > 0 {
            //Give an error message and do not proceed.
            var alertMessage = ""
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
            let account = AccountSettings(managedObjectContext: managedObjectContext, entityDescription: entityDescription, ref: ref)
            account.checkForExistingAccount(username: String(username), view: self, completionHandler: { (response) in
                if !response {
                    //create an account
                    print("There isn't an account yet.")
                    account.createTrainerAccount(username: String(self.username), password: self.passwordTextField.text!, firstname: self.firstNameTextField.text!, lastname: self.lastNameTextField.text!, rememberMe: self.rememberMe)
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
