![Icon](img/icon.png)

# RVS_CalendarInput

---
**NOTE**

[Here is a link to the GitHub repo for this project.](https://github.com/RiftValleySoftware/RVS_CalendarInput/)

[Here is a link to the technical documentation for this project.](https://riftvalleysoftware.github.io/RVS_CalendarInput/)

---

## INTRODUCTION
RVS_CalendarInput is a customized [UIView](https://developer.apple.com/documentation/uikit/uiview) implementation, that will display a basic month/grid calendar, with active buttons, on selected dates.

The workflow may be familiar to people that have used Web-based "booking" systems. A date grid is presented, in calendar form, with certain dates highlighted as toggle buttons. The user can select these dates.
 
## WHAT PROBLEM DOES IT SOLVE?
Unlike some of the other open-source widgets that we've produced, this widget is being designed for a single application and workflow, so it will be less "general purpose" than other Great Rift Valley Software Company widgets.

In our application, we are adding a workflow, that allows the user of the app to declare that they will be attending events on certain dates. This widget is how they will do that.

## HOW DOES IT WORK?
The user is presented with a grid of possible dates, and certain dates are enabled. This is visually indicated by a combination of colors/contrasts, and transparency. The user can select or deselect enabled dates, and the view will contain a scroller, allowing the implementor to present a range of possible dates. When the user selects an enabled date, its state will toggle. The stored dataset will have that date modified, and the delegate will be informed of the change.

There are headers for wekdays, years and months. They can all be individually hidden. The weekdays header is "fixed." The scroller will scroll underneath it.

The widget is completely localized, respecting the user's calendar and week start. All weekdays and months are displayed in the localized form. It also adapts well to various layouts, and can have its headers and other items customized.

## REQUIREMENTS

This is a [Swift](https://apple.com/swift)-only module. It is based on [standard UIKit](https://developer.apple.com/documentation/uikit), for [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados).

There are no dependencies for the widget, or the test harness app.

## HOW DO WE USE IT?
The widget consists of just [one single source file](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift). That's all that is needed for your project. Everything else is testing and documentation. You can access this file in several ways.

### INSTALLATION

#### Where to Get the Package

You can get this package as a [Swift Package Manager](https://swift.org/package-manager/) (SPM) package, or you can include it, using [GitHub's Carthage Package Manager](https://github.com/Carthage/Carthage). Finally, you can also [directly access the GitHub repository](https://github.com/RiftValleySoftware/RVS_CalendarInput), and simply include [the single source file](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift) into your app.

##### The Swift Package Manager

In order to use the SPM, add the package to your project with its GitHub repo location:

    git@github.com:RiftValleySoftware/RVS_CalendarInput.git (SSH),

or

    https://github.com/RiftValleySoftware/RVS_CalendarInput.git (HTTPS).

Add the static `RVS_CalendarInput` library to your project, and add the following `import` line to the top of the files that will use the widget:

    import RVS_CalendarInput
    
##### Carthage

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

    github "RiftValleySoftware/RVS_CalendarInput.git"
    
Then, run `carthage update` in the main project directory.

This will create a directory, called "Carthage". Inside of that, will be another directory, called `Checkins`. Inside of that, will be [`RVS_CalendarInput/Sources/RVS_CalendarInput/RVS_CalendarInput.swift`](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift).

I recommend that you include this file directly into your app, as opposed to building the library, and adding that. If you do this, there will be no need to import a module. Additionally, the IBDesignables stuff should work (these are the previews in the storyboard file).

##### Directly From GitHub

The above Carthage instructions will also basically apply to getting the file from GitHub. You can use the following GitHub URLs to access the repository:

    git@github.com:RiftValleySoftware/RVS_CalendarInput.git (SSH),

or

    https://github.com/RiftValleySoftware/RVS_CalendarInput.git (HTTPS).

You can add the repo as a [Git Submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules), or even as a separate repo, that you use as a source for the physical file.

Get the same file, as indicated by Carthage, and add it to your project.

### IMPLEMENTATION
The implementor will instantiate an instance of this class (either via storyboard, or programmatically). They will then present an array of date objects (conforming to [ `RVS_CalendarInput_DateItemProtocol`](https://riftvalleysoftware.github.io/RVS_CalendarInput/Classes/RVS_CalendarInput/RVS_CalendarInput_DateItemProtocol.html)) to the widget, and the widget will configure itself around that array.

The minimal unit is a month. Months will always be displayed completely, from the first day of the month, to the last. The dataset's earliest date will determine the starting month, athe the dataset's latest date, the final month of the dataset. The dataset does not need to be sorted, upon presentation, but the internal dataset will always be sorted (by date). [There is a useful Array Extension](https://riftvalleysoftware.github.io/RVS_CalendarInput/Extensions/Array.html), for filtering the dataset.

There must be at least one date in the array presented. Any additional dates will be synthesized within the widget (for example, if one date is the twentieth of a month, the entire month, including all the other days that were not provided, will be created).

Only dates specifically in the initial set can be enabled and/or selected (Not required. These dates can also be disabled and/or deselected). All other (artificial) dates will be deselected and disabled.

Implementors can register as [delegates](https://riftvalleysoftware.github.io/RVS_CalendarInput/Protocols/RVS_CalendarInputDelegate.html), to [receive notifications](https://riftvalleysoftware.github.io/RVS_CalendarInput/Protocols/RVS_CalendarInputDelegate.html#/s:17RVS_CalendarInput0a1_bC8DelegateP08calendarC0_15dateItemChangedyA2AC_AF04DateG0CtF), when the user [de]selects a day, or they can examine an array of data objects, representing the state of the control.

## MORE INFORMATION
The control does not derive from [UIControl](https://developer.apple.com/documentation/uikit/uicontrol), as the event targeting system would not be useful for the types of interactions
that can occur with this control. Instead, the implementor should register as a [delegate (`RVS_CalendarInputDelegate`)](https://riftvalleysoftware.github.io/RVS_CalendarInput/Protocols/RVS_CalendarInputDelegate.html), and [receive messages, when the control is used](https://riftvalleysoftware.github.io/RVS_CalendarInput/Protocols/RVS_CalendarInputDelegate.html#/s:17RVS_CalendarInput0a1_bC8DelegateP08calendarC0_15dateItemChangedyA2AC_AF04DateG0CtF).
The implementor can always examine the [`data` array](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift#L315), and determine the control state. That array is updated in realtime.
The data is kept in an array of [`RVS_CalendarInput_DateItemProtocol`](https://riftvalleysoftware.github.io/RVS_CalendarInput/Classes/RVS_CalendarInput/RVS_CalendarInput_DateItemProtocol.html) instances. The widget maintains an internal array that cannot be affected from outside the control, but can be read.

The control is entirely executed in programmatic autolayout. All the implementor needs to do, is instantiate an instance of this class, position it in the layout, and supply it with an initial dataset. The widget, itself, uses autolayout to maintain its internal layout. All the user needs to worry about, is positioning the widget as a rectangle, in their own layout.

The colors for most of the control can be customized, but the disabled colors will always be based on the system background color (and the days will be slightly transparent). You cannot change the color of the disabled days.

The widget class is also declared as [`open`](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html#ID5), so it can be subclassed, and completely modified.

## THE TEST HARNESS APP
The test harness app is a simple, 1-screen iOS app that presents the widget under a "dashboard." The default date range goes from one (or, occasionally, two) month[s] prior to today, to up to four subsequent months. The same weekday as today, is highlighted in all the displayed days (that fall within the date range).

### THE BASICS

"Today" is enabled and selected (note October 31, in Figure 1). Subsequent instances of the same weekday as "today," are enabled, but not highlighted (note November 7 - January 22, in Figure 1 and Figure 2) The enabled days end at the end date, specified in the date picker. Even if there are more displayed days in the widget, after the end date, they will not be enabled or selected (note January 30 in Figure 2).

Past days are always disabled. Past days of the same weekday, after the start date, are also selected (note October 3-24, in Figure 1).

| ![Figure 1: The Test Harness Default Screen](img/Figure-01.png) | ![Figure 2: The Test Harness Default Screen (Scrolled)](img/Figure-02.png) |
| - | - |
| Figure 1: The Test Harness Default Screen | Figure 2: The Test Harness Default Screen (Scrolled) |

### HIDING HEADERS

The three switches in the dashboard will hide the widget headers. Figures 3-6 will show how this happens:

| ![Figure 3: Hiding the Year Header](img/Figure-03.png) | ![Figure 4: Hiding the Month Header](img/Figure-04.png) |
| - | - |
| Figure 3: Hiding the Year Header | Figure 4: Hiding the Month Header |

| ![Figure 5: Hiding the Weekday Header](img/Figure-05.png) | ![Figure 6: Hiding All Headers](img/Figure-06.png) |
| - | - |
| Figure 5: Hiding the Weekday Header | Figure 6: Hiding All Headers |

### CHANGING DATE RANGES

Use the date pickers to choose a range. Note that any days before today (this file was authored on October 31, 2021 -Happy Halloween!) will be disabled. The same weekday as today, will be highlighted.

| ![Figure 7: Selecting the Month of October, 2021](img/Figure-07.png) | ![Figure 8: Leaving Out Today (October 31)](img/Figure-08.png) |
| - | - |
| Figure 7: Selecting the Month of October, 2021 | Figure 8: Leaving Out Today (October 31) |

In Figure 8, we restrict the range, so that today is not included, so we do not get October 31 selected and enabled, even though it is displayed.

### "CLOWN MODE"

If you hit the little "clown" button, the colors of the widget will be customized to some truly ghastly colors (Not to worry. Hit the button again, and you'll get the defaults back):

| ![Figure 9: Clown Mode On](img/Figure-09.png) | ![Figure 10: Clown Mode Off](img/Figure-01.png) |
| - | - |
| Figure 9: Clown Mode On | Figure 10: Clown Mode Off |

### BROWSE THE CODE

[The source code for the test harness](https://github.com/RiftValleySoftware/RVS_CalendarInput/tree/master/Tests/RVS_CalendarInput/RVS_CalendarInputTestHarness) should give a good example of how to use the app.

## LICENSE

MIT License

Copyright (c) 2021 Rift Valley Software, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
