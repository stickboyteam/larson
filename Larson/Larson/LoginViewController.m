//
//  LoginViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 06/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "LoginViewController.h"
#import "ClassesViewController.h"
#import "MBProgressHUD.h"

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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _loginInputField.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)loginButtonAction:(id)sender
{
    [_loginInputField resignFirstResponder];
    _trim(_loginInputField.text);
    
    if (_loginInputField.text.length > 0)
    {
        [self loginRequestWithPasscode:_loginInputField.text];
    }
}

- (void) loginRequestWithPasscode:(NSString*)passcode
{
    HttpConnection* httpConn = [[HttpConnection alloc] initWithServerURL:kSubURLLogin withPostString:[NSString stringWithFormat:@"&login=%@",passcode]];
    [httpConn setRequestType:kRequestTypeLogin];
    [httpConn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) httpConnection:(id)handler didFailWithError:(NSError*)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [UIUtils alertWithErrorMessage:error.localizedDescription];
}

- (void) httpConnection:(id)handler didFinishedSucessfully:(NSData*)data
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    NSDictionary* responseDict = (NSDictionary*)[handler responseData];
    if ([[responseDict objectForKey:@"status"] isEqualToString:@"success"])
    {
        ClassesViewController* classesVC = [self.storyboard instantiateViewControllerWithIdentifier:kClassesViewID];
        if (classesVC)
        {
            classesVC.classesList = [NSArray arrayWithArray:[responseDict objectForKey:@"classes"]];
            [self.navigationController pushViewController:classesVC animated:YES];
        }
    }
    else
    {
        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
    }
}

@end
