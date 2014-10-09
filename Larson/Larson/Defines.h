//
//  Defines.h
//  Larson
//
//  Created by Vishwanath Vallamkondi on 06/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#ifndef Larson_Defines_h
#define Larson_Defines_h

#define UIColorFromHEX(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

//#ifdef DEBUG
#define NSLog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#else
//#define NSLog(__FORMAT__, ...)  ((void)0)
//#endif

#define kLoginBGColor 0xebebeb
#define kCommonBGColor 0xf2f2f2

#define kLoginViewID            @"LoginView"
#define kClassesViewID          @"ClassesView"
#define kStudentRosterViewID    @"StudentRosterView"
#define kStudentInfoViewID      @"StudentInfoView"
#define kAttendanceViewID       @"AttendanceView"
#define kAddStudentViewID       @"AddStudentView"

typedef enum serverRequestType
{
	kRequestTypeLogin = 100,
    kRequestTypeClassDetail,
    kRequestTypeEditStudentInfo,
    kRequestTypeAddStudentInfo,
    kRequestTypeSubmitAttendanceViaEmail,
    kRequestTypeSubmitAttendanceViaQrcode,
    kRequestTypeUpdatePaymentDetails,
    kRequestTypeUpdateScannedQrCode,
    kRequestTypeSearchStudents,
    kRequestTypeUpdatePartialPayments,
    kRequestTypeAssignStudent
} RequestType;

typedef enum screenType
{
	kScreenTypeEditStudent = 200,
    kScreenTypeNewStudent,
    kScreenTypeScanCard,
    kScreenTypeAttendance
} ScreenType;

#define kServerURL @"http://www.larsoned.com.php53-9.dfw1-2.websitetestlink.com/"

#define kSubURLLogin   @"api/login.php"
#define kSubURLClassDetail @"api/class-details.php"
#define kSubURLEditStudentInfo  @"api/edit-student.php"
#define kSubURLAddStudentInfo   @"api/new-student.php"
#define kSubURLAttendanceViaEmail   @"api/student-attendance-via-email.php"
#define kSubURLUpdatePaymentDetails @"api/payment.php"
#define kSubURLAttendanceViaQrcode @"api/student-attendance-via-qrcode.php"
#define kSubURLUpdatePaymentDetails @"api/payment.php"
#define kSubURLUpdateScannedQrCode    @"/api/scan-card.php"
#define kSubURLSearchStudents         @"api/search-students.php"
#define kSubURLUpdatePartialPayments    @"api/partial-payment.php"
#define kSubURLAssignStudent            @"api/student-assign.php"

#define _trim(text) [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define _appDelegate (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define _calculateShippingAmount(amt) 0
#define _calculateTaxAmount(amt) 0
#define kDateFormat    @"YYYY-MM-dd HH:mm:ss"

#define kTaxRate    @"0"

#define kAppDelegateOpenURLNotification @"appDelegateOpenUrlNotification"

/************* PayPal Information *****************/

#define kPayPalMerchantName @"Larson App"
#define kPayPalMerchantPrivacyPolicyURL @"https://www.paypal.com/webapps/mpp/ua/privacy-full"
#define kPayPalMerchantUserAgreementURL @"https://www.paypal.com/webapps/mpp/ua/useragreement-full"
#define kPayPalMerchantAcceptCreditCards    1 // 0 - NO, 1 - YES
#define kMerchantEmail  @"vishwa.larson@gmail.com"

// Set the environment:
// - For live charges, use PayPalEnvironmentProduction (default).
// - To use the PayPal sandbox, use PayPalEnvironmentSandbox.
// - For testing, use PayPalEnvironmentNoNetwork.
#define kPayPalEnvironment PayPalEnvironmentSandbox

#define kPayPalClientID @"AWlWVBA5vnk0r1wWKNLRJNXgT011RrF7GOUzJTUBolhtDaekfBzHGhFeonS3"
#define kPayPalSecretID @"EOd5ghBqh6vEqAnlBuDYh-NBhhVP7RsdxvXpBrr5aUS_InFil4Z75vbT1f7v"

/************************RayGun************************/

#define kRayGunApiKey   @"G178Se4AvSB0dtxETIcdQg=="

#endif

