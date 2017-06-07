//
//  MyImageVIew.m
//  ImgAnimation
//
//  Created by LHJ on 2017/6/6.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ReplicatorImgView.h"

@implementation ReplicatorImgView
{
    CALayer         *mLayerReplicator;
    CAGradientLayer *mLayerGradient;
}
- (void) setImage:(UIImage *)image
{
    [super setImage:image];
    
    [self setReplicatorView];
}
- (void) setReplicatorView
{
    if(mLayerReplicator == nil){
        mLayerReplicator = [CALayer new];
        mLayerReplicator.contentsGravity = kCAGravityResizeAspect;
    }
    int y = self.bounds.origin.y + self.bounds.size.height/2 + self.image.size.height*6/10 + 20;
    int x = self.bounds.origin.x + self.bounds.size.width/2;
    mLayerReplicator.bounds = self.bounds;
    mLayerReplicator.contents = self.layer.contents;
    mLayerReplicator.position = CGPointMake(x, y);
    mLayerReplicator.contentsScale = [UIScreen mainScreen].scale;
    mLayerReplicator.allowsEdgeAntialiasing = YES;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1/500.0f;
    transform = CATransform3DRotate(transform, M_PI_4*1.6f, 1.f, 0, 0);
    transform = CATransform3DRotate(transform, M_PI, 1.f, 0, 0);
    transform = CATransform3DScale(transform, 1.25f, 1.0f, 1.0f);
    mLayerReplicator.transform = transform;
    
//    mLayerReplicator.opacity = 0.6f;
    
    if(mLayerGradient == nil){
        mLayerGradient = [CAGradientLayer layer];
        mLayerGradient.bounds = mLayerReplicator.bounds;
        mLayerGradient.anchorPoint = CGPointMake(0, 0);
        mLayerGradient.position = CGPointMake(0, 0);
        mLayerGradient.startPoint = CGPointMake(0.5f, 1.0f);
        mLayerGradient.endPoint = CGPointMake(0.5f, 0.0f);
        mLayerGradient.colors = @[ (id)RGBAColor(255, 255, 255, 0.8f).CGColor,
                                   (id)RGBAColor(255, 255, 255, 0.2f).CGColor,
                                   (id)Color_Transparent.CGColor];
        mLayerGradient.contentsScale = mLayerReplicator.contentsScale;
    }
    [mLayerReplicator setMask:mLayerGradient];

    [self.layer addSublayer:mLayerReplicator];
}

@end
