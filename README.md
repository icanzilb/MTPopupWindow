MTPopupWindow
=============

MTPopupWindow is an Objective-C class, which allows the programmer to show a popup style window within an iOS application. 
The class uses Quartz2D to draw the popup and the buttons needed for the UI, so it is fully compatible with Auto Layout.

This class requires __iOS6+__ as it uses layout constraints. 

The popup window is useful to show terms&conditions, about screens, or embeded web pages within an app. 
The popup is designed to show HTML content - from a local for the app html file (+ local images) or a remote HTML web page.

![GitHub Logo](http://www.touch-code-magazine.com/wp-content/uploads/2011/07/popupImage1.jpg)
![GitHub Logo](http://www.touch-code-magazine.com/wp-content/uploads/2011/07/popupImage2.jpg)

__MTPopupWindow announce post + source code examples:__

http://touch-code-magazine.com/showing-a-popup-window-in-ios6-modernized-tutorial-code-download/

__Code samples:__

Short source code example:

```objc
#import "MTPopupWindow.h"
...
[MTPopupWindow showWindowWithHTMLFile:@"info.html"];

```

This 1-liner will load the info.html from the app Resources directory and show it in a popup window maximized in the app window.

To specify in which view the popup window should appear, use this code:

```objc
#import "MTPopupWindow.h"
...
MTPopupWindow* winPop = [[MTPopupWindow alloc] init];
winPop.fileName = @"info.html";
[winPop showInView:self.view];
```