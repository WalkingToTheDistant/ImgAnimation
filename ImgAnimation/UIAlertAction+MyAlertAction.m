//
//  UIAlertAction+MyAlertAction.m
//  ImgAnimation
//
//  Created by LHJ on 2017/5/9.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "UIAlertAction+MyAlertAction.h"
#import <objc/runtime.h>

static NSString *const TAGKEY = @"TAGKEY";

@implementation UIAlertAction (MyAlertAction)

- (void) setTag:(int)index
{
    objc_setAssociatedObject(self, (__bridge const void *)(TAGKEY), @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int) getTag
{
    return [(NSNumber*)objc_getAssociatedObject(self, (__bridge const void *)TAGKEY) integerValue];
}

@end
