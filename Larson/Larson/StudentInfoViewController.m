//
//  EditStudentInfoViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "StudentInfoViewController.h"
#import "AttendanceViewController.h"

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
    }
    else
    {
        _titleLabel.text = @"New Student Information";
    }
    
    [self updateClassInfoUIWithBalance:[self.studentDict objectForKey:@"classBalance"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cashCheckPaymentButtonAction:(id)sender
{
    NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[self.studentDict objectForKey:@"name"],[self.studentDict objectForKey:@"email"],[self.classDict objectForKey:@"classCode"]];
    [self initiatePaymentWithPaypalWithCreditCard:NO withDescription:paymentDescription];
}

- (IBAction)creditCardPaymentButtonAction:(id)sender
{
    NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[self.studentDict objectForKey:@"name"],[self.studentDict objectForKey:@"email"],[self.classDict objectForKey:@"classCode"]];
    [self initiatePaymentWithPaypalWithCreditCard:YES withDescription:paymentDescription];
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
    AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
    if (attendanceVC)
    {
        [self.navigationController pushViewController:attendanceVC animated:YES];
    }
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
    if (balance.length > 0)
        _courseFeeLabel.text = [NSString stringWithFormat:@"$%@",balance];
    else
        _courseFeeLabel.text = @"$0.00";
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
    NSString* postString = [NSString stringWithFormat:@"&classId=%@&first_name=%@&last_name=%@&email=%@&phone=%@&address=%@&apt=%@&city=%@&state=%@&zip=%@&btnRegistrationSubmit=submit",[self.classDict objectForKey:@"classId"],_firstNameField.text,_lastNameField.text,_emailField.text,_phoneNumberField.text,_addressField.text,_apartmentField.text,_cityField.text,_stateField.text,_zipcodeField.text];
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLAddStudentInfo withPostString:postString];
    [conn setRequestType:kRequestTypeEditStudentInfo];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];    
}

- (void) initiatePaymentWithPaypalWithCreditCard:(BOOL)acceptCreditCard withDescription:(NSString*)description
{
    NSString* amount = [self.studentDict objectForKey:@"classBalance"];
    int totalAmount = [amount intValue];
    //include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithInt:_calculateShippingAmount(totalAmount)];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithInt:_calculateTaxAmount(totalAmount)];
    NSDecimalNumber *subtotal = [[NSDecimalNumber alloc] initWithInt:totalAmount];
    
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal                                                                              withShipping:shipping                                                                                    withTax:tax];
    
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = description;
    payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
    // Set up payPalConfig
    PayPalConfiguration *payPalConfig = [[PayPalConfiguration alloc] init];
    if (kPayPalMerchantAcceptCreditCards)
        payPalConfig.acceptCreditCards = YES;
    else
        payPalConfig.acceptCreditCards = NO;
    payPalConfig.languageOrLocale = @"en";
    payPalConfig.merchantName = kPayPalMerchantName;
    payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:kPayPalMerchantPrivacyPolicyURL];
    payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:kPayPalMerchantUserAgreementURL];
    payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    // Update payPalConfig re accepting credit cards.
    payPalConfig.acceptCreditCards = acceptCreditCard;
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment                                                                                                configuration:payPalConfig                                                                                                     delegate:self];
    
    if (!payment.processable)
    {
        [UIUtils alertWithErrorMessage:@"Unable to process your payment, please try later"];
    }

    if (paymentViewController)
        [self presentViewController:paymentViewController animated:YES completion:nil];
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

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment
{
    NSLog(@"PayPal Payment Success!");
    NSLog(@"PayPal Payment description %@",[completedPayment description]);
    NSLog(@"PayPal Payment confirmation %@",[completedPayment confirmation]);
    
    [UIUtils alertWithInfoMessage:[NSString stringWithFormat:@"Payment made successfull with Id - %@",[[[completedPayment confirmation] objectForKey:@"response"] objectForKey:@"id"]]];
    //details to be sent to server
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
