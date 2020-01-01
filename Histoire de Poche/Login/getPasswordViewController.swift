//
//  getPasswordViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 29/03/2017.
//  Copyright © 2017 OLIVETTI Octave. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

class getPasswordViewController: UIViewController {
    @IBOutlet weak var userEmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userEmailTextField.borderStyle = .none;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userGoBack(_ sender: Any) {
        self.dismiss(animated: true, completion: {});
    }

    @IBAction func getPasswordPressed(_ sender: Any) {
        
        let email = userEmailTextField.text
        
        if email == nil || email == "" {
            SCLAlertView().showInfo("Oups", subTitle:  "You must fill your email")
        }
        else {
            let url = GlobalConstants.api_url + "pwdresettoken"
            let parameters: Parameters = ["email": email]
            
            let request = Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            request.responseJSON{ response in
                print(response)
                SCLAlertView().showSuccess("Success", subTitle:  "An email has been sent")
                return
            }
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
