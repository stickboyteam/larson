//
//  StudentRosterViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "PayPalMobile.h"

@protocol StudentRosterViewControllerDelegate <NSObject>

- (void) dismissWithStudentInfo:(NSDictionary*)studentInfo;

@end

@interface StudentRosterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, StudentRosterViewControllerDelegate, PayPalPaymentDelegate>
{
    IBOutlet UILabel *_courseNameLabel;
    IBOutlet UILabel *_courseCodeLabel;
    
    IBOutlet UIButton *_sortByNameButton;
    IBOutlet UIButton *_sortByBalanceButton;
    IBOutlet UITableView *_tableView;
    
    IBOutlet UIView *_takePaymentView;
    
    IBOutlet UITextField *_amountField;
    
    NSIndexPath *_rowIndexPath;
    
    NSArray *_sortedStudentsList;
    
    BOOL _isPaidByCard;
}

@property (nonatomic, strong) NSDictionary* classObject;
@property (nonatomic, strong) NSDictionary* classDetailObject;

- (IBAction)cashCheckButtonAction:(id)sender;
- (IBAction)creditCardButtonAction:(id)sender;
- (IBAction)takePaymentTapGestureAction:(id)sender;
- (IBAction)addNewStudentButtonAction:(id)sender;
- (IBAction)startAttendanceButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)sortByNameButtonAction:(id)sender;
- (IBAction)sortByBalanceButtonAction:(id)sender;
- (IBAction)addCurrentStudentButtonAction:(id)sender;

@end
