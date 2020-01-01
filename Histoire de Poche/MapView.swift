//
//  MapView.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 13/03/2018.
//  Copyright © 2018 OLIVETTI Octave. All rights reserved.
//

import Foundation
import MapKit

typealias MapViewDelegate = ViewController
extension MapViewDelegate
{
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		let current_pos = self.mapView.userLocation.coordinate
		let to = CLLocation(latitude: current_pos.latitude, longitude: current_pos.longitude)
		let distance = last_location.distance(from: to)
		if (distance > 500){
			last_location = to
			print("manage article called in mapview")
			
			longitude = "\(userLocation.coordinate.longitude)"
			latitude = "\(userLocation.coordinate.latitude)"
			if (UserDefaults.standard.object(forKey: "userToken") as? String != nil)
			{
				manage_article_call()
			}
		}
		
	}
	
	//center the map on a point (called in view did load)
	func centerMapOnLocation(location: CLLocation)
	{
		mapView.userTrackingMode = .follow
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation
		{
			return nil
		}
		var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
		if annotationView == nil
		{
			annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
			annotationView?.canShowCallout = false
		}else
		{
			annotationView?.annotation = annotation
		}
		annotationView?.image = UIImage(named: "mappin")
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
	{
		// 1
		if view.annotation is MKUserLocation
		{
			// Don't proceed with custom callout
			return
		}
		// 2
		let customAnnotation = view.annotation as! CustomAnnotation
		let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
		let calloutView = views?[0] as! CustomCalloutView
		calloutView.ViewName.text = customAnnotation.name
		calloutView.ViewImage.image = customAnnotation.image
		
		calloutView.ID = customAnnotation.ID
		calloutView.image_link = customAnnotation.image_link
		
		let button = UIButton(frame: calloutView.frame)
		button.addTarget(self, action: #selector(ViewController.Pinselected(sender:)), for: .touchUpInside)
		calloutView.addSubview(button)
		// 3
		calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
		view.addSubview(calloutView)
		mapView.setCenter((view.annotation?.coordinate)!, animated: true)
	}
    
	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		if view.isKind(of: AnnotationView.self)
		{
			for subview in view.subviews
			{
				subview.removeFromSuperview()
			}
		}
	}
}

