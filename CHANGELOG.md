# RVS_CalendarInput Change Log

## 1.3.0

- **November 18, 2021**

Added a "Read-Only Mode."
Made a couple of internal data types public, and adjusted the delegate callback, to add the button that was selected.

## 1.2.4

- **November 13, 2021**

- Removed the @IBDesignable. It was nothing but misery.

## 1.2.3

- **November 11, 2021**

- Added a simple sorting integer to the data protocol.

## 1.2.2

- **November 11, 2021**

- Just made sure that the internal seed data is sorted. This will help to have a predictable response.

## 1.2.1

- **November 11, 2021**

- It was possible for the control to get in a "set layout loop," so I added some "checks and balances."

## 1.2.0

- **November 10, 2021**

- Significant performance boost, by removing the runtime string height calculations, and also speeding up the comparison, in the inner loop.

## 1.1.7

- **November 4, 2021**

- Improved documentation.
- Make sure that the setup is done ine the main thread, so the data can be presented in other threads.

## 1.1.6

- **November 3, 2021**

- No internal changes. Just changed the module name to use an underscore.

## 1.1.5

- **November 3, 2021**

- Internal refactoring to simplify the code.
- Improved documentation.

## 1.1.4

- **November 2, 2021**

- Some internal refactoring, and added the ability to modify the transparency of disabled dates.

## 1.1.3

- **November 1, 2021**

- Needed to make the internal extensions private (as opposed to fileprivate).
- Removed the @IBInspectable from the UIView extension (it was a leftover, anyway).
- Fixed some storyboard issues in the test harness.

## 1.1.2

- **November 1, 2021**

- Further simplification of the date item protocol.

## 1.1.1

- **November 1, 2021**

- Changed the internal "cornerRadius" UIView extension, to avoid conflicts with implementations.

## 1.1.0

- **November 1, 2021**

- Changed everything to use a protocol interface, in order to maximize flexibility.

## 1.0.0

- **October 31, 2021**

- Initial Release
