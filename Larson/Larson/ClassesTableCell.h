//
//  ClassesTableCell.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 07/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassesTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *codeCategoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *courseCodeLabel;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@end
