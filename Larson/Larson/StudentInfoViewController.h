//
//  EditStudentInfoViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentInfoViewController : UIViewController
{
    IBOutlet UILabel* _titleLabel;
    
    IBOutlet UITextField* _firstNameField;
    IBOutlet UITextField *_lastNameField;
    IBOutlet UITextField *_emailField;
    IBOutlet UITextField *_phoneNumberField;
    IBOutlet UITextField *_addressField;
    IBOutlet UITextField *_apartmentField;
    IBOutlet UITextField *_cityField;
    IBOutlet UITextField *_stateField;
    IBOutlet UITextField *_zipcodeField;
    IBOutlet UILabel *_courseNameLabel;
    IBOutlet UILabel *_courseFeeLabel;
}

- (IBAction)cashCheckPaymentButtonAction:(id)sender;
- (IBAction)creditCardPaymentButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;
@end
