//
//  FollowedViewController.swift
//  Histoire de Poche
//
//  Created by Octave on 11/22/18.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import UIKit
import Alamofire

class FollowedViewController: UIViewController, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func UserGoBack(_ sender: Any) {
        print("trying to go back")
        self.dismiss(animated: true, completion: {});
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool){
        data_authors = []
        manage_fav_call()
    }
    
    var author_id: String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoAuthor" {
            if let destinationVC = segue.destination as? AuthorViewController {
                destinationVC.author_id = author_id
            }
        }
    }

    
    /*struct AuthorResponse: Codable {
        struct user : Codable {
            enum userCodingKeys: String, CodingKey {
                case _id
                case admin
                case profil_pic
                case superAdmin
                case username
            }
            let _id: String?
            let admin: Bool?
            let profil_pic: String?
            let superAdmin: Bool?
            let username: String?
        }

        let result: [user]?
        let error: String?
        
        enum CodingKeys : String, CodingKey {
            case result
            case error
        }
    }*/
    
    struct AuthorResponse: Codable {
        let result: [Result]?
    }
    
    struct Result: Codable {
        let user: User?
    }
    
    struct User: Codable {
        let id, username: String?
        let profilPic: String?
        let admin, superAdmin: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case username
            case profilPic = "profil_pic"
            case admin, superAdmin
        }
    }
    
    func manage_fav_call()
    {
        //we fetch articles
        print("Fetching follows")
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"
        let headers: HTTPHeaders = ["x-access-token": userToken]
        //let parameters: Parameters = ["target_id": self.author_id!]
        let url = GlobalConstants.api_url + "user/follow"
        
        let request = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
        request.responseJSON{ response in
            //print(response)
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    print("example success")
                default:
                    print("error with response status: \(status)")
                }
            }

            print(response)
            let parsed_response = try? JSONDecoder().decode(AuthorResponse.self, from: response.data!)
            print(parsed_response)
 
            if let results = parsed_response?.result {
                for result in results {
                    if let author_data = result.user {
                        let auth_username = author_data.username ?? "Not found"
                        let auth_id = author_data.id ?? "Not found"
                        let auth_image_url = author_data.profilPic ?? "Not found"
                        
                        var image: UIImage
                        let url = URL(string: auth_image_url)
                        if url != nil
                        {
                            let data = try? Data(contentsOf: url!)
                            if data != nil, let image = UIImage(data: data!) {
                                data_authors.append(Author(username: auth_username, author_id: auth_id, image: image))
                            }
                            else {
                                data_authors.append(Author(username: auth_username, author_id: auth_id, image: UIImage(named: "profil_placeholder")!))
                            }
                        }
                        else {
                            data_authors.append(Author(username: auth_username, author_id: auth_id, image: UIImage(named: "profil_placeholder")!))
                        }
                        print(auth_id, auth_username, auth_image_url)
                        
                    }
                }
                print ("Followed data set")
            }
            else {
                print ("Could not set followed data")
            }
            
            
            var cells = [Cell]()
            
            for author in data_authors
            {
                cells.append(Cell(image: author.image, label: author.username, content: "", is_BtoB: false))
            }
            
            self.dataSource = FollowCellDataSource(cells: cells)
            self.tableView.estimatedRowHeight = 230
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.reloadData()
            
            /*
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                let json_result = JSON["result"]

                print(json_result)
                print(type(of: result))
            }
            */
            return
        }
        
        /*fetch_articles(type: "fav")
        {
            (articles) -> Void in

            if articles.count == 0 {
                print("no fav damn")
                return
            }
            //print(articles);
            let tmp_author = Author(username: "Osten", author_id: "5b86ac1657e5691100260b54", image: UIImage(named: "follow_false")!)
            data_authors = [tmp_author, tmp_author, tmp_author]

            var cells = [Cell]()

            for author in data_authors
            {
                cells.append(Cell(image: author.image, label: author.username, content: ""))
            }

            self.dataSource = FollowCellDataSource(cells: cells)
            self.tableView.estimatedRowHeight = 230
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.reloadData()
        }*/
    }

    @IBOutlet weak var tableView: UITableView!
    var dataSource: FollowCellDataSource

    //function called when row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("selected")
        print(indexPath.row)
        print(data_authors.count)
        print("url =", data_authors[indexPath.row].author_id)
        
        author_id = data_authors[indexPath.row].author_id
        self.performSegue(withIdentifier: "gotoAuthor", sender: self)
    }
    
    //cells
    required init?(coder aDecoder: NSCoder)
    {
        let cells = [Cell]()
        self.dataSource = FollowCellDataSource(cells: cells)
        super.init(coder: aDecoder)
    }
}

class FollowTableViewCell: UITableViewCell {
    @IBOutlet weak var CellLabel: UILabel!
    @IBOutlet weak var CellImage: UIImageView!
}


class FollowCellDataSource: NSObject, UITableViewDataSource {
    let cells: [Cell]
    
    init(cells: [Cell]){
        self.cells = cells
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FollowTableViewCell.self)) as! FollowTableViewCell
        let elem = cells[indexPath.row]
        cell.CellLabel?.text = elem.label
        cell.CellImage?.image = elem.image
        
        return cell
    }
}

struct Author {
    let username: String
    let author_id: String
    let image: UIImage
}

var data_authors:[Author] = []
