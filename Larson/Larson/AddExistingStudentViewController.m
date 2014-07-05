//
//  AddExistingStudentViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 05/07/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "AddExistingStudentViewController.h"
#import "AddExistingStudentCell.h"

@interface AddExistingStudentViewController ()

@end

@implementation AddExistingStudentViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonAction:(id)sender
{
    [_searchTextField resignFirstResponder];
    _trim(_searchTextField.text);
    
    if (_searchTextField.text.length)
    {
        [self searchRequestWithSearchText:_searchTextField.text];
    }
    else
    {
        [UIUtils alertWithErrorMessage:@"Please enter student name to search"];
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

#pragma mark -

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void) addButtonAction:(id)sender
{
    
}

- (void) searchRequestWithSearchText:(NSString*)searchText
{
    NSString* postString = [NSString stringWithFormat:@"&txtSearchName=%@&searchSubmit=submit",searchText];
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLSearchStudents withPostString:postString];
    [conn setRequestType:kRequestTypeSearchStudents];
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
    return [_searchedStudentsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddExistingStudentCell";
    
    AddExistingStudentCell* cell = (AddExistingStudentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.addButton.tag = indexPath.row;
    [cell.addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary* studentDict = [_searchedStudentsList objectAtIndex:indexPath.row];
    cell.firstNameLabel.text = [studentDict objectForKey:@"name"];
    if ([studentDict objectForKey:@"lastname"])
        cell.lastNameLabel.text = [studentDict objectForKey:@"lastname"];
    else
        cell.lastNameLabel.text = @"";
    cell.emailLabel.text = [studentDict objectForKey:@"email"];
    cell.addressLabel.text = [studentDict objectForKey:@"address"];
    cell.phoneNumberLabel.text = [studentDict objectForKey:@"phone"];
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
        if ([handler requestType] == kRequestTypeSearchStudents)
        {
            _searchedStudentsList = nil;
            _searchedStudentsList = [[NSArray alloc] initWithArray:[responseDict objectForKey:@"students"]];
            
            [_tableView reloadData];
        }
        else
        {
            [UIUtils alertWithInfoMessage:[responseDict objectForKey:@"message"]];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
    }
}

@end
