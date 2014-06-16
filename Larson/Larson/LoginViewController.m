//
//  LoginViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 06/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "LoginViewController.h"
#import "ClassesViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = UIColorFromHEX(kLoginBGColor);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@",_loginInputField.font.familyName);
    NSLog(@"%@",_loginInputField.font.fontName);


    //_loginInputField.font = [UIFont fontWithName:@"Lato-Regular" size:73];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonAction:(id)sender
{
    ClassesViewController* classesVC = [self.storyboard instantiateViewControllerWithIdentifier:kClassesViewID];
    if (classesVC)
    {
        [self.navigationController pushViewController:classesVC animated:YES];        
    }
}

@end
