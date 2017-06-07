//
//  UIImageView+MyImgView.h
//  ImgAnimation
//
//  Created by LHJ on 2017/4/12.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MyImgView)

- (void) setFrameOrigin:(CGPoint)origin;

- (void) setFrameSize:(CGSize)size;

/** 设置图片，根据ImgView的尺寸自动调整图片的尺寸 */
- (void) setImageForAdjustSize:(UIImage *)image;

@end
