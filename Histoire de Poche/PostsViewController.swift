//
//  PostsViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 15/05/2018.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PostsViewController: UIViewController, UITableViewDelegate {
	override func viewDidLoad() {
		super.viewDidLoad()

        //self.tableView.setEditing(true, animated: true)
		// Do any additional setup after loading the view.
	}
    
	@IBAction func UserGoBack(_ sender: Any) {
		print("trying to go back")
		//self.dismiss(animated: true, completion: {});
		//self.navigationController?.popViewController(animated: true)
		self.dismiss(animated: true, completion: {});
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(_ animated: Bool){
		manage_posts_call()
	}
	
	var article_id: String?
	var image_link: String?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditArticleZoom" {
			if let destinationVC = segue.destination as? EditArticleViewController {
				print("setting article id")
				destinationVC.article_id = article_id
				destinationVC.image_link = image_link
			}
		}
	}
	
	func manage_posts_call()
	{
		//we fetch articles
		print("Fetching posts")
		fetch_articles(type: "posts")
		{
			(articles) -> Void in
			//print(articles.count)
			if articles.count == 0 {
				print("no posts damn")
				return
			}
			//print(articles);
			data_articles = articles
			var cells = [Cell]()
			
			for article in articles
			{
                cells.append(Cell(image: article.image, label: article.title, content: article.content, is_BtoB: article.is_BtoB))
			}
			self.dataSource = PostsCellDataSource(cells: cells)
			self.tableView.estimatedRowHeight = 230
			self.tableView.rowHeight = UITableViewAutomaticDimension
			self.tableView.dataSource = self.dataSource
			self.tableView.reloadData()
		}
	}
	
	@IBOutlet weak var tableView: UITableView!
	var dataSource: PostsCellDataSource
    
	//function called when row is selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		print("selected")
		print("url =", data_articles[indexPath.row].ID)
		
		article_id = data_articles[indexPath.row].ID
		image_link = data_articles[indexPath.row].image_link
		self.performSegue(withIdentifier: "EditArticleZoom", sender: self)
		//print("user selected article", article_id, image_link)
	}
	
	//cells
	required init?(coder aDecoder: NSCoder)
	{
		let cells = [Cell]()
		self.dataSource = PostsCellDataSource(cells: cells)
		super.init(coder: aDecoder)
	}
}

class PostsTableViewCell: UITableViewCell {
	@IBOutlet weak var CellLabel: UILabel!
	@IBOutlet weak var CellContent: UILabel!
	@IBOutlet weak var CellImage: UIImageView!
}

class PostsCellDataSource: NSObject, UITableViewDataSource {
	var cells: [Cell]
	
	init(cells: [Cell]){
		self.cells = cells
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("Editing called")
        if editingStyle == .delete {
            //CALL API HERE FOR DELITION
            cells.remove(at: indexPath.row)
            print("url =", data_articles[indexPath.row].ID)
            let headers: HTTPHeaders = ["x-access-token": UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"]
            print (GlobalConstants.api_url + "articles/" + data_articles[indexPath.row].ID)
            Alamofire.request(GlobalConstants.api_url + "articles/" + data_articles[indexPath.row].ID, method: .delete, headers: headers)
            .responseJSON { response in
                print(response)
                guard response.result.error == nil else {
                    print("error calling DELETE on /todos/1")
                    if let error = response.result.error {
                        print("Error: \(error)")
                    }
                    return
                }
                print("DELETE ok")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("deleted")
        }
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PostsTableViewCell.self)) as! PostsTableViewCell
		let elem = cells[indexPath.row]
		cell.CellLabel?.text = elem.label
		cell.CellContent?.text = elem.content
		cell.CellImage?.image = elem.image
		
		return cell
	}
}

