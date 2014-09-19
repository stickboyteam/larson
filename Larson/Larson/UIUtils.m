//
//  UIUtils.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 19/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "UIUtils.h"
#import <objc/runtime.h>

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

+ (BOOL) validateEmail: (NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+ (NSString*) getDateStringOfFormat:(NSString*)dateFormat
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (void) handlePaymentWithName:(NSString*)name amount:(NSString*)amount description:(NSString*)description payerEmail:(NSString*)payerEmail
{
    NSMutableDictionary *student = [NSMutableDictionary dictionary];
    NSMutableDictionary *itemList = [NSMutableDictionary dictionary];
    NSMutableDictionary *invoice = [NSMutableDictionary dictionary];
    
    [student setObject:kTaxRate forKey:@"taxRate"];
    [student setObject:amount forKey:@"unitPrice"];
    [student setObject:@"1" forKey:@"quantity"];
    [student setObject:name forKey:@"name"];
    [student setObject:description forKey:@"description"];
    [student setObject:@"Tax" forKey:@"taxName"];
    
    NSMutableArray *items = [NSMutableArray arrayWithObject:student];
    [itemList setObject:items forKey:@"item"];
    
    [invoice setObject:@"DueOnReceipt" forKey:@"paymentTerms"];
    [invoice setObject:@"0" forKey:@"discountPercent"];
    [invoice setObject:@"USD" forKey:@"currencyCode"];
    [invoice setObject:kMerchantEmail forKey:@"merchantEmail"];
    [invoice setObject:payerEmail forKey:@"payerEmail"];
    [invoice setObject:itemList forKey:@"itemList"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:invoice options:0 error:&err];
    NSString * jsonInvoice = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *encodedInvoice = [jsonInvoice stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *encodedPaymentTypes = [@"cash,card,paypal" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *encodedReturnUrl = [@"larsonapp://handler?{result}?Type={Type}&InvoiceId={InvoiceId}&Tip={Tip}&Email={Email}&TxId={TxId}" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *pphUrlString = [NSString stringWithFormat:@"paypalhere://takePayment?accepted=%@&returnUrl=%@&invoice=%@&step=choosePayment",
                              encodedPaymentTypes, encodedReturnUrl, encodedInvoice];
    
    NSURL *pphUrl = [NSURL URLWithString:pphUrlString];
    
    NSLog(@"%@", pphUrlString);
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:pphUrl]){
        [application openURL:pphUrl];
    } else {
        NSURL *url = [NSURL URLWithString:@"itms://itunes.apple.com/us/app/paypal-here/id505911015?mt=8"];
        [application openURL:url];
    }
}

@end

@implementation UIButton(indexPath)

static char UIB_PROPERTY_KEY;

@dynamic indexPath;

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath*)indexPath
{
    return (NSIndexPath*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

@end