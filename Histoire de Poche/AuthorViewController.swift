//
//  AuthorViewController.swift
//  Histoire de Poche
//
//  Created by Octave on 11/12/18.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import Photos
import SCLAlertView

class AuthorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    var author_id: String?
    var is_follow: Bool?
    
    
    @IBOutlet var ProfilPic: UIImageView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var EditPictureButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    struct Userresponse: Codable {
        struct Result : Codable {
            struct User : Codable {
                enum userCodingKeys: String, CodingKey {
                    case _id// = "_id"
                    case username
                    case firstName
                    case lastName
                    case email
                    case admin
                    case is_Follow
                    case superAdmin
                    case profil_pic
                }
                let _id: String?
                let username: String?
                let firstName: String?
                let lastName: String?
                let email: String?
                let admin: Bool?
                let is_Follow: Bool?
                let superAdmin: Bool?
                let profil_pic: String?
            }
            enum resultCodingKeys: String, CodingKey {
                case user
            }
            let user : User?
        }
        let result: Result?
        let error: String?
    }
    
    func fetch_Profilresponse(completionHandler: @escaping (_ profil: Userresponse.Result?) -> Void){
        let userId = author_id ?? ""
        
        if userId != "" {
            print(GlobalConstants.api_url + "users/" + userId)
            get_send_data(url: GlobalConstants.api_url + "users/" + userId, response_type: Userresponse.self){
                (response) -> Void in
                //print(response)
                if response.error != nil {
                    completionHandler(nil)
                }
                else if response.result != nil {
                    completionHandler(response.result)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ProfilPic.alpha = 1
        self.EditPictureButton.alpha = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    print("authorized")
                }
                else
                {
                    print("we try to close")
                    self.dismiss(animated: true, completion: {});
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        usernameTextField.delegate = self
        
        //Dismiss keyboard when clicking elsewhere
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        print("author =", self.author_id)
        
        fetch_Profilresponse()
            {
                (response) -> Void in
                if let user_info = response?.user {
                    if let username = user_info.username {
                        self.usernameTextField.text = username
                    }
                    if let photoUrl = user_info.profil_pic {
                        self.load_profilPicture(urlString: photoUrl)
                    }
                    else {
                        self.ProfilPic.image = UIImage(named: "profil_placeholder")
                    }
                    if let followed = user_info.is_Follow {
                        self.is_follow = followed
                        print("is_follow =", self.is_follow)
                        if self.is_follow! {
                            self.FollowButton.setImage(UIImage(named: "is_fav")!, for: UIControlState.normal)
                        }
                        else {
                             self.FollowButton.setImage(UIImage(named: "fav")!, for: UIControlState.normal)
                        }
                    }
                    else {
                        self.FollowButton.setImage(UIImage(named: "fav")!, for: UIControlState.normal)
                    }
                }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0
            {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0
            {
                //self.view.frame.origin.y = 0
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func show_imagePicker()
    {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func EditProfilPic(_ sender: Any) {
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        print(photos)
        if photos == PHAuthorizationStatus.authorized {
            self.show_imagePicker()
        }
        else if photos == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.show_imagePicker()
                } else {
                    SCLAlertView().showError("Error", subTitle: "Photo permission is required, go to setting and edit it")
                }
            })
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ProfilPic.contentMode = .scaleAspectFill
            self.ProfilPic.image = pickedImage
            
            
            let img = UIImageJPEGRepresentation(ProfilPic.image!, 0.5)!
            
            let url = GlobalConstants.api_url + "upload/profile"
            let userToken = UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"
            let headers: HTTPHeaders = ["x-access-token": userToken]
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(img, withName: "profilPic", fileName: "image.png", mimeType: "image/png")
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers)
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    upload.responseJSON { response in
                        print(response)
                        print("image upload response", response.result)
                    }
                case .failure(let encodingError):
                    print("error decoding responde", encodingError)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    func load_profilPicture(urlString: String)
    {
        print("photo url", urlString)
        let url = URL(string: urlString)
        
        self.ProfilPic.clipsToBounds = true;
        
        //self.ProfilPic.kf.indicatorType = .activity
        self.ProfilPic.kf.setImage(with: url,  options: [.forceRefresh]) {
            (image, error, cacheType, imageUrl) in
            if (error != nil) {
                print("error fetching pic", error!)
                self.ProfilPic.image = UIImage(named: "profil_placeholder")
            }
            //self.setProfilPicRound()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.hasText) {
            self.updateField(Field_name: textField.restorationIdentifier!, Value: textField.text!)
        }
    }
    
    func updateField(Field_name: String!, Value: String!) {
        let userId = UserDefaults.standard.object(forKey: "userId") as? String ?? ""
        let url = URL(string: GlobalConstants.api_url + "users/" + userId)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String
        request.setValue(userToken, forHTTPHeaderField: "x-access-token")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let para:NSMutableDictionary = NSMutableDictionary()
        para.setValue(Value, forKey: Field_name)
        let jsonData = try! JSONSerialization.data(withJSONObject: para)
        request.httpBody = jsonData
        
        let dataString = String(data: jsonData, encoding: .utf8)!
        print("Json = ", dataString)
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard data != nil else { return }
            //Implement JSON decoding and parsing
            do {
                //print(String(data: data, encoding: String.Encoding.utf8)!)
                print("updated ", Field_name, "with value ", Value)
            }
            }.resume()
    }

    @IBAction func panPerformed(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            
            let translation = sender.translation(in: self.view).y
            
            //print("ici")
            if translation > 0 {
                // swipe down
                print("we try to close")
                self.dismiss(animated: true, completion: {});
            }
        }
    }

    @IBOutlet weak var FollowButton: UIButton!
    @IBAction func FollowButtonPressed(_ sender: Any) {
        print("user pressed follow")
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"
        let headers: HTTPHeaders = ["x-access-token": userToken]
        let parameters: Parameters = ["target_id": self.author_id!]
        let url = GlobalConstants.api_url + "user/follow"

        
        if self.is_follow! == false {
            let request = Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            request.responseJSON{ response in
                print(response)
                SCLAlertView().showSuccess("Success", subTitle:  self.usernameTextField.text! + " has been followed")
                self.is_follow = true
                self.FollowButton.setImage(UIImage(named: "is_fav")!, for: UIControlState.normal)
                return
            }
        }
        else{
            let request = Alamofire.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            request.responseJSON{ response in
                print(response)
                SCLAlertView().showSuccess("Success", subTitle:  self.usernameTextField.text! + " has been unfollowed")
                self.is_follow = false
                self.FollowButton.setImage(UIImage(named: "fav")!, for: UIControlState.normal)
                return
            }
        }
    }
}
