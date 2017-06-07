//
//  AnimationView.h
//  ImgAnimation
//
//  Created by LHJ on 2017/4/13.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 动画类型 */
typedef enum : int{
    AnimationType_Line = 1, /* 直线 */
    AnimationType_Circle_1, /* 圆圈-1 */
    AnimationType_Circle_2, /* 圆圈-2 */
    AnimationType_Cask_1, /* 圆桶-1 */
    AnimationType_Cask_2, /* 圆桶-2 */
    AnimationType_Cask_3, /* 圆桶-3 */
    AnimationType_Line_1, /* 翻页-1 */
    AnimationType_Line_2, /* 翻页-2 */
    
}AnimationType;

@interface AnimationView : UIView

/** 初始化索引值并更新UI */
- (void) updateAnimationViewAndInitIndex;

- (void) updateAnimationView;

@property(nonatomic, assign, readonly, getter=getImgSize) CGSize mImgSize;

@property(nonatomic, retain, setter=setAryImgs:) NSArray<UIImage*> *mAryImgs;

@property(nonatomic, assign, setter=setAnimationType:) AnimationType mAnimationType;

@end
