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
 
 Version 1.2.3
 */

import UIKit

#if os(iOS) // This prevents the IB errors from showing up, under SPM (From SO Answer: https://stackoverflow.com/a/66334661/879365).
/* ###################################################################################################################################### */
// MARK: - Private UIView Extension -
/* ###################################################################################################################################### */
/**
 Add a corner radius
 */
private extension UIView {
    /* ################################################################## */
    /**
     This gives us access to the corner radius, so we can give the view rounded corners.
     
    ***NOTE:** This requires that `clipsToBounds` be set, which will be done, if the value is greater than zero.*
     */
    var _cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = 0 < newValue ? true : clipsToBounds
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Private UIColor Extension -
/* ###################################################################################################################################### */
/**
 Allow inversion
 */
private extension UIColor {
    /* ################################################################## */
    /**
     Returns a "blunt instrument" inversion of the color. It may not always be what we want.
     This always returns a new instance (copy).
     */
    var _inverse: UIColor {
        var ret: UIColor?
        var alpha = CGFloat(1)
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            ret = UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        } else {
            var hue = CGFloat(0)
            var saturation = CGFloat(0)
            var brightness = CGFloat(0)
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                ret = UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
            } else {
                var white = CGFloat(0)
                if getWhite(&white, alpha: &alpha) {
                    ret = UIColor(white: 1.0 - white, alpha: alpha)
                }
            }
        }

        return ret ?? UIColor(cgColor: cgColor)
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Calendar Input Class -
/* ###################################################################################################################################### */
/**
 This is a customized [UIView](https://developer.apple.com/documentation/uikit/uiview) implementation, that will display a basic month/grid calendar, with active buttons, on selected dates.
 The idea is to present a simple, intuitive interface, much like the classic "booking" interfaces, presented by Web sites.
 
 The control does not derive from [UIControl](https://developer.apple.com/documentation/uikit/uicontrol), as the event targeting system would not be useful for the types of interactions
 that can occur with this control. Instead, the implementor should register as a delegate (`RVS_CalendarInputDelegate`), and receive messages, when the control is used.
 The implementor can always examine the `data` array, and detrmine the control state. That array is updated in realtime.
 */
@IBDesignable
open class RVS_CalendarInput: UIView {
    /* ################################################################################################################################## */
    // MARK: Private Individual Day Button Class
    /* ################################################################################################################################## */
    /**
     Each day is represented by a button. This allows us to associate a DateItem with the button, and customize its display
     */
    private class _DayButton: UIButton {
        /* ############################################################## */
        /**
         The date item associated with this instance. Remember that we are using reference emantics for the date items.
         */
        var dateItem: _DateItem? { didSet { DispatchQueue.main.async { [weak self] in self?.setNeedsLayout() } } }
        
        /* ############################################################## */
        /**
         The control that "owns" these buttons.
         */
        weak var myHandler: RVS_CalendarInput?
        
        /* ############################################################## */
        /**
         Called when the views are being laid out.
         */
        override func layoutSubviews() {
            _cornerRadius = RVS_CalendarInput._dayCornerRadiusInDisplayUnits
            titleLabel?.font = myHandler?.weekdayFont
            titleLabel?.textAlignment = .center
            setTitle(String(dateItem?.day ?? 0), for: .normal)

            if dateItem?.isEnabled ?? false {
                isEnabled = true
                backgroundColor = (dateItem?.isSelected ?? false) ? myHandler?.tintColor : myHandler?.enabledItemBackgroundColor
                setTitleColor((dateItem?.isSelected ?? false) ? myHandler?.enabledItemBackgroundColor : myHandler?.tintColor, for: .normal)
                addTarget(myHandler, action: #selector(_buttonHit(_:)), for: .primaryActionTriggered)
                alpha = 1.0
            } else {
                isEnabled = false
                backgroundColor = (dateItem?.isSelected ?? false) ? .systemBackground._inverse : .systemBackground
                setTitleColor((dateItem?.isSelected ?? false) ? .label._inverse : .label, for: .disabled)
                removeTarget(myHandler, action: #selector(_buttonHit(_:)), for: .primaryActionTriggered)
                alpha = myHandler?.disabledAlpha ?? RVS_CalendarInput._defaultDisabledAlpha
            }

            super.layoutSubviews()
        }
    }

    /* ################################################################################################################################## */
    // MARK: Private Date Item Class (One element of the `data` array)
    /* ################################################################################################################################## */
    /**
     This is one element of the data that is provided to, and read from, the view.
     
     This is a class, as opposed to a struct, because we rely on reference semantics to set and get state.
     */
    private class _DateItem: RVS_CalendarInput_DateItemProtocol {
        // MARK: Required Stored Properties
        /* ############################################################## */
        /**
         The year, as an integer. REQUIRED
         */
        var year: Int
        
        /* ############################################################## */
        /**
         The month, as an integer (1 -> 12). REQUIRED
         */
        var month: Int
        
        /* ############################################################## */
        /**
         The day of the month (1 -> [28|29|30|31]), as an integer. REQUIRED
         */
        var day: Int
        
        // MARK: Optional Stored Properties
        /* ############################################################## */
        /**
         True, if the item is enabled for selection. Default is false. OPTIONAL
         */
        var isEnabled: Bool
        
        /* ############################################################## */
        /**
         True, if the item is currently selected. Default is false. OPTIONAL
         */
        var isSelected: Bool

        /* ############################################################## */
        /**
         Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        var refCon: Any?
        
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
        init(day inDay: Int,
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

        // MARK: Convenience Initializers
        /* ############################################################## */
        /**
         DateComponents Initializer (can return nil)
         
         - parameter dateComponents: The day/month/year, as DateComponents. The calendar used, will be the current one. REQUIRED
         - parameter isEnabled: True, if the item is enabled for selection. Default is false. OPTIONAL
         - parameter isSelected: True, if the item is currently selected. Default is false. OPTIONAL
         - parameter refCon: Reference context. This is how we attach arbitrary data to the item. OPTIONAL
         */
        convenience init?(dateComponents inDateComponents: DateComponents,
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
        convenience init?(date inDate: Date,
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
    }

    // MARK: Private Static Constants
    /* ################################################################## */
    /**
     This is the "padding" around each day button.
     */
    private static let _buttonPaddingInDisplayUnits = CGFloat(2)

    /* ################################################################## */
    /**
     This is the corner radius of each day button.
     */
    private static let _dayCornerRadiusInDisplayUnits = CGFloat(8)

    /* ################################################################## */
    /**
     This is the default opacity for the disabled days.
     */
    private static let _defaultDisabledAlpha = CGFloat(0.4)

    // MARK: Private Instance Properties
    /* ################################################################## */
    /**
     This contains the data that defines the state of this control. This will have *every* day shown by the control; not just the ones passed in.
     */
    private var _data: [_DateItem] = [] { didSet { _resetControl() } }

    // MARK: Public State Properties That Cannot Be Changed At Runtime
    /* ################################################################## */
    /**
     This contains the data that defines the state of this control. This will have *every* day shown by the control; not just the ones passed in. READ-ONLY
     */
    public var data: [RVS_CalendarInput_DateItemProtocol] { _data }

    // MARK: Public State Properties That Can Be Changed At Runtime
    /* ################################################################## */
    /**
     The height, in display units, of the weekday header.
     We "hardcode" this, because dynamically calculating it is crazy slow.
     */
    public var weekdayHeaderHeightInDisplayUnits = CGFloat(30) { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The height, in display units, of the year header.
     We "hardcode" this, because dynamically calculating it is crazy slow.
     */
    public var yearHeaderHeightInDisplayUnits = CGFloat(25) { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The height, in display units, of the month header.
     We "hardcode" this, because dynamically calculating it is crazy slow.
     */
    public var monthHeaderHeightInDisplayUnits = CGFloat(20) { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     This contains the calendar used for the control. It defaults to the current calendar, but can be changed.
     */
    public var calendar: Calendar = Calendar.current { didSet { _resetControl() } }
    
    /* ################################################################## */
    /**
     The font to be used for the weekday header, at the top.
     */
    public var weekdayHeaderFont = UIFont.boldSystemFont(ofSize: 18) { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The font to be used for the year header.
     */
    public var yearHeaderFont = UIFont.boldSystemFont(ofSize: 20) { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The font to be used for the month header.
     */
    public var monthHeaderFont = UIFont.boldSystemFont(ofSize: 18) { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The font to be used for each of the days.
     */
    public var weekdayFont = UIFont.boldSystemFont(ofSize: 24) { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     This is the color for the background of unselected and enabled days.
     The [`UIView.tintColor`](https://developer.apple.com/documentation/uikit/uiview/1622467-tintcolor) property is used to set the font color for the enabled days (and becomes the background, when the day is selected).
     If the day is selected, this becomes the font color.
     */
    public var enabledItemBackgroundColor = UIColor.white { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The font to be used for the weekday header, at the top.
     */
    public var weekdayHeaderFontColor = UIColor.label { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The font color to be used for the year header.
     */
    public var yearHeaderFontColor = UIColor.white { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The font color to be used for the month header.
     */
    public var monthHeaderFontColor = UIColor.white { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The background color to be used for the year header.
     */
    public var yearHeaderBackgroundColor = UIColor.systemGray { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The background color to be used for the month header.
     */
    public var monthHeaderBackgroundColor = UIColor.systemGray2 { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     The opacity of disabled date buttons.
     */
    public var disabledAlpha = RVS_CalendarInput._defaultDisabledAlpha { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     If this is false (default is true), then the month headers will not be shown.
     */
    @IBInspectable public var showMonthHeaders: Bool = true { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     If this is false (default is true), then the year headers will not be shown.
     */
    @IBInspectable public var showYearHeaders: Bool = true { didSet { _resetControl() } }

    /* ################################################################## */
    /**
     If this is false (default is true), then the weekday header will not be shown.
     */
    @IBInspectable public var showWeekdayHeader: Bool = true { didSet { _resetControl() } }

    // MARK: Delegate
    /* ################################################################## */
    /**
     This is the delegate that is used to receive notifications of date items changing. The delegate needs to be a class, and this is a weak reference.
     This is not IB-accessible, because we don't want to require delegates to conform to [`NSObjectProtocol`](https://developer.apple.com/documentation/objectivec/nsobjectprotocol)
     */
    public weak var delegate: RVS_CalendarInputDelegate?

    // MARK: Scroll View
    /* ################################################################## */
    /**
     The scroller that will contain the view.
     */
    public weak var scrollView: UIScrollView?
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     This is called to completely reset the control from scratch.
     */
    private func _resetControl() {
        DispatchQueue.main.async { [weak self] in
            self?.scrollView?.removeFromSuperview()
            self?.scrollView = nil
            self?.setNeedsLayout()
        }
    }
    
    /* ################################################################## */
    /**
     This creates a single day button.
 
     - parameter inDay: The date item associated with this button.
     - parameter in: The container for this button.
     */
    private func _makeMyDay(_ inDay: _DateItem, in inContainer: UIView) {
        let dayButton = _DayButton()
        inContainer.addSubview(dayButton)
        dayButton.dateItem = inDay
        dayButton.myHandler = self
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        dayButton.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor, constant: Self._buttonPaddingInDisplayUnits).isActive = true
        dayButton.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor, constant: -Self._buttonPaddingInDisplayUnits).isActive = true
        dayButton.topAnchor.constraint(equalTo: inContainer.topAnchor, constant: Self._buttonPaddingInDisplayUnits).isActive = true
        dayButton.bottomAnchor.constraint(equalTo: inContainer.bottomAnchor, constant: -Self._buttonPaddingInDisplayUnits).isActive = true
    }
    
    /* ################################################################## */
    /**
     This creates a week of buttons, accounting for offset days (month start), as well as weeks that begin on different days.
     It has a week container (strip), then seven square day containers, which are filled with buttons.
 
     - parameter inAllDays: This is an array of DateItem, containing all the days for the month (usually). It does not need to be just the month, but it should have at least one date in this week.
     - parameter index: The current index into the date item array.
     - parameter in: The container for this week.
     - parameter topAnchor: This is the item immediately above this week, and the week will be attached to it.
     - returns: A tuple, containing the new index (incremented past the items needed for this week), and the new top anchor (which is the bottom of the week conrtainer).
     */
    private func _populateWeek(_ inAllDays: [_DateItem],
                               index inCurrentIndex: Int,
                               in inContainer: UIView,
                               topAnchor inTopAnchor: NSLayoutYAxisAnchor) -> (topAnchor: NSLayoutYAxisAnchor, endIndex: Int) {
        var index = inCurrentIndex
        
        let weekContainerView = UIView()
        inContainer.addSubview(weekContainerView)
        weekContainerView.backgroundColor = .clear
        weekContainerView.translatesAutoresizingMaskIntoConstraints = false
        weekContainerView.topAnchor.constraint(equalTo: inTopAnchor).isActive = true
        weekContainerView.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor).isActive = true
        weekContainerView.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor).isActive = true

        let startingWeekday = calendar.firstWeekday - 1
        
        if let firstDay = inAllDays[index].date,
           let firstDataWeekday = calendar.dateComponents([.weekday], from: firstDay).weekday {
            let offsetWeekday = (firstDataWeekday - 1) - startingWeekday
            let startingWeekdayIndex = 0 > offsetWeekday ? offsetWeekday + 7 : offsetWeekday

            var leadingAnchor = weekContainerView.leadingAnchor
            var measurement: NSLayoutDimension?
            for weekday in (0..<7) {
                let dayContainerView = UIView()
                weekContainerView.addSubview(dayContainerView)
                dayContainerView.backgroundColor = .clear
                dayContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                dayContainerView.translatesAutoresizingMaskIntoConstraints = false
                dayContainerView.topAnchor.constraint(equalTo: weekContainerView.topAnchor).isActive = true
                dayContainerView.bottomAnchor.constraint(equalTo: weekContainerView.bottomAnchor).isActive = true
                measurement?.constraint(equalTo: dayContainerView.widthAnchor).isActive = true
                dayContainerView.heightAnchor.constraint(equalTo: dayContainerView.widthAnchor).isActive = true
                if weekday >= startingWeekdayIndex,
                   index < inAllDays.count {
                    dayContainerView.backgroundColor = .clear
                    _makeMyDay(inAllDays[index], in: dayContainerView)
                    index += 1
                }
                measurement = dayContainerView.widthAnchor
                leadingAnchor = dayContainerView.trailingAnchor
            }
            
            leadingAnchor.constraint(equalTo: weekContainerView.trailingAnchor).isActive = true
        }

        return (topAnchor: weekContainerView.bottomAnchor, endIndex: index)
    }
    
    /* ################################################################## */
    /**
     This populates the actual weeks inside the month, under the header.
 
     - parameter inMonth: The numerical value of the month, in the calendar used for the data.
     - parameter inYear: The numerical year, in the calendar used for the data.
     - parameter in: The container for this month.
     - parameter topAnchor: This is the item immediately above this month of weeks (the header).
     */
    private func _populateMonth(_ inMonth: Int,
                                year inYear: Int,
                                in inContainer: UIView,
                                topAnchor inTopAnchor: NSLayoutYAxisAnchor) {
        let dataForThisMonth = _data.allResults(forThisYear: inYear, forThisMonth: inMonth)
        
        if !dataForThisMonth.isEmpty {
            let monthWeekContainerView = UIView()
            inContainer.addSubview(monthWeekContainerView)
            monthWeekContainerView.backgroundColor = .clear
            monthWeekContainerView.translatesAutoresizingMaskIntoConstraints = false
            monthWeekContainerView.topAnchor.constraint(equalTo: inTopAnchor).isActive = true
            monthWeekContainerView.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor).isActive = true
            monthWeekContainerView.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor).isActive = true
            monthWeekContainerView.bottomAnchor.constraint(equalTo: inContainer.bottomAnchor).isActive = true
            
            var topAnchor = monthWeekContainerView.topAnchor
            var index = 0
            while index < dataForThisMonth.count {
                (topAnchor, index) = _populateWeek(dataForThisMonth, index: index, in: monthWeekContainerView, topAnchor: topAnchor)
            }
            
            topAnchor.constraint(equalTo: monthWeekContainerView.bottomAnchor).isActive = true
        }
    }
    
    /* ################################################################## */
    /**
     This adds and populates a month of days, under the previous month (or the top of the container).
 
     - parameter inMonth: The numerical value of the month, in the calendar used for the data.
     - parameter inYear: The numerical year, in the calendar used for the data.
     - parameter to: The container for this month.
     - parameter topAnchor: This is the item immediately above this month, and the month will be attached to it.
     - returns: The Y-axis anchor to be used as the top of the next month/year, or attached to the bottom of the control.
     */
    private func _addMonth(_ inMonth: Int,
                           year inYear: Int,
                           to inContainer: UIView,
                           topAnchor inTopAnchor: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
        guard (1..<13).contains(inMonth) else { return inTopAnchor }
        
        let monthView = UIView()
        inContainer.addSubview(monthView)
        monthView.translatesAutoresizingMaskIntoConstraints = false
        monthView.topAnchor.constraint(equalTo: inTopAnchor, constant: 8).isActive = true
        monthView.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor).isActive = true
        monthView.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor).isActive = true
        
        var monthBottom = monthView.topAnchor
        if showMonthHeaders {
            let monthHeader = UILabel()
            
            let text = String(calendar.monthSymbols[inMonth - 1])

            monthHeader.font = monthHeaderFont
            monthHeader.text = text
            monthHeader.textColor = monthHeaderFontColor
            monthHeader.textAlignment = .center
            monthHeader.backgroundColor = monthHeaderBackgroundColor
            monthHeader._cornerRadius = monthHeaderHeightInDisplayUnits / 2

            monthView.addSubview(monthHeader)
            monthHeader.translatesAutoresizingMaskIntoConstraints = false
            monthHeader.topAnchor.constraint(equalTo: monthView.topAnchor).isActive = true
            monthHeader.leadingAnchor.constraint(equalTo: monthView.leadingAnchor, constant: 20).isActive = true
            monthHeader.trailingAnchor.constraint(equalTo: monthView.trailingAnchor, constant: -20).isActive = true
            monthHeader.heightAnchor.constraint(equalToConstant: monthHeaderHeightInDisplayUnits).isActive = true

            monthBottom = monthHeader.bottomAnchor
        }
        
        _populateMonth(inMonth, year: inYear, in: monthView, topAnchor: monthBottom)
        
        return monthView.bottomAnchor
    }
    
    /* ################################################################## */
    /**
     This adds a year container, with a header that displays the given year.
     
     - parameter inYear: The year, as an Int. If the Int is 0 (or less), the year header will not be displayed.
     - parameter in: The container for this year.
     - parameter topAnchor: This is the item immediately above this year of months (the header).
     - returns: The Y-axis anchor to be used as the top of the next year, or attached to the bottom of the control.
     */
    private func _addYear(_ inYear: Int,
                          in inContainer: UIView,
                          topAnchor inTopAnchor: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
        var bottomAnchor = inTopAnchor
        
        let yearView = UIView()
        inContainer.addSubview(yearView)
        yearView.translatesAutoresizingMaskIntoConstraints = false
        yearView.topAnchor.constraint(equalTo: inTopAnchor, constant: 8).isActive = true
        yearView.leadingAnchor.constraint(equalTo: inContainer.leadingAnchor).isActive = true
        yearView.trailingAnchor.constraint(equalTo: inContainer.trailingAnchor).isActive = true
        
        var monthBottom = yearView.topAnchor

        if showYearHeaders {
            let yearHeader = UILabel()
            
            yearHeader.font = yearHeaderFont
            yearHeader.text = String(inYear)
            yearHeader.textAlignment = .center
            yearHeader.textColor = yearHeaderFontColor
            yearHeader.backgroundColor = yearHeaderBackgroundColor
            yearHeader._cornerRadius = yearHeaderHeightInDisplayUnits / 4
            
            yearView.addSubview(yearHeader)
            yearHeader.translatesAutoresizingMaskIntoConstraints = false
            yearHeader.topAnchor.constraint(equalTo: yearView.topAnchor).isActive = true
            yearHeader.leadingAnchor.constraint(equalTo: yearView.leadingAnchor).isActive = true
            yearHeader.trailingAnchor.constraint(equalTo: yearView.trailingAnchor).isActive = true
            yearHeader.heightAnchor.constraint(equalToConstant: yearHeaderHeightInDisplayUnits).isActive = true

            monthBottom = yearHeader.bottomAnchor
        }

        _data.monthRange(for: inYear).forEach { monthBottom = _addMonth($0, year: inYear, to: yearView, topAnchor: monthBottom) }

        bottomAnchor = yearView.bottomAnchor

        monthBottom.constraint(equalTo: bottomAnchor).isActive = true
        
        return bottomAnchor
    }
    
    /* ################################################################## */
    /**
     This sets up the entire control, creating the views necessary, and relating all the various anchors and constraints.
     */
    private func _setUpGrid() {
        if nil == scrollView,
           !_data.isEmpty {
            let scrollViewTemp = UIScrollView()
            addSubview(scrollViewTemp)
            scrollView = scrollViewTemp
            
            let weekdayHeight = showWeekdayHeader ? weekdayHeaderHeightInDisplayUnits : 0

            // Set up the main scroller
            scrollViewTemp.translatesAutoresizingMaskIntoConstraints = false
            scrollViewTemp.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            // Adding the weekday header height as an offset, allows us to keep the weekdays over the actual grid.
            scrollViewTemp.topAnchor.constraint(equalTo: topAnchor, constant: weekdayHeight).isActive = true
            scrollViewTemp.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            scrollViewTemp.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            // Set up the scolled container
            let containerView = UIView()
            scrollViewTemp.addSubview(containerView)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.leadingAnchor.constraint(equalTo: scrollViewTemp.contentLayoutGuide.leadingAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: scrollViewTemp.contentLayoutGuide.topAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: scrollViewTemp.contentLayoutGuide.trailingAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: scrollViewTemp.contentLayoutGuide.bottomAnchor).isActive = true
            containerView.widthAnchor.constraint(equalTo: scrollViewTemp.widthAnchor).isActive = true

            var bottomAnchor = containerView.topAnchor
            
            // The years, months, and days
            _data.yearRange.forEach { bottomAnchor = _addYear($0, in: containerView, topAnchor: bottomAnchor) }
            
            bottomAnchor.constraint(equalTo: scrollViewTemp.contentLayoutGuide.bottomAnchor).isActive = true
            
            // This displays a fixed header, containing the weekday column headers, over the grid.
            if showWeekdayHeader {
                let weekdayLabelHeader = UIView()
                addSubview(weekdayLabelHeader)
                weekdayLabelHeader.translatesAutoresizingMaskIntoConstraints = false
                weekdayLabelHeader.topAnchor.constraint(equalTo: topAnchor).isActive = true
                weekdayLabelHeader.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                weekdayLabelHeader.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                weekdayLabelHeader.heightAnchor.constraint(equalToConstant: weekdayHeight).isActive = true

                let startingWeekday = calendar.firstWeekday
                // Start everything at the beginning of the container.
                var leadingAnchor = weekdayLabelHeader.leadingAnchor
                var indexAnchor: NSLayoutDimension? // This will contain the width constraint of the *previous* day (starting with nothing).
                // We make all the day widths equal, and attach each end to the sides of the container. Each day is attached to the next/previous one.
                for weekday in startingWeekday..<(startingWeekday + 7) {
                    let weekDayIndex = weekday < 8 ? weekday - 1 : weekday - 8
                    let thisWeekdayHeader = UILabel()
                    let text = String(calendar.shortWeekdaySymbols[weekDayIndex])
                    thisWeekdayHeader.adjustsFontSizeToFitWidth = true  // Will probably never be necessary, but belt and suspenders...
                    thisWeekdayHeader.minimumScaleFactor = 0.5
                    thisWeekdayHeader.text = text
                    thisWeekdayHeader.font = weekdayHeaderFont
                    thisWeekdayHeader.textColor = weekdayHeaderFontColor
                    thisWeekdayHeader.textAlignment = .center
                    weekdayLabelHeader.addSubview(thisWeekdayHeader)
                    thisWeekdayHeader.translatesAutoresizingMaskIntoConstraints = false
                    thisWeekdayHeader.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                    // This makes the day width the same as the previous one. If no previous, then nothing happens.
                    indexAnchor?.constraint(equalTo: thisWeekdayHeader.widthAnchor).isActive = true
                    thisWeekdayHeader.topAnchor.constraint(equalTo: weekdayLabelHeader.topAnchor).isActive = true
                    thisWeekdayHeader.bottomAnchor.constraint(equalTo: weekdayLabelHeader.bottomAnchor).isActive = true
                    // The next one will attach to the trailing of this one.
                    leadingAnchor = thisWeekdayHeader.trailingAnchor
                    // The next width will be equal to us.
                    indexAnchor = thisWeekdayHeader.widthAnchor
                }
            
                // tie off the loose end to the trailing of the container.
            leadingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            }
        }
    }
    
    /* ################################################################## */
    /**
     This will clear and repopulate the data Array, based on the "seed" data, passed in.
     It should be noted that this *clears* the current data array, and does not preserve its previous state, so it is incumbent upon the user to "snapshot" the data, if so desired.
     This copies data. Even though it is stored internally, as a reference type, when it is submitted here, we copy it into our internal data.
 
     - parameter from: This is an array of "seed" data.
     */
    private func _determineDataSetup(from inSeedData: [RVS_CalendarInput_DateItemProtocol]) {
        _data = []
        
        let localSeedDataCopy = inSeedData.sorted { $0.dateSortKey < $1.dateSortKey }
        
        // From the given data, we determine the earliest date, and the latest date.
        let startDate = localSeedDataCopy.reduce(Date.distantFuture) { current, next in
            guard let nextDate = next.date,
                  current > nextDate
            else { return current }
            
            return nextDate
        }
        
        let endDate = localSeedDataCopy.reduce(Date.distantPast) { current, next in
            guard let nextDate = next.date,
                  current < nextDate
            else { return current }
            
            return nextDate
        }
        
        guard endDate >= startDate else { return }
        
        // What we do here, is strip out the days. We are only interested in the month and year of each end. This also translates the data into our view's calendar.
        let startComponents = calendar.dateComponents([.year, .month], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month], from: endDate)
        
        // We get the range, in years and months.
        guard let startYear = startComponents.year,
              var startMonth = startComponents.month,
              let endYear = endComponents.year,
              let endMonth = endComponents.month
        else { return }
        
        // Now, a fairly simple nested loop is used to poulate our data.
        for year in startYear...endYear {
            for month in startMonth...12 where year < endYear || month <= endMonth {
                if let calcDate = calendar.date(from: DateComponents(year: year, month: month)),
                   let numberOfDaysInThisMonth = calendar.range(of: .day, in: .month, for: calcDate)?.count {
                    for day in 1...numberOfDaysInThisMonth {
                        let dateItemForThisDay = _DateItem(day: day, month: month, year: year)
                        if let dateItemForThisDayTemp = localSeedDataCopy.first(where: { $0.day == day && $0.month == month && $0.year == year }) {
                            // Since we are copying, the date is already OK, so we duplicate the rest of the state.
                            dateItemForThisDay.isEnabled = dateItemForThisDayTemp.isEnabled
                            dateItemForThisDay.isSelected = dateItemForThisDayTemp.isSelected
                            dateItemForThisDay.refCon = dateItemForThisDayTemp.refCon
                        }
                        
                        _data.append(dateItemForThisDay)
                    }
                }
            }
            
            startMonth = 1
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Private Callbacks
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     This is called by buttons for days. It toggles the state of the day, and notifies the delegate.
 
     - parameter inButton: The button object that was hit.
     */
    @objc private func _buttonHit(_ inButton: _DayButton) {
        if let dateItem = inButton.dateItem,
           dateItem.isEnabled {
            dateItem.isSelected = !dateItem.isSelected
            delegate?.calendarInput(self, dateItemChanged: dateItem)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Public Computed Properties
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     This is basically a write-only way to set up the control. Read will always return an empty array.
     This contains the particular dates that you want to affect. The date range of the control will be determined from these data.
     Setting this value will re-initialize the control.
     This copies the data. It does not make references to it.
     */
    public var setupData: [RVS_CalendarInput_DateItemProtocol] {
        get { [] }
        set {
            if !newValue.isEmpty {
                DispatchQueue.main.async { [weak self] in
                    self?._determineDataSetup(from: newValue)
                    self?.setNeedsLayout()
                }
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Public Base Class Overrides
/* ###################################################################################################################################### */
public extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     Called when we will lay out our view hierarchy.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        _setUpGrid()
    }
}

/* ###################################################################################################################################### */
// MARK: Public Convenience Initializer
/* ###################################################################################################################################### */
extension RVS_CalendarInput {
    /* ################################################################## */
    /**
     This allows the instance to be instantiated with an initial frame and/or initial data and/or a delegate.
 
     - parameter frame: An initial frame. OPTIONAL
     - parameter setUpData: This is an array of initial date objects that will be used. OPTIONAL
     - parameter delegate: A delegate for this instance. OPTIONAL
     */
    public convenience init(frame inFrame: CGRect = .zero,
                            setUpData inSetupData: [RVS_CalendarInput_DateItemProtocol] = [],
                            delegate inDelegate: RVS_CalendarInputDelegate? = nil) {
        if inFrame.isEmpty {
            self.init()
        } else {
            self.init(frame: inFrame)
        }
        
        if !inSetupData.isEmpty {
            setupData = inSetupData
        }
        
        delegate = inDelegate
    }
}

/* ###################################################################################################################################### */
// MARK: - Date Item Protocol (One element of the `data` array) -
/* ###################################################################################################################################### */
/**
 This protocol defines the basic structure of one item of the stored data.
 All properties are required.
 */
public protocol RVS_CalendarInput_DateItemProtocol {
    /* ################################################################## */
    /**
     The year, as an integer.
     */
    var year: Int { get set }
    
    /* ################################################################## */
    /**
     The month, as an integer (1 -> 12).
     */
    var month: Int { get set }
    
    /* ################################################################## */
    /**
     The day of the month (1 -> [28|29|30|31]), as an integer.
     */
    var day: Int { get set }
    
    /* ################################################################## */
    /**
     True, if the item is enabled for selection.
     */
    var isEnabled: Bool { get set }
    
    /* ################################################################## */
    /**
     True, if the item is currently selected.
     */
    var isSelected: Bool { get set }

    /* ################################################################## */
    /**
     Reference context. This is how we attach arbitrary data to the item.
     */
    var refCon: Any? { get set }
    
    // MARK: Computed (Read-Only) Optional Properties
    /* ################################################################## */
    /**
     Return the date item state as a date. OPTIONAL
     */
    var date: Date? { get }
    
    /* ################################################################## */
    /**
     Return the date item state as date components. OPTIONAL
     */
    var dateComponents: DateComponents? { get }
    
    /* ################################################################## */
    /**
     This allows us to sort the data by the date.
     It returns a simple int, which is useful for sorting.
     */
    var dateSortKey: Int { get }
}

/* ###################################################################################################################################### */
// MARK: DDefaults
/* ###################################################################################################################################### */
extension RVS_CalendarInput_DateItemProtocol {
    /* ############################################################## */
    /**
     This returns the instance as a standard Foundation DateComponents instance. The calendar used, will be the current one.
     */
    public var dateComponents: DateComponents? { DateComponents(calendar: Calendar.current, year: year, month: month, day: day) }

    /* ############################################################## */
    /**
     This returns the instance as a standard Foundation Date. It may be nil. The calendar used, will be the current one.
     */
    public var date: Date? { dateComponents?.date }
    
    /* ################################################################## */
    /**
     The default returns a simple int, which is a sum of the various date components (YYYYMMDD).
     */
    public var dateSortKey: Int { (year * 10000) + (month * 100) + day }
}

/* ###################################################################################################################################### */
// MARK: - Special Calendar Input Class Delegate -
/* ###################################################################################################################################### */
/**
 This is used to send change notifications out.
 */
public protocol RVS_CalendarInputDelegate: AnyObject {
    /* ################################################################## */
    /**
     This is called when a data item changes (user selects the item).
 
     - parameter inCalendarInput: The calendar input instance
     - parameter dateItemChanged: The date item that changed selection state.
     */
    func calendarInput(_ inCalendarInput: RVS_CalendarInput, dateItemChanged inDateItem: RVS_CalendarInput_DateItemProtocol)
}

/* ###################################################################################################################################### */
// MARK: Defaults
/* ###################################################################################################################################### */
public extension RVS_CalendarInputDelegate {
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func calendarInput(_: RVS_CalendarInput, dateItemChanged: RVS_CalendarInput_DateItemProtocol) { }
}

/* ###################################################################################################################################### */
// MARK: - Special Public Array Extension Functions for Date Items (Equatable) -
/* ###################################################################################################################################### */
/**
 This extension allows you to filter an Array, and get some information about the contents.
 */
public extension Array where Element: RVS_CalendarInput_DateItemProtocol {
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
     This returns the range of months, in the given year. It allows the user to specify a calendar to use for this.
 
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
     This returns a filtered array of the data, depending on the criteria provided. The criteria are all optional.
     If no criteria are provided, the entire array is returned. All responses are sorted from earliest date, to the latest date.
 
     - parameter forThisYear: The year, as an integer. If not specified, then all years are returned.
     - parameter forThisMonth: The month of the year, as an integer. If not specified, then all months are returned.
     - parameter forThisDayOfTheMonth: The day of the month, as an integer. If not specified, then all days of the month are returned.
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
        }.sorted { a, b in
            guard let aDate = a.date,
                  let bDate = b.date else { return false }
            
            return aDate < bDate
        }
    }
}
#endif
