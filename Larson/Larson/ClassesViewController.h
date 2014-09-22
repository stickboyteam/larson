//
//  ClassesViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//


@interface ClassesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,HttpConnectionDelegate,UIPopoverControllerDelegate>
{
    IBOutlet UITableView *_classesTableView;
    IBOutlet UIButton *_sortByCodeButton;
    IBOutlet UIButton *_sortByNameButton;
    
    NSInteger _rowIndex;
    
    NSArray *_sortedClassesList;
    
    BOOL _isFirstTime;
}

@property (nonatomic, strong) NSArray *classesList;
@property (nonatomic, strong) NSDictionary* passphraseObject;

- (IBAction)sortByCodeButtonAction:(id)sender;
- (IBAction)sortByNameButtonAction:(id)sender;
- (IBAction)logoutButtonAction:(id)sender;
- (IBAction)startAttendanceButtonAction:(id)sender;

@end
