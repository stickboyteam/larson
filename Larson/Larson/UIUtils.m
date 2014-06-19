//
//  UIUtils.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 19/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

+ (void) alertWithTitle:(NSString*)title message:(NSString*)message okBtnTitle:(NSString*)okBtnTitle cancelBtnTitle:(NSString*)cancelBtnTitle delegate:(id)delegate tag:(int)tag
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelBtnTitle otherButtonTitles:okBtnTitle, nil];
    alert.tag = tag;
    [alert show];
}

+ (void) alertWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate
{
    [self alertWithTitle:title message:message okBtnTitle:nil cancelBtnTitle:@"Ok" delegate:delegate tag:0];
}

+ (void) alertWithTitle:(NSString*)title message:(NSString*)message
{
    [self alertWithTitle:title message:message delegate:nil];
}

+ (void) alertWithErrorMessage:(NSString*)errorMessage
{
    [self alertWithTitle:@"Error" message:errorMessage];
}

+ (void) alertWithInfoMessage:(NSString*)infoMessage
{
    [self alertWithTitle:@"Info" message:infoMessage];
}

@end
