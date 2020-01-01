//
//  loginViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 29/03/2017.
//  Copyright © 2017 OLIVETTI Octave. All rights reserved.
//

import UIKit
import Foundation
import SCLAlertView

class loginViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    struct Loginresponse: Codable {
        struct Result : Codable {
            struct User : Codable {
                    enum userCodingKeys: String, CodingKey {
                        case _id// = "_id"
                        case username
                        case firstName
                        case lastName
                        case email
                        case admin
                        case superAdmin
                    }
                    let _id: String?
                    let username: String?
                    let firstName: String?
                    let lastName: String?
                    let email: String?
                    let admin: Bool?
                    let superAdmin: Bool?
                }
            enum resultCodingKeys: String, CodingKey {
                case token
                case user
            }
            let user : User?
            let token : String?
        }
        let result: Result?
        let error: String?
    }
    
    override func viewDidLoad() {
        userNameTextField.borderStyle = .none;
        userPasswordTextField.borderStyle = .none;
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View appeared")
        
        let userId = UserDefaults.standard.object(forKey: "userId") as? String
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String
        if (userId != nil && userToken != nil)
        {
            DispatchQueue.main.async()
            {
                    self.dismiss(animated: true, completion: {});
            }
        }
    }
    
    @IBAction func userGoBack(_ sender: Any) {
        self.dismiss(animated: true, completion: {});
    }
    
    @IBAction func UserPressedConnection(_ sender: Any) {
        print("User trying to login")
        
        if (userNameTextField.text!.isEmpty || userPasswordTextField.text!.isEmpty)
        {
            SCLAlertView().showError("Error", subTitle: "All fields are required")
            return;
        }
        
        struct UserInfo : Codable {
            let username: String
            let password: String
        }
        let userInfo = UserInfo(username: userNameTextField.text!,
                                password: userPasswordTextField.text!);
        
        print(userInfo);
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(userInfo)
        post_send_data(url: GlobalConstants.api_url + "login", json: data, response_type: Loginresponse.self)
        {
            (response) -> Void in
            print("we are good");
                if response.error != nil {
                    SCLAlertView().showError("Error", subTitle: response.error!)
                } else
                {
                    let userToken = response.result!.token!
                    print(userToken)
                    
                    let userId = response.result!.user!._id!
                    UserDefaults.standard.set(userId, forKey: "userId")
                    UserDefaults.standard.set(userToken, forKey: "userToken")
                    UserDefaults.standard.synchronize()
                    
                    print("On ferme la page de login")
                    DispatchQueue.main.async()
                        {
                            self.dismiss(animated: true, completion: {});
                    }
                }
        }
    }

}
