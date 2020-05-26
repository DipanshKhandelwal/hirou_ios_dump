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
        
        let date = (self.viewControllers?.first as! TaskTableViewController).date!
        self.date = date
        let dateStr = self.dateFormatter.string(from: date)

        DispatchQueue.main.async {
            self.dateTitle.setTitle(dateStr, for: .normal)
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    private func tableViewPage(for date: Date) -> TaskTableViewController? {
        // Create a new view controller and pass suitable data.
        guard let tableViewPage = storyboard?.instantiateViewController(withIdentifier: "TaskTableViewControllerId") as? TaskTableViewController else {
            return nil
        }
        
        self.dateTitle.setTitle(self.dateFormatter.string(from: self.date), for: .normal)
        tableViewPage.date = date
        return tableViewPage
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let today = (viewController as! TaskTableViewController).date!
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: -1, to: today) else {
            return nil
        }
        return tableViewPage(for: tomorrow)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let today = (viewController as! TaskTableViewController).date!
        guard let yesterday = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
            return nil
        }
        return tableViewPage(for: yesterday)
    }
}

class PageViewController: UIPageViewController {
    var date = Date()
    let dateFormatter = DateFormatter()

    var calendar = Calendar(identifier: .iso8601)
    var dateTitle = UIButton(type: .system)
    private var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        dateTitle.titleLabel?.sizeToFit()
        dateTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        dateTitle.titleLabel?.font.withSize(15)
        dateTitle.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        self.navigationItem.titleView = dateTitle;

        self.setViewControllers([tableViewPage(for: date)!], direction: .forward, animated: true, completion: nil)
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    @objc
    func tapped() {
        print(dateTitle.titleLabel?.text as Any)
    }
    
    @objc
    func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        print(dateFormatter.string(from: datePicker.date))
        view.endEditing(true)
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
