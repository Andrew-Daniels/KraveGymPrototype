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

class Login: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    var account: AccountSettings!
    var firstRespondingTextField: UITextField!
    var rememberMe = false
    
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
        // Do any additional setup after loading the view.
        //whiteView.roundCorners([.topLeft, .topRight], radius: 10)
        //whiteView.layer.cornerRadius = 10
        entityDescription = NSEntityDescription.entity(forEntityName: "Account", in: managedObjectContext)
        account = AccountSettings(managedObjectContext: managedObjectContext, entityDescription: entityDescription, ref: ref)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickHereBtn(_ sender: Any) {
    }
    @IBAction func rememberMeBtn(_ sender: Any) {
        rememberMe = !rememberMe
    }
    @IBAction func loginBtn(_ sender: Any) {
        account.login(username: usernameTextField.text!, password: passwordTextField.text!, view: self, rememberMe: rememberMe) { (response) in
            if response {
                //Login then
            }
        }
    }
    
    @IBAction func unwindBackToLogin(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let registerVC = segue.destination as! Register
        registerVC.account = self.account
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
