//
//  CustomTextField.m
//  Larson
//
//  Created by Vishwanath Vallamkondi on 09/06/14.
//  Copyright (c) 2014 Vishwanath Vallamkondi. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

@end
