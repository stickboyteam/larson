//
//  ClassesViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *_classesTableView;
    IBOutlet UIButton *_sortByCodeButton;
    IBOutlet UIButton *_sortByNameButton;
}

- (IBAction)sortByCodeButtonAction:(id)sender;
- (IBAction)sortByNameButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;


@end
