//
//  myCollectionViewCell.m
//  myDmeo
//
//  Created by Eddy on 15-6-12.
//  Copyright (c) 2015年 huawei. All rights reserved.
//

#import "myCollectionViewCell.h"

@implementation myCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor orangeColor];

        CGRect rect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height - 15);
        //英雄图片
        self.ImageView = [[UIImageView alloc] initWithFrame:rect];
        self.ImageView.layer.cornerRadius = 5;
        self.ImageView.layer.masksToBounds = YES;
        [self addSubview:self.ImageView];

        //英雄名
        rect = CGRectMake(self.bounds.origin.x, self.bounds.size.height - 14, self.bounds.size.width, 12);
        self.heroNameLabel = [[UILabel alloc] initWithFrame:rect];
        self.heroNameLabel.textAlignment = NSTextAlignmentCenter;
        self.heroNameLabel.font = [UIFont fontWithName:@"Arial" size:12];
        [self addSubview:self.heroNameLabel];
    }
    return self;
}

- (void)loadFromNib
{
    //加载cell对应的xib文件
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"myCollectionViewCell" owner:self options:nil];
    //加载失败返回
    if (arrayOfViews.count < 1)
    {
        //return nil;
    }
    //xib中的view不属于UICollectionViewCell类，则返回
    if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
    {
        //return nil;
    }
    //self = [arrayOfViews objectAtIndex:0];
}
@end
