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
#import "AttendanceViewController.h"

@interface ClassesViewController ()

@property (nonatomic, strong) UIPopoverController* popOverController;
@property (nonatomic, strong) NSMutableArray* filteredClassesList;

@end

@implementation ClassesViewController

@synthesize popOverController = _popOverController;

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
    
    _filteredClassesList = [[NSMutableArray alloc] init];

    if (_sortedClassesList.count == 0)
    {
        [UIUtils alertWithInfoMessage:@"No classes available"];
    }
    else
    {
        [self filterClassesList];
    }
    
    _isFirstTime = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isFirstTime)
    {
        [self loginRequestWithPasscode:[self.passphraseObject objectForKey:@"passcode"]];
    }
    
    _isFirstTime = NO;
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

- (IBAction)startAttendanceButtonAction:(id)sender
{
    UITableView* table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 120, 250)];
    table.tag = 11;
    table.delegate = self;
    table.dataSource = self;
    [table reloadData];
    UIViewController* viewC = [[UIViewController alloc] init];
    viewC.view = table;
    UIPopoverController* popOverC = [[UIPopoverController alloc] initWithContentViewController:viewC];
    popOverC.delegate = self;
    popOverC.popoverContentSize = CGSizeMake(120, 250);
    [popOverC presentPopoverFromRect:[(UIButton*)sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
    _popOverController = popOverC;
}

#pragma mark - 

- (void) nextButtonAction:(id)sender
{
    _rowIndex = [sender tag];
//    NSDictionary* classDict = [_sortedClassesList objectAtIndex:[sender tag]];
//    [self classDetailRequestWithClassId:[classDict objectForKey:@"classId"]];
    
    StudentRosterViewController* studentRosterVC = [self.storyboard instantiateViewControllerWithIdentifier:kStudentRosterViewID];
    if (studentRosterVC)
    {
        studentRosterVC.classObject = [_sortedClassesList objectAtIndex:_rowIndex];
        [self.navigationController pushViewController:studentRosterVC animated:YES];
    }
}

- (void) classDetailRequestWithClassId:(NSString*)classId
{
    HttpConnection* conn = [[HttpConnection alloc] initWithServerURL:kSubURLClassDetail withPostString:[NSString stringWithFormat:@"&classId=%@",classId]];
    [conn setRequestType:kRequestTypeClassDetail];
    [conn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) loginRequestWithPasscode:(NSString*)passcode
{
    HttpConnection* httpConn = [[HttpConnection alloc] initWithServerURL:kSubURLLogin withPostString:[NSString stringWithFormat:@"&login=%@",passcode]];
    [httpConn setRequestType:kRequestTypeLogin];
    [httpConn setDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) filterClassesList
{
    [_filteredClassesList removeAllObjects];
    
    for (NSDictionary* classDict in _sortedClassesList)
    {
        if ([[[classDict objectForKey:@"units"] lastObject] isKindOfClass:[NSDictionary class]])
        {
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"courseCodeId == %@",[classDict objectForKey:@"courseCodeId"]];
            NSArray* array = [self.filteredClassesList filteredArrayUsingPredicate:predicate];
            if (array.count == 0)
            {
                NSDictionary* dict = [[NSDictionary alloc] initWithDictionary:classDict copyItems:YES];
                [self.filteredClassesList addObject:dict];
            }
        }
    }
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 11)
    {
        return [self.filteredClassesList count];
    }
    else
    {
        return [_sortedClassesList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.tag == 0 ? 85 : 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0)
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
    else
    {
        static NSString *CellIdentifier2 = @"ClassesCell";
        UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        }
        NSDictionary* classDict = [self.filteredClassesList objectAtIndex:indexPath.row];
        cell.textLabel.text = [classDict objectForKey:@"classPrefix"];
        return cell;
    }
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == 11)
    {
        _rowIndex = indexPath.row;
        NSDictionary* classDict = [_filteredClassesList objectAtIndex:indexPath.row];

        if ([[[classDict objectForKey:@"units"] lastObject] isKindOfClass:[NSDictionary class]])
        {
            [self.popOverController dismissPopoverAnimated:YES];
            AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
            if (attendanceVC)
            {
                attendanceVC.classObject = [self.filteredClassesList objectAtIndex:_rowIndex];
                attendanceVC.isAttendanceScreen = YES;
                attendanceVC.isFromClasses = YES;
                [self.navigationController pushViewController:attendanceVC animated:YES];
            }

//            [self classDetailRequestWithClassId:[classDict objectForKey:@"classId"]];
        }
        else
        {
            [UIUtils alertWithInfoMessage:@"No units available for the selected class, please try later"];
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
        if ([handler requestType] == kRequestTypeLogin)
        {
            if ([[responseDict objectForKey:@"classes"] isKindOfClass:[NSArray class]])
            {
                _classesList = [NSArray arrayWithArray:[responseDict objectForKey:@"classes"]];
                [self sortByCodeButtonAction:nil];
                [self filterClassesList];
//                [_classesTableView reloadData];
            }
        }
        else
        {
            AttendanceViewController* attendanceVC = [self.storyboard instantiateViewControllerWithIdentifier:kAttendanceViewID];
            if (attendanceVC)
            {
                attendanceVC.classDetailObject = [NSDictionary dictionaryWithDictionary:responseDict];
                attendanceVC.classObject = [_sortedClassesList objectAtIndex:_rowIndex];
                attendanceVC.isAttendanceScreen = YES;
                [self.navigationController pushViewController:attendanceVC animated:YES];
            }
        }
    }
    else
    {
        [UIUtils alertWithErrorMessage:[responseDict objectForKey:@"message"]];
    }
}

@end
