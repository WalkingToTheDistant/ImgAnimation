//
//  AnimationView.m
//  ImgAnimation
//
//  Created by LHJ on 2017/4/13.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "AnimationView.h"
#import "UIImageView+MyImgView.h"
#import "CPublic.h"
#import "MyImageView.h"

/** 摩擦因子 */
const float FACTOR = 0.95f;

@interface AnimationView()

@property(nonatomic, assign, setter=setScrollX:, getter=getScrollX) float mScrollX;

- (void) setScrollX:(float)scrollX;

@end

@implementation AnimationView
{
    int mDistanceIndex;
    int mItemWidth;
    int mNumOfImgs;
    NSArray<UIView*> *mAryImgViews;
    CGPoint mPreMove;
    
    /* 手势结束后的惯性滑动 */
    float mStartVelocity;
    CGFloat mEndOffsetX;
    CADisplayLink *mDisplayLink;
    CGFloat mRangeForScrollX;
    BOOL mIsFixureLoc;
    int mFixureLocIndex;
}

@synthesize mAryImgs;
@synthesize mAnimationType;
@synthesize mScrollX;
@synthesize mImgSize;

// ======================================================================================
- (instancetype) init
{
    self = [super init];
    if(self != nil){
        [self initData];
    }
    return self;
}
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    int height = frame.size.height*5/10;
    int width = height * 2/3;
    mImgSize = CGSizeMake(width, height);
}
- (void) initData
{
    mAnimationType = AnimationType_Line;
    mDistanceIndex = 16;
    self.mScrollX = 0;
    mRangeForScrollX = 0;
    mIsFixureLoc = NO;
    [self addGesEvent];
}
- (void) addGesEvent
{
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
    [self addGestureRecognizer:panGes];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
    [self addGestureRecognizer:tapGes];
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    if(mAryImgViews == nil) { return; }
    
    static dispatch_once_t once;
    __weak typeof(self) wkSelf = self;
    dispatch_once(&once, ^{
        [wkSelf initAnimationView];
    });
}
- (void) setScrollX:(float)scrollX
{
    mScrollX = scrollX;
    [self handleScrollValueRange];
}
- (void) setAryImgs:(NSArray<UIImage*>*)aryImgs
{
    if(mAryImgs == aryImgs) { return; }
    
    mAryImgs = aryImgs;
    
    for(UIView *view in [self subviews]){
        [view removeFromSuperview];
    }
    mAryImgViews = nil;
    
    NSMutableArray<UIView*> *muAryImgViews = [NSMutableArray new];
    int centerX = self.bounds.size.width/2;
    int centerY = self.bounds.size.height/2;
    for(UIImage *img in mAryImgs){

        MyImageView *imgView = [MyImageView new];
        [imgView setFrameSize:mImgSize];
        [imgView setCenter:CGPointMake(centerX, centerY)];
        [imgView setImage:img];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        [imgView.layer setAnchorPoint:CGPointMake(0.5, 0.5)]; // 瞄点
        [imgView setBackgroundColor:[UIColor clearColor]];
        [imgView setUserInteractionEnabled:NO];
        [self addSubview:imgView];
        [muAryImgViews addObject:imgView];
    }
    mItemWidth = mImgSize.width + mDistanceIndex;
    mNumOfImgs = (int)mAryImgs.count;
    mAryImgViews = muAryImgViews;
    muAryImgViews = nil;
    mRangeForScrollX = mNumOfImgs * mItemWidth;
}
- (void) updateAnimationViewAndInitIndex
{
    mScrollX = 0;
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.4f animations:^{
        [wkSelf doScrollAni];
    }];
}
- (void) updateAnimationView
{
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.4f animations:^{
        [wkSelf doScrollAni];
    }];
}
- (void) initAnimationView
{
    self.mScrollX = 0;
    [self doScrollAni];
}
- (void) doScrollAni
{
    if(mAryImgViews != nil){
        for(int i=0; i<mAryImgViews.count; i+=1){
            UIView *view = mAryImgViews[i];
            view.layer.transform = [self updateTransformWithIndex:i];
        }
    }
}
- (CATransform3D) updateTransformWithIndex:(int)index
{
    CGFloat offset = [self handleOffsetWithIndex:index];
    return [self updateTransformWithOffset:offset];
}
- (CGFloat) handleOffsetWithIndex:(int)index
{
    float indexBegin = mScrollX / mItemWidth;
    CGFloat result = index - indexBegin;
    if(result > mNumOfImgs/2){
        result -= mNumOfImgs;
    } else if(result < -mNumOfImgs/2){
        result += mNumOfImgs;
    }
    return result;
}
- (CATransform3D) updateTransformWithOffset:(float)offset
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f/500.0f;
    switch(mAnimationType){
        case AnimationType_Line:{
            transform = CATransform3DTranslate(transform, offset * mItemWidth, 0, 0);
            break;
        }
        case AnimationType_Cask_1:
        case AnimationType_Cask_2:
        case AnimationType_Cask_3:{
            float angle = M_PI*2 / mNumOfImgs; // 获取在一个圆圈中每个图片的角度
            angle = angle/2;
            float radius = (mItemWidth/2) / tanf(angle);
            float angleForTrans = offset * angle * 2; // 位移的角度
            if(mAnimationType == AnimationType_Cask_2){
                radius = -radius;
                angleForTrans = -angleForTrans;
            }
            float y = 0;
            if(mAnimationType == AnimationType_Cask_3){
                y = (cosf(angleForTrans) * radius - radius)/2 + 40;
            }
            transform = CATransform3DTranslate(transform, 0.f, 0, -radius);
            transform = CATransform3DRotate(transform, angleForTrans, 0, 1.0f, 0);
            transform = CATransform3DTranslate(transform, 0.f, y, radius);
            break;
        }
        case AnimationType_Circle_1:
        case AnimationType_Circle_2:{
            float angle = M_PI*2 / mNumOfImgs; // 获取在一个圆圈中每个图片的角度
            angle = angle/2;
            float radius = (mItemWidth/2) / tanf(angle);
            float angleForTrans = offset * angle * 2; // 位移的角度
            float x = sinf(angleForTrans) * radius;
            float y = 0.0f;
            float z = cosf(angleForTrans) * radius - radius; // 减去 radius 是为了圆点移到后面
            if(mAnimationType == AnimationType_Circle_2){
                y = (cosf(angleForTrans) * radius - radius)/2 + 40;
            }
            transform = CATransform3DTranslate(transform, x, y, z);
            break;
        }
        case AnimationType_Line_1:
        case AnimationType_Line_2:{
            float x = offset * mItemWidth*4/5;
            float y = 0;
            if(mAnimationType == AnimationType_Line_2){
                y = fabs(offset/4 *mItemWidth);
            }
            
            float angle = -(M_PI_2*7/9);
            angle *= (fabs(offset)<=1)? -angle*offset : -angle*1*offset/fabs(offset);
            transform = CATransform3DTranslate(transform, x, y, 0);
            transform = CATransform3DRotate(transform, angle, 0, 1.0f, 0);
            break;
        }
    }
    return transform;
}
- (void) handleScrollValueRange
{
    if(mRangeForScrollX == 0) { return; } // 还没设置范围，不需要判断
    
    float value = fabs(mScrollX) + self.bounds.size.width; // 提前一个屏幕判断，避免出现断带
    if(value >= mRangeForScrollX){
        int sign = mScrollX / fabs(mScrollX);
        mScrollX = (fabs(mScrollX) - mRangeForScrollX) * sign;
    }
}
- (void) startScrollAni
{
    [self endScrollAni];
    mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLink)];
    [mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void) endScrollAni
{
    if(mDisplayLink != nil){
        [mDisplayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [mDisplayLink invalidate];
    }
    mDisplayLink = nil;
}
- (void) displayLink
{
    if(fabs(mEndOffsetX) == 0.f){ // 小于某个值，可以停止滑动了
        [self endScrollAni];
        return;
    }
    if(mIsFixureLoc!=YES && fabs(mEndOffsetX) <= 0.2f){
        BOOL bResult = [self transformWithScrollX]; // 滑动到固定
        if(bResult != YES){
            self.mScrollX += mEndOffsetX;
            mEndOffsetX = 0.0f;
            [self doScrollAni];
            return;
        }
    }
    if(mIsFixureLoc == YES){
        if(mFixureLocIndex <= 0){
            [self endScrollAni];
            mIsFixureLoc = NO;
            mFixureLocIndex = 0.0f;
            return;
        } else {
            mFixureLocIndex -= 1;
        }
    } else {
        mEndOffsetX *= FACTOR;
    }
    self.mScrollX += mEndOffsetX;
    [self doScrollAni];
    
}
- (BOOL) transformWithScrollX
{
    BOOL bResult = YES;
    float indexBegin = mScrollX / mItemWidth;
    indexBegin = roundf(indexBegin); // 四舍五入
    float value = (indexBegin * mItemWidth) - mScrollX;
    if(fabs(value) < 0.1f){
        bResult = NO;
    } else { // 开始滚动到指定位置
        mIsFixureLoc = YES;
        bResult = YES;
        if(fabs(value) > 10){
            mFixureLocIndex = 10;
            
        } else if(fabs(value) > 5 && fabs(value) < 10){
            mFixureLocIndex = 5;
            
        } else {
            mFixureLocIndex = 2;
            
        }
        mEndOffsetX = value/mFixureLocIndex;
    }
    return bResult;
}
// ======================================================================================
#pragma mark - 动作触发方法
/** 处理拖动手势 */
- (void) handlePanGes:(UIPanGestureRecognizer*)panGes
{
    switch(panGes.state){
        case UIGestureRecognizerStateBegan:{ // 开始拖动
            mIsFixureLoc = NO;
            mFixureLocIndex = 0;
            [self endScrollAni];
            mPreMove = [panGes locationInView:panGes.view];
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 拖动
            CGPoint moveNow = [panGes locationInView:panGes.view];
            float moveX = -(moveNow.x - mPreMove.x);
            self.mScrollX += moveX;
            mPreMove = moveNow;
            [self doScrollAni];
            break;
        }
        case UIGestureRecognizerStateEnded:// 结束拖动
        case UIGestureRecognizerStateCancelled:{ // 取消
            mStartVelocity = [panGes velocityInView:panGes.view].x;
            mEndOffsetX = -(mStartVelocity / 80);
            mIsFixureLoc = NO;
            mFixureLocIndex = 0;
            [self startScrollAni];
            break;
        }
        default:{
            break;
        }
    }
}
/** 处理单点手势 */
- (void) handleTapGes:(UITapGestureRecognizer*)tapGes
{
    CGPoint point = [tapGes locationInView:tapGes.view];
    float distance = point.x - tapGes.view.bounds.size.width/2;
    float indexBegin = (mScrollX+distance) / mItemWidth;
    indexBegin = roundf(indexBegin); // 四舍五入
    float value = (indexBegin * mItemWidth) - mScrollX;
    if(fabs(value) > 10){
        mFixureLocIndex = 10;
        
    } else if(fabs(value) > 5 && fabs(value) < 10){
        mFixureLocIndex = 5;
        
    } else {
        mFixureLocIndex = 2;
        
    }
    mIsFixureLoc = YES;
    mEndOffsetX = value/mFixureLocIndex;
    [self startScrollAni];
}
@end
