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
    _classesTableView.contentInset = UIEdgeInsetsMake(-35, 0, -30, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sortByCodeButtonAction:(id)sender
{
    
}

- (IBAction)sortByNameButtonAction:(id)sender
{
    
}

- (IBAction)logoutButtonAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 

- (void) nextButtonAction:(id)sender
{
    StudentRosterViewController* studentRosterVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentRosterViewID];
    if (studentRosterVC)
    {
        [self.navigationController pushViewController:studentRosterVC animated:YES];
    }
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
