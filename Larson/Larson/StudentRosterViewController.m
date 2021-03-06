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
#import "AppDelegate.h"

@interface StudentRosterViewController ()

@property (nonatomic, strong) NSMutableArray* studentCheckedInList;
@property (nonatomic, strong) NSMutableArray* studentNonCheckedInList;
@property (nonatomic, assign) BOOL addNewStudent;
@property (nonatomic, strong) NSDictionary* paymentDetails;

@end

@implementation StudentRosterViewController

@synthesize addNewStudent = _addNewStudent;

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
    
    if (!_studentCheckedInList)
        _studentCheckedInList = [[NSMutableArray alloc] init];
    
    if (!_studentNonCheckedInList)
        _studentNonCheckedInList = [[NSMutableArray alloc] init];
    
    if (!_rowIndexPath)
        _rowIndexPath = [[NSIndexPath alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [PayPalMobile preconnectWithEnvironment:kPayPalEnvironment];
    [self classDetailRequestWithClassId:[self.classObject objectForKey:@"classId"]];
    
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

- (void) setInterface
{
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
        [self.studentNonCheckedInList removeAllObjects];
        [self.studentNonCheckedInList addObjectsFromArray:_sortedStudentsList];
        [self sortStudentRosterList];
    }
    else
    {
        _sortedStudentsList = [[NSArray alloc] init];
        [UIUtils alertWithInfoMessage:@"No students registered for this class"];
    }
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cashButtonAction:(id)sender
{
    [_amountField resignFirstResponder];
    NSString* amount = [_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    int totalAmount = [amount intValue];
    if (totalAmount > 0)
    {
        NSDictionary* studentDict;
        if (_rowIndexPath.section == 0)
        {
            studentDict = [self.studentNonCheckedInList objectAtIndex:_rowIndexPath.row];
        }
        else
        {
            studentDict = [self.studentCheckedInList objectAtIndex:_rowIndexPath.row];
        }
        //NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
        _isPaidByCard = NO;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Confirm Payment of %@ ?",_amountField.text] message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 1111;
        [alert show];
//        [self initiatePaymentWithPaypalWithCreditCard:NO withDescription:paymentDescription];
    }
    else
    {
        [UIUtils alertWithErrorMessage:@"Please enter a valid amount"];
    }
}

- (IBAction)checkButtonAction:(id)sender
{
    [_amountField resignFirstResponder];
    NSString* amount = [_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    int totalAmount = [amount intValue];
    if (totalAmount > 0)
    {
        NSDictionary* studentDict;
        if (_rowIndexPath.section == 0)
        {
            studentDict = [self.studentNonCheckedInList objectAtIndex:_rowIndexPath.row];
        }
        else
        {
            studentDict = [self.studentCheckedInList objectAtIndex:_rowIndexPath.row];
        }
        //NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
        _isPaidByCard = NO;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Confirm Payment of %@ ?",_amountField.text] message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 2222;
        [alert show];
        //        [self initiatePaymentWithPaypalWithCreditCard:NO withDescription:paymentDescription];
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
        NSDictionary* studentDict;
        if (_rowIndexPath.section == 0)
        {
            studentDict = [self.studentNonCheckedInList objectAtIndex:_rowIndexPath.row];
        }
        else
        {
            studentDict = [self.studentCheckedInList objectAtIndex:_rowIndexPath.row];
        }
       // NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
        _isPaidByCard = YES;
//        [self initiatePaymentWithPaypalWithCreditCard:YES withDescription:paymentDescription];
        
        [_takePaymentView removeFromSuperview];
        
        [UIUtils alertWithTitle:[NSString stringWithFormat:@"Process payment of %@ ?",_amountField.text] message:nil okBtnTitle:@"Yes" cancelBtnTitle:@"No" delegate:self tag:222];

        //[UIUtils handlePaymentWithName:[self.classObject objectForKey:@"className"] amount:amount description:paymentDescription payerEmail:[studentDict objectForKey:@"email"]];
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
    _addNewStudent = YES;
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

    [self sortStudentRosterList];
}

- (IBAction)sortByBalanceButtonAction:(id)sender
{
    [_sortByBalanceButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];
    [_sortByNameButton setImage:nil forState:UIControlStateNormal];

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"classBalance"                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    _sortedStudentsList = [[NSArray alloc] initWithArray:[[self.classDetailObject objectForKey:@"students"] sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self sortStudentRosterList];
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

- (void) editButtonAction:(UIButton*)sender
{
    _addNewStudent = NO;
    _rowIndexPath = [sender indexPath];
    StudentInfoViewController* editStudentInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentInfoViewID];
    if (editStudentInfoVC)
    {
        editStudentInfoVC.screenType = kScreenTypeEditStudent;
        editStudentInfoVC.classDict = self.classObject;
        editStudentInfoVC.delegate = self;
        if (sender.indexPath.section == 0)
        {
            editStudentInfoVC.studentDict = [self.studentNonCheckedInList objectAtIndex:[[sender indexPath] row]];
        }
        else
        {
            editStudentInfoVC.studentDict = [self.studentCheckedInList objectAtIndex:[[sender indexPath] row]];
        }

        [self.navigationController pushViewController:editStudentInfoVC animated:YES];
    }
}

- (void) paymentButtonAction:(id)sender
{
    _rowIndexPath = [sender indexPath];
    NSDictionary* studentDict;
    if (_rowIndexPath.section == 0)
    {
        studentDict = [self.studentNonCheckedInList objectAtIndex:_rowIndexPath.row];
    }
    else
    {
        studentDict = [self.studentCheckedInList objectAtIndex:_rowIndexPath.row];
    }

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

- (void) scanButtonAction:(UIButton*)sender
{
    AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
    if (attendanceVC)
    {
        attendanceVC.classObject = self.classObject;
        attendanceVC.classDetailObject = self.classDetailObject;
        if (sender.indexPath.section == 0)
        {
            attendanceVC.studentDict = [self.studentNonCheckedInList objectAtIndex:sender.indexPath.row];
        }
        else
        {
            attendanceVC.studentDict = [self.studentCheckedInList objectAtIndex:sender.indexPath.row];
        }
        attendanceVC.isAttendanceScreen = NO;
        [self.navigationController pushViewController:attendanceVC animated:YES];
    }
}

- (void) checkInButtonAction:(UIButton*)sender
{
    sender.selected = !sender.selected;

    if (sender.selected)
    {
        NSDictionary* studentDict = [self.studentNonCheckedInList objectAtIndex:[[sender indexPath] row]];
        NSString* checkInString = [[NSString alloc] initWithFormat:@"%@_%@",[self.classObject objectForKey:@"classId"],[studentDict objectForKey:@"id"]];
        [[_appDelegate checkInList] addObject:checkInString];
        [self.studentCheckedInList addObject:studentDict];
        [self.studentNonCheckedInList removeObject:studentDict];
    }
    else
    {
        NSDictionary* studentDict = [self.studentCheckedInList objectAtIndex:[[sender indexPath] row]];
        NSString* checkInString = [[NSString alloc] initWithFormat:@"%@_%@",[self.classObject objectForKey:@"classId"],[studentDict objectForKey:@"id"]];
        [[_appDelegate checkInList] removeObject:checkInString];
        [self.studentNonCheckedInList addObject:studentDict];
        [self.studentCheckedInList removeObject:studentDict];
    }
    
    NSLog(@"%@",[_appDelegate checkInList]);
    
    [_tableView reloadData];
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
    
}

- (void) updatePaymentDetailsToServerWithAmountPaid:(NSString*)amountPaid transactionId:(NSString*)transactionId paymentMethod:(NSString*)paymentMethod
{
    NSDictionary* studentDict;
    if (_rowIndexPath.section == 0)
    {
        studentDict = [self.studentNonCheckedInList objectAtIndex:_rowIndexPath.row];
    }
    else
    {
        studentDict = [self.studentCheckedInList objectAtIndex:_rowIndexPath.row];
    }
    NSString* outstandingAmount = @"0.00";
    if ([[studentDict objectForKey:@"classBalance"] intValue] - amountPaid.intValue > 0)
        outstandingAmount = [NSString stringWithFormat:@"%d",[[studentDict objectForKey:@"classBalance"] intValue] - amountPaid.intValue];

    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLUpdatePaymentDetails withPostString:[NSString stringWithFormat:@"&studentId=%@&classId=%@&transactionDate=%@&studentpaidamount=%@&paymentmethod=%@&transactionId=%@&studentOutstandingBalance=%@&totalclassamount=%@&paymentstatus=p&btnPaymentSubmit=submit&courseCodeId=%@",[studentDict objectForKey:@"id"],[self.classObject objectForKey:@"classId"],[UIUtils getDateStringOfFormat:kDateFormat],amountPaid,paymentMethod,transactionId,outstandingAmount,[self.classObject objectForKey:@"classPrice"],[self.classObject objectForKey:@"courseCodeId"]]];
    
    [conn setRequestType:kRequestTypeUpdatePaymentDetails];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) updatePaymentDetailsToServerMadeThroughPaypalHere:(NSDictionary*)paymentInfo
{
    NSDictionary* studentDict;
    if (_rowIndexPath.section == 0)
    {
        studentDict = [self.studentNonCheckedInList objectAtIndex:_rowIndexPath.row];
    }
    else
    {
        studentDict = [self.studentCheckedInList objectAtIndex:_rowIndexPath.row];
    }
    NSString* paymentMethod = [paymentInfo objectForKey:@"Type"];
    NSString* outstandingAmount = @"0.00";
    if ([[studentDict objectForKey:@"classBalance"] intValue] - [[paymentInfo objectForKey:@"Tip"] intValue] > 0)
        outstandingAmount = [NSString stringWithFormat:@"%d",[[studentDict objectForKey:@"classBalance"] intValue] - [[paymentInfo objectForKey:@"Tip"] intValue]];

    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLUpdatePaymentDetails withPostString:[NSString stringWithFormat:@"&studentId=%@&classId=%@&transactionDate=%@&studentpaidamount=%@&paymentmethod=%@&transactionId=%@&studentOutstandingBalance=%@&totalclassamount=%@&paymentstatus=p&btnPaymentSubmit=submit&courseCodeId=%@",[studentDict objectForKey:@"id"],[self.classObject objectForKey:@"classId"],[UIUtils getDateStringOfFormat:kDateFormat],[paymentInfo objectForKey:@"Tip"],paymentMethod,[paymentInfo objectForKey:@"TxId"],outstandingAmount,[self.classObject objectForKey:@"classPrice"],[self.classObject objectForKey:@"courseCodeId"]]];

    [conn setRequestType:kRequestTypeUpdatePaymentDetails];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) classDetailRequestWithClassId:(NSString*)classId
{
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLClassDetail withPostString:[NSString stringWithFormat:@"&classId=%@",classId]];
    [conn setRequestType:kRequestTypeClassDetail];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) sortStudentRosterList
{
    NSString* classIdString = [NSString stringWithFormat:@"%@_",[self.classObject objectForKey:@"classId"]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self contains %@",classIdString];
    NSArray* filteredCheckInList = [[_appDelegate checkInList] filteredArrayUsingPredicate:predicate];

    if (filteredCheckInList.count > 0)
    {
        [self.studentCheckedInList removeAllObjects];
        [self.studentNonCheckedInList removeAllObjects];

        for (NSDictionary* studentDict in _sortedStudentsList)
        {
            for (NSString* checkInId in filteredCheckInList)
            {
                NSString* checkInKey = [NSString stringWithFormat:@"%@_%@",[self.classObject objectForKey:@"classId"],[studentDict objectForKey:@"id"]];
                if ([checkInId isEqualToString:checkInKey])
                {
                    [self.studentCheckedInList addObject:studentDict];
                    break;
                }
            }
        }
        
        for (NSDictionary* studentDict in _sortedStudentsList)
        {
            NSPredicate* predicate1 = [NSPredicate predicateWithFormat:@"self contains %@",[studentDict objectForKey:@"id"]];
            NSArray* filteredCheckInList1 = [self.studentCheckedInList filteredArrayUsingPredicate:predicate1];
            
            if (filteredCheckInList1.count == 0)
                [self.studentNonCheckedInList addObject:studentDict];
        }
    }
    
    [_tableView reloadData];
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.studentNonCheckedInList count];
    }
    else
    {
        return [self.studentCheckedInList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
    {
        return 37;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView* view2 = [[UIView alloc] initWithFrame:CGRectZero];
        return view2;
    }
    else
    {
        UIView* view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 37)];
        UIImageView* iView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 37)];
        iView.image = [UIImage imageNamed:@"bg_nav.png"];
        [view1 addSubview:iView];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 768, 37)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
        label.text = @"Checked In";
        [view1 addSubview:label];
        return view1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StudentRosterCell* cell;
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"StudentRosterCell";
        
       cell = (StudentRosterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    else
    {
        static NSString *CellIdentifier = @"StudentRosterCell2";
        
       cell = (StudentRosterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    cell.editButton.indexPath = indexPath;
    cell.paymentButton.indexPath = indexPath;
    cell.scanButton.indexPath = indexPath;
    cell.checkButton.indexPath = indexPath;
    [cell.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.paymentButton addTarget:self action:@selector(paymentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.scanButton addTarget:self action:@selector(scanButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.checkButton addTarget:self action:@selector(checkInButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary* studentDict;
    if (indexPath.section == 0)
    {
        studentDict = [self.studentNonCheckedInList objectAtIndex:indexPath.row];
        cell.checkButton.selected = NO;
    }
    else
    {
        studentDict = [self.studentCheckedInList objectAtIndex:indexPath.row];
        cell.checkButton.selected = YES;
    }

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

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
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
    
    if (_addNewStudent)
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
        if ([handler requestType] == kRequestTypeClassDetail)
        {
            _classDetailObject = nil;
            [self.studentNonCheckedInList removeAllObjects];
            [self.studentCheckedInList removeAllObjects];
            _classDetailObject = [[NSDictionary alloc] initWithDictionary:responseDict];
            [self setInterface];
        }
        else if ([handler requestType] == kRequestTypeUpdatePaymentDetails)
        {
//            [UIUtils alertWithTitle:@"Info" message:[responseDict objectForKey:@"message"] okBtnTitle:@"Ok" cancelBtnTitle:nil delegate:self tag:111];
            [UIUtils alertWithTitle:@"Info" message:[responseDict objectForKey:@"message"] okBtnTitle:@"Ok" cancelBtnTitle:nil delegate:self tag:111];
        }
        else
        {
            [UIUtils alertWithTitle:@"Info" message:[responseDict objectForKey:@"message"] delegate:self];
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


#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1111)
    {
        if (buttonIndex == 1)
        {
            [self updatePaymentDetailsToServerWithAmountPaid:[_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""] transactionId:@"Cash" paymentMethod:@"Cash"];
        }
    }
    else if (alertView.tag == 2222)
    {
        if (buttonIndex == 1)
        {
            [self updatePaymentDetailsToServerWithAmountPaid:[_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""] transactionId:@"Check" paymentMethod:@"Check"];
        }
    }
    else if (alertView.tag == 111)
    {
        [self classDetailRequestWithClassId:[self.classObject objectForKey:@"classId"]];
    }
    else if (alertView.tag == 222)
    {
        if (buttonIndex == 1)
        {
            NSString* amount = [_amountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
            
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:amount forKey:@"Tip"];
            [dictionary setObject:@"Paypal here" forKey:@"Type"];
            [dictionary setObject:@"paypalhere_txid" forKey:@"TxId"];
            self.paymentDetails = dictionary;
            
            NSDictionary* studentDict;
            if (_rowIndexPath.section == 0)
            {
                studentDict = [self.studentNonCheckedInList objectAtIndex:_rowIndexPath.row];
            }
            else
            {
                studentDict = [self.studentCheckedInList objectAtIndex:_rowIndexPath.row];
            }
            NSString* paymentDescription = [NSString stringWithFormat:@"%@_%@_%@",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"email"],[self.classObject objectForKey:@"classCode"]];
            _isPaidByCard = YES;
            [UIUtils handlePaymentWithName:[self.classObject objectForKey:@"className"] amount:amount description:paymentDescription payerEmail:[studentDict objectForKey:@"email"]];
//            [self updatePaymentDetailsToServerMadeThroughPaypalHere:dictionary];
        }
    }
    else if (alertView.tag == 333)
    {
        if (buttonIndex == 1)
        {
            [self updatePaymentDetailsToServerMadeThroughPaypalHere:self.paymentDetails];
        }
    }
    else
    {
        [self classDetailRequestWithClassId:[self.classObject objectForKey:@"classId"]];
        [_takePaymentView removeFromSuperview];
    }
}

#pragma mark - openURL notification

- (void) openURLNotification:(NSNotification*)notification
{
    [_takePaymentView removeFromSuperview];

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

@end
