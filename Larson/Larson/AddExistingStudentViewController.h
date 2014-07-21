//
//  AddExistingStudentViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 05/07/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddExistingStudentViewController : UIViewController
{
    
    IBOutlet UITextField *_searchTextField;
    IBOutlet UITableView *_tableView;
    
    NSArray *_searchedStudentsList;
    
    NSInteger _rowIndex;
}

@property (nonatomic, strong) NSDictionary *classObject;

- (IBAction)searchButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;

@end
