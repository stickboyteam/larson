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
    {
        _titleLabel.text = @"Edit Student Information";
        [self updateStudentInfoUI];
        [self updateClassInfoUIWithBalance:[self.studentDict objectForKey:@"classBalance"]];
    }
    else
    {
        _titleLabel.text = @"New Student Information";
        [self updateClassInfoUIWithBalance:@"0.00"];
    }
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
    _trim(_firstNameField.text);
    _trim(_lastNameField.text);
    _trim(_addressField.text);
    _trim(_apartmentField.text);
    _trim(_cityField.text);
    _trim(_stateField.text);
    _trim(_zipcodeField.text);
    
    if (self.screenType == kScreenTypeEditStudent)
    {
        [self editStudentInfoRequest];
    }
    else
    {
        [self addStudentInfoRequest];
    }
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

#pragma mark -

- (void) updateStudentInfoUI
{
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
}

- (void) updateClassInfoUIWithBalance:(NSString*)balance
{
    _courseNameLabel.text = [self.classDict objectForKey:@"className"];
    _courseFeeLabel.text = [NSString stringWithFormat:@"$%@",balance];
}

- (void) editStudentInfoRequest
{
    NSString* postString = [NSString stringWithFormat:@"&id=%@&first_name=%@&last_name=%@&email=%@&phone=%@&address=%@&apt=%@&city=%@&state=%@&zip=%@&btnUpdateSubmit=submit",[self.studentDict objectForKey:@"id"],_firstNameField.text,_lastNameField.text,_emailField.text,_phoneNumberField.text,_addressField.text,_apartmentField.text,_cityField.text,_stateField.text,_zipcodeField.text];
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLEditStudentInfo withPostString:postString];
    [conn setRequestType:kRequestTypeEditStudentInfo];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) addStudentInfoRequest
{
    NSString* postString = [NSString stringWithFormat:@"&first_name=%@&last_name=%@&email=%@&phone=%@&address=%@&apt=%@&city=%@&state=%@&zip=%@&btnRegistrationSubmit=submit",_firstNameField.text,_lastNameField.text,_emailField.text,_phoneNumberField.text,_addressField.text,_apartmentField.text,_cityField.text,_stateField.text,_zipcodeField.text];
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLAddStudentInfo withPostString:postString];
    [conn setRequestType:kRequestTypeEditStudentInfo];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];    
}

#pragma mark - HttpConnection delegate

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
        if (self.screenType == kScreenTypeEditStudent)
        {
            [UIUtils alertWithInfoMessage:@"Updated student info successfully"];
            
            NSMutableDictionary* stdDict = [NSMutableDictionary dictionary];
            [stdDict setObject:[self.studentDict objectForKey:@"id"] forKey:@"id"];
            [stdDict setObject:_firstNameField.text forKey:@"name"];
            [stdDict setObject:_lastNameField.text forKey:@"lastname"];
            [stdDict setObject:_emailField.text forKey:@"email"];
            [stdDict setObject:_phoneNumberField.text forKey:@"phone"];
            [stdDict setObject:_addressField.text forKey:@"address"];
            [stdDict setObject:_apartmentField.text forKey:@"apt"];
            [stdDict setObject:_cityField.text forKey:@"city"];
            [stdDict setObject:_stateField.text forKey:@"state"];
            [stdDict setObject:_zipcodeField.text forKey:@"zip"];
            [stdDict setObject:[self.studentDict objectForKey:@"classBalance"] forKey:@"classBalance"];
            
            [self.delegate dismissWithStudentInfo:stdDict];
        }
        else
        {
            [UIUtils alertWithInfoMessage:@"Added student info successfully"];
            [self.delegate dismissWithStudentInfo:[responseDict objectForKey:@"student"]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
    }
}

@end
