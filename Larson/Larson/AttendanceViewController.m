//
//  AttendanceViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "AttendanceViewController.h"

@interface AttendanceViewController ()

@end

@implementation AttendanceViewController

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
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsZBarControls = NO;
    ZBarImageScanner *scanner = reader.scanner;
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    reader.view.frame = CGRectMake(0, 0, 558, 445);
    [_scanView addSubview:reader.view];
    
    _successImageView.hidden = YES;
    
    _unitList = [[NSArray alloc] initWithObjects:@"Unit 1",@"Unit 2",@"Unit 3",@"Unit 4",@"Unit 5",@"Unit 6",@"Unit 7", nil];
    [_dropdownTableView reloadData];
    
    _unitField.text = [_unitList objectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterEmailAddressButtonAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Enter your email" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (void) registerAttendanceWithEmail:(NSString*)email
{
    if ([UIUtils validateEmail:email])
    {
        HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLAttendanceViaEmail withPostString:[NSString stringWithFormat:@"&classId=%@&email=%@&btnEmailAttendanceSubmit=submit",[self.classDict objectForKey:@"classId"],email]];
        [conn setRequestType:kRequestTypeSubmitAttendanceViaEmail];
        [conn setDelegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else
    {
        [UIUtils alertWithErrorMessage:@"Please enter a valid email"];
    }
}

- (void) showDropdownView:(BOOL)show
{
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         CGRect frame = _dropdownTableView.frame;
         frame.size.height = show ?  320 : 0;
         _dropdownTableView.frame = frame;
     }                     completion:^(BOOL finished)
     {
     }];
}

#pragma mark - ZBarReaderDelegate

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry
{
    NSLog(@"Q-R code text not found");
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    NSLog(@"Scanned text %@",symbol.data);
    
    [UIUtils alertWithInfoMessage:[NSString stringWithFormat:@"Scanned text %@",symbol.data]];
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"%@",[alertView textFieldAtIndex:0].text);
        
        [self registerAttendanceWithEmail:[[alertView textFieldAtIndex:0] text]];
    }
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
        [_successImageView setHidden:NO];
        
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
    }
    else
    {
        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
    }
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showDropdownView:YES];
    return NO;
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_unitList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UnitCell";
    
    UITableViewCell* cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.row == _selectedUnitIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = [_unitList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *prevSelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedUnitIndex inSection:0]];
    prevSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    _selectedUnitIndex = [indexPath row];
    
    _unitField.text = [_unitList objectAtIndex:_selectedUnitIndex];
    
    [self performSelector:@selector(showDropdownView:) withObject:nil afterDelay:0.2];
}

@end
