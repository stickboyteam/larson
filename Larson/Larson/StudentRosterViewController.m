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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cashCheckButtonAction:(id)sender
{
    
}

- (IBAction)creditCardButtonAction:(id)sender
{
    
}

- (IBAction)takePaymentTapGestureAction:(id)sender
{
    [_takePaymentView removeFromSuperview];
}

- (IBAction)addNewStudentButtonAction:(id)sender
{
    StudentInfoViewController* addStudentInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentInfoViewID];
    if (addStudentInfoVC)
    {
        [self.navigationController pushViewController:addStudentInfoVC animated:YES];
    }
}

- (IBAction)startAttendanceButtonAction:(id)sender
{
    
}

#pragma mark -

- (void) editButtonAction:(id)sender
{
    StudentInfoViewController* editStudentInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentInfoViewID];
    if (editStudentInfoVC)
    {
        editStudentInfoVC.screenType = kScreenTypeEditStudent;
        editStudentInfoVC.studentDict = [[self.classDetailObject objectForKey:@"students"] objectAtIndex:[sender tag]];
        editStudentInfoVC.classDict = self.classObject;
        [self.navigationController pushViewController:editStudentInfoVC animated:YES];
    }
}

- (void) paymentButtonAction:(id)sender
{
    [self.view addSubview:_takePaymentView];
}

- (void) scanButtonAction:(id)sender
{
    
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.classDetailObject objectForKey:@"students"] count];
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
    
    NSDictionary* studentDict = [[self.classDetailObject objectForKey:@"students"] objectAtIndex:indexPath.row];
    cell.firstNameLabel.text = [studentDict objectForKey:@"name"];
    if ([studentDict objectForKey:@"lastname"])
        cell.lastNameLabel.text = [studentDict objectForKey:@"lastname"];
    else
        cell.lastNameLabel.text = @"";
    cell.emailLabel.text = [studentDict objectForKey:@"email"];
    cell.addressLabel.text = [studentDict objectForKey:@"address"];
    cell.phoneNumberLabel.text = [studentDict objectForKey:@"phone"];
    cell.balanceAmountLabel.text = [NSString stringWithFormat:@"$%@",[studentDict objectForKey:@"classBalance"]];
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
