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
    /* ################################################################################################################################## */
    // MARK: Date Item Class (One element of the `data` array)
    /* ################################################################################################################################## */
    /**
     This is one element of the data that is provided to, and read from, the view.
     */
    private struct _DateItem: RVS_CalendarInput_DateItemProtocol {
        // MARK: Required Stored Properties
        /* ############################################################## */
        /**
         The year, as an integer. REQUIRED
         */
        public var year: Int
        
        /* ############################################################## */
        /**
         The month, as an integer (1 -> 12). REQUIRED
         */
        public var month: Int
        
        /* ############################################################## */
        /**
         The day of the month (1 -> [28|29|30|31]), as an integer. REQUIRED
         */
        public var day: Int
        
        // MARK: Optional Stored Properties
        /* ############################################################## */
        /**
         True, if the item is enabled for selection. Default is false. OPTIONAL
         */
        public var isEnabled: Bool
        
        /* ############################################################## */
        /**
         True, if the item is currently selected. Default is false. OPTIONAL
         */
        public var isSelected: Bool

        /* ############################################################## */
        /**
         Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public var refCon: Any?
        
        // MARK: Default Initializer
        /* ############################################################## */
        /**
         Default Initializer. The calendar used, will be the current one.
         
         - parameter day: The day of the month (1 -> [28|29|30|31]), as an integer. REQUIRED
         - parameter month: The month, as an integer (1 -> 12). REQUIRED
         - parameter year: The year, as an integer. REQUIRED
         - parameter isEnabled: True, if the item is enabled for selection. Default is false. OPTIONAL
         - parameter isSelected: True, if the item is currently selected. Default is false. OPTIONAL
         - parameter refCon: Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public init(day inDay: Int,
                    month inMonth: Int,
                    year inYear: Int,
                    isEnabled inIsEnabled: Bool = false,
                    isSelected inIsSelected: Bool = false,
                    refCon inRefCon: Any? = nil
        ) {
            day = inDay
            month = inMonth
            year = inYear
            isEnabled = inIsEnabled
            isSelected = inIsSelected
            refCon = inRefCon
        }
    }

    /* ################################################################## */
    /**
     The initial (default) color for the widget's weekday header font.
     */
    var initialWeekdayHeaderFontColor: UIColor = .clear
    
    /* ################################################################## */
    /**
     The initial (default) color for the widget's year header font.
     */
    var initialYearHeaderFontColor: UIColor = .clear
    
    /* ################################################################## */
    /**
     The initial (default) color for the widget's year header.
     */
    var initialYearHeaderBackgroundColor: UIColor = .clear

    /* ################################################################## */
    /**
     The initial (default) color for the widget's month header font.
     */
    var initialMonthHeaderFontColor: UIColor = .clear
    
    /* ################################################################## */
    /**
     The initial (default) color for the widget's month header.
     */
    var initialMonthHeaderBackgroundColor: UIColor = .clear

    /* ################################################################## */
    /**
     The initial (default) color for the widget's day header font. If the day is selected, then this will be the background color.
     */
    var initialDayFontColor: UIColor = .clear
    
    /* ################################################################## */
    /**
     The initial (default) color for the widget's day header background. If the day is selected, then this will be the font color.
     */
    var initialDayBackgroundColor: UIColor = .clear
    
    /* ################################################################## */
    /**
     This is the actual widget, in our layout.
     */
    @IBOutlet weak var calendarWidgetInstance: RVS_CalendarInput!
    
    /* ################################################################## */
    /**
     This is the date picker for the start date.
     */
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    /* ################################################################## */
    /**
     This is the date picker for the end date.
     */
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    /* ################################################################## */
    /**
     The switch to show/hide the year headers.
     */
    @IBOutlet weak var showYearHeaderSwitch: UISwitch!
    
    /* ################################################################## */
    /**
     The switch to show/hide the month headers.
     */
    @IBOutlet weak var showMonthHeaderSwitch: UISwitch!

    /* ################################################################## */
    /**
     The switch to show/hide the weekday header.
     */
    @IBOutlet weak var showWeekdayHeaderSwitch: UISwitch!

    /* ################################################################## */
    /**
     This is a button that initiates "clown mode," with disgusting colors.
     */
    @IBOutlet weak var clownButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_CalendarInputTestHarness_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been initialized.
     We basically use this to set our stored default colors, and initialize the control with our "starter" set.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarWidgetInstance?.delegate = self
        initialWeekdayHeaderFontColor = calendarWidgetInstance?.weekdayHeaderFontColor ?? .clear
        initialYearHeaderFontColor = calendarWidgetInstance?.yearHeaderFontColor ?? .clear
        initialYearHeaderBackgroundColor = calendarWidgetInstance?.yearHeaderBackgroundColor ?? .clear
        initialMonthHeaderFontColor = calendarWidgetInstance?.monthHeaderFontColor ?? .clear
        initialMonthHeaderBackgroundColor = calendarWidgetInstance?.monthHeaderBackgroundColor ?? .clear
        initialDayFontColor = calendarWidgetInstance?.tintColor ?? .clear
        initialDayBackgroundColor = calendarWidgetInstance?.enabledItemBackgroundColor ?? .clear
        // Four or five month window. 30 days before today, and 90 days after.
        if let today = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date())) {
            startDatePicker?.date = today.addingTimeInterval(-2592000)
            endDatePicker?.date = today.addingTimeInterval(7776000)
            datePickerChanged()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_CalendarInputTestHarness_ViewController {
    /* ################################################################## */
    /**
     This creates a new array of date items, and sets them to the widget.
     */
    func setUpWidgetFromDates() {
        if let startDate = startDatePicker?.date,
           let endDate = endDatePicker?.date,
           startDate < endDate {
            var seedData = [_DateItem]()

            // Determine a start day, and an end day. Remember that we work in "whole month" increments.
            if let today = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date())),
               let thisWeekday = Calendar.current.dateComponents([.weekday], from: today).weekday {
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
                                var dateItemForThisDay = _DateItem(day: day, month: month, year: year)
                                
                                if let date = dateItemForThisDay.date,
                                   let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday,
                                   weekday == thisWeekday {
                                    dateItemForThisDay.isEnabled = today <= endDate && (today...endDate).contains(date)
                                    dateItemForThisDay.isSelected = date <= today
                                }
                                seedData.append(dateItemForThisDay)
                            }
                        }
                    }
                    
                    startMonth = 1
                }
                
                calendarWidgetInstance?.setupData = seedData
                calendarWidgetInstance?.showMonthHeaders = showMonthHeaderSwitch?.isOn ?? true
                calendarWidgetInstance?.showYearHeaders = showYearHeaderSwitch?.isOn ?? true
                calendarWidgetInstance?.showWeekdayHeader = showWeekdayHeaderSwitch?.isOn ?? true
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_CalendarInputTestHarness_ViewController {
    /* ################################################################## */
    /**
     This is called whenever either of the date pickers are called.
     - parameter: ignored.
     */
    @IBAction func datePickerChanged(_: UIDatePicker! = nil) {
        setUpWidgetFromDates()
    }
    
    /* ################################################################## */
    /**
     This is called whenever the show year header switch, or its label button, are hit.
     - parameter inControl: The control. It is used to determine the behavior of the callback (button only toggles the switch).
     */
    @IBAction func showYearHeaderSwitchHit(_ inControl: Any) {
        if inControl is UIButton {
            showYearHeaderSwitch?.isOn = !(showYearHeaderSwitch?.isOn ?? true)
            showYearHeaderSwitch?.sendActions(for: .valueChanged)
        } else {
            calendarWidgetInstance?.showYearHeaders = showYearHeaderSwitch?.isOn ?? true
        }
    }
    
    /* ################################################################## */
    /**
     This is called whenever the show month header switch, or its label button, are hit.
     - parameter inControl: The control. It is used to determine the behavior of the callback (button only toggles the switch).
    */
    @IBAction func showMonthHeaderSwitchHit(_ inControl: Any) {
        if inControl is UIButton {
            showMonthHeaderSwitch?.isOn = !(showMonthHeaderSwitch?.isOn ?? true)
            showMonthHeaderSwitch?.sendActions(for: .valueChanged)
        } else {
            calendarWidgetInstance?.showMonthHeaders = showMonthHeaderSwitch?.isOn ?? true
        }
    }

    /* ################################################################## */
    /**
     This is called whenever the show the weekday header switch, or its label button, are hit.
     - parameter inControl: The control. It is used to determine the behavior of the callback (button only toggles the switch).
     */
    @IBAction func showWeekdayHeaderSwitchHit(_ inControl: Any) {
        if inControl is UIButton {
            showWeekdayHeaderSwitch?.isOn = !(showWeekdayHeaderSwitch?.isOn ?? true)
            showWeekdayHeaderSwitch?.sendActions(for: .valueChanged)
        } else {
            calendarWidgetInstance?.showWeekdayHeader = showWeekdayHeaderSwitch?.isOn ?? true
        }
    }

    /* ################################################################## */
    /**
     This is called when the "clown mode" button is hit.
     The color state is toggled, as is the button image placement.
     - parameter inButton: The control. It is used to toggle the images.
     */
    @IBAction func clownButtonHit(_ inButton: UIButton) {
        if initialWeekdayHeaderFontColor == calendarWidgetInstance?.weekdayHeaderFontColor {
            calendarWidgetInstance?.weekdayHeaderFontColor = .red
            calendarWidgetInstance?.yearHeaderFontColor = .yellow
            calendarWidgetInstance?.yearHeaderBackgroundColor = .blue
            calendarWidgetInstance?.monthHeaderFontColor = .orange
            calendarWidgetInstance?.monthHeaderBackgroundColor = .purple
            calendarWidgetInstance?.tintColor = .green
            calendarWidgetInstance?.enabledItemBackgroundColor = .red
        } else {
            calendarWidgetInstance?.weekdayHeaderFontColor = initialWeekdayHeaderFontColor
            calendarWidgetInstance?.yearHeaderFontColor = initialYearHeaderFontColor
            calendarWidgetInstance?.yearHeaderBackgroundColor = initialYearHeaderBackgroundColor
            calendarWidgetInstance?.monthHeaderFontColor = initialMonthHeaderFontColor
            calendarWidgetInstance?.monthHeaderBackgroundColor = initialMonthHeaderBackgroundColor
            calendarWidgetInstance?.tintColor = initialDayFontColor
            calendarWidgetInstance?.enabledItemBackgroundColor = initialDayBackgroundColor
        }
        
        if let highlightedImage = inButton.image(for: .highlighted),
           let normalImage = inButton.image(for: .normal) {
            inButton.setImage(highlightedImage, for: .normal)
            inButton.setImage(normalImage, for: .highlighted)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: RVS_CalendarInputDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_CalendarInputTestHarness_ViewController: RVS_CalendarInputDelegate {
    /* ################################################################## */
    /**
     This is called when the user selects an enabled calendar date.
     Currently, only a console message is sent.
     - parameter inCalendarInput: The calendar input widget instance. It is ignored in this handler.
     - parameter dateItemChanged: The date item that was changed.
     */
    func calendarInput(_ inCalendarInput: RVS_CalendarInput, dateItemChanged inDateItem: RVS_CalendarInput_DateItemProtocol) {
        print("The date \(String(describing: inDateItem.date)) was selected by the user. It is currently \(inDateItem.isSelected ? "" : "not ")selected.")
    }
}
