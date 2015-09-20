//
//  UIViewController+showMarkView.m
//  Dota2Info
//
//  Created by Cusen on 15/9/19.
//  Copyright © 2015年 cusen. All rights reserved.
//

#import "UIViewController+showMarkView.h"
#import "MarkView.h"
#import "AppDelegate.h"

@implementation UIViewController (showMarkView)
- (void)showSelectMarkView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    MarkView *markView = [[MarkView alloc] initWithFrame:
                          CGRectMake(0, 0, rect.size.width, rect.size.height)];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:markView];
}
@end
