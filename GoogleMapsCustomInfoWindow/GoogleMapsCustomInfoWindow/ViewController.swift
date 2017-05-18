//
//  ViewController.swift
//  GoogleMapsCustomInfoWindow
//
//  Created by Sofía Swidarowicz Andrade on 10/5/17.
//  Copyright © 2017 Sofía Swidarowicz Andrade. All rights reserved.
//

import GoogleMaps
import UIKit
import GooglePlaces
import GoogleMapsCore


/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

let kClusterItemCount = 20
let kCameraLatitude = 40.463667
let kCameraLongitude = -3.74922

class ViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate {
    
    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    private var infoWindow = MapInfoWindow()
    
    // MARK: Needed to create the custom info window
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                                          longitude: kCameraLongitude, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
        infoWindow = loadNiB()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Generate and add random items to the cluster manager.
        generateClusterItems()
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    

    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                           zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
    

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        
        // Needed to create the custom info window
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        self.view.addSubview(infoWindow)
        
        return false
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }

    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    // MARK: Needed to create the custom info window (this is optional)
    func sizeForOffset(view: UIView) -> CGFloat {
        return  135.0
    }
    
    // MARK: Needed to create the custom info window (this is optional)
    func loadNiB() -> MapInfoWindow{
        let infoWindow = MapInfoWindow.instanceFromNib() as! MapInfoWindow
        return infoWindow
    }
    
    // MARK: - Private
    /// Randomly generates cluster items within some extent of the camera and adds them to the
    /// cluster manager.
    private func generateClusterItems() {
        let extent = 0.2
        for index in 1...kClusterItemCount {
            let lat = kCameraLatitude + extent * randomScale()
            let lng = kCameraLongitude + extent * randomScale()
            let name = "Item \(index)"
            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            clusterManager.add(item)
        }
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
 
}
