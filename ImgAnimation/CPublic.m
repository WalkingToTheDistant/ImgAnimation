//
//  CPublic.m
//  ImgAnimation
//
//  Created by LHJ on 2017/5/4.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "CPublic.h"

@implementation CPublic

/** 根据newSize大小裁剪图片，避免图片过大占用内存 */
+ (UIImage*) getImgWithNewSize:(UIImage*)oldImg withNewSize:(CGSize)newSize
{
    UIImage *newImg = nil;
    if(oldImg == nil) { return newImg; }
    
    NSLog(@"%i * %i  -- to -- %i * %i", (int)oldImg.size.width, (int)oldImg.size.height, (int)newSize.width, (int)newSize.height);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    [oldImg drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    oldImg = nil;
    newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImg;
}

@end
