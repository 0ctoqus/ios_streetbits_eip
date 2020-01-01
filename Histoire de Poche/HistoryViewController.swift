//
//  HistoryViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 12/02/2018.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

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
		 manage_history_call()
	}
	
	var article_id: String?
	var image_link: String?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowArticleZoom" {
			if let destinationVC = segue.destination as? ZoomArticleViewController {
				destinationVC.article_id = article_id
				destinationVC.image_link = image_link
			}
		}
	}
	
	func manage_history_call()
	{
		//we fetch articles
		print("Fetching history")
		fetch_articles(type: "history")
			{
				(articles) -> Void in
				//print(articles.count)
				if articles.count == 0 {
					print("no history damn")
					return
				}
				//print(articles);
				data_articles = articles
				var cells = [Cell]()
				
				for article in articles
				{
					//self.annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(article.latitude), longitude: CLLocationDegrees(article.longitude))
					//self.mapView.addAnnotation(self.annotation)
                    cells.append(Cell(image: article.image, label: article.title, content: article.content, is_BtoB: article.is_BtoB))
				}
				self.dataSource = HistoryCellDataSource(cells: cells)
				self.tableView.estimatedRowHeight = 230
				self.tableView.rowHeight = UITableViewAutomaticDimension
				self.tableView.dataSource = self.dataSource
				self.tableView.reloadData()
		}
	}
	
	@IBOutlet weak var tableView: UITableView!
	var dataSource: HistoryCellDataSource
	
	//function called when row is selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		print("selected")
		print("url =", data_articles[indexPath.row].ID)
		
		article_id = data_articles[indexPath.row].ID
		image_link = data_articles[indexPath.row].image_link
		self.performSegue(withIdentifier: "ShowArticleZoom", sender: self)
	}

	//cells
	required init?(coder aDecoder: NSCoder)
	{
		let cells = [Cell]()
		self.dataSource = HistoryCellDataSource(cells: cells)
		super.init(coder: aDecoder)
	}
}

class HistoryTableViewCell: UITableViewCell {
	@IBOutlet weak var CellLabel: UILabel!
	@IBOutlet weak var CellContent: UILabel!
	@IBOutlet weak var CellImage: UIImageView!
}

class HistoryCellDataSource: NSObject, UITableViewDataSource {
	let cells: [Cell]
	
	init(cells: [Cell]){
		self.cells = cells
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryTableViewCell.self)) as! HistoryTableViewCell
		let elem = cells[indexPath.row]
		cell.CellLabel?.text = elem.label
		cell.CellContent?.text = elem.content
		cell.CellImage?.image = elem.image
		
		return cell
	}
}

