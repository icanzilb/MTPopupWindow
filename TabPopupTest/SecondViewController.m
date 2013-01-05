//
//  SecondViewController.m
//  TabPopupTest
//
//  Created by Marin Todorov on 05/09/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "SecondViewController.h"
#import "MTPopupWindow.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

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

- (IBAction)useSafariButtonPressed:(id)sender {
    MTPopupWindow *popup = [[MTPopupWindow alloc] init];
    popup.usesSafari = YES;
    popup.fileName = @"info.html";
    [popup show];
}

- (IBAction)useDelegateButtonPressed:(id)sender {
    MTPopupWindow *popup = [[MTPopupWindow alloc] init];
    popup.delegate = self;
    popup.fileName = @"more.html";
    [popup show];
}

#pragma mark - webview delegate methods

- (void) didShowMTPopupWindow:(MTPopupWindow*)sender {
    [[[UIAlertView alloc] initWithTitle:@"MTPopupWindow Delegate"
                                message:@"MTPopupWindow Showed"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void) didCloseMTPopupWindow:(MTPopupWindow*)sender {
    [[[UIAlertView alloc] initWithTitle:@"MTPopupWindow Delegate"
                                message:@"MTPopupWindow Closed"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
