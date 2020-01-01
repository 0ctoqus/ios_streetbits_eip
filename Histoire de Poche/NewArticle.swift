//
//  ProfilViewController.swift
//  Oeta
//
//  Created by OLIVETTI Octave on 15/03/2018.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import UIKit
import TagListView
import Photos
import SCLAlertView

class NewArticleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, TagListViewDelegate {
	var tags: [String] = []
	var tags_number: Int = 0
	
	@IBOutlet var ProfilPic: UIImageView!
    var ImagePicked: Bool!
    
	@IBOutlet var EditPictureButton: UIButton!
	
	@IBOutlet weak var TitleTextField: UITextField!
	@IBOutlet weak var ContentTextView: UITextView!
	
	@IBOutlet weak var LongitudeLabel: UILabel!
	@IBOutlet weak var LattitudeLabel: UILabel!
	
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
				case user
			}
			let user : User?
		}
		let result: Result?
		let error: String?
	}
    
    struct ArticleResponse: Codable {
        struct ArticleResult : Codable {
                let sourceId: String?
                let author: String?
                let language: String?
                let source: String?
                let description: String?
                let title: String?
                let _id: String?
                let tags_used: [String]?
        }
        let result: ArticleResult?
        let error: String?
    }

	@IBOutlet weak var tagListView: TagListView!
	@IBOutlet weak var TagInputTextField: UITextField!

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if (textField.restorationIdentifier == "taginput")
		{
			if (textField.text?.isEmpty != true &&
				tags_number < 6 &&
				tags.contains(textField.text!.removingWhitespaces()) == false)
			{
				tags_number += 1
				let new_tag = textField.text!.removingWhitespaces()
				tagListView.addTag(new_tag)
				tags.append(new_tag)
			}
			textField.text = ""
			self.view.endEditing(true)
			return true
		}
		if (textField.restorationIdentifier == "title")
		{
			self.view.endEditing(true)
			return true
		}
		else{
			self.view.endEditing(true)
			return false
		}
	}
	
	//tagview delegate
	func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
		print("Tag pressed: \(title), \(sender)")
		tags_number -= 1
		if let index = tags.index(of: title) {
			tags.remove(at: index)
		}
		tagListView.removeTag(title)
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
	}
	
	override func viewWillAppear(_ animated: Bool) {
		LongitudeLabel.text = "Longitude: " + longitude.prefix(5)
		LattitudeLabel.text = "Lattitude: " + latitude.prefix(5)
        
		super.viewWillAppear(animated)
		
	}
	
    override func viewDidAppear(_ animated: Bool) {
        //Photos
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
		
		tagListView.delegate = self
		TagInputTextField.delegate = self
		imagePicker.delegate = self
        ImagePicked = false
		
		//Dismiss keyboard when clicking elsewhere
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		
		
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
				self.view.frame.origin.y += keyboardSize.height
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func EditProfilPic(_ sender: Any) {
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			ProfilPic.contentMode = .scaleAspectFill
			self.ProfilPic.image = pickedImage
            
            print("we set picked image to true")
            ImagePicked = true

			//let data = UIImageJPEGRepresentation(ProfilPic.image!, 0.8)!

		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion:nil)
	}
	
	/*func load_profilPicture(urlString: String)
	{
		let url = URL(string: urlString)
		
		self.ProfilPic.clipsToBounds = true;
	}*/
	
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
		
	@IBAction func AddArticleButton(_ sender: Any) {
		//let userId = UserDefaults.standard.object(forKey: "userId") as? String ?? ""
		if (TitleTextField.text!.isEmpty || ContentTextView.text!.isEmpty)
		{
            SCLAlertView().showError("Error", subTitle: "All Fields are required") // Error
			return;
		}
		
		print(GlobalConstants.api_url + "articles/create")
		let url = URL(string: GlobalConstants.api_url + "articles/create")!
		var request = URLRequest(url: url)
		
		request.httpMethod = "POST"
		let userToken = UserDefaults.standard.object(forKey: "userToken") as? String
		request.setValue(userToken, forHTTPHeaderField: "x-access-token")
		
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let para:NSMutableDictionary = NSMutableDictionary()
		
		para.setValue(TitleTextField.text, forKey: "title")
		para.setValue(ContentTextView.text, forKey: "description")
		//para.setValue(" ", forKey: "imagePath")
		para.setValue(latitude, forKey: "lat")
		para.setValue(longitude, forKey: "long")
		para.setValue("fr", forKey: "language")
        para.setValue(tags, forKey: "tags")
		
		let jsonData = try! JSONSerialization.data(withJSONObject: para)
		request.httpBody = jsonData
		
		let dataString = String(data: jsonData, encoding: .utf8)!
		print("Json = ", dataString)
		
		var result = false
        
        var image: UIImage? = nil
        if self.ImagePicked == true
        {
            print("upload image")
            image = self.ProfilPic.image!
        }
        
		let group = DispatchGroup()
		group.enter()
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			if error != nil {
				print(error!.localizedDescription)
			}
			guard let data = data else { return }
			//Implement JSON decoding and parsing
			do {
                print(data)
                let response = try? JSONDecoder().decode(ArticleResponse.self, from: data)
                print(response)
				//print(String(data: data, encoding: String.Encoding.utf8)!)
                if let rest_result = response?.result
                {
                    print("added article")
                    
                    if self.ImagePicked == true
                    {
                        print("upload image")
                        upload_image(Image: image, Purpose: "articles", ArticleId: rest_result._id)
                    }
                    else
                    {
                        print("no image to upload")
                    }
                    result = true
                }
			}
			group.leave()
			}.resume()
		group.wait()
		if (result)
		{
			let myAlert = UIAlertController(title: "Success", message: "Article added", preferredStyle: UIAlertControllerStyle.alert);
			let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
				UIAlertAction in
				self.dismiss(animated: true, completion: {});
				print("ok pressed")
			}
			
			myAlert.addAction(okAction);
			self.present(myAlert, animated: true, completion: nil);
			
		}
		else {
            SCLAlertView().showError("Error", subTitle: "Error while sending article") // Error
		}
	}
}
