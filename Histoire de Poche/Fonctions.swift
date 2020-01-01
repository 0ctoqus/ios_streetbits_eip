//
//  Fonctions.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 02/04/2017.
//  Copyright © 2017 OLIVETTI Octave. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct GlobalConstants {
    // Constant define here.
    //static let api_url = "http://35.187.40.64/"
    static let api_url = "https://test.streetbits.fr/"
}

func post_send_data<T: Decodable>(url: String, json: Data, response_type: T.Type, completionHandler: @escaping (_ responseJSON: T) -> Void){
    // create post request with json obkect
    let url = URL(string: url)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	request.httpBody = json
	print(json)
	
	print(url)

    // insert json data to the request
    print("we send infos")
	
	print(request)
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if error != nil {
            print(error!.localizedDescription)
        }
        guard let data = data else { return }
        //Implement JSON decoding and parsing
        do {
            //Decode retrived data with JSONDecoder and assing type of Article object
            //print(data);
            print("we try to decode");
            let response = try JSONDecoder().decode(response_type, from: data)
            print(response);
            
            //Get back to the main queue
            DispatchQueue.main.async(){
                completionHandler(response)
            }
            
        } catch let jsonError {
            print(jsonError)
        }
        }.resume()
}

struct ArticleResponse: Codable {
    struct Article: Codable {
        let language: String?
        let _id: String?
        let title: String?
        let description: String?
        let imagePath: String?
        let tags_used: [String]?
        let is_BtoB: Bool?
        let images: [String]?
        
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
            case is_BtoB
        }
    }
    let result: [Article]?
    let error: String?
    
    enum CodingKeys : String, CodingKey {
        case result
        case error
    }
}

func get_send_data<T: Decodable>(url: String, response_type: T.Type, completionHandler: @escaping (_ responseJSON: T) -> Void){
    // create get request
    if let url = URL(string: url) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String
        //print("\n" + userToken! + "\n")
        request.setValue(userToken, forHTTPHeaderField: "x-access-token")

        
        // insert json data to the request
        print("we send infos")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                print(data);
                print("we try to decode");
                let response = try JSONDecoder().decode(response_type, from: data)

                DispatchQueue.main.async(){
                    completionHandler(response)
                }
                
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    else {
        print("error while searching")
    }
}

func put_send_data(url: String, completionHandler: @escaping (_ responseJSON: Bool) -> Void){
	// create get request
	let url = URL(string: url)!
	var request = URLRequest(url: url)
	request.httpMethod = "PUT"
	//request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
	
	let userToken = UserDefaults.standard.object(forKey: "userToken") as? String
	
	print("\n" + userToken! + "\n")
	request.setValue(userToken, forHTTPHeaderField: "x-access-token")
	
	
	// insert json data to the request
	print("we send infos")
	
	URLSession.shared.dataTask(with: request) { (data, response, error) in
		if error != nil {
			print(error!.localizedDescription)
		}
		guard let data = data else { return }
		//Implement JSON decoding and parsing
		do {
			//Decode retrived data with JSONDecoder and assing type of Article object
			print(data);
			print("we got a response");
			//let response = try JSONDecoder().decode(response_type, from: data)
			
			DispatchQueue.main.async(){
				completionHandler(true)
			}
			
		} //catch let jsonError {
		//	print(jsonError)
		//}
	}.resume()
}

var data_articles:[Article] = []
var other_articles:[Article] = []

struct Article {
    let title: String
	let content: String
    let ID: String
    let image: UIImage
	let latitude: Float
	let longitude: Float
	let image_link: String
    let is_BtoB: Bool
}


func fetch_articles(type: String, author: String? = nil, tag: String? = nil, completionHandler: @escaping (_ articles:[Article]) -> Void){
    var articles:[Article] = []

    print("Fetching articles with author", author, " and tag ", tag)
    
	var current_url = GlobalConstants.api_url
	if type == "history" {
		current_url += "articles/history"
	}
	else if type == "position" {
		current_url += "articles?lat=" + latitude + "&long=" + longitude + "&radius=1" + "&limite=15"
        if (author != nil) {current_url += "&author=" + author!}
        if (tag != nil) {current_url += "&tag=" + tag!}
	}
	else if type == "posts" {
		current_url += "createdhistory"
	}
	else {
		current_url += "articles/favory"
	}
    print(current_url)
	get_send_data(url: current_url, response_type: ArticleResponse.self){
        (response) -> Void in
		print("here we have article response")
		//print(response)
		
        if response.error != nil {completionHandler([])}
        else if response.result != nil {
            for article in response.result!//.prefix(10)
            {
                let articleTitle = article.title ?? "Not Found"
                let articleID = article._id ?? "Not Found"
                
                //we set images either from wiki or a user
                var articleImgLink = "Not Found"
                if let wikiImgLink = article.imagePath {
                    articleImgLink = wikiImgLink
                }
                else if article.images != [], let userImgLink = article.images?[0] {
                    articleImgLink = userImgLink
                }
                let articleContentDirty = article.description ?? "Not Found"
				
				var articleContent = articleContentDirty.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
				if articleContent.count > 250 {
					articleContent = String(articleContent.prefix(250)) + " ..."
				}
				
				articleImgLink = articleImgLink.replacingOccurrences(of: "50px", with: "150px", options: .regularExpression, range: nil)
				
				let articleLatitude = article.loc?.coordinates?[0] ?? 0.0
				let articleLongitude = article.loc?.coordinates?[1] ?? 0.0
                
                let is_BtoB = article.is_BtoB ?? false
				
                 if (articleTitle != "Not Found" && articleID != "Not Found" && articleContent != "Not Found")
                 {
                    //print("imageurl", articleImgLink, articleID, articleTitle)
					if let url:NSURL = NSURL(string: articleImgLink), let data:NSData = NSData(contentsOf : url as URL)
                     {
                     let articleImg = UIImage(data : data as Data) ?? UIImage(named: "profil_placeholder")!
                        let article = Article(title: articleTitle, content: articleContent, ID: articleID, image: articleImg, latitude: articleLatitude, longitude: articleLongitude, image_link: articleImgLink, is_BtoB: is_BtoB)
                     articles.append(article)
                     }
                     else
                     {
                    //print("Failing while looking for image")
                     let articleImg = UIImage(named: "profil_placeholder")!
                        let article = Article(title: articleTitle, content: articleContent, ID: articleID, image: articleImg, latitude: articleLatitude, longitude: articleLongitude, image_link: articleImgLink, is_BtoB: is_BtoB)
                     articles.append(article)
                     }
                 }
				
            }
			completionHandler(articles)
        }
    }
}

extension String {
	func removingWhitespaces() -> String {
		return components(separatedBy: .whitespaces).joined()
	}
}

func validateEmail(enteredEmail:String) -> Bool {
	let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
	let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
	return emailPredicate.evaluate(with: enteredEmail)
}


func upload_image(Image: UIImage!, Purpose: String!, ArticleId: String!) {
    //let storageRef = storage.reference().child("profile_pictures")
    //print("upload image on articleId ", ArticleId)
    
    // Data in memory
    let img = UIImageJPEGRepresentation(Image, 0.5)!
    
    let url = GlobalConstants.api_url + "upload/" + Purpose
    let userToken = UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"
    let headers: HTTPHeaders = ["x-access-token": userToken]
    Alamofire.upload(multipartFormData: { (multipartFormData) in
        if (Purpose == "articles")
        {
            multipartFormData.append(ArticleId.data(using: .utf8)!, withName: "articleId")
            multipartFormData.append(img, withName: "File0", fileName: "image.png", mimeType: "image/png")
        }
        else
        {
            multipartFormData.append(img, withName: "Data", fileName: "image.png", mimeType: "image/png")
        }
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

