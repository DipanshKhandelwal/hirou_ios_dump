//
//  PageViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 25/05/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.date = (self.viewControllers?.first as! TaskTableViewController).date
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    private func tableViewPage(for date: Date) -> TaskTableViewController? {
        // Create a new view controller and pass suitable data.
        guard let tableViewPage = storyboard?.instantiateViewController(withIdentifier: "TaskTableViewControllerId") as? TaskTableViewController else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        DispatchQueue.main.async {
            self.dateTitle.setTitle(dateFormatter.string(from: date), for: .normal)
        }
        
        tableViewPage.date = date
        return tableViewPage
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let today = (viewController as! TaskTableViewController).date!
        guard var yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return nil
        }
        yesterday = calendar.startOfDay(for: yesterday)

        return tableViewPage(for: yesterday)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let today = (viewController as! TaskTableViewController).date!
        guard var tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else {
            return nil
        }
        tomorrow = calendar.startOfDay(for: tomorrow)

        return tableViewPage(for: tomorrow)
    }
}

class PageViewController: UIPageViewController {

    var date: Date!
    var calendar = Calendar(identifier: .iso8601)
    
    var dateTitle = UIButton(type: .system)
    
    func generateRandomDate(daysBack: Int)-> Date?{
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(23)
        let minute = arc4random_uniform(59)
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = -1 * Int(day - 1)
        offsetComponents.hour = -1 * Int(hour)
        offsetComponents.minute = -1 * Int(minute)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        return randomDate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        let randomInt = Int.random(in: 0..<30)
        date = generateRandomDate(daysBack: randomInt)
        
        // Do any additional setup after loading the view.
        self.setViewControllers([tableViewPage(for: date)!], direction: .forward, animated: true, completion: nil)
        
        dateTitle.titleLabel?.sizeToFit()
        dateTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        dateTitle.titleLabel?.font.withSize(15)
        dateTitle.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        self.navigationItem.titleView = dateTitle;
        
        dateTitle.setTitle("Date", for: .normal)
    }
    
    @objc
    func tapped() {
        print(dateTitle.titleLabel?.text as Any)
    }
    
    
    
    func getViewControllerAtIndex(index: Int) -> TaskTableViewController
    {
        // Create a new view controller and pass suitable data.
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TaskTableViewControllerId") as! TaskTableViewController
        return viewController
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
