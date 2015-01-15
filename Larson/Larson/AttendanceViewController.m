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
    
    _successImageView.hidden = YES;
    
    [self setInterface];
    
    ZBarImageScanner * scanner = [ZBarImageScanner new];
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    _readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    _readerView.trackingColor = [UIColor redColor];
    _readerView.readerDelegate = self;
    _readerView.tracksSymbols = YES;
    _readerView.device = [self frontCamera];
    
    _readerView.frame = CGRectMake(0,0,558,445);
    _readerView.torchMode = 0;
    [_scanView addSubview:_readerView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_readerView start];
}

- (void) setInterface
{
    if (!self.isAttendanceScreen)
    {
        _screenTitleLabel.text = @"Scan Card";
        if ([self.studentDict objectForKey:@"lastname"])
            _courseNameLabel.text = [NSString stringWithFormat:@"• %@ %@ •",[self.studentDict objectForKey:@"name"],[self.studentDict objectForKey:@"lastname"]];
        else
            _courseNameLabel.text = [self.studentDict objectForKey:@"name"];
        _unitField.hidden = YES;
        _dropdownTableView.hidden = YES;
        _forgetCardLabel.hidden = YES;
        _enterEmailButton.hidden = YES;
        _dropdownTableView.delegate = nil;
        _dropdownTableView.dataSource = nil;
    }
    else
    {
        _dropdownTableView.delegate = self;
        _dropdownTableView.dataSource = self;
        if (_isFromClasses)
            _courseNameLabel.text = [self.classObject objectForKey:@"classPrefix"];
        else
            _courseNameLabel.text = [self.classObject objectForKey:@"className"];

        if ([[[self.classObject objectForKey:@"units"] lastObject] isKindOfClass:[NSDictionary class]])
        {
            _selectedUnitIndex = 0;
            _unitField.text = [[[self.classObject objectForKey:@"units"] objectAtIndex:0] objectForKey:@"unitTitle"];
            [_dropdownTableView reloadData];
        }
        else
        {
            _selectedUnitIndex = -1;
            _unitField.text = @"Units not available";
        }
    }
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
        NSString* unitId = @"na";
        if (_selectedUnitIndex > -1)
            unitId = [[[self.classObject objectForKey:@"units"] objectAtIndex:_selectedUnitIndex] objectForKey:@"unitId"];
        
        HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLAttendanceViaEmail withPostString:[NSString stringWithFormat:@"&classId=%@&email=%@&unitId=%@&btnEmailAttendanceSubmit=submit&dateOfAttendance=%@&courseCodeId=%@",[self.classObject objectForKey:@"classId"],email,unitId,[UIUtils getDateStringOfFormat:kDateFormat],[self.classObject objectForKey:@"courseCodeId"]]];
        [conn setRequestType:kRequestTypeSubmitAttendanceViaEmail];
        [conn setDelegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else
    {
        [UIUtils alertWithErrorMessage:@"Please enter a valid email"];
    }
}

- (void) registerAttendanceWithQrcode:(NSString*)qrcode
{
    NSString* unitId = @"na";
    if (_selectedUnitIndex > -1)
        unitId = [[[self.classObject objectForKey:@"units"] objectAtIndex:_selectedUnitIndex] objectForKey:@"unitId"];

    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLAttendanceViaQrcode withPostString:[NSString stringWithFormat:@"&classId=%@&qrCode=%@&unitId=%@&btnAttendanceSubmit=submit&dateOfAttendance=%@&courseCodeId=%@",[self.classObject objectForKey:@"classId"],qrcode,unitId,[UIUtils getDateStringOfFormat:kDateFormat],[self.classObject objectForKey:@"courseCodeId"]]];
    [conn setRequestType:kRequestTypeSubmitAttendanceViaQrcode];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) updateServerWithCard:(NSString*)qrcode
{
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLUpdateScannedQrCode withPostString:[NSString stringWithFormat:@"&qrCode=%@&studentId=%@&btnScanSubmit=submit",qrcode,[self.studentDict objectForKey:@"id"]]];
    [conn setRequestType:kRequestTypeUpdateScannedQrCode];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self showDropdownView:NO];
}

- (AVCaptureDevice *)frontCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionFront)
        {
            return device;
        }
    }
    return nil;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_readerView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) restartScanning
{
    [_successImageView setHidden:YES];
    [_readerView start];
}

#pragma mark - ZBarReaderReaderView delegate

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    [readerView stop];

    // do something useful with results
    for(ZBarSymbol *sym in symbols) {
        
        NSLog(@"Scanned text %@",sym.data);
        
        if (self.isAttendanceScreen)
        {
            [self registerAttendanceWithQrcode:sym.data];
        }
        else
        {
            [self updateServerWithCard:sym.data];
        }

        break;
    }

    NSLog(@"scanned qrcode");
}


#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3)
    {
        [self performSelector:@selector(restartScanning) withObject:nil afterDelay:0.5];
    }
    else if (alertView.tag == 2)
    {
        if (buttonIndex == 1)
        {
            [_successImageView setHidden:YES];
            [_readerView start];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            NSLog(@"%@",[alertView textFieldAtIndex:0].text);
            
            [self registerAttendanceWithEmail:[[alertView textFieldAtIndex:0] text]];
        }
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
        
        if (self.isAttendanceScreen)
        {
//            [UIUtils alertWithTitle:@"Want to scan more cards?" message:Nil okBtnTitle:@"Yes" cancelBtnTitle:@"No" delegate:self tag:2];
            [self performSelector:@selector(restartScanning) withObject:nil afterDelay:1];
        }
        else
        {
            [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
        }
    }
    else
    {
        if (self.isAttendanceScreen)
        {
            //        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
            [UIUtils alertWithTitle:@"Error" message:[responseDict objectForKey:@"message"] okBtnTitle:@"Ok" cancelBtnTitle:nil delegate:self tag:3];
        }
        else
        {
            [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
        }
    }
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([[self.classObject objectForKey:@"units"] isKindOfClass:[NSArray class]])
    {
        [self showDropdownView:YES];
    }
    return NO;
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_selectedUnitIndex == -1)
        return 0;
    else
        return [(NSArray*)[self.classObject objectForKey:@"units"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UnitCell";
    
    UITableViewCell* cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (indexPath.row == _selectedUnitIndex)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = [[[self.classObject objectForKey:@"units"] objectAtIndex:indexPath.row] objectForKey:@"unitTitle"];
    
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
    
    _unitField.text = [[[self.classObject objectForKey:@"units"] objectAtIndex:_selectedUnitIndex] objectForKey:@"unitTitle"];
    
    [self performSelector:@selector(showDropdownView:) withObject:nil afterDelay:0.2];
}

@end
