//
//  ViewController.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 28/03/2017.
//  Copyright © 2017 OLIVETTI Octave. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SCLAlertView
import Alamofire

var latitude = "0.0"
var longitude = "0.0"

class ViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate
{
	@IBOutlet weak var SubMenuView: UIStackView!

	func hideSubMenu() {
		UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.SubMenuView.alpha = 0 // Here you will get the animation you want
		}, completion: { _ in
			self.SubMenuView.isHidden = true // Here you hide it when animation done
		})
	}
	
	@IBAction func TapPerformed(_ sender: UITapGestureRecognizer){
		
		if sender.state == .ended {
			// handling code
			print("began")
			if sender.view != self.SubMenuView && SubMenuView.isHidden != true {
				self.hideSubMenu()
			}
		}
	}
	
	@IBAction func MenuButtonPressed(_ sender: Any) {
		if SubMenuView.isHidden {
			self.SubMenuView.isHidden = false // Here you hide it when animation done
			UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
				self.SubMenuView.alpha = 100 // Here you will get the animation you want
			})
		}
		else{
			self.hideSubMenu()
		}
	}
	
	//location manager to authorize user location for Maps app
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus()
    {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        {
            mapView.showsUserLocation = true
        }
        else
        {
            locationManager.requestWhenInUseAuthorization()
        }
    }
	
   func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first
        {
            print("Found user's location: \(location)")
           	//longitude = "\(location.coordinate.longitude)"
           	//latitude = "\(location.coordinate.latitude)"
			//print("manage arcticle called in location manager")
			//manage_article_call()
        }
    }
    
    func locationManager(_ locationManager: CLLocationManager, didFailWithError error: Error)
    {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    //map view
    @IBOutlet weak var mapView: MKMapView!
    let annotation = MKPointAnnotation()
	
	let regionRadius: CLLocationDistance = 250
	var last_location = CLLocation(latitude: 0, longitude: 0)
	


        //Bouton logout
    @IBAction func LougoutButtonPressed(_ sender: Any)
    {
		self.hideSubMenu()
		//did_find_location = false
        UserDefaults.standard.set(nil, forKey: "userId")
        UserDefaults.standard.set(nil, forKey: "userToken")
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: "goto_home", sender: self)
    }

	//Bouton reload
	@IBAction func RefreshButtonPressed(_ sender: Any) {
		self.hideSubMenu()
		//load_article()
		manage_article_call()
	}
	
	@IBAction func ProfilButtonPressed(_ sender: Any) {
	}
	
	@IBAction func WriteButtonPressed(_ sender: Any) {
		self.hideSubMenu()
		self.performSegue(withIdentifier: "goto_write", sender: self)
	}
	
	@IBAction func PostsButtonPressed(_ sender: Any) {
		self.hideSubMenu()
		self.performSegue(withIdentifier: "goto_posts", sender: self)
	}
	
	
	@IBAction func HistoryButtonPressed(_ sender: Any) {
		self.hideSubMenu()
		self.performSegue(withIdentifier: "goto_history", sender: self)
	}
	
	@IBAction func FavButtonPressed(_ sender: Any) {
		self.hideSubMenu()
		self.performSegue(withIdentifier: "goto_fav", sender: self)
	}
    
    @IBAction func FollowButtonPressed(_ sender: Any) {
        self.hideSubMenu()
        print("trying to go to follow")
        self.performSegue(withIdentifier: "goto_follow", sender: self)
    }
    

	@IBAction func panPerformed(_ sender: UIPanGestureRecognizer) {

		if sender.state == .began || sender.state == .changed {
			if SubMenuView.isHidden != true {
				self.hideSubMenu()
			}
			let translation = sender.translation(in: self.view).y
			let bar_position = AccesBarView.superview?.convert(AccesBarView.frame.origin, to: nil).y ?? CGFloat(0.0)
			let cliping = CGFloat(80)
			let bottom_max = UIScreen.main.bounds.height - bar_position - CGFloat(70)

			if translation > 0 {
				// swipe down
				if self.viewConstraint.constant < bottom_max {
					UIView.animate(withDuration: 0.2, animations: {
						self.viewConstraint.constant += translation / 10
						self.view.layoutIfNeeded()
					})
				}
				//cliping
				if self.viewConstraint.constant >= bottom_max - cliping {
					UIView.animate(withDuration: 0.2, animations: {
						self.viewConstraint.constant = bottom_max
						self.view.layoutIfNeeded()
					})
				}

				//we reset the top bar if needed
				if topviewconstraint.constant != 0 {
					UIView.animate(withDuration: 0.4, animations: {
						self.topviewconstraint.constant = UIScreen.main.bounds.height
						self.view.layoutIfNeeded()
					})
				}
			}
			else {
				// swipe up
				if viewConstraint.constant > 0 {
					UIView.animate(withDuration: 0.2, animations: {
						self.viewConstraint.constant += translation / 10
						self.view.layoutIfNeeded()
					})
				}
				// cliping
				if viewConstraint.constant <= cliping {
					UIView.animate(withDuration: 0.2, animations: {
						self.viewConstraint.constant = 0
						self.topviewconstraint.constant = bar_position
						self.view.layoutIfNeeded()
					})
				}
			}
		}
		else if sender.state == .ended {
			let bar_position = AccesBarView.superview?.convert(AccesBarView.frame.origin, to: nil).y ?? CGFloat(0.0)
			//let bottom_max = UIScreen.main.bounds.height * 0.8
			let bottom_max = UIScreen.main.bounds.height - bar_position - CGFloat(70)

			//on check que on aille pas trop bas
			if viewConstraint.constant > bottom_max {
				UIView.animate(withDuration: 0.2, animations: {
					
					self.viewConstraint.constant = bottom_max
					self.view.layoutIfNeeded()
				})
			}
			//on check que on aille pas trop haut
			if viewConstraint.constant < 0 {
				UIView.animate(withDuration: 0.2, animations: {
					self.viewConstraint.constant = 0
					self.topviewconstraint.constant = bar_position
					self.view.layoutIfNeeded()
				})
			}
		}
	}
	
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))

        
		//print(UIScreen.main.nativeBounds.height / 4);
		//initial_yposition = viewConstraint.constant
		viewConstraint.constant = UIScreen.main.bounds.height / 2
		topviewconstraint.constant = UIScreen.main.bounds.height
        //we hide the ugly top bar
        self.navigationController!.navigationBar.isHidden = true

        print("loading notifications")
        self.load_notifications()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		//load_article()
	}
	
    override func viewDidAppear(_ animated: Bool)
	{
		//load_article()
        self.mapView.userTrackingMode = .follow
        
        let userId = UserDefaults.standard.object(forKey: "userId") as? String
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String
        
        if ((userId == nil) || (userToken == nil))
        {
            print("No user info found going to login page")
            self.performSegue(withIdentifier: "goto_home", sender: self)
            return
        }
        if (self.dataSource.cells.count == 0)
        {
            load_article()
        }
	}

    //tableview
    @IBOutlet weak var tableView: UITableView!
	
	var article_id: String?
	var image_link: String?

    //function called when row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("url =", other_articles[indexPath.row].ID)

		article_id = other_articles[indexPath.row].ID
		image_link = other_articles[indexPath.row].image_link
		self.performSegue(withIdentifier: "ShowArticleZoom", sender: self) 
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowArticleZoom" {
			if let destinationVC = segue.destination as? ZoomArticleViewController {
				destinationVC.article_id = article_id
				destinationVC.image_link = image_link
			}
		}
	}
	
	@IBAction func centerMapButtonPressed(_ sender: Any) {
		self.mapView.userTrackingMode = .follow
	}
	
	
    //cells
    var dataSource: CellDataSource

    required init?(coder aDecoder: NSCoder)
    {
        let cells = [Cell]()
        self.dataSource = CellDataSource(cells: cells)
        super.init(coder: aDecoder)
    }
	
	@IBOutlet weak var viewConstraint: NSLayoutConstraint!
	@IBOutlet weak var topviewconstraint: NSLayoutConstraint!
	@IBOutlet weak var AccesBarView: UIView!

	func load_article()
    {
        let userId = UserDefaults.standard.object(forKey: "userId") as? String
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String

        if ((userId == nil) || (userToken == nil))
        {
            print("No user info found going to login page")
            self.performSegue(withIdentifier: "goto_home", sender: self)
			return
        }
        else
        {
            print("UserId =", userId ?? "Not found", "UserToken =", userToken ?? "Not found");
        }
        //we set location Authorization
        checkLocationAuthorizationStatus()
        
        // set initial location of the map
        locationManager.delegate = self
		
		locationManager.requestLocation()
		
        let location = self.locationManager.location
		
		print("setting initial location")
		latitude = "\(location?.coordinate.latitude ?? 0.0)"
        longitude = "\(location?.coordinate.longitude ?? 0.0)"
        
        let initialLocation = CLLocation(latitude:location?.coordinate.latitude ?? 0.0,
										 longitude: location?.coordinate.longitude ?? 0.0)
        //locationManager.requestLocation()
        centerMapOnLocation(location: initialLocation)
		manage_article_call()
    }
	
	func manage_article_call(author: String? = nil, tag: String? = nil)
    {
        // we reset annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        //we fetch articles
        print("Fetching articles")
        fetch_articles(type: "position", author: author, tag: tag)
            {
                (articles) -> Void in
                other_articles = articles
                var cells = [Cell]()
				
                for article in articles
                {
                    var new_title = article.title
                    if (article.is_BtoB){
                        new_title = "SPONSO " + article.title
                    }
                    cells.append(Cell(image: article.image, label: new_title, content: article.content, is_BtoB: article.is_BtoB))

					let point = CustomAnnotation(coordinate:
						CLLocationCoordinate2D(latitude: CLLocationDegrees(article.latitude),
											   longitude: CLLocationDegrees(article.longitude)))

					//print("added anotation")
					point.image = article.image
					point.name = new_title
					point.ID = article.ID
					point.image_link =  article.image_link

					self.mapView.addAnnotation(point)
                }
                self.dataSource = CellDataSource(cells: cells)
                self.tableView.estimatedRowHeight = 230
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.dataSource = self.dataSource
                self.tableView.reloadData()
        }
    }
	
	
	@objc func Pinselected(sender: UIButton)
	{
		print("pin selected")
		let v = sender.superview as! CustomCalloutView
		
		article_id = v.ID
		image_link = v.image_link
		self.performSegue(withIdentifier: "ShowArticleZoom", sender: self)
	}
    
    //Search text field
    @IBOutlet weak var SearchTextField: UITextField!
    @IBAction func searchPressed(_ sender: Any) {
        print()
        var author: String? = nil
        var tag: String? = nil
        let input = SearchTextField.text!.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        for elem in input {
            let command = elem.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            print(command)
            
            if command[0] == "author" {author = String(command[1])}
            if command[0] == "tag" {tag = String(command[1])}
        }
        manage_article_call(author: author, tag: tag)
        self.view.endEditing(true)
    }
    
    
    //Notifications
    func load_notifications()
    {
        // create get request
        get_send_data(url: GlobalConstants.api_url + "notifications/all", response_type: notifications.self){
            (response) -> Void in

            if response.error != nil {
                SCLAlertView().showError("Error", subTitle: "Could not get notifications from server")
            }
            
            self.display_notification(notifications: response, index: 0)
        }
    }
    
    func display_notification(notifications: notifications, index: Int){
        //if let notif = notifications.result[index] {
        //for notif in notifications.result {
        
        if notifications.result.indices.contains(index) {
            let notif = notifications.result[index]

            print(notif.status)
            if notif.status != "read" {
                
                let origin_name = notif.idOrigin?.username ?? "Not found"
                var alert = "Info"
                var message = origin_name
                let notif_id = notif._id ?? "000000"
                if notif.type == "has_created" {
                    message += " has posted a new article"
                    alert = "New article"
                }
                if notif.type == "has_liked" {
                    message += " has liked one of your articles"
                    alert = "New like"
                }
                if notif.type == "has_followed" {
                    message += " has followed you"
                    alert = "New follower"
                }
  
                let group = DispatchGroup()
                group.enter()

                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                
                alertView.addButton("Mark as read") {
                    
                    print("user marked as read")
                    
                    print("https://test.streetbits.fr/notifications/:_id")
                    let url = GlobalConstants.api_url + "notifications/" + notif_id
                    print(url)
                    let userToken = UserDefaults.standard.object(forKey: "userToken") as? String ?? "Not found"
                    let headers: HTTPHeaders = ["x-access-token": userToken]
                    let parameters : Parameters = ["status" : "read"]
                    Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                        .responseJSON
                        { response in
                            print("response")
                            print(response)
                            switch response.result {
                            case .success( _):
                                print ("success")
                                break
                            case .failure(let error):
                                print("Request failed with error: \(error.localizedDescription)")
                                break
                            }
                    }
                    group.leave()
                }
                alertView.addButton("Dismiss") {
                    print("dismiss pressed")
                    group.leave()
                }
                
                alertView.showInfo(alert, subTitle: message)//, closeButtonTitle: "Dismiss")
                
                group.notify(queue: .main) {
                    print("notification dismiss")
                    //alertView.hideView()
                    self.display_notification(notifications: notifications, index: index + 1)
                }
            }
            else if notifications.result.indices.contains(index + 1) {
                self.display_notification(notifications: notifications, index: index + 1)
            }
        }
    }
}

struct notifications: Codable {
    struct notification : Codable {
        let _id: String?
        let type: String?
        let status: String?
        let createdAt: String?
        let idOrigin: userNotif?
        let idTarget: userNotif?
        let idArticle: articleNotif?
        
        struct userNotif: Codable {
            let _id: String?
            let username: String?
            
            enum articleNotifCodingKeys: String, CodingKey {
                case _id
                case username
            }
        }
        
        struct articleNotif: Codable {
            let _id: String?
            let title: String?
            
            enum articleNotifCodingKeys: String, CodingKey {
                case _id
                case title
            }
        }
        
        enum notificationCodingKeys: String, CodingKey {
            case _id
            case type
            case status
            case createdAt
            case idOrigin
            case idTarget
            case idArticle
        }
    }
    let result: [notification]
    let error: String?
    
    enum notificationsCodingKeys: String, CodingKey {
        case result
        case error
    }
}

//class du contenue d'une cell
class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var CellLabel: UILabel!
    @IBOutlet weak var CellImage: UIImageView!
	@IBOutlet weak var CellContent: UILabel!
}

//structure definisant notre contenue
struct Cell {
    let image: UIImage
    let label: String
	let content: String
    let is_BtoB: Bool
}

//class definisant notre liste de contenue
class CellDataSource: NSObject, UITableViewDataSource {
    let cells: [Cell]
    
    init(cells: [Cell]){
        self.cells = cells
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}
	
	//on redefinit les fonction pour que l'algo detect quel contenue est dans nos cell et comment le recuperer en flux tandue
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as! HomeTableViewCell
		let elem = cells[indexPath.row]

        cell.CellLabel?.text = elem.label
		cell.CellContent?.text = elem.content
		cell.CellImage?.image = elem.image
		
		return cell
	}
    
    
}


