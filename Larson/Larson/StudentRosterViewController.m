//
//  StudentRosterViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "StudentRosterViewController.h"
#import "StudentRosterCell.h"
#import "StudentInfoViewController.h"
#import "AttendanceViewController.h"
#import "AddExistingStudentViewController.h"

@interface StudentRosterViewController ()

@end

@implementation StudentRosterViewController

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
    _tableView.backgroundColor = UIColorFromHEX(kCommonBGColor);
    
    [_takePaymentView removeFromSuperview];
    
    _courseNameLabel.text = [self.classObject objectForKey:@"className"];
    NSString* studentEnrolled = @"0";
    if ([self.classDetailObject objectForKey:@"classStudentEnrolledTotal"])
        studentEnrolled = [self.classDetailObject objectForKey:@"classStudentEnrolledTotal"];
    
    NSString* totalStudents = @"0";
    if ([self.classDetailObject objectForKey:@"classStudentTotal"])
        totalStudents = [self.classDetailObject objectForKey:@"classStudentTotal"];
    _courseCodeLabel.text = [NSString stringWithFormat:@"%@ • Total Students %@/%@",[self.classObject objectForKey:@"classCode"],studentEnrolled,totalStudents];
    
    [_sortByBalanceButton setImage:nil forState:UIControlStateNormal];
    [_sortByNameButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];
    
    if ([[self.classDetailObject objectForKey:@"students"] isKindOfClass:[NSArray class]])
    {
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"                                                                 ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        _sortedStudentsList = [[NSArray alloc] initWithArray:[[self.classDetailObject objectForKey:@"students"] sortedArrayUsingDescriptors:sortDescriptors]];
    }
    else
    {
        _sortedStudentsList = [[NSArray alloc] init];
        [UIUtils alertWithInfoMessage:@"No students registered for this class"];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [PayPalMobile preconnectWithEnvironment:kPayPalEnvironment];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cashCheckButtonAction:(id)sender
{
    [_amountField resignFirstResponder];
    NSString* amount = [_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    int totalAmount = [amount intValue];
    if (totalAmount > 0)
    {
        NSDictionary* studentDict = [_sortedStudentsList objectAtIndex:_rowIndex];
        NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
        _isPaidByCard = NO;
        [self initiatePaymentWithPaypalWithCreditCard:NO withDescription:paymentDescription];
    }
    else
    {
        [UIUtils alertWithErrorMessage:@"Please enter a valid amount"];
    }
}

- (IBAction)creditCardButtonAction:(id)sender
{
    [_amountField resignFirstResponder];
    NSString* amount = [_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    int totalAmount = [amount intValue];
    if (totalAmount > 0)
    {
        NSDictionary* studentDict = [_sortedStudentsList objectAtIndex:_rowIndex];
        NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
        _isPaidByCard = YES;
        [self initiatePaymentWithPaypalWithCreditCard:YES withDescription:paymentDescription];
    }
    else
    {
        [UIUtils alertWithErrorMessage:@"Please enter a valid amount"];
    }
}

- (IBAction)takePaymentTapGestureAction:(id)sender
{
    [_takePaymentView removeFromSuperview];
    [self.view endEditing:YES];
}

- (IBAction)addNewStudentButtonAction:(id)sender
{
    _rowIndex = -1;
    
    StudentInfoViewController* addStudentInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentInfoViewID];
    if (addStudentInfoVC)
    {
        addStudentInfoVC.screenType = kScreenTypeNewStudent;
        addStudentInfoVC.classDict = self.classObject;
        addStudentInfoVC.delegate = self;
        [self.navigationController pushViewController:addStudentInfoVC animated:YES];
    }
}

- (IBAction)startAttendanceButtonAction:(id)sender
{
    if ([[[self.classObject objectForKey:@"units"] lastObject] isKindOfClass:[NSDictionary class]])
    {
        AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
        if (attendanceVC)
        {
            attendanceVC.classDetailObject = self.classDetailObject;
            attendanceVC.classObject = self.classObject;
            attendanceVC.isAttendanceScreen = YES;
            [self.navigationController pushViewController:attendanceVC animated:YES];
        }
    }
    else
    {
        [UIUtils alertWithInfoMessage:@"No units available, please try later"];
    }
}

- (IBAction)sortByNameButtonAction:(id)sender
{
    [_sortByBalanceButton setImage:nil forState:UIControlStateNormal];
    [_sortByNameButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    _sortedStudentsList = [[NSArray alloc] initWithArray:[[self.classDetailObject objectForKey:@"students"] sortedArrayUsingDescriptors:sortDescriptors]];

    [_tableView reloadData];
}

- (IBAction)sortByBalanceButtonAction:(id)sender
{
    [_sortByBalanceButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];
    [_sortByNameButton setImage:nil forState:UIControlStateNormal];

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"classBalance"                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    _sortedStudentsList = [[NSArray alloc] initWithArray:[[self.classDetailObject objectForKey:@"students"] sortedArrayUsingDescriptors:sortDescriptors]];
    
    [_tableView reloadData];
}

- (IBAction)addCurrentStudentButtonAction:(id)sender
{
    AddExistingStudentViewController* addExistingStudentVC = [self.storyboard instantiateViewControllerWithIdentifier:kAddStudentViewID];
    if (addExistingStudentVC)
    {
        addExistingStudentVC.classObject = self.classObject;
        [self.navigationController pushViewController:addExistingStudentVC animated:YES];
    }
}

#pragma mark -

- (void) editButtonAction:(id)sender
{
    _rowIndex = [sender tag];
    StudentInfoViewController* editStudentInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentInfoViewID];
    if (editStudentInfoVC)
    {
        editStudentInfoVC.screenType = kScreenTypeEditStudent;
        editStudentInfoVC.studentDict = [_sortedStudentsList objectAtIndex:[sender tag]];
        editStudentInfoVC.classDict = self.classObject;
        editStudentInfoVC.delegate = self;
        [self.navigationController pushViewController:editStudentInfoVC animated:YES];
    }
}

- (void) paymentButtonAction:(id)sender
{
    _rowIndex = [sender tag];
    NSDictionary* studentDict = [_sortedStudentsList objectAtIndex:_rowIndex];
    _amountField.text = [NSString stringWithFormat:@"$%@",[studentDict objectForKey:@"classBalance"]];
    
    if ([[studentDict objectForKey:@"classBalance"] intValue] > 0)
    {
        [self.view addSubview:_takePaymentView];
    }
    else
    {
        [UIUtils alertWithInfoMessage:@"You do not have balance to pay"];
    }
}

- (void) scanButtonAction:(id)sender
{
    AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
    if (attendanceVC)
    {
        attendanceVC.classObject = self.classObject;
        attendanceVC.classDetailObject = self.classDetailObject;
        attendanceVC.studentDict = [_sortedStudentsList objectAtIndex:[sender tag]];
        attendanceVC.isAttendanceScreen = NO;
        [self.navigationController pushViewController:attendanceVC animated:YES];
    }
}

- (void) initiatePaymentWithPaypalWithCreditCard:(BOOL)acceptCreditCard withDescription:(NSString*)description
{
    NSString* amount = [_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
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
    
    if (!payment.processable)
    {
        [UIUtils alertWithErrorMessage:@"Unable to process your payment, please try later"];
    }
    
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
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

- (void) updatePaymentDetailsToServer:(PayPalPayment*)paymentInfo
{
    NSDictionary* studentDict = [_sortedStudentsList objectAtIndex:_rowIndex];
    NSString* paymentMethod = @"Credit";
    if (!_isPaidByCard)
        paymentMethod = @"Cash";
    NSString* outstandingAmount = @"0.00";
    if ([[studentDict objectForKey:@"classBalance"] intValue] - paymentInfo.amount.intValue > 0)
        outstandingAmount = [NSString stringWithFormat:@"%d",[[studentDict objectForKey:@"classBalance"] intValue] - paymentInfo.amount.intValue];
    HttpConnection* conn;
    if (outstandingAmount.intValue > 0)
    {
        conn = [[HttpConnection alloc] initWithServerURL:kSubURLUpdatePartialPayments withPostString:[NSString stringWithFormat:@"&studentId=%@&classId=%@&transactionDate=%@&studentpaidamount=%@&paymentmethod=%@&transactionId=%@&studentOutstandingBalance=%@&totalclassamount=%@&paymentstatus=p&btnPartialSubmit=submit",[studentDict objectForKey:@"id"],[self.classObject objectForKey:@"classId"],[UIUtils getDateStringOfFormat:kDateFormat],paymentInfo.amount.stringValue,paymentMethod,[[[paymentInfo confirmation] objectForKey:@"response"] objectForKey:@"id"],outstandingAmount,[self.classObject objectForKey:@"classPrice"]]];
    }
    else
    {
        conn = [[HttpConnection alloc] initWithServerURL:kSubURLUpdatePaymentDetails withPostString:[NSString stringWithFormat:@"&studentId=%@&classId=%@&transactionDate=%@&studentpaidamount=%@&paymentmethod=%@&transactionId=%@&studentOutstandingBalance=%@&totalclassamount=%@&paymentstatus=p&btnPaymentSubmit=submit",[studentDict objectForKey:@"id"],[self.classObject objectForKey:@"classId"],[UIUtils getDateStringOfFormat:kDateFormat],paymentInfo.amount.stringValue,paymentMethod,[[[paymentInfo confirmation] objectForKey:@"response"] objectForKey:@"id"],outstandingAmount,[self.classObject objectForKey:@"classPrice"]]];
    }
    [conn setRequestType:kRequestTypeUpdatePaymentDetails];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sortedStudentsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StudentRosterCell";
    
    StudentRosterCell* cell = (StudentRosterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.editButton.tag = indexPath.row;
    cell.paymentButton.tag = indexPath.row;
    cell.scanButton.tag = indexPath.row;
    [cell.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.paymentButton addTarget:self action:@selector(paymentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.scanButton addTarget:self action:@selector(scanButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary* studentDict = [_sortedStudentsList objectAtIndex:indexPath.row];
    cell.firstNameLabel.text = [studentDict objectForKey:@"name"];
    if ([studentDict objectForKey:@"lastname"])
        cell.lastNameLabel.text = [studentDict objectForKey:@"lastname"];
    else
        cell.lastNameLabel.text = @"";
    cell.emailLabel.text = [studentDict objectForKey:@"email"];
    cell.addressLabel.text = [studentDict objectForKey:@"address"];
    cell.phoneNumberLabel.text = [studentDict objectForKey:@"phone"];
    if ([[studentDict objectForKey:@"classBalance"] length] > 0)
        cell.balanceAmountLabel.text = [NSString stringWithFormat:@"$%@",[studentDict objectForKey:@"classBalance"]];
    else
        cell.balanceAmountLabel.text = @"$0.00";
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - StudentRosterViewControllerDelegate

- (void) dismissWithStudentInfo:(NSDictionary*)studentInfo
{
    NSMutableArray* studentsList;
    if ([[self.classDetailObject objectForKey:@"students"] isKindOfClass:[NSArray class]])
    {
        studentsList = [NSMutableArray arrayWithArray:[self.classDetailObject objectForKey:@"students"]];
    }
    else
        studentsList = [[NSMutableArray alloc] init];
    
    if (_rowIndex == -1)
    {
        [studentsList addObject:studentInfo];
    }
    else
    {
        NSMutableArray *filteredarray = [NSMutableArray arrayWithArray:[studentsList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [studentInfo objectForKey:@"id"]]]];
        NSInteger index = [studentsList indexOfObject:[filteredarray lastObject]];
        [studentsList replaceObjectAtIndex:index withObject:studentInfo];
    }
    
    NSMutableDictionary* classDetailDict = [NSMutableDictionary dictionaryWithDictionary:self.classDetailObject];
    [classDetailDict setObject:studentsList forKey:@"students"];
    self.classDetailObject = [NSDictionary dictionaryWithDictionary:classDetailDict];

    [self sortByNameButtonAction:nil];
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
        [UIUtils alertWithInfoMessage:[responseDict objectForKey:@"message"]];
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
    
//    [UIUtils alertWithInfoMessage:[NSString stringWithFormat:@"Payment made successfull with Id - %@",[[[completedPayment confirmation] objectForKey:@"response"] objectForKey:@"id"]]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [_takePaymentView removeFromSuperview];

    //details to be sent to server
    [self updatePaymentDetailsToServer:completedPayment];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
