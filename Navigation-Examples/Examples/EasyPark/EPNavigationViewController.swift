import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Mapbox


class EPNavigationViewController: UIViewController {
    var mapView: NavigationMapView?
    var navigationService: MapboxNavigationService?
    private let origin = CLLocationCoordinate2DMake(59.349102999999999, 18.113700999999999)
    private let destination = CLLocationCoordinate2DMake(59.347019000000003, 18.107286999999999)

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = NavigationMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.userTrackingMode = .follow

        mapView.delegate = self
        mapView.tracksUserCourse = true
        self.mapView = mapView
        view.addSubview(mapView)
    }

    func getWaypoints() -> [Waypoint] {
        let serializedWaypointsData = serializedWaypointsAsString.data(using: .utf8)!
        let waypoints: [Waypoint] = try! JSONDecoder().decode([Waypoint].self, from: serializedWaypointsData)
        return waypoints
    }

    private func startNavigating() {
        let waypoints = getWaypoints()

        let navigationMatchOptions = NavigationMatchOptions(waypoints: waypoints, profileIdentifier: .automobile)
        //Defaults to polyline5 encoding but nav-native only accepts polyline6 currently. So the route ends up somewhere in the Atlantic, which triggers a reroute.
        //        navigationMatchOptions.shapeFormat = .polyline
        navigationMatchOptions.includesSteps = true

        Directions.shared.calculateRoutes(matching: navigationMatchOptions) { [weak self] (_, result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first else {
                    return
                }
                self.parkingRoute = route
                self.parkingRouteWaypoints = response.waypoints

                self.startNavigation()
            }
        }
    }

    private func startNavigation() {
        guard let parkingRoute = parkingRoute else { return }
        let navigationRouteOptions = NavigationRouteOptions(coordinates: [])

        let navigationService = MapboxNavigationService(route: parkingRoute, routeIndex: 0, routeOptions: navigationRouteOptions, simulating: .always)
        navigationService.delegate = self
        navigationService.simulationSpeedMultiplier = 1.0
        navigationService.start()
        self.navigationService = navigationService
    }

    private var parkingRoute: Route?
    private var parkingRouteWaypoints: [Waypoint]?
    private var lastDistanceTravelled: Double = 0
}

extension EPNavigationViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapView.setCenter(origin, zoomLevel: 17, animated: false)
        startNavigating()
    }
}

extension EPNavigationViewController: NavigationServiceDelegate {
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        mapView?.updateCourseTracking(location: location, animated: true)
        print("Distance travelled: \(progress.distanceTraveled), distance remaining: \(progress.distanceRemaining)")
        if lastDistanceTravelled > progress.distanceTraveled && progress.distanceTraveled > 0 {
            print("‼️ Travelling backwards on route")
        }
        lastDistanceTravelled = progress.distanceTraveled
    }

    func navigationService(_ service: NavigationService, shouldPreventReroutesWhenArrivingAt waypoint: Waypoint) -> Bool {
        return true
    }
}

private let serializedWaypointsAsString = """
[{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.113700999999999,59.349102999999999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.112978110404999,59.349120904676802]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.112228017142801,59.348839253020401]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1129242285866,59.348523921139197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.114080511280701,59.348500823675003]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1142997481553,59.3490223436349]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1136763160074,59.348804725170602]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.113614801051501,59.348156982856203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.112102253002998,59.3474882142336]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.112789345859799,59.347067402174197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.113548540610498,59.3474103558002]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.111212920871701,59.347877503871203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.110252455108,59.347669389949999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.109456714491301,59.347808805051201]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.108360769844701,59.348333193064597]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1080882169856,59.3486342791075]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.108616789700601,59.3486423267044]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.109645360700998,59.348610268604197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1112802945181,59.348564471268801]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1129242285866,59.348523921139197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.114080511280701,59.348500823675003]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1142997481553,59.3490223436349]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1136763160074,59.348804725170602]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.113614801051501,59.348156982856203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.112102253002998,59.3474882142336]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.112789345859799,59.347067402174197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1134674510762,59.346423172120701]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.113692817009699,59.345783319320503]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.114352532789699,59.3453997259857]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.114011172981801,59.345253160279803]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1136698131738,59.345108884380799]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.111937846790902,59.345993934880802]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.109803517538801,59.3468935398448]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.109170687805602,59.347121937038203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.108899759015099,59.347160753065303]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1090541339839,59.346715841999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.1103819792339,59.3460065896994]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.110875505420701,59.3454784043751]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.110377487657502,59.345319572992402]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.109736101558799,59.345140032564402]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.108295361351999,59.346024869856102]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":false,\"targetCoordinate\":null,\"location\":[18.107286999999999,59.347019000000003]}]
"""

private let serializedWaypointsSeparatesLegsAsString = """
[{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113700999999999,59.349102999999999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112978110404999,59.349120904676802]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112228017142801,59.348839253020401]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1129242285866,59.348523921139197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114080511280701,59.348500823675003]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1142997481553,59.3490223436349]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1136763160074,59.348804725170602]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113614801051501,59.348156982856203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112102253002998,59.3474882142336]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112789345859799,59.347067402174197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113548540610498,59.3474103558002]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.111212920871701,59.347877503871203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.110252455108,59.347669389949999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109456714491301,59.347808805051201]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108360769844701,59.348333193064597]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1080882169856,59.3486342791075]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108616789700601,59.3486423267044]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109645360700998,59.348610268604197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1112802945181,59.348564471268801]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1129242285866,59.348523921139197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114080511280701,59.348500823675003]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1142997481553,59.3490223436349]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1136763160074,59.348804725170602]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113614801051501,59.348156982856203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112102253002998,59.3474882142336]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112789345859799,59.347067402174197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1134674510762,59.346423172120701]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113692817009699,59.345783319320503]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114352532789699,59.3453997259857]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114011172981801,59.345253160279803]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1136698131738,59.345108884380799]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.111937846790902,59.345993934880802]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109803517538801,59.3468935398448]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109170687805602,59.347121937038203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108899759015099,59.347160753065303]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1090541339839,59.346715841999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1103819792339,59.3460065896994]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.110875505420701,59.3454784043751]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.110377487657502,59.345319572992402]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109736101558799,59.345140032564402]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108295361351999,59.346024869856102]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.107286999999999,59.347019000000003]}]
"""
