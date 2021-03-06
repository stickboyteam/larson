//
//  UIUtils.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 19/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIUtils : NSObject

+ (void) alertWithTitle:(NSString*)title message:(NSString*)message okBtnTitle:(NSString*)okBtnTitle cancelBtnTitle:(NSString*)cancelBtnTitle delegate:(id)delegate tag:(int)tag;

+ (void) alertWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate;

+ (void) alertWithTitle:(NSString*)title message:(NSString*)message;

+ (void) alertWithErrorMessage:(NSString*)errorMessage;

+ (void) alertWithInfoMessage:(NSString*)infoMessage;

+ (BOOL) validateEmail: (NSString *) candidate;

+ (NSString*) getDateStringOfFormat:(NSString*)dateFormat;

+ (void) handlePaymentWithName:(NSString*)name amount:(NSString*)amount description:(NSString*)description payerEmail:(NSString*)payerEmail;

+ (NSDictionary*) getDictionaryFromCallbackResponse:(NSURL*)responseUrl;

@end

@interface UIButton(indexPath)

@property (nonatomic, retain) NSIndexPath *indexPath;

@end