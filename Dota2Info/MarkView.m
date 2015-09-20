//
//  MarkView.m
//  Dota2Info
//
//  Created by Cusen on 15/9/19.
//  Copyright © 2015年 cusen. All rights reserved.
//

#import "MarkView.h"

@implementation MarkView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.image = [UIImage imageNamed:@"05.jpg"];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [self removeFromSuperview];
}

@end
