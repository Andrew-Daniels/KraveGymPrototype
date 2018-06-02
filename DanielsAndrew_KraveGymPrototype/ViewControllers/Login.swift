//
//  Login.swift
//  DanielsAndrew_KraveGymPrototype
//
//  Created by Andrew Daniels on 4/12/18.
//  Copyright © 2018 Andrew Daniels. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import FirebaseStorage
import FirebaseAuth

private let loginIdentifier = "LoggedIn"
private let registerIdentifier = "Register"
let kraveBlueColor = UIColor(displayP3Red: 33/255, green: 49/255, blue: 84/255, alpha: 1)


class Login: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var rememberMeBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    var account: AccountWork!
    var firstRespondingTextField: UITextField!
    var rememberMe = false
    var successfullyLoggedIn = false
    
    //ManagedObjectContext - Our notepad, we write on the notepad, then save the notepad to the device
    //It's our data middleman, between our code and the harddrive.
    var managedObjectContext: NSManagedObjectContext!
    
    //NSEntityDescription - Used to help build our Entity by describing a specific entity from our .xcdatamodel file.
    private var entityDescription: NSEntityDescription!
    
    //NSManagedObject - Used to represent the entity Type 'rememberMeDetails' that we created in our xcdatamodelid file
    //Use the EntityDescription to help us build the right kind of entity
    //This is where our Data lives, everything else is just setup.
    private var rememberMeDetails: NSManagedObject!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        entityDescription = NSEntityDescription.entity(forEntityName: "Account", in: managedObjectContext)
        account = AccountWork(managedObjectContext: managedObjectContext, entityDescription: entityDescription, ref: ref)
        //retrieveRememberedAccountIfAny()
        //loginBtn.layer.borderWidth = 2
        //loginBtn.layer.borderColor = kraveBlueColor.cgColor
        //loginBtn.layer.cornerRadius = 10
        passwordTextField.useUnderline()
        usernameTextField.useUnderline()
    }

    func retrieveRememberedAccountIfAny() {
        let rememberedAccount = account.retrieveRememberedAccount()
        if rememberedAccount.username != "" && rememberedAccount.password != "" {
            usernameTextField.text = rememberedAccount.username
            passwordTextField.text = rememberedAccount.password
            rememberMe = true
            rememberMeBtn.setImage(#imageLiteral(resourceName: "ic_check_box_3x"), for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickHereBtn(_ sender: Any) {
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
    @IBAction func loginBtn(_ sender: Any) {
        activityIndicator.startAnimating()
        self.view.endEditing(true)
        if usernameTextField.text != "" && passwordTextField.text != "" {
            account.login(username: usernameTextField.text!.trimmingCharacters(in: .whitespaces), password: passwordTextField.text!, view: self, rememberMe: rememberMe) { (response) in
                if response {
                    //Login then
                    self.successfullyLoggedIn = true
                    if self.rememberMe {
                        self.account.saveRememberedAccount(username: self.usernameTextField.text!.trimmingCharacters(in: .whitespaces), password: self.passwordTextField.text!.trimmingCharacters(in: .whitespaces))
                    }
                    self.passwordTextField.text = ""
                    self.usernameTextField.text = ""
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: loginIdentifier, sender: sender)
                } else {
                    let alert = UIAlertController(title: "Couldn't Login", message: "Wrong username or password.", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == registerIdentifier {
            let registerVC = segue.destination as! Register
            registerVC.account = self.account
        } else if segue.identifier == loginIdentifier {
            let homeTabVC = segue.destination as! HomeTabBarController
            homeTabVC.account = account
        }
        
    }
    
    @IBAction func backToLogin(segue: UIStoryboardSegue) {
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == loginIdentifier && successfullyLoggedIn {
            return true
        } else if identifier == registerIdentifier {
            return true
        }
        return false
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
    
    override func viewWillAppear(_ animated: Bool) {
        //retrieveRememberedAccountIfAny()
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
extension UITextField {
    
    func useUnderline() {
        
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = kraveBlueColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
