//
//  ViewController.swift
//  Mapas
//
//  Created by Thales Toniolo on 10/1/15.
//  Copyright © 2015 Flameworks. All rights reserved.
//
import UIKit
import MapKit

// MARK: - Class Declaration
class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {
	// MARK: - Public Objects
	
	// MARK: - Private Objects
	let locationManager: CLLocationManager = CLLocationManager()
	
	// MARK: - Interface Objects
	@IBOutlet weak var myMapView: MKMapView!
	
	// MARK: - Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		self.locationManager.requestWhenInUseAuthorization()

		// Define minha localizacao e centraliza o mapa nela
		let fiapLocation:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(-23.573978, -46.623272)
		self.myMapView.region = MKCoordinateRegionMakeWithDistance(fiapLocation, 1200, 1200)

		// Adiciona o pino do metro
		let metroAnnotation: MetroAnnotation = MetroAnnotation(coordinate: CLLocationCoordinate2DMake(-23.589541, -46.634701), title: "Metrô Vila Mariana", subtitle: "Linha Azul")

		self.myMapView.addAnnotation(metroAnnotation)
	}

	// MARK: - Private Methods
	
	// MARK: - Action Methods
	@IBAction func segmentChange(sender: UISegmentedControl) {
		switch (sender.selectedSegmentIndex) {
			case 0:
				self.myMapView.mapType = MKMapType.Standard
			case 1:
				self.myMapView.mapType = MKMapType.Satellite
			case 2:
				self.myMapView.mapType = MKMapType.Hybrid
			default:
				print("Tipo nao previsto")
		}
	}

	func displayRegionCenteredOnMapItem(from: MKMapItem){
		//Obtem a localizacao do item passado como parametro
		let fromLocation: CLLocation = from.placemark.location!
		let region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 500, 500)
		let opts = [
			MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: region.span),
			MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: region.center)
		]
		from.openInMapsWithLaunchOptions(opts)
	}

	// MARK: - Public Methods

	// MARK: - MKMapViewDelegate
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

		if (annotation is MetroAnnotation) {
			//verificar se a marcação já existe para tentar reutilizá-la
			let reuseId = "reuseMetroAnnotation"
			var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
			//se a view não existir
			if (anView == nil) {
				//criar a view como subclasse de MKAnnotationView
				anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
				//trocar a imagem pelo logo do metro
				anView!.image = UIImage(named:"metroLogo")
				//permitir que mostre o "balão" com informações da marcação
				anView!.canShowCallout = true
				//adiciona um botão do lado direito do balão
				anView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
			}
			return anView
		} else if (annotation is MKUserLocation) {
			//verificar se a marcação já existe para tentar reutilizá-la
			let reuseId = "reuseMyLocation"
			var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
			//se a view não existir
			if (anView == nil) {
				//criar a view como subclasse de MKAnnotationView
				anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
				//trocar a imagem pelo logo do usuario
				anView!.image = UIImage(named:"userLogo")
				//permitir que mostre o "balão" com informações da marcação
				anView!.canShowCallout = false
			}
			return anView
		} else if (annotation is InteressesAnnotation) {
			//verificar se a marcação já existe para tentar reutilizá-la
			let reuseId = "reuseInteresses"
			var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
			//se a view não existir
			if (anView == nil) {
				//criar a view como subclasse de MKAnnotationView
				anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
				//trocar a imagem pelo logo do metro
				anView!.image = UIImage(named:"interesseLogo")
				//permitir que mostre o "balão" com informações da marcação
				anView!.canShowCallout = true
				//adiciona um botão do lado direito do balão
				anView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
			}
			return anView
		}

		return nil
	}

	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if (view.annotation is InteressesAnnotation) {
			let interesseAnnotation: InteressesAnnotation = view.annotation! as! InteressesAnnotation
			self.displayRegionCenteredOnMapItem(interesseAnnotation.mapItem!)
		} else if (view.annotation is MetroAnnotation) {
			let url:NSURL = NSURL(string: "http://www.metro.sp.gov.br")!
			UIApplication.sharedApplication().openURL(url)
		}
	}

	// MARK: - UISearchBarDelegate
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = searchBar.text
		request.region = self.myMapView.region

		let search = MKLocalSearch(request: request)
		search.startWithCompletionHandler { (response, error) -> Void in
			if (error == nil) {
				//cria um array para guardar os resultados retornados
				var placemarks: [InteressesAnnotation] = []
				for item: MKMapItem in response!.mapItems {
					//cria uma nova marcação por resultado
					let place = InteressesAnnotation(coordinate: item.placemark.coordinate, title: item.name!, subtitle: "", mapItem: item)
					placemarks.append(place)
				}

				//clean and add the annotations in the placemarks array
				self.myMapView.removeAnnotations(self.myMapView.annotations)
				self.myMapView.addAnnotations(placemarks)
				
			}
			searchBar.resignFirstResponder()
		}
	}

	// MARK: - Navigation
//	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//		if (segue.identifier == "mySegue") {
//			//...
//		}
//	}
	
	// MARK: - Death Cycle
	override func viewDidDisappear(animated: Bool) {
		//...
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
