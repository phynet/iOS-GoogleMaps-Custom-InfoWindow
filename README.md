## Create customizable and interactible custom view (annotation in Apple Maps)

![process](https://cloud.githubusercontent.com/assets/724536/26211835/c3a6146e-3bf3-11e7-853d-08ed197119c5.gif)

## Follow this Steps

1.- In your project, use pods to install Google's libs

    pod 'GooglePlaces'
    pod 'Google-Maps-iOS-Utils'
    
1.1.- You can install Google's example cluster map to see how clusters work. I used this code to build from there the rest code needed for custom info window functionality 

    pod try Google-Maps-iOS-Utils

2.- In **Bridgin-Header** add this line:

    #import <Google-Maps-iOS-Utils/GMUMarkerClustering.h>

3.- **Very important!!**: create the API Key in Google's developer pane, follow instructions in this link: https://developers.google.com/maps/documentation/ios-sdk/get-api-key

4.- **Add** that key as a constant in AppDelegate's, or in the place where you're going to use it.

5.- Create a **Swift file** subclassing from **UIView**

6.- Create an instance of your custom class, in our example is:

```swift
    private var infoWindow = MapInfoWindow()
```    

7.- Instanciate this variable in function `loadView()` like:

```swift
    infoWindow = loadNiB()
```

  `LoadNiB's function just instanciate the custom UIView NIB`
  
8.- Instanciate a new variable of type *GMSMarker*

```swift
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
```

9.- Add this line of code inside *didTap marker method*

```swift
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
```

10.- And add this methods 

```swift
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
```

11.- Don't forget to create a XIB and swift file for the custom info view. Add this class function to load a xib. Replace `"MapInfoWindowView"` with your XIB's file name

```swift
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapInfoWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
```
