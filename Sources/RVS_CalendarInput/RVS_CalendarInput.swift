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
     
     > **NOTE:** This requires that `clipsToBounds` be set, which will be done, if the value is nonzero.
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
    
    /* ################################################################## */
    /**
     This allows us to add a subview, and set it up with auto-layout constraints to fill the superview.
     
     - parameter inSubview: The subview we want to add.
     - parameter underThis: If supplied, this is a Y-axis anchor to use as the attachment of the top anchor. Default is nil (can be omitted, which will simply attach to the top of the container).
     - parameter andGiveMeABottomHook: If this is true, then the bottom anchor of the subview will not be attached to anything, and will simply be returned.
                                       Default is false, which means that the bottom anchor will simply be attached to the bottom of the view.
     - returns: The bottom hook, if requested. Can be ignored.
     */
    @discardableResult
    func addContainedView(_ inSubView: UIView, underThis inUpperConstraint: NSLayoutYAxisAnchor? = nil, andGiveMeABottomHook inBottomLoose: Bool = false) -> NSLayoutYAxisAnchor? {
        addSubview(inSubView)
        
        inSubView.translatesAutoresizingMaskIntoConstraints = false
        if let underConstraint = inUpperConstraint {
            inSubView.topAnchor.constraint(equalTo: underConstraint, constant: 0).isActive = true
        } else {
            inSubView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        }
        inSubView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        inSubView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        
        if inBottomLoose {
            return inSubView.bottomAnchor
        } else {
            inSubView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - Sepecial Array Extension Functions for Date Items -
/* ###################################################################################################################################### */
public extension Array where Element: RVS_CalendarInput.DateItem {
    /* ################################################################## */
    /**
     */
    var yearRange: Range<Int> {
        let lowerBound = reduce(Int.max) { current, next in current > next.year ? next.year : current }
        let upperBound = reduce(Int.min) { current, next in current < next.year ? next.year : current }
        
        guard lowerBound <= upperBound else { return 0..<0 }
        
        return lowerBound..<(upperBound + 1)
    }
    
    /* ################################################################## */
    /**
     */
    func monthRange(for inYear: Int) -> Range<Int> {
        let lowerBound = reduce(13) { current, next in (next.year == inYear) && current > next.month ? next.month : current }
        let upperBound = reduce(0) { current, next in (next.year == inYear) && current < next.month ? next.month : current }
        
        guard 13 < lowerBound,
              0 > upperBound,
              lowerBound <= upperBound else { return 0..<0 }
        
        return lowerBound..<(upperBound + 1)
    }
    
    /* ################################################################## */
    /**
     */
    func dayRange(year inYear: Int, month inMonth: Int, calendar inCalendar: Calendar? = Calendar.current) -> Range<Int> {
        guard let calendar = inCalendar,
              let calcDate = calendar.date(from: DateComponents(year: inYear, month: inMonth)),
              let dayRange = calendar.range(of: .day, in: .month, for: calcDate),
              !dayRange.isEmpty
        else { return 0..<0 }
    
        return dayRange
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
        public init(day inDay: Int,
                    month inMonth: Int,
                    year inYear: Int,
                    isEnabled inIsEnabled: Bool = false,
                    isSelected inIsSelected: Bool = false,
                    calendar inCalendar: Calendar? = nil,
                    refCon inRefCon: Any? = nil
        ) {
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
     This adds a year container, with a header that displays the given year.
     
     - parameter inYear: The year, as an Int. If the Int is 0 (or less), the year header will not be displayed.
     */
    private func _addYear(_ inYear: Int) {
    }
    
    /* ################################################################## */
    /**
     */
    private func _setUpGrid() {
        _scrollView?.removeFromSuperview() // Clean the surface with an alcohol swab, before beginning...
        _containerView = nil
        let scrollView = UIScrollView()
        _scrollView = scrollView
        addContainedView(scrollView)
        let containerView = UIView()
        _containerView = containerView
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
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
#endif
