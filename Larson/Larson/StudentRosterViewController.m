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
    _tableView.contentInset = UIEdgeInsetsMake(-35, 0, -30, 0);
    
    [_takePaymentView removeFromSuperview];
    
    _courseNameLabel.text = [self.classObject objectForKey:@"className"];
    _courseCodeLabel.text = [NSString stringWithFormat:@"%@ • Total Students %@/%@",[self.classObject objectForKey:@"classCode"],[self.classDetailObject objectForKey:@"classStudentEnrolledTotal"],[self.classDetailObject objectForKey:@"classStudentTotal"]];
    
    [_sortByBalanceButton setImage:nil forState:UIControlStateNormal];
    [_sortByNameButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    _sortedStudentsList = [[NSArray alloc] initWithArray:[[self.classDetailObject objectForKey:@"students"] sortedArrayUsingDescriptors:sortDescriptors]];
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
    NSDictionary* studentDict = [_sortedStudentsList objectAtIndex:[sender tag]];
    NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
    [self initiatePaymentWithPaypalWithCreditCard:NO withDescription:paymentDescription];
}

- (IBAction)creditCardButtonAction:(id)sender
{
    NSDictionary* studentDict = [_sortedStudentsList objectAtIndex:[sender tag]];
    NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
    [self initiatePaymentWithPaypalWithCreditCard:YES withDescription:paymentDescription];
}

- (IBAction)takePaymentTapGestureAction:(id)sender
{
    [_takePaymentView removeFromSuperview];
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
    AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
    if (attendanceVC)
    {
        [self.navigationController pushViewController:attendanceVC animated:YES];
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
    [self.view addSubview:_takePaymentView];
}

- (void) scanButtonAction:(id)sender
{
    AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
    if (attendanceVC)
    {
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
    NSMutableArray* studentsList = [NSMutableArray arrayWithArray:[self.classDetailObject objectForKey:@"students"]];
    
    if (_rowIndex == -1)
    {
//        [studentsList addObject:studentInfo];
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

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment
{
    NSLog(@"PayPal Payment Success!");
    NSLog(@"PayPal Payment description %@",[completedPayment description]);
    NSLog(@"PayPal Payment confirmation %@",[completedPayment confirmation]);
    
    [UIUtils alertWithInfoMessage:[NSString stringWithFormat:@"Payment made successfull with Id - %@",[[[completedPayment confirmation] objectForKey:@"response"] objectForKey:@"id"]]];
    //details to be sent to server
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [_takePaymentView removeFromSuperview];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController
{
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
