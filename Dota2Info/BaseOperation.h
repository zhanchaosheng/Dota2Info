//
//  BaseOperation.h
//  Dota2Info
//
//  Created by 詹朝圣 on 15/7/5.
//  Copyright (c) 2015年 cusen. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define LOADHEROESEVENT  @"loadHeroesEvent"
#define LOADITEMESEVENT  @"loadItemesEvent"
#define LOADABILITYEVENT @"loadAbilityEvent"

typedef NS_ENUM(NSUInteger, Dota2DataType)
{
    Dota2DataTypeHeroData = 0,       //英雄
    Dota2DataTypeHeroEXData,         //英雄扩展信息
    Dota2DataTypeItemData,           //物品
    Dota2DataTypeAbilityData,        //技能
    Dota2DataTypeHeroItemAbilityData //英雄+物品+技能
};

@interface BaseOperation : NSObject
{
    BOOL _bHeroImageLoading;
}

+ (BaseOperation *)sharedInstance;

//从网络获取一张图片
- (UIImage *)getImageFromUrl:(NSString *)fileURL;

//从本地获取一张图片
- (UIImage *)getImageFromLocal:(NSString *)filePath;

//将图片保存到本地
- (void)saveImage:(UIImage *)image
     withFileName:(NSString *)imageName
           ofType:(NSString *)exitension
  inDirectoryPath:(NSString *)directoryPath;

//从网络获取Dota2数据
- (void)getDota2DataFromURL:(Dota2DataType)dataType;

@end
