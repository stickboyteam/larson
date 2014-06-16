//
//  LoginViewController.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 06/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    
    IBOutlet UITextField *_loginInputField;
}

- (IBAction)loginButtonAction:(id)sender;

@end
