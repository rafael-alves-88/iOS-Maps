//
//  InteressesAnnotation.swift
//  Mapas
//
//  Created by Thales Toniolo on 10/1/15.
//  Copyright © 2015 Flameworks. All rights reserved.
//
import UIKit
import MapKit

class InteressesAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?
	var mapItem: MKMapItem?
	
	init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, mapItem: MKMapItem) {
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
		self.mapItem = mapItem
	}
}
