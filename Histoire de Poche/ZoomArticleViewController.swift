//
//  ZoomArticleViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 05/02/2018.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import UIKit
import TagListView
import Alamofire
import SCLAlertView

class ZoomArticleViewController: UIViewController {
	var fav = false

    struct Zoomarticlenresponse: Codable {
        struct Article: Codable {
            let language: String?
            let _id: String?
            let title: String?
            let description: String?
            let imagePath: String?
            let tags_used: [String]?
            let images: [String]?
            let is_fav: Bool?
            let is_BtoB: Bool?
            
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
                case is_BtoB
            }
        }
        let result: Article?
        let error: String?
        
        enum CodingKeys : String, CodingKey {
            case result
            case error
        }
    }
    
    @IBOutlet weak var tagListView: TagListView!

	func fetch_zoom_articles(article_id: String, completionHandler: @escaping (_ articles: Zoomarticlenresponse.Article?) -> Void){
		print(GlobalConstants.api_url + "articles/" + article_id)
		get_send_data(url: GlobalConstants.api_url + "articles/" + article_id, response_type: Zoomarticlenresponse.self){
			(response) -> Void in
            
			if response.error != nil  {completionHandler(nil)}
			else if response.result != nil {
				completionHandler(response.result)
			}
		}
	}
	
	@IBAction func FavHandler(_ sender: Any) {
		print(GlobalConstants.api_url + "articles/favory/" + article_id!)
		put_send_data(url: GlobalConstants.api_url + "articles/favory/" + article_id!){
			(response) -> Void in
			print("added fav")
			print(response)
			
			if (self.fav)
			{
				self.fav = false
				self.fav_View.setBackgroundImage(UIImage(named: "fav")!, for: UIControlState.normal)
				let alertController = UIAlertController(title: "Favorite Removed", message:
					"Article removed from favorite", preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
				self.present(alertController, animated: true, completion: nil)
			}
			else
			{
				self.fav = true
				self.fav_View.setBackgroundImage(UIImage(named: "is_fav")!, for: UIControlState.normal)
				let alertController = UIAlertController(title: "Favorite Added", message:
					"Article added to favorite", preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
				self.present(alertController, animated: true, completion: nil)
			}
		}
	}
	
	var article_id: String?
    var author_id: String?
    var author_name: String?
	var image_link: String?
	
	@IBOutlet weak var Title_label: UILabel!
	@IBOutlet weak var Content_label: UILabel!
	@IBOutlet weak var Image_View: UIImageView!
	@IBOutlet weak var fav_View: UIButton!
    
    @IBOutlet weak var Author: UIButton!
    
	override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		print("User looking at article")
		//let id = "test"
		//self.Image_View.image = article_image
        
		print(image_link!)
		let new_image_link = image_link!.replacingOccurrences(of: "150px", with: "1000px", options: .regularExpression, range: nil)
		
		//let url:NSURL? = NSURL(string: new_image_link)
		//let data:NSData? = NSData(contentsOf : url! as URL) ?? nil
		if let url:NSURL = NSURL(string: new_image_link), let data:NSData = NSData(contentsOf : url as URL)
		{
			self.Image_View.image = UIImage(data : data as Data) ?? UIImage(named: "profil_placeholder")!
		}
		else
		{
			self.Image_View.image = UIImage(named: "profil_placeholder")!
		}
		print(article_id ?? "Not found")
		if article_id != nil{
			fetch_zoom_articles(article_id: article_id!)
			{
				(response) -> Void in
				if response?.is_fav == true
				{
					self.fav = true
					self.fav_View.setBackgroundImage(UIImage(named: "is_fav")!, for: UIControlState.normal)
				}
                
                var new_title = response?.title ?? "Not found"
                if let is_BtoB = response!.is_BtoB{
                    if is_BtoB {
                        new_title = "SPONSO " + new_title
                    }
                }
				self.Title_label.text = new_title
                
				if response?.description != nil
				{
					let str = response?.description?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
					self.Content_label.text = str
				}
				else
				{
					self.Content_label.text =  "Not found"
				}
                if let tags = response?.tags_used {
                    for element in tags {
                        self.tagListView.addTag(element)
                    }
                }
                
                if let authorName = response?.author?.username {
                    print (authorName)
                    self.Author.titleLabel?.numberOfLines = 1
                    self.Author.titleLabel?.adjustsFontSizeToFitWidth = true
                    self.Author.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
                    //self.Author.titleLabel?.text =
                    self.Author.setTitle(authorName, for: .normal)
                    
                    self.author_name = authorName
                    self.author_id = response?.author?._id
                }

			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

	@IBAction func learnMoreClicked(_ sender: Any) {
		
		let myurl = URL(string: "http://www.epitech.eu/")
		if myurl != nil
		{
		    UIApplication.shared.open(myurl!)
		}
	}
    
    @IBAction func authorPressed(_ sender: Any) {
        print("author pressed id=", self.author_id)
        
        //let v = sender.superview as! AuthorViewController
        //article_id = v.ID
        //image_link = v.image_link
        //print(self.author_id)
        if self.author_id != nil {
            self.performSegue(withIdentifier: "gotoAuthor", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoAuthor" {
            if let destinationVC = segue.destination as? AuthorViewController {
                destinationVC.author_id = self.author_id
            }
        }
    }
    
	
    @IBAction func reportClicked(_ sender: Any) {
        print("reporting article")
        let id = article_id ?? "0000"
        let url = GlobalConstants.api_url + "articles/report"
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"
        let headers: HTTPHeaders = ["x-access-token": userToken]
        let userId = UserDefaults.standard.object(forKey: "userId") as? String
        let param = ["userId": userId!,
                    "reportClass": "invalid",
                    "reportComm": "test",
                    "articleId": id]
        print(url)
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            switch response.result {
            case .success:
                print(response)
                SCLAlertView().showSuccess("Success", subTitle:  "Article as been reported")
                break
            case .failure(let error):
                SCLAlertView().showError("Error", subTitle: "Could not report article")
                print(error)
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
