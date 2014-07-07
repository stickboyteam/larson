//
//  ClassesViewController.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "ClassesViewController.h"
#import "ClassesTableCell.h"
#import "StudentRosterViewController.h"

@interface ClassesViewController ()

@end

@implementation ClassesViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = UIColorFromHEX(kCommonBGColor);
    _classesTableView.backgroundColor = UIColorFromHEX(kCommonBGColor);    
    
    [_sortByCodeButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];
    [_sortByNameButton setImage:nil forState:UIControlStateNormal];
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"classPrefix"                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    _sortedClassesList = [[NSArray alloc] initWithArray:[self.classesList sortedArrayUsingDescriptors:sortDescriptors]];
    
    if (_sortedClassesList.count == 0)
    {
        [UIUtils alertWithInfoMessage:@"No classes available"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sortByCodeButtonAction:(id)sender
{
    [_sortByCodeButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];
    [_sortByNameButton setImage:nil forState:UIControlStateNormal];

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"classPrefix"                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    _sortedClassesList = [[NSArray alloc] initWithArray:[self.classesList sortedArrayUsingDescriptors:sortDescriptors]];
    
    [_classesTableView reloadData];
}

- (IBAction)sortByNameButtonAction:(id)sender
{
    [_sortByCodeButton setImage:nil forState:UIControlStateNormal];
    [_sortByNameButton setImage:[UIImage imageNamed:@"sorting_arrow"] forState:UIControlStateNormal];

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"className"                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    _sortedClassesList = [[NSArray alloc] initWithArray:[self.classesList sortedArrayUsingDescriptors:sortDescriptors]];
    
    [_classesTableView reloadData];
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 

- (void) nextButtonAction:(id)sender
{
    _rowIndex = [sender tag];
    NSDictionary* classDict = [_sortedClassesList objectAtIndex:[sender tag]];
    [self classDetailRequestWithClassId:[classDict objectForKey:@"classId"]];
}

- (void) classDetailRequestWithClassId:(NSString*)classId
{
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLClassDetail withPostString:[NSString stringWithFormat:@"&classId=%@",classId]];
    [conn setRequestType:kRequestTypeClassDetail];
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
    return [_sortedClassesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ClassesTableCell";
    
    ClassesTableCell* cell = (ClassesTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.nextButton.tag = indexPath.row;
    [cell.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary* classDict = [_sortedClassesList objectAtIndex:indexPath.row];
    cell.codeCategoryLabel.text = [classDict objectForKey:@"classPrefix"];
    cell.courseNameLabel.text = [classDict objectForKey:@"className"];
    cell.courseCodeLabel.text = [classDict objectForKey:@"classCode"];
    
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
        StudentRosterViewController* studentRosterVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentRosterViewID];
        if (studentRosterVC)
        {
            studentRosterVC.classDetailObject = [NSDictionary dictionaryWithDictionary:responseDict];
            studentRosterVC.classObject = [_sortedClassesList objectAtIndex:_rowIndex];
            [self.navigationController pushViewController:studentRosterVC animated:YES];
        }
    }
    else
    {
        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
    }
}

@end
