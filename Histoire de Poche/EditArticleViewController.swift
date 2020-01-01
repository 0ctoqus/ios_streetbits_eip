//
//  EditArticleViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 18/05/2018.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import TagListView
import SCLAlertView
import Photos

class EditArticleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, TagListViewDelegate {
	
	@IBOutlet var ProfilPic: UIImageView!
	@IBOutlet var EditPictureButton: UIButton!
    var ImagePicked: Bool!
	
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
	
    struct Editarticlenresponse: Codable {
        struct Article: Codable {
            let language: String?
            let _id: String?
            let title: String?
            let description: String?
            let imagePath: String?
            let tags_used: [String]?
            let images: [String]?
            let is_fav: Bool?
            
            let author: Author?
            struct Author: Codable {
                let _id: String?
                let username: String?
                
                enum CodingKeys : String, CodingKey {
                    case _id
                    case username
                }
            }
            
            let source: String?
            let sourceId: String?
            let loc: Location?
            struct Location: Codable {
                let type: String?
                let coordinates: [Float]?
                
                enum CodingKeys : String, CodingKey {
                    case type
                    case coordinates
                }
            }
            
            enum CodingKeys : String, CodingKey {
                case language
                case images
                case _id
                case title
                case description
                case imagePath
                case tags_used
                case author
                case source
                case sourceId
                case loc
                case is_fav
            }
        }
        let result: Article?
        let error: String?
        
        enum CodingKeys : String, CodingKey {
            case result
            case error
        }
    }
	
	override func viewWillDisappear(_ animated: Bool) {
	}
	
	var article_id: String?
	var image_link: String?
	
	func fetch_zoom_articles(article_id: String, completionHandler: @escaping (_ articles: Editarticlenresponse.Article?) -> Void){
		print(GlobalConstants.api_url + "articles/" + article_id)
		get_send_data(url: GlobalConstants.api_url + "articles/" + article_id, response_type: Editarticlenresponse.self){
			(response) -> Void in
			print("raw response")
            print(response)
			if response.error != nil {completionHandler(nil)}
			else if response.result != nil {
				completionHandler(response.result)
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
	}

    var tags: [String] = []
    var tags_number: Int = 0
    
    @IBOutlet weak var TagInputTextField: UITextField!
    @IBOutlet weak var tagListView: TagListView!
    
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
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imagePicker.delegate = self
        tagListView.delegate = self
        TagInputTextField.delegate = self
        ImagePicked = false
        
		//Dismiss keyboard when clicking elsewhere
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let new_image_link = image_link!.replacingOccurrences(of: "150px", with: "1000px", options: .regularExpression, range: nil)
        
        if let url:NSURL = NSURL(string: new_image_link), let data:NSData = NSData(contentsOf : url as URL)
        {
            self.ProfilPic.image = UIImage(data : data as Data) ?? UIImage(named: "profil_placeholder")!
        }
        else
        {
            self.ProfilPic.image = UIImage(named: "profil_placeholder")!
        }
        print(article_id ?? "Not found")
        if article_id != nil{
            fetch_zoom_articles(article_id: article_id!)
            {
                (response) -> Void in
                self.TitleTextField.text = response?.title ?? "Not found"
                if response?.description != nil
                {
                    self.ContentTextView.text = response?.description
                }
                else
                {
                    self.ContentTextView.text =  "Not found"
                }
                self.LongitudeLabel.text = "Longitude: " + String(response?.loc?.coordinates?[0] ?? 0.0).prefix(5)
                self.LattitudeLabel.text = "Lattitude: " + String(response?.loc?.coordinates?[1] ?? 0.0).prefix(5)
                
                if let fetched_tags = response?.tags_used {
                    self.tags = fetched_tags
                    self.tags_number = self.tags.count
                    for tag in self.tags {
                        self.tagListView.addTag(tag)
                    }
                }
            }
        }
	}
	
    override func viewDidAppear(_ animated: Bool) {
        //Photos
        print("checking permissions for camera roll")
        let photos = PHPhotoLibrary.authorizationStatus()
        print(photos)
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
        else if photos == .denied {self.dismiss(animated: true, completion: {});}
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
            print("picked image")
			ProfilPic.contentMode = .scaleAspectFill
			self.ProfilPic.image = pickedImage
			
            print("we set picked image to true")
            self.ImagePicked = true
			//let data = UIImageJPEGRepresentation(ProfilPic.image!, 0.8)!
			
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion:nil)
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

	@IBAction func AddArticleButton(_ sender: Any) {
		//let userId = UserDefaults.standard.object(forKey: "userId") as? String ?? ""
		if (TitleTextField.text!.isEmpty || ContentTextView.text!.isEmpty)
		{
            SCLAlertView().showError("Error", subTitle: "All fields are required") // Error
			return;
		}
		
		
		print("trying to save changes")
		
		let url = GlobalConstants.api_url + "articles/correct/" + article_id!
		let userToken = UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"
		let headers: HTTPHeaders = ["x-access-token": userToken]
		let parameters : Parameters = [
			"title" : TitleTextField.text!,
			"description" : ContentTextView.text!,
            "tags": tags
		] //Optional for extra parameter

		Alamofire.request(url,
						  method: .patch,
						  parameters: parameters,
						  encoding: JSONEncoding.default,
						  headers: headers)
		.responseJSON
		{ response in
            print("response")
				switch response.result {
				case .success( _):
                    if self.ImagePicked == true
                    {
                        print("upload image")
                        upload_image(Image: self.ProfilPic.image!, Purpose: "articles", ArticleId: self.article_id!)
                    }
					let myAlert = UIAlertController(title: "Success", message: "Article edited", preferredStyle: UIAlertControllerStyle.alert);
					let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
						UIAlertAction in
						self.dismiss(animated: true, completion: {});
						print("ok pressed")
					}
					
					myAlert.addAction(okAction);
					
					self.present(myAlert, animated: true, completion: nil);
					break
				case .failure(let error):
					print("Request failed with error: \(error.localizedDescription)")
                    SCLAlertView().showError("Error", subTitle: "Could not edit article")
					break
				}
		}
	}
}


