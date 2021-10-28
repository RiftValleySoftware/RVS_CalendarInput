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
 
 Version 1.0.0
 */

import UIKit
#if os(iOS) // This prevents the IB errors from showing up, under SPM (From SO Answer: https://stackoverflow.com/a/66334661/879365).
/* ###################################################################################################################################### */
// MARK: - Main Class
// MARK: Special Calendar Input Class -
/* ###################################################################################################################################### */
/**
 */
@IBDesignable
open class RVS_CalendarInput: UIView {
    /* ################################################################################################################################## */
    // MARK: Data Item Struct
    /* ################################################################################################################################## */
    /**
     This is one element of the data that is provided to, and read from, the view.
     */
    public struct DateItem: Comparable {
        // MARK: Required Stored Properties
        /* ############################################################## */
        /**
         The year, as an integer. REQUIRED
         */
        public let year: Int
        
        /* ############################################################## */
        /**
         The month, as an integer (1 -> 12). REQUIRED
         */
        public let month: Int
        
        /* ############################################################## */
        /**
         The day of the month (1 -> [28|29|30|31]), as an integer. REQUIRED
         */
        public let day: Int
        
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

        // MARK: Optional Stored Properties
        /* ############################################################## */
        /**
         This is the calendar to use for our component. If ignored, the current calendar will be used. OPTIONAL
         */
        public var calendar: Calendar
        
        /* ############################################################## */
        /**
         Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public var refCon: Any?
        
        // MARK: Computed Properties
        /* ############################################################## */
        /**
         This returns the instance as a standard Foundation DateComponents instance.
         */
        public var dateComponents: DateComponents { DateComponents(calendar: calendar, year: year, month: month, day: day) }
        
        /* ############################################################## */
        /**
         This returns the instance as a standard Foundation Date. It may be nil.
         */
        public var date: Date? { dateComponents.date }
        
        // MARK: Initializers
        /* ############################################################## */
        /**
         Default Initializer
         
         - parameter day: The day of the month (1 -> [28|29|30|31]), as an integer. REQUIRED
         - parameter month: The month, as an integer (1 -> 12). REQUIRED
         - parameter year: The year, as an integer. REQUIRED
         - parameter isEnabled: True, if the item is enabled for selection. Default is false. OPTIONAL
         - parameter isSelected: True, if the item is currently selected. Default is false. OPTIONAL
         - parameter calendar: This is the calendar to use for our component. If ignored, the current calendar will be used. OPTIONAL
         - parameter refCon: Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public init(day inDay: Int, month inMonth: Int, year inYear: Int, isEnabled inIsEnabled: Bool = false, isSelected inIsSelected: Bool = false, calendar inCalendar: Calendar? = nil, refCon inRefCon: Any? = nil) {
            day = inDay
            month = inMonth
            year = inYear
            isEnabled = inIsEnabled
            isSelected = inIsSelected
            calendar = inCalendar ?? Calendar.current
            refCon = inRefCon
        }

        /* ############################################################## */
        /**
         DateComponents Initializer (can return nil)
         
         - parameter dateComponents: The day/month/year, as DateComponents. REQUIRED
         - parameter isEnabled: True, if the item is enabled for selection. Default is false. OPTIONAL
         - parameter isSelected: True, if the item is currently selected. Default is false. OPTIONAL
         - parameter calendar: This is the calendar to use for our component. If ignored, the current calendar will be used. OPTIONAL
         - parameter refCon: Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public init?(dateComponents inDateComponents: DateComponents, isEnabled inIsEnabled: Bool = false, isSelected inIsSelected: Bool = false, calendar inCalendar: Calendar? = nil, refCon inRefCon: Any? = nil) {
            guard let inDay = inDateComponents.day,
                  let inMonth = inDateComponents.month,
                  let inYear = inDateComponents.year
            else { return nil }
            
            self.init(day: inDay, month: inMonth, year: inYear, isEnabled: inIsEnabled, isSelected: inIsSelected, calendar: inCalendar, refCon: inRefCon)
        }

        /* ############################################################## */
        /**
         Date Initializer (can return nil)
         
         - parameter date: The day/month/year, as a Date instance. REQUIRED
         - parameter isEnabled: True, if the item is enabled for selection. Default is false. OPTIONAL
         - parameter isSelected: True, if the item is currently selected. Default is false. OPTIONAL
         - parameter calendar: This is the calendar to use for our component. If ignored, the current calendar will be used. OPTIONAL
         - parameter refCon: Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public init?(date inDate: Date, isEnabled inIsEnabled: Bool = false, isSelected inIsSelected: Bool = false, calendar inCalendar: Calendar? = nil, refCon inRefCon: Any? = nil) {
            let tempCalendar = inCalendar ?? Calendar.current
            let tempComponents = tempCalendar.dateComponents([.day, .month, .year], from: inDate)
            guard let inDay = tempComponents.day,
                  let inMonth = tempComponents.month,
                  let inYear = tempComponents.year
            else { return nil }
            
            self.init(day: inDay, month: inMonth, year: inYear, isEnabled: inIsEnabled, isSelected: inIsSelected, calendar: inCalendar, refCon: inRefCon)
        }

        // MARK: Comparable Conformance
        /* ############################################################## */
        /**
         Less-than comparison test.
         
         - parameter lhs: The left-hand side of the comparison.
         - parameter rhs: The right-hand side of the comparison.
         - returns: true, if lhs is less than rhs. False will be returned, if either has a nil date.
         */
        public static func < (lhs: DateItem, rhs: DateItem) -> Bool {
            guard let lhsDate = lhs.date,
                  let rhsDate = rhs.date
            else { return false }
            
            return lhsDate < rhsDate
        }
        
        // MARK: Equatable Conformance
        /* ############################################################## */
        /**
         Equality test.
         
         - parameter lhs: The left-hand side of the comparison.
         - parameter rhs: The right-hand side of the comparison.
         - returns: true, if lhs is equal to rhs. If either one has a nil date, false will be returned; even if both are nil.
         */
        public static func == (lhs: DateItem, rhs: DateItem) -> Bool { nil != lhs.date && lhs.date == rhs.date }
    }
    
    /* ################################################################## */
    /**
     This contains the data that defines the state of this control. This will have *every* day shown by the control; not just the ones passed in. READ-ONLY
     */
    public private(set) var data: [DateItem] = []

    /* ################################################################## */
    /**
     This contains the calendar used for the control. It defaults to the current calendar, but can be changed.
     */
    public var calendar: Calendar = Calendar.current
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     This is basically a write-only way to set up the control. Read will always return an empty array.
     This contains the particular dates that you want to affect. The date range of the control will be determined from these data.
     Setting this value will re-initialize the control.
     */
    public var setupData: [DateItem] {
        get { [] }
        set {
            let temp = newValue
            
            if !temp.isEmpty {
                _determineDataSetup(from: temp)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     This will clear and repopulate the data Array, based on the "seed" data, passed in.
     It should be noted that this *clears* the current data array, and does not preserve its previous state, so it is incumbent upon the user to "snapshot" the data, if so desired.
     - parameter from: This is an array of "seed" data.
     */
    private func _determineDataSetup(from inSeedData: [DateItem]) {
        data = []
        
        // From the given data, we determine the earliest date, and the latest date.
        let startDate = inSeedData.reduce(Date.distantFuture) { current, next in
            guard let nextDate = next.date,
                  current > nextDate
            else { return current }
            return nextDate
        }
        
        let endDate = inSeedData.reduce(Date.distantPast) { current, next in
            guard let nextDate = next.date,
                  current < nextDate
            else { return current }
            return nextDate
        }
        
        // What we do here, is strip out the days. We are only interested in the month and year of each end. This also translates the data into our view's calendar.
        let startComponents = calendar.dateComponents([.year, .month], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month], from: endDate)
        
        guard let startYear = startComponents.year,
              let endYear = endComponents.year,
              var startMonth = startComponents.month,
              let endMonth = endComponents.month
        else { return }
        // Now, a fairly simple nested loop is used to poulate our data.
        for year in startYear...endYear {
            for month in startMonth...12 where year < endYear || month <= endMonth {
                if let calcDate = calendar.date(from: DateComponents(year: year, month: month)),
                   let numberOfDaysInThisMonth = calendar.range(of: .day, in: .month, for: calcDate)?.count {
                    for day in 1...numberOfDaysInThisMonth {
                        let comparisonInstance = DateItem(day: day, month: month, year: year)
                        var dateItemForThisDay = comparisonInstance
                        if inSeedData.contains(comparisonInstance),
                           let dateItemForThisDayTemp = inSeedData.first(where: { $0 == comparisonInstance }) {
                            dateItemForThisDay = dateItemForThisDayTemp
                        }
                        
                        data.append(dateItemForThisDay)
                    }
                }
            }
            
            startMonth = 1
        }
    }
}
#endif
