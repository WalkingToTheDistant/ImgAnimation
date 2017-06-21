//
//  ViewController.m
//  ImgAnimation
//
//  Created by LHJ on 2017/4/12.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ViewController.h"
#import "AnimationView.h"
#import "CPublic.h"
#import "UIAlertAction+MyAlertAction.h"
#import "UIImageView+MyImgView.h"
#import "RITLPhotoNavigationViewModel.h"
#import "RITLPhotoNavigationViewController.h"

#define RGB(r, g, b) [UIColor colorWithRed:r green:g blue:b alpha:1]
#define ColorTransparent [UIColor clearColor]
#define Img(Named) [UIImage imageNamed:Named]

#define ImgFileDirectory [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"/ImgsFileDirectory/"]

typedef enum : NSInteger{
    ViewTag_BtnSwitchAniType = 1,
    ViewTag_BtnPhoto,
}ViewTag;

@interface ViewController ()

@property(nonatomic, retain) AnimationView *mAnimationView;

@property(nonatomic, retain) UIButton *mBtnSwitchAniType;

@property(nonatomic, retain) UIButton *mBtnPhoto;

@end

@implementation ViewController

@synthesize mAnimationView;
@synthesize mBtnSwitchAniType;
@synthesize mBtnPhoto;

- (void) loadView
{
    UIView *viewBg = [UIView new];
    [viewBg setFrame:[UIScreen mainScreen].bounds];
    [viewBg setBackgroundColor:RGB(240, 240, 240)];
    [viewBg setUserInteractionEnabled:YES];
    [self setView:viewBg];
    
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"bg" ofType:@"jpeg"];
    UIImage *imgBG = [UIImage imageWithContentsOfFile:strPath];
    imgBG = [CPublic getImgWithNewSize:imgBG withNewSize:viewBg.bounds.size];
    [viewBg setBackgroundColor:[UIColor colorWithPatternImage:imgBG]];
    
    if(mAnimationView == nil){
        mAnimationView = [AnimationView new];
        [mAnimationView setFrame:viewBg.bounds];
        [mAnimationView setBackgroundColor:ColorTransparent];
        [viewBg addSubview:mAnimationView];
    }
    int width = 60;
    int height = 60;
    int x = 10;
    int y = 20;
    CGSize sizeImg = CGSizeMake(30, 30);
    if(mBtnSwitchAniType == nil){
        NSString *strPath = [[NSBundle mainBundle] pathForResource:@"switch" ofType:@"png"];
        UIImage *img = [UIImage imageWithContentsOfFile:strPath];
        img = [CPublic getImgWithNewSize:img withNewSize:sizeImg];
        
        mBtnSwitchAniType = [UIButton new];
        [mBtnSwitchAniType setFrame:CGRectMake(x, y, width, height)];
        [mBtnSwitchAniType setBackgroundColor:ColorTransparent];
        [mBtnSwitchAniType setContentMode:UIViewContentModeCenter];
        [mBtnSwitchAniType setImage:img forState:UIControlStateNormal];
        [mBtnSwitchAniType setTag:ViewTag_BtnSwitchAniType];
        [mBtnSwitchAniType addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [viewBg addSubview:mBtnSwitchAniType];
    }
    x = viewBg.bounds.size.width - width - 10;
    if(mBtnPhoto == nil){
        NSString *strPath = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"png"];
        UIImage *img = [UIImage imageWithContentsOfFile:strPath];
        img = [CPublic getImgWithNewSize:img withNewSize:sizeImg];
        
        mBtnPhoto = [UIButton new];
        [mBtnPhoto setFrame:CGRectMake(x, y, width, height)];
        [mBtnPhoto setBackgroundColor:ColorTransparent];
        [mBtnPhoto setContentMode:UIViewContentModeCenter];
        [mBtnPhoto setImage:img forState:UIControlStateNormal];
        [mBtnPhoto setTag:ViewTag_BtnPhoto];
        [mBtnPhoto addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [viewBg addSubview:mBtnPhoto];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initData];
}
- (void) initData
{
    __weak typeof(self) wkSelf = self;
    __weak typeof(mAnimationView) wkAniView = mAnimationView;
    __block NSArray<UIImage*> *aryImgs = [NSArray new];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        
        aryImgs = [wkSelf getImgsFromLocalFilePath];
        if(aryImgs == nil
           || aryImgs.count == 0){ // 本地没有图片，使用默认图
            NSMutableArray<UIImage*> *muAryImgs = [NSMutableArray new];
            for(int i=0; i<=23; i+=1){
                // 使用imageNamed会产生缓存
                NSString *strPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", i]
                                                                    ofType:@"jpg"];
                UIImage *img = [UIImage imageWithContentsOfFile:strPath];
                if(img == nil){
                    NSLog(@"%i", i);
                    continue;
                }
                [muAryImgs addObject:img];
            }
            aryImgs = [wkSelf handleImgSize:muAryImgs];
        }
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [wkAniView setAryImgs:aryImgs];
        [wkAniView setAnimationType:AnimationType_Cask_3];
        [wkAniView setNeedsLayout];
        [wkAniView layoutSubviews];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/** 根据枚举值切换动画样式 */
- (void) handleSwitchAniType:(int)index
{
    if(mAnimationView != nil){
        if([mAnimationView mAnimationType] == index) {// 样式没改变，不需要更新
            return;
        }
        [mAnimationView setAnimationType:index];
        [mAnimationView updateAnimationView];
    }
}
/** 打开选择动画样式的选择框 */
- (void) openSwitchAniType
{
    /* AnimationType_Line = 1,  直线 
     AnimationType_Circle_1, 圆圈-1
    AnimationType_Circle_2, 圆圈-2
    AnimationType_Cask_1, 圆桶-1
    AnimationType_Cask_2, 圆桶-2
    AnimationType_Cask_3, 圆桶-3 */
    NSArray *aryBtnTitle = @[@"直线", @"圆圈-1", @"圆圈-2", @"圆桶-1", @"圆桶-2", @"圆桶-3", @"翻页-1", @"翻页-2"];
    
    if([[UIDevice currentDevice].systemVersion floatValue] < 8.0){
#ifdef __IPHONE_8_0
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图片流样式" delegate:(id)self cancelButtonTitle:@"关闭" destructiveButtonTitle:nil otherButtonTitles:nil];
        for(NSString *strTitle in aryBtnTitle){
            [actionSheet addButtonWithTitle:strTitle];
        }
        [actionSheet showInView:self.view];
#endif
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择" message:@"选择图片流样式" preferredStyle:UIAlertControllerStyleActionSheet];
        __weak typeof(self) wkSelf = self;
        void (^handleBlock) (UIAlertAction *action) = ^(UIAlertAction *action){
            [wkSelf handleSwitchAniType:action.getTag];
        };
        for(int i=0; i<aryBtnTitle.count; i+=1){
            NSString *strTitle = aryBtnTitle[i];
            UIAlertAction *action = [UIAlertAction actionWithTitle:strTitle style:UIAlertActionStyleDefault handler:handleBlock];
            [action setTag:(i+1)];
            [alertController addAction:action];
        }
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
/** 打开多选照片的选择框 */
- (void) openPhoto
{
    RITLPhotoNavigationViewModel * viewModel = [RITLPhotoNavigationViewModel new];
    viewModel.maxNumberOfSelectedPhoto = 60;
    __weak typeof(self) wkSelf = self;
    viewModel.RITLBridgeGetImageBlock = ^(NSArray <UIImage *> * images){
        
        if(images == nil
          || images.count <= 0) {
           return;
        }
        @autoreleasepool {
            NSLog(@"beiginHanldeImg");
            __block NSArray<UIImage*> *aryImgsAfterHandleSize = nil;
            __block NSMutableArray<UIImage*> *muAryBlock = [NSMutableArray arrayWithArray:images];
            images = nil;
            dispatch_group_t group = dispatch_group_create();
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            NSLog(@"createGCD");
            dispatch_group_async(group, queue, ^{
                NSLog(@"handleImgSize - start");
                aryImgsAfterHandleSize = [wkSelf handleImgSize:muAryBlock];
                NSLog(@"handleImgSize - end");
                muAryBlock = nil;
            });
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                if(wkSelf.mAnimationView != nil){
                    [wkSelf.mAnimationView setAryImgs:aryImgsAfterHandleSize];
                    [wkSelf.mAnimationView updateAnimationViewAndInitIndex];
                }
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    [wkSelf clearImgFile];
                    [wkSelf saveImgsToLocalFilePath:aryImgsAfterHandleSize];
                    aryImgsAfterHandleSize = nil;
                });
            });
        }
    };
    RITLPhotoNavigationViewController * viewController = [RITLPhotoNavigationViewController photosViewModelInstance:viewModel];
    
    [self presentViewController:viewController animated:true completion:^{}];
}
/** 保存图片到沙盒中 */
- (void) saveImgsToLocalFilePath:(NSArray<UIImage*>*)aryImgs
{
    // 首先先删除原先的图片，然后才保存新选择的图片
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *strFileDir = ImgFileDirectory;
    if([fileManager fileExistsAtPath:strFileDir] != YES){
        BOOL bIsCreate = [fileManager createDirectoryAtPath:strFileDir withIntermediateDirectories:YES attributes:nil error:nil];
        if(bIsCreate == YES){
            NSLog(@"创建文件夹成功");
        }
    }
    for(int i=0; i<aryImgs.count; i+=1){
        @autoreleasepool {
            NSString *strPath = [NSString stringWithFormat:@"%@/%i.jpg", strFileDir, i];
            NSLog(@"%@", strPath);
            UIImage *img = aryImgs[i];
            NSData *data = UIImageJPEGRepresentation(img, 0.4);
            img = nil;
            [data writeToFile:strPath atomically:YES];
            data  = nil;
        }
    }
}
- (void) clearImgFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray<NSString*> *aryPaths = [fileManager contentsOfDirectoryAtPath:ImgFileDirectory error:nil];
    if([fileManager fileExistsAtPath:ImgFileDirectory isDirectory:nil] == YES){
        for(NSString *strPath in aryPaths){
            [fileManager removeItemAtPath:strPath error:nil];
        }
    }
}
- (NSArray<UIImage*>*) getImgsFromLocalFilePath
{
    NSMutableArray<UIImage*> *muAryImgs = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *strFileDir = ImgFileDirectory;
    if([fileManager fileExistsAtPath:strFileDir] != YES){ // 不存在这个路径，直接返回
        muAryImgs = nil;
    } else {
        muAryImgs = [NSMutableArray new];
        NSArray<NSString*> *aryPaths = [fileManager contentsOfDirectoryAtPath:strFileDir error:nil];
        for(NSString *strPath in aryPaths){
            UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", strFileDir, strPath]];
            [muAryImgs addObject:img];
        }
    }
    return muAryImgs;
}
// ======================================================================================
#pragma mark - 动作触发方法
- (void) clickBtn:(UIButton*)btn
{
    switch (btn.tag) {
        case ViewTag_BtnSwitchAniType:{
            [self openSwitchAniType];
            break;
        }
        case ViewTag_BtnPhoto:{
            [self openPhoto];
            break;
        }
        default:
            break;
    }
}

// ======================================================================================
#pragma mark - UIActionSheetDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){ // 关闭按钮
        return;
    } else {
        [self handleSwitchAniType:(int)buttonIndex];
    }
}

- (NSArray<UIImage*>*) handleImgSize:(NSMutableArray<UIImage*>*) muAryOldImgs
{
//    NSMutableArray<UIImage*> *muAryNewImgs = [NSMutableArray new];
//    for(UIImage *oldImg in aryOldImgs){
//        @autoreleasepool{
//            UIImage *imgNew = [self handleImgSizeWithImgObj:oldImg];
//            [muAryNewImgs addObject:imgNew];
//            imgNew = nil;
//        }
//    }
    NSMutableArray<UIImage*> *muAryNewImgs = [NSMutableArray new];
    if(muAryOldImgs != nil){
        NSLog(@"while(muAryOldImgs.count > 0)");
        while(muAryOldImgs.count > 0){
            @autoreleasepool{
                UIImage *oldImg = muAryOldImgs[0];
                NSLog(@"handleImgSizeWithImgObj - start");
                UIImage *imgNew = [self handleImgSizeWithImgObj:oldImg];
                [muAryNewImgs addObject:imgNew];
                NSLog(@"handleImgSizeWithImgObj - end");
                imgNew = nil;
                [muAryOldImgs removeObject:oldImg];
                oldImg = nil;
            }
        }
    }
   
    return muAryNewImgs;
}
- (UIImage*) handleImgSizeWithImgObj:(UIImage*)oldImg
{
    CGSize sizeImg = mAnimationView.mImgSize;
    CGSize sizeNew;
    if(oldImg.size.height > oldImg.size.width){
        float value = oldImg.size.height / (float)sizeImg.height;
        sizeNew.height = (int)(sizeImg.height);
        sizeNew.width = (int)(oldImg.size.width /value);
    } else {
        float value = oldImg.size.width / (float)sizeImg.width;
        sizeNew.height = (int)(oldImg.size.height/value);
        sizeNew.width = (int)(sizeImg.width);
    }
    NSLog(@" [CPublic getImgWithNewSize:oldImg withNewSize:sizeNew] - start");
    UIImage *imgNew = [CPublic getImgWithNewSize:oldImg withNewSize:sizeNew];
    NSLog(@" [CPublic getImgWithNewSize:oldImg withNewSize:sizeNew] - end");
    oldImg = nil;
    return imgNew;
}
@end
