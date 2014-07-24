//
//  AttendanceViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "ZBarSDK.h"
#import <AVFoundation/AVFoundation.h>

@interface AttendanceViewController : UIViewController <ZBarReaderViewDelegate>
{
    IBOutlet UILabel *_courseNameLabel;
    IBOutlet UIView *_scanView;
    IBOutlet UIImageView *_successImageView;
    IBOutlet UITextField *_unitField;
    IBOutlet UITableView *_dropdownTableView;
    IBOutlet UILabel *_screenTitleLabel;
    IBOutlet UILabel *_forgetCardLabel;
    IBOutlet UIButton *_enterEmailButton;
    
    NSInteger _selectedUnitIndex;
    
    ZBarReaderView *_readerView;
}

@property (nonatomic, strong) NSDictionary *classObject;
@property (nonatomic, strong) NSDictionary *studentDict;
@property (nonatomic, strong) NSDictionary *classDetailObject;
@property (nonatomic, assign) BOOL isAttendanceScreen;

- (IBAction)enterEmailAddressButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end
