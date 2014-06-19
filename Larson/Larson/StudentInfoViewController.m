//
//  EditStudentInfoViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "StudentInfoViewController.h"

@interface StudentInfoViewController ()

@end

@implementation StudentInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColorFromHEX(kCommonBGColor);
    if (self.screenType == kScreenTypeEditStudent)
        _titleLabel.text = @"Edit Student Information";
    else
        _titleLabel.text = @"New Student Information";
    
    _firstNameField.text = [self.studentDict objectForKey:@"name"];
    if ([self.studentDict objectForKey:@"lastname"])
        _lastNameField.text = [self.studentDict objectForKey:@"lastname"];
    else
        _lastNameField.text = @"";
    _emailField.text = [self.studentDict objectForKey:@"email"];
    _addressField.text = [self.studentDict objectForKey:@"address"];
    _phoneNumberField.text = [self.studentDict objectForKey:@"phone"];
    _apartmentField.text = [self.studentDict objectForKey:@"apt"];
    _cityField.text = [self.studentDict objectForKey:@"city"];
    _stateField.text = [self.studentDict objectForKey:@"state"];
    _zipcodeField.text = [self.studentDict objectForKey:@"zip"];
    
    _courseNameLabel.text = [self.classDict objectForKey:@"className"];
    _courseFeeLabel.text = [NSString stringWithFormat:@"$%@",[self.studentDict objectForKey:@"classBalance"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cashCheckPaymentButtonAction:(id)sender
{
    
}

- (IBAction)creditCardPaymentButtonAction:(id)sender
{
    
}

- (IBAction)saveButtonAction:(id)sender
{
    
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)scanButtonAction:(id)sender
{
    
}

- (IBAction)cancelButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
