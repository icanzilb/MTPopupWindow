//
//  MTPopupWindow.h
//  TabPopupTest
//
//  Created by Marin Todorov on 05/09/2012.
//

// MIT License
//
// Copyright (C) 2012 Marin Todorov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import <UIKit/UIKit.h>

@class MTPopupWindow;

/**
 * Define delegate protocol that will allow users of the popup window to be
 * notified when the popup does certian actions (open and close for now).
 */
@protocol MTPopupWindowDelegate <NSObject>
@optional
- (void) willShowMTPopupWindow:(MTPopupWindow*)sender;
- (void) didShowMTPopupWindow:(MTPopupWindow*)sender;
- (void) willCloseMTPopupWindow:(MTPopupWindow*)sender;
- (void) didCloseMTPopupWindow:(MTPopupWindow*)sender;
@end

/**
 * Class to easily show popup windows in iOS apps.
 * Blocks the content behind and shows the contents of an HTML file,
 * useful for showin terms&conditions, about dialogues, etc.
 */
@interface MTPopupWindow : UIView

/**
 * Shows a popup window and loads the HTML file passed as a parameter
 * @param NSString* fileName - either path to an HTML file in the app bundle resources path, or an URL to a website to load
 */
+(MTPopupWindow*)showWindowWithHTMLFile:(NSString*)fileName;

/**
 * Shows a popup window and loads the HTML file passed as a parameter
 * @param NSString* fileName - either path to an HTML file in the app bundle resources path, or an URL to a website to load
 * @param UIView* view - the target view where the popup window should show up
 */
+(MTPopupWindow*)showWindowWithHTMLFile:(NSString*)fileName insideView:(UIView*)view;

/**
 * If you are not using one of the one-shot methods, but you are creating the view by using alloc/init
 * then to show the window you need to call this method
 */
-(void)show;

/**
 * If you are not using one of the one-shot methods, but you are creating the view by using alloc/init
 * then to show the window you need to call this method
 * @param UIView* view - the target view where the popup window should show up
 */
-(void)showInView:(UIView*)v;

/**
 * This method allows you to change the horizontal and vertical margin of the popup window
 * @param CGSize margin - width will set the horizontal margin, height - the vertical
 */
+(void)setWindowMargin:(CGSize)margin;

@property (strong, nonatomic) NSString* fileName;
@property (strong, nonatomic) UIWebView* webView;
@property (weak, nonatomic) id <MTPopupWindowDelegate> delegate;
@property (nonatomic) BOOL usesSafari;

@end