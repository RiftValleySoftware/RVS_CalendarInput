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
// MARK: - UIView Extension -
/* ###################################################################################################################################### */
/**
 Add a corner radius
 */
extension UIView {
    /* ################################################################## */
    /**
     This gives us access to the corner radius, so we can give the view rounded corners.
     
    **NOTE:** This requires that `clipsToBounds` be set, which will be done, if the value is greater than zero.*
     */
    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            if 0 < newValue {
                clipsToBounds = true
            }
            setNeedsDisplay()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Sepecial Array Extension Functions for Date Items -
/* ###################################################################################################################################### */
public extension Array where Element: RVS_CalendarInput.DateItem {
    /* ################################################################## */
    /**
     This returns the range of years. It uses the calendar system for the data.
     */
    var yearRange: Range<Int> {
        let lowerBound = reduce(Int.max) { current, next in current > next.year ? next.year : current }
        let upperBound = reduce(Int.min) { current, next in current < next.year ? next.year : current }
        
        guard lowerBound <= upperBound else { return 0..<0 }
        
        return lowerBound..<(upperBound + 1)
    }
    
    /* ################################################################## */
    /**
     This returns the range of months, in the given year. IT allows the user to specify a calendar to use for this.
     - parameter for: The year, as an integer. This needs to be in the calendar system used by the data.
     - returns: The integer range (1-based) of the months available in this year.
     */
    func monthRange(for inYear: Int) -> Range<Int> {
        // What we do here, is look for the range of months, that are available in the
        let lowerBound = reduce(13) { current, next in (next.year == inYear) && current > next.month ? next.month : current }
        let upperBound = reduce(0) { current, next in (next.year == inYear) && current < next.month ? next.month : current }
        
        return upperBound < lowerBound ? 0..<0 : lowerBound..<(upperBound + 1)
    }
    
    /* ################################################################## */
    /**
     This returns the range of months, in the given year. IT allows the user to specify a calendar to use for this.
     - parameter year: The year, as an integer. This needs to be in the calendar system described by the calendar passed in (or current).
     - parameter month: The month of the year, as an integer. This needs to be in the calendar system described by the calendar passed in (or current).
     - parameter calendar: This is the calendar to use, for determining the month range.
                           The year needs to be in this calendar system.
                           It is optional. If not specified, the current calendar is used.
     */
    func dayRange(year inYear: Int,
                  month inMonth: Int,
                  calendar inCalendar: Calendar? = Calendar.current) -> Range<Int> {
        guard let calendar = inCalendar,
              let calcDate = calendar.date(from: DateComponents(year: inYear, month: inMonth)),
              let dayRange = calendar.range(of: .day, in: .month, for: calcDate),
              !dayRange.isEmpty
        else { return 0..<0 }
    
        return dayRange
    }
    
    /* ################################################################## */
    /**
     This returns a filtered array of the data, depending on the criteria provided. If no criteria are provided, the the entire array is returned. All responses are sorted from earliest date, to the latest date.
     - parameter forThisYear: The year, as an integer. If not specified, then all years are returned.
     - parameter forThisMonth: The month of the year, as an integer. If not specified, then all months are returned.
     - parameter forThisDayOfTheMonth: The day of the month of the year, as an integer. If not specified, then all days of the month are returned.
     - parameter enabled: If true, then only items that are enabled will be returned. If false, the only items that are not enabled will be returned. Default is nil (all items returned, ignoring enabled status).
     - parameter selected: If true, then only items that are selected will be returned. If false, the only items that are not selected will be returned. Default is nil (all items returned, ignoring selected status).
     */
    func allResults(forThisYear inYear: Int = 0,
                    forThisMonth inMonth: Int = 0,
                    forThisDayOfTheMonth inDay: Int = 0,
                    enabled inIsEnabled: Bool? = nil,
                    selected inIsSelected: Bool? = nil) -> [Element] {
        filter {
                    (0 == inYear || inYear == $0.year)
                &&  (0 == inMonth || inMonth == $0.month)
                &&  (0 == inDay || inDay == $0.day)
                &&  (nil == inIsEnabled || inIsEnabled == $0.isEnabled)
                &&  (nil == inIsSelected || inIsSelected == $0.isSelected)
        }.sorted()
    }
}

/* ###################################################################################################################################### */
// MARK: - Main Class
// MARK: Special Calendar Input Class -
/* ###################################################################################################################################### */
/**
 */
@IBDesignable
open class RVS_CalendarInput: UIView {
    /* ################################################################################################################################## */
    // MARK: Individual Day Button
    /* ################################################################################################################################## */
    /**
     Each day is represented by a button. This allows us to associate a DateItem with the button, and customize its display
     */
    private class _DayButton: UIButton {
        /* ############################################################## */
        /**
         */
        var dateItem: DateItem?
        
        /* ############################################################## */
        /**
         */
        weak var myHandler: RVS_CalendarInput?
    }
    
    /* ################################################################################################################################## */
    // MARK: Data Item Class
    /* ################################################################################################################################## */
    /**
     This is one element of the data that is provided to, and read from, the view.
     
     This is a class, as opposed to a struct, because I rely on reference semantics to set and get state.
     */
    public class DateItem: Comparable {
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
         Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public var refCon: Any?
        
        // MARK: Computed Properties
        /* ############################################################## */
        /**
         This returns the instance as a standard Foundation DateComponents instance. The calendar used, will be the current one.
         */
        public var dateComponents: DateComponents { DateComponents(calendar: Calendar.current, year: year, month: month, day: day) }
        
        /* ############################################################## */
        /**
         This returns the instance as a standard Foundation Date. It may be nil. The calendar used, will be the current one.
         */
        public var date: Date? { dateComponents.date }
        
        // MARK: Initializers
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

        /* ############################################################## */
        /**
         DateComponents Initializer (can return nil)
         
         - parameter dateComponents: The day/month/year, as DateComponents. The calendar used, will be the current one. REQUIRED
         - parameter isEnabled: True, if the item is enabled for selection. Default is false. OPTIONAL
         - parameter isSelected: True, if the item is currently selected. Default is false. OPTIONAL
         - parameter refCon: Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public convenience init?(dateComponents inDateComponents: DateComponents,
                                 isEnabled inIsEnabled: Bool = false,
                                 isSelected inIsSelected: Bool = false,
                                 calendar inCalendar: Calendar? = nil,
                                 refCon inRefCon: Any? = nil
        ) {
            guard let inDay = inDateComponents.day,
                  let inMonth = inDateComponents.month,
                  let inYear = inDateComponents.year
            else { return nil }
            
            self.init(day: inDay, month: inMonth, year: inYear, isEnabled: inIsEnabled, isSelected: inIsSelected, refCon: inRefCon)
        }

        /* ############################################################## */
        /**
         Date Initializer (can return nil)
         
         - parameter date: The day/month/year, as a Date instance. The calendar used, will be the current one. REQUIRED
         - parameter isEnabled: True, if the item is enabled for selection. Default is false. OPTIONAL
         - parameter isSelected: True, if the item is currently selected. Default is false. OPTIONAL
         - parameter refCon: Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        public convenience init?(date inDate: Date,
                                 isEnabled inIsEnabled: Bool = false,
                                 isSelected inIsSelected: Bool = false,
                                 calendar inCalendar: Calendar? = nil,
                                 refCon inRefCon: Any? = nil
        ) {
            let tempCalendar = inCalendar ?? Calendar.current
            let tempComponents = tempCalendar.dateComponents([.day, .month, .year], from: inDate)
            guard let inDay = tempComponents.day,
                  let inMonth = tempComponents.month,
                  let inYear = tempComponents.year
            else { return nil }
            
            self.init(day: inDay, month: inMonth, year: inYear, isEnabled: inIsEnabled, isSelected: inIsSelected, refCon: inRefCon)
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
     This is a scroll view that wraps the grid. It is created dynamically.
     */
    private var _scrollView: UIScrollView?
    
    /* ################################################################## */
    /**
     This contains the "wrapper" view for the grid.
     */
    private var _containerView: UIView?

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
                setNeedsLayout()
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
     */
    private func _addMonth(_ inMonth: Int, year inYear: Int, to inContainer: UIView, topAnchor inTopAnchor: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
        guard (1..<13).contains(inMonth) else { return inTopAnchor }
        
        let monthView = UIView()
        inContainer.addSubview(monthView)
        monthView.translatesAutoresizingMaskIntoConstraints = false
        monthView.topAnchor.constraint(equalTo: inTopAnchor).isActive = true
        monthView.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor).isActive = true
        monthView.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor).isActive = true
        
        let monthHeader = UILabel()
        
        let font = UIFont.boldSystemFont(ofSize: 14)
        let text = String(calendar.shortMonthSymbols[inMonth - 1])
        let calcString = NSAttributedString(string: text, attributes: [.font: font])
        let cropRect = calcString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), context: nil)
        monthHeader.font = font
        monthHeader.text = text
        monthHeader.textAlignment = .center
        
        monthView.addSubview(monthHeader)
        monthHeader.translatesAutoresizingMaskIntoConstraints = false
        monthHeader.topAnchor.constraint(equalTo: monthView.topAnchor).isActive = true
        monthHeader.leadingAnchor.constraint(equalTo: monthView.leadingAnchor).isActive = true
        monthHeader.trailingAnchor.constraint(equalTo: monthView.trailingAnchor).isActive = true
        monthHeader.heightAnchor.constraint(equalToConstant: ceil(cropRect.size.height)).isActive = true
        monthHeader.bottomAnchor.constraint(equalTo: monthView.bottomAnchor).isActive = true

        return monthView.bottomAnchor
    }
    
    /* ################################################################## */
    /**
     This adds a year container, with a header that displays the given year.
     
     - parameter inYear: The year, as an Int. If the Int is 0 (or less), the year header will not be displayed.
     */
    private func _addYear(_ inYear: Int, topAnchor inTopAnchor: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
        var bottomAnchor = inTopAnchor
        
        if let containerView = _containerView,
           0 < inYear {
            let yearView = UIView()
            containerView.addSubview(yearView)
            yearView.translatesAutoresizingMaskIntoConstraints = false
            yearView.topAnchor.constraint(equalTo: inTopAnchor).isActive = true
            yearView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            yearView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            
            let yearHeader = UILabel()
            
            let font = UIFont.boldSystemFont(ofSize: 20)
            let text = String(inYear)
            let calcString = NSAttributedString(string: text, attributes: [.font: font])
            let cropRect = calcString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), context: nil)
            yearHeader.font = font
            yearHeader.text = text
            yearHeader.textAlignment = .center
            
            yearView.addSubview(yearHeader)
            yearHeader.translatesAutoresizingMaskIntoConstraints = false
            yearHeader.topAnchor.constraint(equalTo: yearView.topAnchor).isActive = true
            yearHeader.leadingAnchor.constraint(equalTo: yearView.leadingAnchor).isActive = true
            yearHeader.trailingAnchor.constraint(equalTo: yearView.trailingAnchor).isActive = true
            yearHeader.heightAnchor.constraint(equalToConstant: ceil(cropRect.size.height)).isActive = true
            
            var monthBottom = yearHeader.bottomAnchor
            
            let months = data.monthRange(for: inYear)
            
            // The months, and days
            months.forEach {
                monthBottom = _addMonth($0, year: inYear, to: yearView, topAnchor: monthBottom)
            }

            bottomAnchor = yearView.bottomAnchor

            monthBottom.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        return bottomAnchor
    }
    
    /* ################################################################## */
    /**
     */
    private func _setUpGrid() {
        _scrollView?.removeFromSuperview() // Clean the surface with an alcohol swab, before beginning...
        _containerView = nil
        
        // Set up the main scroller
        let scrollView = UIScrollView()
        _scrollView = scrollView
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Set up the scolled container
        let containerView = UIView()
        _containerView = containerView
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        var bottomAnchor = containerView.topAnchor
        
        let years = data.yearRange
        
        // The years, months, and days
        years.forEach {
            bottomAnchor = _addYear($0, topAnchor: bottomAnchor)
        }
        
        bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
    }
    
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

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     Called when we will lay out our view hierarchy.
     */
    open override func layoutSubviews() {
        super.layoutSubviews()
        _setUpGrid()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     */
    private func _buttonHit(_ inButton: _DayButton) {
    }
}
#endif
