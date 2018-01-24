//
//  CPublic.h
//  ImgAnimation
//
//  Created by LHJ on 2017/5/4.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGBAColor(r,g,b,a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define Color_Transparent   [UIColor clearColor]

@interface CPublic : NSObject

/** 根据newSize大小裁剪图片，避免图片过大占用内存 */
+ (UIImage*) getImgWithNewSize:(UIImage*)oldImg withNewSize:(CGSize)newSize;

@end
