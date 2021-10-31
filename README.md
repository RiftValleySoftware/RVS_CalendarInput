![Icon](img/icon.png)

# RVS_CalendarInput

---
**NOTE**

[Here is a link to the GitHub repo for this project.](https://github.com/RiftValleySoftware/RVS_CalendarInput/)

[Here is a link to the technical documentation for this project.](https://riftvalleysoftware.github.io/RVS_CalendarInput/)

---

## INTRODUCTION
RVS_CalendarInput is a customized [UIView](https://developer.apple.com/documentation/uikit/uiview) implementation, that will display a basic month/grid calendar, with active buttons, on selected dates.

The workflow may be familiar to people that have used Web-based "booking" systems. A date grid is presented, in calendar form, with certain dates higlighted as toggle buttons. The user can select these dates.
 
## WHAT PROBLEM DOES IT SOLVE?
Unlike some of the other open-source widgets that we've produced, this widget is being designed for a single application and workflow, so it will be less "general purpose" than other Great Rift Valley Software Company widgets.

In our application, we are adding a workflow, that allows the user of the app to declare that they will be attending events on certain dates. This widget is how they will do that.

## HOW DOES IT WORK?
The user is presented with a grid of possible dates, and certain dates are enabled. This is visually indicated by a combination of colors/contrasts, and transparency. The user can select or deselect enabled dates, and the view will contain a scroller, allowing the implementor to present a range of possible dates. When the user selects an enabled date, its state will toggle. The stored dataset will have that date modified, and the delegate will be informed of the change.

The widget is completely localized, respecting the user's calendar and week start. It also adapts well to various layouts, and can have its headers and other items customized.

## REQUIREMENTS

This is a [Swift](https://apple.com/swift)-only module. It is based on [standard UIKit](https://developer.apple.com/documentation/uikit), for [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados).

There are no dependencies for the widget, or the test harness app.

## HOW DO WE USE IT?
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

This will create a directory, called "Carthage". Inside of that, will be another directory, called `Checkins`. Inside of that, will be `RVS_CalendarInput/Sources/RVS_CalendarInput/RVS_CalendarInput.swift`.

I recommend that you include this file directly into your app, as opposed to building the library, and adding that. If you do this, there will be no need to import a module. Additionally, the IBDesignables stuff should work (these are the previews in the storyboard file).

##### Directly From GitHub

The above Carthage instructions will also basically apply to getting the file from GitHub. You can use the following GitHub URLs to access the repository:

    git@github.com:RiftValleySoftware/RVS_CalendarInput.git (SSH),

or

    https://github.com/RiftValleySoftware/RVS_CalendarInput.git (HTTPS).

You can add the repo as a [Git Submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules), or even as a separate repo, that you use as a source for the physical file.

Get the same file, as indicated by Carthage, and add it to your project.

### IMPLEMENTATION
The implementor will instantiate an instance of this class (either via storyboard, or programmatically). They will then present an array of date objects to the widget, and the widget will configure itself around that array.

The minimal unit is a month. The dataset's earliest date will determine the starting month; including dates before the dataset start (from the first of the month), to the final month of the dataset.

There must be at least one date in the array presented. Any additional dates will be synthesized within the widget (for example, if one date is the twentieth of a month, the entire month, including all the other days that were not provided, will be created).

Implementors can register as [delegates](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift#L897), to [receive notifications](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift#L904), when the user [de]selects a day, or they can examine an array of data objects, representing the state of the control.

## MORE INFORMATION
The control does not derive from [UIControl](https://developer.apple.com/documentation/uikit/uicontrol), as the event targeting system would not be useful for the types of interactions
that can occur with this control. Instead, the implementor should register as a delegate ([`RVS_CalendarInputDelegate`](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift#L897)), and receive messages, when the control is used.
The implementor can always examine the [`data` array](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift#L315), and detrmine the control state. That array is updated in realtime.
The data is kept in an array of [`RVS_CalendarInput.DateItem`](https://github.com/RiftValleySoftware/RVS_CalendarInput/blob/master/Sources/RVS_CalendarInput/RVS_CalendarInput.swift#L153) instances. The widget maintains an internal array that cannot be affected from outside the control, but can be read.

The control is entirely executed in programmatic autolayout. All the implementor needs to do, is instantiate an instance of this class, position it in the layout, and supply it with an initial dataset. The widget, itself, uses autolayout to maintain its internal layout. All the user needs to worry about, is positioning the widget as a rectangle, in their own layout.

The colors for most of the control can be customized, but the disabled colors will be based on the system background color (and the days will be slightly transparent).

## THE TEST HARNESS APP

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
