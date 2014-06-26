//
//  AttendanceViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "ZBarSDK.h"

@interface AttendanceViewController : UIViewController <ZBarReaderDelegate>
{
    IBOutlet UILabel *_courseNameLabel;
    IBOutlet UIView *_scanView;
    IBOutlet UIImageView *_successImageView;
    IBOutlet UITextField *_unitField;
    IBOutlet UITableView *_dropdownTableView;
    
    NSArray *_unitList;
    NSInteger _selectedUnitIndex;
}

@property (nonatomic, strong) NSDictionary *classDict;
@property (nonatomic, strong) NSDictionary *studentDict;

- (IBAction)enterEmailAddressButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end
