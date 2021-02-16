import UIKit
import CoreLocation
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class EPNavigationController: UIViewController {
    private var mapView = NavigationMapView()

    private var aToBRoute: Route?
    private var parkingRoute: Route?
    private var locationManager: NavigationLocationManager?
    private var navigationService: NavigationService?
    private var parkingDestinationAnnotation = MGLPointAnnotation()
    private var isRerouting = false
    private static let startCoordinate = CLLocationCoordinate2D(latitude:59.34914, longitude: 18.11226)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
    }

    private func configureMap() {
        mapView.centerCoordinate = EPNavigationController.startCoordinate
        mapView.isRotateEnabled = false
        mapView.setUserTrackingMode(.followWithCourse, animated: false)
        mapView.allowsZooming = true
        mapView.tracksUserCourse = true
        mapView.compassView.isHidden = true
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    @objc func progressDidChange(_ notification: NSNotification) {
        guard   let routeProgress = notification.userInfo?[RouteControllerNotificationUserInfoKey.routeProgressKey] as? RouteProgress,
            let location = notification.userInfo?[RouteControllerNotificationUserInfoKey.locationKey] as? CLLocation else { return }

        mapView.updateCourseTracking(location: location, animated: true)
        switch routeProgress.currentLegProgress.currentStep.maneuverType {
        case .arrive:
            print("Arrived at destination")
            return
        case .depart:
            print("Departing route.")
        default:
            print("Maneuver type at current step: \(routeProgress.currentLegProgress.currentStep.maneuverType).")
        }
    }

    private func fetchRoutes() {
        let parkingRouteOptions = NavigationMatchOptions(coordinates: parkingRouteCoordinates, profileIdentifier: .automobile)
        parkingRouteOptions.waypointIndices = IndexSet([0, parkingRouteCoordinates.count - 1])
        parkingRouteOptions.includesSteps = true

        Directions.shared.calculateRoutes(matching: parkingRouteOptions) { (_, routes, error) in
            guard let firstRoute = routes?.first, error == nil else {
                print("Couldn't get directions to optimal route: \(String(describing: error))")
                return
            }
            self.parkingRoute = firstRoute

            guard let parkingRouteStartCoordinate = firstRoute.routeOptions.waypoints.first?.coordinate, let aToBRouteStartCoordinate = self.aToBRouteCoordinates.first else {
                print("Couldn't get directions to parking route: \(String(describing: error))")
                return
            }
            let aToBRouteOptions: RouteOptions = NavigationRouteOptions(coordinates: [aToBRouteStartCoordinate, parkingRouteStartCoordinate], profileIdentifier: .automobile)
            Directions.shared.calculate(aToBRouteOptions) { (_, routes, error) in
                guard let firstRoute = routes?.first, firstRoute.coordinates != nil, error == nil else {
                    print("Error getting mapbox directions to destination: \(String(describing: error))")
                    return
                }
                self.aToBRoute = firstRoute

                self.locationManager = SimulatedLocationManager(route: firstRoute)
                self.navigationService = MapboxNavigationService(route: firstRoute, locationSource: self.locationManager, simulating: .always)
                self.navigationService?.delegate = self

                self.mapView.addAnnotation(self.parkingDestinationAnnotation)
                if let parkingDest = self.parkingRoute?.coordinates?.first {
                    self.parkingDestinationAnnotation.coordinate = parkingDest
                }

                self.navigationService?.start()
            }
        }
    }

    private let aToBRouteCoordinates = [
        EPNavigationController.startCoordinate,
        CLLocationCoordinate2D(latitude:59.34854, longitude: 18.112199999999998),
        CLLocationCoordinate2D(latitude:59.34786, longitude: 18.112139999999997),
        CLLocationCoordinate2D(latitude:59.34749, longitude: 18.112109999999998)
    ]

    private let parkingRouteCoordinates = [
        CLLocationCoordinate2D(latitude:59.34749, longitude: 18.11211),
        CLLocationCoordinate2D(latitude:59.34713, longitude: 18.112080000000002),
        CLLocationCoordinate2D(latitude:59.34721, longitude: 18.11107),
        CLLocationCoordinate2D(latitude:59.34713, longitude: 18.112080000000002),
        CLLocationCoordinate2D(latitude:59.34703, longitude: 18.113350000000004),
        CLLocationCoordinate2D(latitude:59.34701999999999, longitude: 18.113520000000005),
        CLLocationCoordinate2D(latitude:59.347809999999996, longitude: 18.113590000000006),
        CLLocationCoordinate2D(latitude:59.34782, longitude: 18.113470000000007),
        CLLocationCoordinate2D(latitude:59.34786, longitude: 18.112140000000007),
        CLLocationCoordinate2D(latitude:59.34854, longitude: 18.11220000000001),
        CLLocationCoordinate2D(latitude:59.34851, longitude: 18.11350000000001),
        CLLocationCoordinate2D(latitude:59.34851, longitude: 18.11365000000001),
        CLLocationCoordinate2D(latitude:59.348499999999994, longitude: 18.114270000000012),
        CLLocationCoordinate2D(latitude:59.34853999999999, longitude: 18.11450000000001),
        CLLocationCoordinate2D(latitude:59.34853999999999, longitude: 18.11452000000001),
        CLLocationCoordinate2D(latitude:59.34866999999999, longitude: 18.11460000000001),
        CLLocationCoordinate2D(latitude:59.349059999999994, longitude: 18.11427000000001),
        CLLocationCoordinate2D(latitude:59.34909999999999, longitude: 18.114110000000007),
        CLLocationCoordinate2D(latitude:59.349109999999996, longitude: 18.113710000000008),
        CLLocationCoordinate2D(latitude:59.348879999999994, longitude: 18.11369000000001),
        CLLocationCoordinate2D(latitude:59.3486, longitude: 18.11366000000001),
        CLLocationCoordinate2D(latitude:59.34851, longitude: 18.11365000000001),
        CLLocationCoordinate2D(latitude:59.34843, longitude: 18.11365000000001),
        CLLocationCoordinate2D(latitude:59.34781, longitude: 18.11359000000001),
        CLLocationCoordinate2D(latitude:59.347820000000006, longitude: 18.11347000000001),
        CLLocationCoordinate2D(latitude:59.347860000000004, longitude: 18.11214000000001),
        CLLocationCoordinate2D(latitude:59.34854000000001, longitude: 18.112200000000012),
        CLLocationCoordinate2D(latitude:59.34859000000001, longitude: 18.11036000000001),
        CLLocationCoordinate2D(latitude:59.347910000000006, longitude: 18.11029000000001),
        CLLocationCoordinate2D(latitude:59.34789000000001, longitude: 18.11029000000001),
        CLLocationCoordinate2D(latitude:59.34767000000001, longitude: 18.11025000000001),
        CLLocationCoordinate2D(latitude:59.34758000000001, longitude: 18.11016000000001),
        CLLocationCoordinate2D(latitude:59.34751000000001, longitude: 18.11008000000001),
        CLLocationCoordinate2D(latitude:59.34709000000001, longitude: 18.110980000000012),
        CLLocationCoordinate2D(latitude:59.34663000000001, longitude: 18.111890000000013),
        CLLocationCoordinate2D(latitude:59.34641000000001, longitude: 18.112350000000013),
        CLLocationCoordinate2D(latitude:59.34613000000002, longitude: 18.112960000000015),
        CLLocationCoordinate2D(latitude:59.346190000000014, longitude: 18.113070000000015),
        CLLocationCoordinate2D(latitude:59.34634000000001, longitude: 18.113370000000014),
        CLLocationCoordinate2D(latitude:59.34643000000001, longitude: 18.113470000000014),
        CLLocationCoordinate2D(latitude:59.347020000000015, longitude: 18.113520000000015),
        CLLocationCoordinate2D(latitude:59.34781000000002, longitude: 18.113590000000016),
        CLLocationCoordinate2D(latitude:59.34782000000002, longitude: 18.113470000000017),
        CLLocationCoordinate2D(latitude:59.34786000000002, longitude: 18.112140000000018),
        CLLocationCoordinate2D(latitude:59.34713000000002, longitude: 18.112080000000017),
        CLLocationCoordinate2D(latitude:59.34703000000002, longitude: 18.11335000000002),
        CLLocationCoordinate2D(latitude:59.347020000000015, longitude: 18.11352000000002),
        CLLocationCoordinate2D(latitude:59.34781000000002, longitude: 18.11359000000002),
        CLLocationCoordinate2D(latitude:59.348430000000015, longitude: 18.11365000000002),
        CLLocationCoordinate2D(latitude:59.34851000000001, longitude: 18.11365000000002),
        CLLocationCoordinate2D(latitude:59.34850000000001, longitude: 18.114270000000023),
        CLLocationCoordinate2D(latitude:59.34854000000001, longitude: 18.11450000000002),
        CLLocationCoordinate2D(latitude:59.34854000000001, longitude: 18.11452000000002),
        CLLocationCoordinate2D(latitude:59.348670000000006, longitude: 18.11460000000002),
        CLLocationCoordinate2D(latitude:59.34906000000001, longitude: 18.11427000000002),
        CLLocationCoordinate2D(latitude:59.34910000000001, longitude: 18.114110000000018),
        CLLocationCoordinate2D(latitude:59.34911000000001, longitude: 18.11371000000002),
        CLLocationCoordinate2D(latitude:59.34888000000001, longitude: 18.11369000000002),
        CLLocationCoordinate2D(latitude:59.34860000000001, longitude: 18.11366000000002),
        CLLocationCoordinate2D(latitude:59.34851000000001, longitude: 18.11365000000002),
        CLLocationCoordinate2D(latitude:59.34851000000001, longitude: 18.11350000000002),
        CLLocationCoordinate2D(latitude:59.348540000000014, longitude: 18.11220000000002),
        CLLocationCoordinate2D(latitude:59.348590000000016, longitude: 18.110360000000018),
        CLLocationCoordinate2D(latitude:59.34791000000001, longitude: 18.110290000000017),
        CLLocationCoordinate2D(latitude:59.347890000000014, longitude: 18.110290000000017),
        CLLocationCoordinate2D(latitude:59.347670000000015, longitude: 18.11025000000002),
        CLLocationCoordinate2D(latitude:59.347580000000015, longitude: 18.11016000000002),
        CLLocationCoordinate2D(latitude:59.347510000000014, longitude: 18.110080000000018),
        CLLocationCoordinate2D(latitude:59.347090000000016, longitude: 18.11098000000002),
        CLLocationCoordinate2D(latitude:59.34663000000002, longitude: 18.11189000000002),
        CLLocationCoordinate2D(latitude:59.34641000000002, longitude: 18.11235000000002),
        CLLocationCoordinate2D(latitude:59.346130000000024, longitude: 18.112960000000022),
        CLLocationCoordinate2D(latitude:59.34570000000002, longitude: 18.113900000000022),
        CLLocationCoordinate2D(latitude:59.345440000000025, longitude: 18.114430000000024),
        CLLocationCoordinate2D(latitude:59.345370000000024, longitude: 18.114280000000022),
        CLLocationCoordinate2D(latitude:59.345150000000025, longitude: 18.11375000000002),
        CLLocationCoordinate2D(latitude:59.345080000000024, longitude: 18.11359000000002),
        CLLocationCoordinate2D(latitude:59.34547000000003, longitude: 18.112980000000018),
        CLLocationCoordinate2D(latitude:59.345640000000024, longitude: 18.11267000000002),
        CLLocationCoordinate2D(latitude:59.34608000000002, longitude: 18.11178000000002),
        CLLocationCoordinate2D(latitude:59.34642000000002, longitude: 18.11106000000002),
        CLLocationCoordinate2D(latitude:59.34657000000002, longitude: 18.11071000000002),
        CLLocationCoordinate2D(latitude:59.34672000000002, longitude: 18.11034000000002),
        CLLocationCoordinate2D(latitude:59.34676000000002, longitude: 18.11021000000002),
        CLLocationCoordinate2D(latitude:59.34690000000002, longitude: 18.10979000000002),
        CLLocationCoordinate2D(latitude:59.34702000000002, longitude: 18.10941000000002),
        CLLocationCoordinate2D(latitude:59.34713000000002, longitude: 18.10916000000002),
        CLLocationCoordinate2D(latitude:59.34719000000002, longitude: 18.108940000000022),
        CLLocationCoordinate2D(latitude:59.34713000000002, longitude: 18.10888000000002),
        CLLocationCoordinate2D(latitude:59.34706000000002, longitude: 18.10881000000002),
        CLLocationCoordinate2D(latitude:59.34699000000002, longitude: 18.10875000000002),
        CLLocationCoordinate2D(latitude:59.34696000000002, longitude: 18.10874000000002),
        CLLocationCoordinate2D(latitude:59.34692000000002, longitude: 18.10875000000002),
        CLLocationCoordinate2D(latitude:59.346890000000016, longitude: 18.108770000000018),
        CLLocationCoordinate2D(latitude:59.34681000000002, longitude: 18.108880000000017),
        CLLocationCoordinate2D(latitude:59.34668000000002, longitude: 18.109130000000018),
        CLLocationCoordinate2D(latitude:59.34642000000002, longitude: 18.109620000000017),
        CLLocationCoordinate2D(latitude:59.34601000000002, longitude: 18.110390000000017)
    ]
}


extension EPNavigationController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        fetchRoutes()
    }

    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        print("mapViewDidFailLoadingMap: \(error)")
    }
}

extension EPNavigationController: NavigationServiceDelegate {

    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        print("Progress did change. Travelled distance: \(progress.distanceTraveled). StepIndex: \(progress.currentLegProgress.stepIndex)")
        mapView.updateCourseTracking(location: location, animated: true)
        switch progress.currentLegProgress.currentStep.maneuverType {
        case .arrive:
            print("Arrived at destination")
            return
        case .depart:
            print("Departing route.")
        default:
            print("Maneuver type at current step: \(progress.currentLegProgress.currentStep.maneuverType).")
        }
    }

    func navigationService(_ service: NavigationService, shouldPreventReroutesWhenArrivingAt waypoint: Waypoint) -> Bool {
        return false
    }

    func navigationService(_ service: NavigationService, shouldRerouteFrom location: CLLocation) -> Bool {
        guard !isRerouting else {
            print("Reroute already in progress")
            return false
        }
        isRerouting = true
        service.stop()
        print("Mapbox asking for reroute. Here we usually calculate a new route and set it on the NavigationService.")
        return false
    }

    func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        print("Did reroute along...")
        isRerouting = false
    }

    func navigationService(_ service: NavigationService, didFailToRerouteWith error: Error) {
        print("Rerouting failed: \(error)")
        isRerouting = false
    }

    func navigationService(_ service: NavigationService, didArriveAt waypoint: Waypoint) -> Bool {
        print("Did arrive at waypoint")
        service.stop()
        guard let parkingRoute = parkingRoute else {
            return true
        }
        service.route = parkingRoute
        service.start()

        return false
    }
}
