//
//  CalenderViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 30/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Alamofire

class DateHeader: JTAppleCollectionReusableView  {
    @IBOutlet var monthTitle: UILabel!
}

class DateCell : JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet var dotView: UIView!
}

class CalendarTableCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "yyyy MM dd"
        //        let startDate = formatter.date(from: "2018 01 01")!
        //        let endDate = Date()
        //        return ConfigurationParameters(startDate: startDate, endDate: endDate, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
        
        let startDate = formatter.date(from: "01-jan-2020")!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return true // Based on a criteria, return true or false
    }
}

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    var calendarDataSource: [String:String] = [:]
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter
    }
    var taskRoutes: [TaskRoute] = []
    @IBOutlet weak var taskRouteTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        populateDataSource()
        // Do any additional setup after loading the view.
    }
    
    func populateDataSource() {
        fetchTaskRoutesAndUpdatetasks()
    }
    
    func getCalendarData (taskRoutes: [TaskRoute]) {
        var calendarTasks: Set<Date> = []
        var calendarDS: [String: String] = [:]
        for tr in taskRoutes {
            calendarTasks.insert(tr.date)
        }
        for task in calendarTasks {
            let dateString = formatter.string(from: task)
            calendarDS[dateString] = "Task"
        }
        calendarDataSource = calendarDS
        DispatchQueue.main.async {
            self.calendarView.reloadData()
        }
    }
    
    func fetchTaskRoutesAndUpdatetasks() {
        AF.request("http://127.0.0.1:8000/api/task_route/", method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                self.taskRoutes = []
                for taskRoute in value as! [Any] {
                    let taskRouteResponse = taskRoute as AnyObject
                    let taskRouteObj = TaskRoute.getTaskRouteFromResponse(obj: taskRouteResponse)
                    self.taskRoutes.append(taskRouteObj)
                }
                self.getCalendarData(taskRoutes: self.taskRoutes)
                DispatchQueue.main.async {
                    self.taskRouteTable.reloadData()
                }
            case .failure(let error):
                print(error)
                //                completion(nil)
            }
        }
    }
    
    
    // Calendar
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
    }
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
            //            cell.isHidden = false
        } else {
            cell.dateLabel.textColor = UIColor.gray
            //            cell.isHidden = true
        }
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.layer.cornerRadius =  13
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        let dateString = formatter.string(from: cellState.date)
        if calendarDataSource[dateString] == nil {
            cell.dotView.isHidden = true
        } else {
            cell.dotView.isHidden = false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleDates = calendarView.visibleDates()
        calendarView.viewWillTransition(to: .zero, with: coordinator, anchorDate: visibleDates.monthDates.first?.date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let formatter = DateFormatter()  // Declare this outside, to avoid instancing this heavy class multiple times.
        formatter.dateFormat = "MMM"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = formatter.string(from: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    
    // Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableCell", for: indexPath) as! CalendarTableCell
        
        cell.title!.text = self.taskRoutes[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tasks"
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
