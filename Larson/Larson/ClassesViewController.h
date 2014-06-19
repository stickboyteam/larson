//
//  ClassesViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//


@interface ClassesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,HttpConnectionDelegate>
{
    IBOutlet UITableView *_classesTableView;
    IBOutlet UIButton *_sortByCodeButton;
    IBOutlet UIButton *_sortByNameButton;
    
    NSInteger _rowIndex;
}

@property (nonatomic, strong) NSArray *classesList;

- (IBAction)sortByCodeButtonAction:(id)sender;
- (IBAction)sortByNameButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;


@end
