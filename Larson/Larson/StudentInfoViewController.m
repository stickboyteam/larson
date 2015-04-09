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

@property (nonatomic, strong) NSDictionary* paymentDetails;

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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openURLNotification:) name:kAppDelegateOpenURLNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cashButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    if (!_studentDict)
    {
        [UIUtils alertWithInfoMessage:@"Please save student info"];
        return;
    }
    
    int totalAmount = [[_courseFeeLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""]intValue];
    if (totalAmount > 0)
    {
        //        NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[self.studentDict objectForKey:@"name"],[self.studentDict objectForKey:@"email"],[self.classDict objectForKey:@"classCode"]];
        //        _isPaidByCard = NO;
        //        [self initiatePaymentWithPaypalWithCreditCard:NO withDescription:paymentDescription amount:totalAmount];
        
        [UIUtils alertWithTitle:[NSString stringWithFormat:@"Confirm Payment of %@ ?",_courseFeeLabel.text] message:nil okBtnTitle:@"Yes" cancelBtnTitle:@"No" delegate:self tag:2222];
    }
    else
    {
        [UIUtils alertWithInfoMessage:@"you do not have any balance amount to pay"];
    }
}

- (IBAction)checkButtonAction:(id)sender
{
    [self.view endEditing:YES];

    if (!_studentDict)
    {
        [UIUtils alertWithInfoMessage:@"Please save student info"];
        return;
    }
    
    int totalAmount = [[_courseFeeLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""]intValue];
    if (totalAmount > 0)
    {
//        NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[self.studentDict objectForKey:@"name"],[self.studentDict objectForKey:@"email"],[self.classDict objectForKey:@"classCode"]];
//        _isPaidByCard = NO;
//        [self initiatePaymentWithPaypalWithCreditCard:NO withDescription:paymentDescription amount:totalAmount];
        
        [UIUtils alertWithTitle:[NSString stringWithFormat:@"Confirm Payment of %@ ?",_courseFeeLabel.text] message:nil okBtnTitle:@"Yes" cancelBtnTitle:@"No" delegate:self tag:1111];
    }
    else
    {
        [UIUtils alertWithInfoMessage:@"you do not have any balance amount to pay"];
    }
}

- (IBAction)creditCardPaymentButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    if (!_studentDict)
    {
        [UIUtils alertWithInfoMessage:@"Please save student info"];
        return;
    }

    NSString* totalAmount = [_courseFeeLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    if ([totalAmount intValue] > 0)
    {
        [UIUtils alertWithTitle:[NSString stringWithFormat:@"Process payment of %@ ?",_courseFeeLabel.text] message:nil okBtnTitle:@"Yes" cancelBtnTitle:@"No" delegate:self tag:222];
        
//        NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[self.studentDict objectForKey:@"name"],[self.studentDict objectForKey:@"email"],[self.classDict objectForKey:@"classCode"]];
//        _isPaidByCard = YES;
//        [UIUtils handlePaymentWithName:[self.classDict objectForKey:@"className"] amount:totalAmount description:paymentDescription payerEmail:[self.studentDict objectForKey:@"email"]];
//        [self initiatePaymentWithPaypalWithCreditCard:YES withDescription:paymentDescription amount:totalAmount];
    }
    else
    {
        [UIUtils alertWithInfoMessage:@"you do not have any balance amount to pay"];
    }
}

- (IBAction)saveButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    _trim(_firstNameField.text);
    _trim(_lastNameField.text);
    _trim(_addressField.text);
    _trim(_apartmentField.text);
    _trim(_cityField.text);
    _trim(_stateField.text);
    _trim(_zipcodeField.text);
    
    if (_firstNameField.text.length > 0)
    {
        if (_emailField.text.length > 0)
        {
            if ([UIUtils validateEmail:_emailField.text])
            {
                if (self.screenType == kScreenTypeEditStudent)
                {
                    [self editStudentInfoRequest];
                }
                else
                {
                    [self addStudentInfoRequest];
                }
            }
            else
            {
                [UIUtils alertWithErrorMessage:@"Please enter valid email"];
            }
        }
        else
        {
            [UIUtils alertWithErrorMessage:@"Please enter email"];
        }
    }
    else
    {
        [UIUtils alertWithErrorMessage:@"Please enter first name"];
    }
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)scanButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    if (!_studentDict)
    {
        [UIUtils alertWithInfoMessage:@"Please save student info"];
        return;
    }
    
    AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
    if (attendanceVC)
    {
        attendanceVC.studentDict = self.studentDict;
        attendanceVC.classObject = self.classDict;
        attendanceVC.isAttendanceScreen = NO;
        [self.navigationController pushViewController:attendanceVC animated:YES];
    }
}

- (IBAction)cancelButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
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
    if (balance && balance.length > 0)
        _courseFeeLabel.text = [NSString stringWithFormat:@"$%@",balance];
    else
        _courseFeeLabel.text = @"$0.00";
}

- (void) editStudentInfoRequest
{
    NSString* fName = _firstNameField.text;
    NSString* lName = _lastNameField.text.length ? _lastNameField.text : @"";
    NSString* email = _emailField.text;
    NSString* phone = _phoneNumberField.text.length ? _phoneNumberField.text : @"";
    NSString* address = _addressField.text.length ? _addressField.text : @"";
    NSString* apt = _apartmentField.text.length ? _apartmentField.text : @"";
    NSString* city = _cityField.text.length ? _cityField.text : @"";
    NSString* state = _stateField.text.length ? _stateField.text : @"";
    NSString* zip = _zipcodeField.text.length ? _zipcodeField.text : @"";
    NSString* postString = [NSString stringWithFormat:@"&id=%@&first_name=%@&last_name=%@&email=%@&phone=%@&address=%@&apt=%@&city=%@&state=%@&zip=%@&btnUpdateSubmit=submit",[self.studentDict objectForKey:@"id"],fName,lName,email,phone,address,apt,city,state,zip];
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLEditStudentInfo withPostString:postString];
    [conn setRequestType:kRequestTypeEditStudentInfo];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) addStudentInfoRequest
{
    NSString* fName = _firstNameField.text;
    NSString* lName = _lastNameField.text.length ? _lastNameField.text : @"";
    NSString* email = _emailField.text;
    NSString* phone = _phoneNumberField.text.length ? _phoneNumberField.text : @"";
    NSString* address = _addressField.text.length ? _addressField.text : @"";
    NSString* apt = _apartmentField.text.length ? _apartmentField.text : @"";
    NSString* city = _cityField.text.length ? _cityField.text : @"";
    NSString* state = _stateField.text.length ? _stateField.text : @"";
    NSString* zip = _zipcodeField.text.length ? _zipcodeField.text : @"";
    NSString* postString = [NSString stringWithFormat:@"&classId=%@&first_name=%@&last_name=%@&email=%@&phone=%@&address=%@&apt=%@&city=%@&state=%@&zip=%@&btnRegistrationSubmit=submit",[self.classDict objectForKey:@"classId"],fName,lName,email,phone,address,apt,city,state,zip];
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLAddStudentInfo withPostString:postString];
    [conn setRequestType:kRequestTypeAddStudentInfo];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) initiatePaymentWithPaypalWithCreditCard:(BOOL)acceptCreditCard withDescription:(NSString*)description amount:(int)totalAmount
{
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

- (void) updatePaymentDetailsToServer:(PayPalPayment*)paymentInfo
{
    
}

- (void) updatePaymentDetailsToServerWithAmountPaid:(NSString*)amountPaid transactionId:(NSString*)transactionId paymentMethod:(NSString*)paymentMethod
{
    NSString* outstandingBalance = @"0.00";
    
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLUpdatePaymentDetails withPostString:[NSString stringWithFormat:@"&studentId=%@&classId=%@&transactionDate=%@&studentpaidamount=%@&paymentmethod=%@&transactionId=%@&studentOutstandingBalance=%@&totalclassamount=%@&paymentstatus=p&btnPaymentSubmit=submit&courseCodeId=%@",[self.studentDict objectForKey:@"id"],[self.classDict objectForKey:@"classId"],[UIUtils getDateStringOfFormat:kDateFormat],amountPaid,paymentMethod,transactionId,outstandingBalance,[self.classDict objectForKey:@"classPrice"],[self.classDict objectForKey:@"courseCodeId"]]];
    [conn setRequestType:kRequestTypeUpdatePaymentDetails];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) updatePaymentDetailsToServerMadeThroughPaypalHere:(NSDictionary*)paymentInfo
{
    NSString* paymentMethod = [paymentInfo objectForKey:@"Type"];
    
    NSString* outstandingBalance = @"0.00";
    
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLUpdatePaymentDetails withPostString:[NSString stringWithFormat:@"&studentId=%@&classId=%@&transactionDate=%@&studentpaidamount=%@&paymentmethod=%@&transactionId=%@&studentOutstandingBalance=%@&totalclassamount=%@&paymentstatus=p&btnPaymentSubmit=submit&courseCodeId=%@",[self.studentDict objectForKey:@"id"],[self.classDict objectForKey:@"classId"],[UIUtils getDateStringOfFormat:kDateFormat],[paymentInfo objectForKey:@"Tip"],paymentMethod,[paymentInfo objectForKey:@"TxId"],outstandingBalance,[self.classDict objectForKey:@"classPrice"],[self.classDict objectForKey:@"courseCodeId"]]];
    [conn setRequestType:kRequestTypeUpdatePaymentDetails];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
        /*
        if ([handler requestType] == kRequestTypeEditStudentInfo)
        {
            [UIUtils alertWithInfoMessage:@"Updated student info successfully"];
            
//            NSMutableDictionary* stdDict = [NSMutableDictionary dictionary];
//            [stdDict setObject:[self.studentDict objectForKey:@"id"] forKey:@"id"];
//            [stdDict setObject:_firstNameField.text forKey:@"name"];
//            [stdDict setObject:_lastNameField.text forKey:@"lastname"];
//            [stdDict setObject:_emailField.text forKey:@"email"];
//            [stdDict setObject:_phoneNumberField.text forKey:@"phone"];
//            [stdDict setObject:_addressField.text forKey:@"address"];
//            [stdDict setObject:_apartmentField.text forKey:@"apt"];
//            [stdDict setObject:_cityField.text forKey:@"city"];
//            [stdDict setObject:_stateField.text forKey:@"state"];
//            [stdDict setObject:_zipcodeField.text forKey:@"zip"];
//            [stdDict setObject:[self.studentDict objectForKey:@"classBalance"] forKey:@"classBalance"];
            
//            [self.delegate dismissWithStudentInfo:stdDict];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else*/

        if ([handler requestType] == kRequestTypeAddStudentInfo)
        {
            [UIUtils alertWithInfoMessage:@"New student info added sucessfully"];
            _studentDict = [responseDict objectForKey:@"student"];
            [self updateClassInfoUIWithBalance:[self.studentDict objectForKey:@"classBalance"]];
        }
        else if ([handler requestType] == kRequestTypeUpdatePaymentDetails)
        {
            [UIUtils alertWithTitle:@"Info" message:[responseDict objectForKey:@"message"] okBtnTitle:@"Ok" cancelBtnTitle:nil delegate:self tag:111];
        }
        else
        {
            [UIUtils alertWithInfoMessage:@"Student info saved successfully"];
//            if (self.screenType == kScreenTypeNewStudent)
//            {
//                NSMutableDictionary* stdDict = [NSMutableDictionary dictionaryWithDictionary:_studentDict];
//                [stdDict setObject:@"0.00" forKey:@"classBalance"];
//                _studentDict = [NSDictionary dictionaryWithDictionary:stdDict];
//                [self.delegate dismissWithStudentInfo:self.studentDict];
//            }
            [self.navigationController popViewControllerAnimated:YES];
        }
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
    
    //[UIUtils alertWithInfoMessage:[NSString stringWithFormat:@"Payment made successfull with Id - %@",[[[completedPayment confirmation] objectForKey:@"response"] objectForKey:@"id"]]];
    [self dismissViewControllerAnimated:YES completion:nil];

    //details to be sent to server
    [self updatePaymentDetailsToServer:completedPayment];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - openURL notification

- (void) openURLNotification:(NSNotification*)notification
{
//    NSDictionary* dictionary = [UIUtils getDictionaryFromCallbackResponse:(NSURL*)[notification object]];
//    if ([[dictionary objectForKey:@"Type"] rangeOfString:@"Unknown"].length > 0)
//    {
//        [UIUtils alertWithInfoMessage:@"Payment cancelled"];
//    }
//    else
//    {
//        [self updatePaymentDetailsToServerMadeThroughPaypalHere:dictionary];
//    }
    [UIUtils alertWithTitle:@"Was payment processed successfully?" message:nil okBtnTitle:@"Yes" cancelBtnTitle:@"No" delegate:self tag:333];
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1111)
    {
        if (buttonIndex == 1)
        {
            [self updatePaymentDetailsToServerWithAmountPaid:[_courseFeeLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""] transactionId:@"Check" paymentMethod:@"Check"];
        }
    }
    else if (alertView.tag == 2222)
    {
        if (buttonIndex == 1)
        {
            [self updatePaymentDetailsToServerWithAmountPaid:[_courseFeeLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""] transactionId:@"Cash" paymentMethod:@"Cash"];
        }
    }
    else if (alertView.tag == 111)
    {
        [self updateClassInfoUIWithBalance:nil];
    }
    else if (alertView.tag == 222)
    {
        if (buttonIndex == 1)
        {
            NSString* totalAmount = [_courseFeeLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:totalAmount forKey:@"Tip"];
            [dictionary setObject:@"Paypal here" forKey:@"Type"];
            [dictionary setObject:@"paypalhere_txid" forKey:@"TxId"];
            self.paymentDetails = dictionary;
            
            if ([totalAmount intValue] > 0)
            {
                NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[self.studentDict objectForKey:@"name"],[self.studentDict objectForKey:@"email"],[self.classDict objectForKey:@"classCode"]];
                _isPaidByCard = YES;
                
                [UIUtils handlePaymentWithName:[self.classDict objectForKey:@"className"] amount:totalAmount description:paymentDescription payerEmail:[self.studentDict objectForKey:@"email"]];
            }

            //[self updatePaymentDetailsToServerMadeThroughPaypalHere:dictionary];
        }
    }
    else if (alertView.tag == 333)
    {
        if (buttonIndex == 1)
        {
            [self updatePaymentDetailsToServerMadeThroughPaypalHere:self.paymentDetails];
        }
    }
}

@end
