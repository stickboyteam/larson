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
    _titleLabel.text = @"New Student Information";
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

@end
