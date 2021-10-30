/* ###################################################################################################################################### */
/**
 © Copyright 2021, The Great Rift Valley Software Company.
 
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_CalendarInput

/* ###################################################################################################################################### */
// MARK: - The Main Test Harness Screen View Controller -
/* ###################################################################################################################################### */
/**
 The test harness app is a very simple app, with only one screen. This screen presents a "dashboard" to test the control.
 */
class RVS_CalendarInputTestHarness_ViewController: UIViewController {
    /* ################################################################## */
    /**
     */
    var seedData: [RVS_CalendarInput.DateItem] = []
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var calendarWidgetInstance: RVS_CalendarInput!
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_CalendarInputTestHarness_ViewController {
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialSeedData()
        calendarWidgetInstance?.setupData = seedData
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_CalendarInputTestHarness_ViewController {
    /* ################################################################## */
    /**
     */
    func setUpInitialSeedData() {
        seedData = []
        // Four or five month window. 30 days before today, and 90 days after.
        if let today = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date())),
           let thisWeekday = Calendar.current.dateComponents([.weekday], from: today).weekday {
            let startDate = today.addingTimeInterval(-2592000)
            let endDate = today.addingTimeInterval(7776000)
            
            // What we do here, is strip out the days. We are only interested in the month and year of each end.
            let startComponents = Calendar.current.dateComponents([.year, .month], from: startDate)
            let endComponents = Calendar.current.dateComponents([.year, .month], from: endDate)
            
            guard let startYear = startComponents.year,
                  let endYear = endComponents.year,
                  var startMonth = startComponents.month,
                  let endMonth = endComponents.month
            else { return }
            
            // Now, a fairly simple nested loop is used to poulate our data.
            for year in startYear...endYear {
                for month in startMonth...12 where year < endYear || month <= endMonth {
                    if let calcDate = Calendar.current.date(from: DateComponents(year: year, month: month)),
                       let numberOfDaysInThisMonth = Calendar.current.range(of: .day, in: .month, for: calcDate)?.count {
                        for day in 1...numberOfDaysInThisMonth {
                            let dateItemForThisDay = RVS_CalendarInput.DateItem(day: day, month: month, year: year)
                            
                            if let date = dateItemForThisDay.date,
                               let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday,
                               weekday == thisWeekday {
                                dateItemForThisDay.isEnabled = date >= today
                                dateItemForThisDay.isSelected = date < today
                            }
                            seedData.append(dateItemForThisDay)
                        }
                    }
                }
                
                startMonth = 1
            }
        }
    }
}
