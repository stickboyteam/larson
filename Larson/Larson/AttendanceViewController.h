//
//  AttendanceViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendanceViewController : UIViewController
{
    IBOutlet UILabel *_courseNameLabel;
    IBOutlet UIView *_scanView;
    
}

- (IBAction)enterEmailAddressButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
@end
