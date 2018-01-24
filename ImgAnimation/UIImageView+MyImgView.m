//
//  UIImageView+MyImgView.m
//  ImgAnimation
//
//  Created by LHJ on 2017/4/12.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "UIImageView+MyImgView.h"
#import "CPublic.h"

@implementation UIImageView (MyImgView)

- (void) setFrameOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void) setFrameSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
- (void) setImageForAdjustSize:(UIImage *)image
{
    if(image != nil) {
        image = [CPublic getImgWithNewSize:image withNewSize:self.bounds.size];
    }
    [self setImage:image];
}

@end
