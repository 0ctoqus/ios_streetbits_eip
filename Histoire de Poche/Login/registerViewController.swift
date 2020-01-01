//
//  registerViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 28/03/2017.
//  Copyright © 2017 OLIVETTI Octave. All rights reserved.
//

import UIKit
import SCLAlertView

class registerViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userFirstnameTextField: UITextField!
    @IBOutlet weak var userSurnameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userRepeatpasswordTextField: UITextField!
    
    struct Registerresponse: Decodable {
		let error : String?
		let account : Account?
		
		enum CodingKeys: String, CodingKey {
			case error
			case account
		}
		
		struct Account : Codable {
			let user : User?
			struct User : Codable {
				let _id : String?
				let username : String?
				let profil_pic : String?
				let firstName : String?
				let lastName : String?
				let email : String?
				let admin : Bool?
				let superAdmin : Bool?
				let interests : [String]?
				let favory : [String]?
				let history : [String]?
				
				enum CodingKeys: String, CodingKey {
					
					case _id
					case username
					case profil_pic
					case firstName
					case lastName
					case email
					case admin
					case superAdmin
					case interests
					case favory
					case history
				}
				
			}
			enum CodingKeys: String, CodingKey {
				case user
			}
		}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.borderStyle = .none;
        userFirstnameTextField.borderStyle = .none;
        userSurnameTextField.borderStyle = .none;
        userEmailTextField.borderStyle = .none;
        userPasswordTextField.borderStyle = .none;
        userRepeatpasswordTextField.borderStyle = .none;
        //userInviteCodeTextField.borderStyle = .none;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userRegister(_ sender: Any) {
        print("User trying to regiter")
        struct UserInfo : Codable {
            let username: String
            let firstName: String
            let lastName: String
            let password: String
            let email: String
			let confirm: String
        }
        
        let userInfo = UserInfo(username: userNameTextField.text!,
            firstName: userFirstnameTextField.text!,
            lastName: userSurnameTextField.text!,
            password: userPasswordTextField.text!,
            email: userEmailTextField.text!,
			confirm: userRepeatpasswordTextField.text!);
        
        //we check for empty field(s)
        if (userInfo.username.isEmpty ||
            userInfo.firstName.isEmpty ||
            userInfo.lastName.isEmpty ||
            userInfo.email.isEmpty ||
            userInfo.password.isEmpty ||
            userRepeatpasswordTextField.text!.isEmpty)// ||
            //userInviteCode!.isEmpty)
        {
            SCLAlertView().showError("Error", subTitle: "All fields are required")
            return;
        }
        //we check that both passwords are the same
        else if (userRepeatpasswordTextField.text! != userInfo.password)
        {
            SCLAlertView().showError("Error", subTitle: "Passwords not matching")
            return;
        }
		else if (validateEmail(enteredEmail: userInfo.email) == false) {
            SCLAlertView().showError("Error", subTitle: "Email is not valid")
			return;
		}
		else {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(userInfo)
            post_send_data(url: GlobalConstants.api_url + "register", json: data, response_type: Registerresponse.self)
            {
                (response) -> Void in
				print("register response")
				print(response)
                if response.account != nil {
                    let alertController = UIAlertController(title: "Hi " + userInfo.username + "!", message:
                        "You have successfully registered", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: { action in self.close_register()}))
                    
                    self.present(alertController, animated: true, completion: nil)
                    print("On ferme la page d'enregistrement")
                   
                } else if response.error != nil {
                    SCLAlertView().showError("Error", subTitle: response.error!)
                }
                else{
                    SCLAlertView().showError("Error", subTitle: "Something went wrong")
                }
            }
        }
    }
    
    @IBAction func userGoBack(_ sender: Any) {
        //l'utilisateur annule la creation de compte
        print("User whent back")
        self.dismiss(animated: true, completion: {});
    }
    func close_register(){
        print("On ferme la page d'enregistrement")
        DispatchQueue.main.async()
            {
                self.dismiss(animated: true, completion: {});
        }
    }

}
