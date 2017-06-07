//
//  UIAlertAction+MyAlertAction.h
//  ImgAnimation
//
//  Created by LHJ on 2017/5/9.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertAction (MyAlertAction)

- (void) setTag:(int)index;

- (int) getTag;

@end
