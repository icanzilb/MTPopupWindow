//
//  SecondViewController.h
//  TabPopupTest
//
//  Created by Marin Todorov on 05/09/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPopupWindow.h"

@interface SecondViewController : UIViewController <MTPopupWindowDelegate>
- (IBAction)useSafariButtonPressed:(id)sender;
- (IBAction)useDelegateButtonPressed:(id)sender;

@end
