//
//  StudentRosterViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentRosterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel *_courseNameLabel;
    IBOutlet UILabel *_courseCodeLabel;
    
    IBOutlet UIButton *_sortByNameButton;
    IBOutlet UIButton *_sortByBalanceButton;
    IBOutlet UITableView *_tableView;
    
    IBOutlet UIView *_takePaymentView;
    
    IBOutlet UITextField *_amountField;
}

- (IBAction)cashCheckButtonAction:(id)sender;
- (IBAction)creditCardButtonAction:(id)sender;
- (IBAction)takePaymentTapGestureAction:(id)sender;
@end
