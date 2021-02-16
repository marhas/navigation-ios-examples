//
//  EPBasicNavigationViewController.swift
//  Navigation-Examples
//
//  Created by Marcel Hasselaar on 2021-02-11.

import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class EPBasicNavigationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let origin = CLLocationCoordinate2DMake(59.349102999999999, 18.113700999999999)
        let destination = CLLocationCoordinate2DMake(59.347019000000003, 18.107286999999999)
        let navigationRouteOptions = NavigationRouteOptions(coordinates: [origin, destination])

        let serializedWaypointsData = serializedWaypointsAsString.data(using: .utf8)!
        let waypoints: [Waypoint] = try! JSONDecoder().decode([Waypoint].self, from: serializedWaypointsData)

        let navigationMatchOptions = NavigationMatchOptions(waypoints: waypoints, profileIdentifier: .automobile)
//        routeOptions.waypointIndices = IndexSet([0, pgRoute.count - 1])
        //Defaults to polyline5 encoding but nav-native only accepts polyline6 currently. So the route ends up somewhere in the Atlantic, which triggers a reroute.
//        navigationMatchOptions.shapeFormat = .polyline
        navigationMatchOptions.includesSteps = true

        calculateABRoute() { abRoute in
            Directions.shared.calculateRoutes(matching: navigationMatchOptions) { [weak self] (_, result) in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let response):
                    guard let route = response.routes?.first else {
                        return
                    }
                    self.routes = response.routes

                    // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
                    // Since first route is retrieved from response `routeIndex` is set to 0.
                    let navigationService = MapboxNavigationService(route: route, routeIndex: 0, routeOptions: navigationRouteOptions, simulating: .always)

                    let navigationOptions = NavigationOptions(navigationService: navigationService)
                    let navigationViewController = NavigationViewController(for: route, routeIndex: 0, routeOptions: navigationRouteOptions, navigationOptions: navigationOptions)
                    navigationViewController.modalPresentationStyle = .fullScreen
                    // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
                    navigationViewController.routeLineTracksTraversal = true
                    navigationViewController.delegate = self
                    self.present(navigationViewController, animated: true, completion: nil)
                    navigationViewController.navigationService.stop()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        navigationViewController.navigationService.start()
                    }

                //                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                //                    guard let routes = self.routes, let firstRoute = routes.first else { return }
                //                    navigationService.indexedRoute = (firstRoute, 0)
                //                }
                }
            }
        }
    }

    private func calculateABRoute(then completion: @escaping (Route) -> Void) {
        let fromWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 59.349136000000001, longitude: 18.112494999999999), coordinateAccuracy: 55)
        let toWaypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 59.349105999999999, longitude: 18.113705), coordinateAccuracy: 55)
        let options: RouteOptions = NavigationRouteOptions(waypoints: [fromWaypoint, toWaypoint], profileIdentifier: .automobile)
        Directions.shared.calculate(options) { (_, result) in
            switch result {
            case .success(let response):
                guard let firstRoute = response.routes?.first else {
                    return
                }
                completion(firstRoute)
            case .failure(let error):
                print("Error getting mapbox directions to destination: \(String(describing: error))")
            }
        }

    }

    private var routes: [Route]?
}

extension EPBasicNavigationViewController: NavigationViewControllerDelegate {
    func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        print("Distance travelled: \(progress.distanceTraveled), distance remaining: \(progress.distanceRemaining)")
    }
}

private let serializedWaypointsAsString = """
[{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113700999999999,59.349102999999999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112978110404999,59.349120904676802]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112228017142801,59.348839253020401]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1129242285866,59.348523921139197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114080511280701,59.348500823675003]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1142997481553,59.3490223436349]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1136763160074,59.348804725170602]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113614801051501,59.348156982856203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112102253002998,59.3474882142336]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112789345859799,59.347067402174197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113548540610498,59.3474103558002]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.111212920871701,59.347877503871203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.110252455108,59.347669389949999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109456714491301,59.347808805051201]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108360769844701,59.348333193064597]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1080882169856,59.3486342791075]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108616789700601,59.3486423267044]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109645360700998,59.348610268604197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1112802945181,59.348564471268801]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1129242285866,59.348523921139197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114080511280701,59.348500823675003]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1142997481553,59.3490223436349]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1136763160074,59.348804725170602]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113614801051501,59.348156982856203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1128613462399,59.3478298947594]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112102253002998,59.3474882142336]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.112789345859799,59.347067402174197]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1134674510762,59.346423172120701]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.113692817009699,59.345783319320503]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114352532789699,59.3453997259857]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.114011172981801,59.345253160279803]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1136698131738,59.345108884380799]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.111937846790902,59.345993934880802]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109803517538801,59.3468935398448]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109170687805602,59.347121937038203]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108899759015099,59.347160753065303]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1090541339839,59.346715841999]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.1103819792339,59.3460065896994]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.110875505420701,59.3454784043751]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.110377487657502,59.345319572992402]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.109736101558799,59.345140032564402]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.108295361351999,59.346024869856102]},{\"allowsArrivingOnOppositeSide\":true,\"coordinateAccuracy\":-1,\"separatesLegs\":true,\"targetCoordinate\":null,\"location\":[18.107286999999999,59.347019000000003]}]
"""
