//
//  RouteListTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 20/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class RouteTableViewCell : UITableViewCell {
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var garbageTypeLabel: UILabel!
}

class RouteMasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //    var detailViewController: RouteDetailViewController? = nil
    var baseRoutes = [BaseRoute]()

    @IBOutlet weak var addRouteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = [self.addRouteButton]
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        let headers = APIHeaders.getHeaders()
        AF.request(Environment.SERVER_URL + "api/base_route/", method: .get, headers: headers).validate().response { response in
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                let baseRoutesList = try! decoder.decode([BaseRoute].self, from: value!)
                self.baseRoutes = baseRoutesList.sorted() { $0.name < $1.name }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        super.viewWillAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.baseRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! RouteTableViewCell
        let route = baseRoutes[indexPath.row]
        cell.routeNameLabel?.text = route.name
        cell.customerLabel?.text = route.customer?.name ?? "n/a"
        cell.garbageTypeLabel?.text =  route.getGarbagesNameList()
        return cell
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRouteDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let route = self.baseRoutes[indexPath.row]
                let controller = (segue.destination as! RouteDetailViewController)
                controller.detailItem = route as Any
            }
        }
    }
}
