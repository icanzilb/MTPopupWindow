//
//  MTPopupWindow.m
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

#import "MTPopupWindow.h"
#import "QuartzCore/QuartzCore.h"

#define kCloseBtnDiameter 30
#define kDefaultMargin 18
static CGSize kWindowMarginSize;

//
// Interface to declare the private class variables
//
@interface MTPopupWindow() <UIWebViewDelegate>
{
    UIView* _dimView;
    UIView* _bgView;
    UIActivityIndicatorView* _loader;
}
@end

//
// The close button has its own class to implement
// the custom drawing method
//
@interface MTPopupWindowCloseButton : UIButton
+ (id)buttonInView:(UIView*)v;
@end

//
// Few helper methods to make maximizing windows
// setting ui elements sizes, and positioning
// easier
//
@interface UIView(MTPopupWindowLayoutShortcuts)
-(void)replaceConstraint:(NSLayoutConstraint*)c;
-(void)layoutCenterInView:(UIView*)v;
-(void)layoutInView:(UIView*)v setSize:(CGSize)s;
-(void)layoutMaximizeInView:(UIView*)v withInset:(float)inset;
-(void)layoutMaximizeInView:(UIView*)v withInsetSize:(CGSize)insetSize;
@end


@implementation MTPopupWindow

@synthesize fileName = _fileName;
@synthesize webView = _webView;
@synthesize usesSafari = _usesSafari;
@synthesize delegate = _delegate;

+ (void)initialize
{
    kWindowMarginSize = CGSizeMake(kDefaultMargin, kDefaultMargin);
}

+(void)setWindowMargin:(CGSize)margin
{
    kWindowMarginSize = margin;
}

+(MTPopupWindow*)showWindowWithHTMLFile:(NSString*)fileName
{
    UIView* view = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    return [self showWindowWithHTMLFile:fileName insideView:view];
}

/**
 * This is the only public method, it opens a popup window and loads the given content
 * @param NSString* fileName provide a file name to load a file from the app resources, or a URL to load a web page
 * @param UIView* view provide a UIViewController's view here (or other view)
 */
+(MTPopupWindow*)showWindowWithHTMLFile:(NSString*)fileName insideView:(UIView*)view
{
    if ([UIApplication sharedApplication].statusBarHidden==NO) {
        [self setWindowMargin:CGSizeMake(kWindowMarginSize.width, 50)];
    }

    //initialize the popup window
    MTPopupWindow* popup = [[MTPopupWindow alloc] initWithFile:fileName];
    
    if ([popup respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
        [popup setTranslatesAutoresizingMaskIntoConstraints:NO];
    }

    //setup and show
    [popup showInView: view];
    
    return popup;
}

/**
 * Inject setupUI into the init initializer
 */
-(id)init
{
    self = [super init];
    if (self) {
        //customzation
        [self setupUI];
    }
    return self;
}

/**
 * Inject setupUI into the initWithFrame initializer
 */
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //customzation
        [self setupUI];
    }
    return self;
}

/**
 * Initializes the class instance, gets a view where the window will pop up in
 * and a file name/ URL
 */
- (id)initWithFile:(NSString*)fName
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.fileName = fName;
    }
    
    return self;
}

/**
 * Shows the popup window in the root view controller
 */
-(void)show
{
    UIView* view = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    [self showInView:view];
}

/**
 * Adds a hierarchy of views to the target view
 * then calls the method to animate the popup window in
 *
 *  v is the target view
 *  +- _dimView - a semi-opaque black background
 *  +- _bgView - the container of the popup window
 *    +- self - this is the popup window instance
 *      +- self.webView - is the web view to show your HTML content
 *      +- btnClose - the custom close button
 *    +- fauxView - an empty view, where the popup window animates into
 *
 * @param UIView* v The view to add the popup window to
 */
-(void)showInView:(UIView*)v
{
    //add the dim layer behind the popup
    _dimView = [[UIView alloc] init];
    [v addSubview: _dimView];
    [_dimView layoutMaximizeInView:v withInset:0];
    
    //add the popup container
    _bgView = [[UIView alloc] init];
    [v addSubview: _bgView];
    [_bgView layoutMaximizeInView:v withInset:0];
    
    //add the web view to show the HTML file
    self.webView = [[UIWebView alloc] init];
    self.webView.scrollView.bounces = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.alpha = 0.0f;
    self.webView.delegate = self;
    [self addSubview: self.webView];

    [self.webView layoutMaximizeInView:self withInset:15];

    //load the content for the popup window
    if ([self.fileName hasPrefix:@"http"]) {
        
        //load a web page from Internet
        _loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_loader];
        [_loader layoutCenterInView:self];
        [_loader startAnimating];
        
        self.webView.scalesPageToFit = YES;
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: self.fileName]]];
        
    } else {
        
        //load a local file
        NSError* error = nil;
        NSString* fileContents = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.fileName] encoding:NSUTF8StringEncoding error: &error];
        if (error!=NULL) {
            NSLog(@"error loading %@: %@", self.fileName, [error localizedDescription]);
        } else {
            [self.webView loadHTMLString: fileContents baseURL:[[NSBundle mainBundle] resourceURL]];
        }
    }
    
    //make the close button
    MTPopupWindowCloseButton* btnClose = [MTPopupWindowCloseButton buttonInView:self];
    [btnClose addTarget:self action:@selector(closePopupWindow) forControlEvents:UIControlEventTouchUpInside];

    // Attempt to alert the delegate.
    if ([_delegate respondsToSelector:@selector(willShowMTPopupWindow:)])
        [_delegate willShowMTPopupWindow:self];
  
    //animate the popup window in
    [self performSelector:@selector(animatePopup:) withObject:v afterDelay:0.01];
}

/**
 * Adds a blank view and then animates the popup window
 * into the parent view
 *
 * @param UIView* v the parent view to do the animations in
 */
-(void)animatePopup:(UIView*)v
{

    //add the faux view to transition from
    UIView* fauxView = [[UIView alloc] init];
    fauxView.backgroundColor = [UIColor redColor];
    [_bgView addSubview: fauxView];

    [fauxView layoutMaximizeInView:_bgView withInset: kDefaultMargin];

    //animation options
    UIViewAnimationOptions options =
        UIViewAnimationOptionTransitionFlipFromRight |
        UIViewAnimationOptionAllowUserInteraction    |
        UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animations
    [UIView transitionWithView:_bgView
                      duration:0.4
                       options:options
                    animations:^{
                        
                        //replace the blank view with the popup window
                        [fauxView removeFromSuperview];
                        [_bgView addSubview: self];
                        
                        //maximize the popup window in the parent view
                        [self layoutMaximizeInView:_bgView withInsetSize: kWindowMarginSize];
                        
                        //turn the background view to black color
                        _dimView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                        
                        //fade in the web view
                        self.webView.alpha = 1.0f;
                        
                    } completion:^(BOOL finished) {
                        //NSLog(@"Finsihed");
                      
                        // Attempt to alert the delegate.
                        if ([_delegate respondsToSelector:@selector(didShowMTPopupWindow:)])
                            [_delegate didShowMTPopupWindow:self];
                    }];
}

/**
 * Closes the popup window
 * the method animates the popup window out
 * and removes it from the view hierarchy
 */
-(void)closePopupWindow
{
    // Attempt to alert the delegate.
    if ([_delegate respondsToSelector:@selector(willCloseMTPopupWindow:)])
        [_delegate willCloseMTPopupWindow:self];
  
    //animation options
    UIViewAnimationOptions options =
        UIViewAnimationOptionTransitionFlipFromLeft |
        UIViewAnimationOptionAllowUserInteraction   |
        UIViewAnimationOptionBeginFromCurrentState;
    
    //animate the popup window out
    [UIView transitionWithView:_bgView
                      duration:0.4
                       options:options
                    animations:^{
                        
                        //fade out the black background
                        _dimView.backgroundColor = [UIColor clearColor];
                        
                        //remove the popup window from the view hierarchy
                        [self removeFromSuperview];
                        
                    } completion:^(BOOL finished) {
                        
                        //remove the container view
                        [_bgView removeFromSuperview];
                        _bgView = nil;
                        
                        //remove the black backgorund
                        [_dimView removeFromSuperview];
                        _dimView = nil;
                      
                        // Attempt to alert the delegate.
                        if ([_delegate respondsToSelector:@selector(didCloseMTPopupWindow:)])
                            [_delegate didCloseMTPopupWindow:self];
                    }];
}

/**
 * Sets up some basic UI properties
 */
-(void)setupUI
{
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.cornerRadius = 15.0;
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - webview delegate methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_loader) [_loader removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"The requested document cannot be loaded, try again later"
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles: nil] show];
    
    if (_loader) [_loader removeFromSuperview];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    if (self.usesSafari) {
      NSURL *requestURL =[request URL];
      if (([[requestURL scheme] hasPrefix:@"http"]) && (navigationType == UIWebViewNavigationTypeLinkClicked)) {
        return ![[UIApplication sharedApplication] openURL:requestURL];
      }
      return YES;
    }
    return YES;
}

@end

/**
 * The close button for the popup window
 */
@implementation MTPopupWindowCloseButton

/**
 * creates a button instance and adds it as a subview to the view, passed as argument
 * the convenience method also creates all the autolayout constraints
 *
 * @param UIView* v - the view to add the close button to
 */
+ (id)buttonInView:(UIView*)v
{
    int closeBtnOffset = 5;
    
    //create button instance
    MTPopupWindowCloseButton* closeBtn = [MTPopupWindowCloseButton buttonWithType:UIButtonTypeCustom];
    if ([closeBtn respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
        [closeBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    [v addSubview: closeBtn];

    //create the contraints to stick the button
    //to the top-right corner of the parent view
    NSLayoutConstraint* rightc = [NSLayoutConstraint constraintWithItem: closeBtn
                                                              attribute: NSLayoutAttributeRight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: v
                                                              attribute: NSLayoutAttributeRight
                                                             multiplier: 1.0f
                                                               constant: -closeBtnOffset];
    
    NSLayoutConstraint* topc = [NSLayoutConstraint constraintWithItem: closeBtn
                                                            attribute: NSLayoutAttributeTop
                                                            relatedBy: NSLayoutRelationEqual
                                                               toItem: v
                                                            attribute: NSLayoutAttributeTop
                                                           multiplier: 0.0f
                                                             constant: closeBtnOffset];
    
    NSLayoutConstraint* wwidth = [NSLayoutConstraint constraintWithItem: closeBtn
                                                              attribute: NSLayoutAttributeWidth
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: v
                                                              attribute: NSLayoutAttributeWidth
                                                             multiplier: 0.0f
                                                               constant: kCloseBtnDiameter];
    
    NSLayoutConstraint* hheight = [NSLayoutConstraint constraintWithItem: closeBtn
                                                               attribute: NSLayoutAttributeHeight
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: v
                                                               attribute: NSLayoutAttributeHeight
                                                              multiplier: 0.0f
                                                                constant: kCloseBtnDiameter];
    //replace the automatically created constraints
    [v replaceConstraint: topc];
    [v replaceConstraint: rightc];
    [v replaceConstraint: wwidth];
    [v replaceConstraint: hheight];
    
    //return the instance
    return closeBtn;
}

/**
 * Draw a circle with a X inside
 */
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextAddEllipseInRect(ctx, CGRectOffset(rect, 0, 0));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:1] CGColor]));
    CGContextFillPath(ctx);

    CGContextAddEllipseInRect(ctx, CGRectInset(rect, 1, 1));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] CGColor]));
    CGContextFillPath(ctx);

    CGContextAddEllipseInRect(ctx, CGRectInset(rect, 4, 4));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]));
    CGContextFillPath(ctx);
    
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1].CGColor);
    CGContextSetLineWidth(ctx, 3.0);
    CGContextMoveToPoint(ctx, kCloseBtnDiameter/4+1,kCloseBtnDiameter/4+1); //start at this point
    CGContextAddLineToPoint(ctx, kCloseBtnDiameter/4*3+1,kCloseBtnDiameter/4*3+1); //draw to this point
    CGContextStrokePath(ctx);

    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1].CGColor);
    CGContextSetLineWidth(ctx, 3.0);
    CGContextMoveToPoint(ctx, kCloseBtnDiameter/4*3+1,kCloseBtnDiameter/4+1); //start at this point
    CGContextAddLineToPoint(ctx, kCloseBtnDiameter/4+1,kCloseBtnDiameter/4*3+1); //draw to this point
    CGContextStrokePath(ctx);
}
@end

//
// Few handy helper methods as a category to UIView
// to help building contraints
//
@implementation UIView(MTPopupWindowLayoutShortcuts)

-(void)replaceConstraint:(NSLayoutConstraint*)c
{
    for (int i=0;i<[self.constraints count];i++) {
        NSLayoutConstraint* c1 = self.constraints[i];
        if (c1.firstItem==c.firstItem && c1.firstAttribute == c.firstAttribute) {
            [self removeConstraint:c1];
        }
    }
    [self addConstraint:c];
}

-(void)layoutCenterInView:(UIView*)v
{
    if ([self respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem: self
                                                               attribute: NSLayoutAttributeCenterX
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: v
                                                               attribute: NSLayoutAttributeCenterX
                                                              multiplier: 1.0f
                                                                constant: 0.0f];
    
    NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem: self
                                                               attribute: NSLayoutAttributeCenterY
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: v
                                                               attribute: NSLayoutAttributeCenterY
                                                              multiplier: 1.0f
                                                                constant: 0.0f];
    
    [v replaceConstraint:centerX];
    [v replaceConstraint:centerY];
    
    [v setNeedsLayout];
}

-(void)layoutInView:(UIView*)v setSize:(CGSize)s
{
    if ([self respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    NSLayoutConstraint* wwidth = [NSLayoutConstraint constraintWithItem: self
                                                              attribute: NSLayoutAttributeWidth
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: v
                                                              attribute: NSLayoutAttributeWidth
                                                             multiplier: 0.0f
                                                               constant: s.width];
    
    NSLayoutConstraint* hheight = [NSLayoutConstraint constraintWithItem: self
                                                               attribute: NSLayoutAttributeHeight
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: v
                                                               attribute: NSLayoutAttributeHeight
                                                              multiplier: 0.0f
                                                                constant: s.height];
    [v replaceConstraint: wwidth];
    [v replaceConstraint: hheight];
    
    [v setNeedsLayout];
}

-(void)layoutMaximizeInView:(UIView*)v withInset:(float)inset
{
    [self layoutMaximizeInView:v withInsetSize:CGSizeMake(inset, inset)];
}

-(void)layoutMaximizeInView:(UIView*)v withInsetSize:(CGSize)insetSize
{
    if ([self respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem: self
                                                               attribute: NSLayoutAttributeCenterX
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: v
                                                               attribute: NSLayoutAttributeCenterX
                                                              multiplier: 1.0f
                                                                constant: 0.0f];
    
    NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem: self
                                                               attribute: NSLayoutAttributeCenterY
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: v
                                                               attribute: NSLayoutAttributeCenterY
                                                              multiplier: 1.0f
                                                                constant: 0.0f];
    
    NSLayoutConstraint* wwidth = [NSLayoutConstraint constraintWithItem: self
                                                              attribute: NSLayoutAttributeWidth
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: v
                                                              attribute: NSLayoutAttributeWidth
                                                             multiplier: 1.0f
                                                               constant: -insetSize.width];
    
    NSLayoutConstraint* hheight = [NSLayoutConstraint constraintWithItem: self
                                                               attribute: NSLayoutAttributeHeight
                                                               relatedBy: NSLayoutRelationEqual
                                                                  toItem: v
                                                               attribute: NSLayoutAttributeHeight
                                                              multiplier: 1.0f
                                                                constant: -insetSize.height];
    
    
    [v replaceConstraint: centerX];
    [v replaceConstraint: centerY];
    [v replaceConstraint: wwidth];
    [v replaceConstraint: hheight];
    
    [v setNeedsLayout];
}

@end
