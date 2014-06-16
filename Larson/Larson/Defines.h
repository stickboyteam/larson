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


#define kLoginBGColor 0xebebeb
#define kCommonBGColor 0xf2f2f2

#define kLoginViewID            @"LoginView"
#define kClassesViewID          @"ClassesView"
#define kStudentRosterViewID    @"StudentRosterView"
#define kStudentInfoViewID      @"StudentInfoView"

#endif

