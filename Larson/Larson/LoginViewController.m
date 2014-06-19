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
    
//    NSString* str = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.larsoned.com.php53-9.dfw1-2.websitetestlink.com/api/login.php?login=LarsonTestCode"] encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"respone %@",str);
//
//    NSString* str1 = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.larsoned.com.php53-9.dfw1-2.websitetestlink.com/api/new-student.php?first_name=john&last_name=cena&email=john.cena1@gmail.com&phone=123456&address=Mnw&city=Austin&state=Texas&zip=4302&btnRegistrationSubmit=submit"] encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"respone %@",str1);
//    
//    NSString* str2 = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.larsoned.com.php53-9.dfw1-2.websitetestlink.com/api/class-details.php?classId=17"] encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"respone %@",str2);
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
    [self loginRequestWithPasscode:_loginInputField.text];
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
    NSDictionary* responseDict = (NSDictionary*)[handler responseData];
    if ([[responseDict objectForKey:@"status"] isEqualToString:@"failure"])
    {
        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
    }
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
}

@end
