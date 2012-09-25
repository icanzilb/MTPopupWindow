//
//  FirstViewController.m
//  TabPopupTest
//
//  Created by Marin Todorov on 05/09/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "FirstViewController.h"
#import "MTPopupWindow.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnMaxTapped:(id)sender
{
    //show local file in top window
    [MTPopupWindow showWindowWithHTMLFile:@"info.html"];
    
    //show local file
    //MTPopupWindow* winPop = [MTPopupWindow showWindowWithHTMLFile:@"info.html" insideView:self.view];
    //winPop.backgroundColor = [UIColor yellowColor];
    
    //show local file, customizable
    //MTPopupWindow* winPop = [[MTPopupWindow alloc] init];
    //winPop.fileName = @"info.html";
    //[winPop showInView:self.view];
    
    //show remote web site
    //[MTPopupWindow showWindowWithHTMLFile:@"http://www.ios5-by-tutorials.com" insideView:self.view];
    
}

@end
