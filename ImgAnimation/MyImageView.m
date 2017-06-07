//
//  MyImageVIew.m
//  ImgAnimation
//
//  Created by LHJ on 2017/6/6.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "MyImageVIew.h"

@implementation MyImageVIew

+ (Class)layerClass
{
    return [CAReplicatorLayer class];
}
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setReplicatorView];
}
- (void) setReplicatorView
{
    CAReplicatorLayer *layer = (CAReplicatorLayer*)[self layer];
    layer.instanceCount = 2;
    
    CATransform3D transform = CATransform3DIdentity;
    CGFloat y = self.bounds.origin.y + self.bounds.size.height + 2;
    transform = CATransform3DTranslate(transform, 0, y, 0);
    transform = CATransform3DScale(transform, 1, -1, 0);
    layer.instanceTransform = transform;
    
    layer.instanceAlphaOffset = 0.6f;
}

@end
