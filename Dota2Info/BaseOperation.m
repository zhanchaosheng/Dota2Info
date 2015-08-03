//
//  BaseOperation.m
//  Dota2Info
//
//  Created by 詹朝圣 on 15/7/5.
//  Copyright (c) 2015年 cusen. All rights reserved.
//

#import "BaseOperation.h"

static BaseOperation *sharedInstance = nil;

@implementation BaseOperation

+ (BaseOperation *)sharedInstance
{
    if (nil == sharedInstance)
    {
        @synchronized(self)
        {
            if (nil == sharedInstance)
            {
                sharedInstance = [[BaseOperation alloc] init];
            }
        }
    }
    return sharedInstance;
}

- (UIImage *)getImageFromUrl:(NSString *)fileURL
{
    //NSLog(@"正在从网络获取图片......");
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    UIImage *imageResult = [UIImage imageWithData:data];
    //NSLog(@"从网络获取图片结束");
    return imageResult;
}

- (UIImage *)getImageFromLocal:(NSString *)filePath
{
    //NSLog(@"正在从本地获取图片......");
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *imageResult = [UIImage imageWithData:data];
   // NSLog(@"从本地获取图片结束");
    return imageResult;
}

- (void)saveImage:(UIImage *)image
     withFileName:(NSString *)imageName
           ofType:(NSString *)exitension
  inDirectoryPath:(NSString *)directoryPath
{
    if ([[exitension lowercaseString] isEqualToString:@"png"])
    {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",imageName,@"png"]];
        NSLog(@"%@",filePath);
        [UIImagePNGRepresentation(image) writeToFile:filePath
                                             options:NSAtomicWrite
                                               error:nil];
    }
    else if ([[exitension lowercaseString] isEqualToString:@"jpg"] ||
             [[exitension lowercaseString] isEqualToString:@"jpeg"])
    {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",imageName,@"jpg"]];
        NSLog(@"%@",filePath);
        [UIImageJPEGRepresentation(image,1.0) writeToFile:filePath
                                             options:NSAtomicWrite
                                               error:nil];
    }
    else
    {
        NSLog(@"只支持保存PNG/JPG格式图片");
    }
}

- (NSString *)getDataUrl:(Dota2DataType)dataType
{
    NSString *getHerosURL;
    switch (dataType)
    {
        case Dota2DataTypeHeroData: //英雄列表数据
        {
            getHerosURL = @"https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key=EFA1E81676FCC47157EA871A67741EF5&language=zh_CN";
            break;
        }
        case Dota2DataTypeHeroEXData: //英雄扩展数据
        {
            getHerosURL = @"http://www.dota2.com/jsfeed/heropediadata?feeds=herodata&l=schinese";
            break;
        }
        case Dota2DataTypeItemData: //物品
        {
            getHerosURL = @"http://www.dota2.com/jsfeed/heropediadata?feeds=itemdata&l=schinese";
            break;
        }
        case Dota2DataTypeAbilityData: //技能
        {
            getHerosURL = @"http://www.dota2.com/jsfeed/heropediadata?feeds=abilitydata&l=schinese";
            break;
        }
        case Dota2DataTypeHeroItemAbilityData: //英雄+物品+技能
        {
            getHerosURL = @"http://www.dota2.com/jsfeed/heropediadata?feeds=herodata,itemdata,abilitydata&l=schinese";
            break;
        }
        default:
            break;
    }
    return getHerosURL;
}

- (void)ParseDota2Data:(NSData *)resultData forDataType:(Dota2DataType)dataType
{
    //Json解析
    NSError *error;
    id webData = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:resultData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
    NSDictionary *resultDict;
    if (error == nil && webData != nil)
    {
        //数据获取成功
        NSLog(@"Successfully deserialized … ");
        if([webData isKindOfClass:[NSDictionary class]])
        {
            //数据是NSDictionary
            resultDict = (NSDictionary *)webData;
            switch (dataType)
            {
                case Dota2DataTypeHeroData: //英雄列表数据
                {
                    [self parseHeroData:resultDict];
                    break;
                }
                case Dota2DataTypeHeroEXData: //英雄扩展数据
                {
                    
                    break;
                }
                case Dota2DataTypeItemData: //物品
                {
                    [self parseItemData:resultDict];
                    break;
                }
                case Dota2DataTypeAbilityData: //技能
                {
                    
                    break;
                }
                case Dota2DataTypeHeroItemAbilityData: //英雄+物品+技能
                {
                    
                    break;
                }
                default:
                    break;
            }
            
        }
        else if([webData isKindOfClass:[NSArray class]])
        {
            //数据是NSArray
            NSArray *deserializedArray = (NSArray *)webData;
            NSLog(@"Dersialized JSON Array =%@",deserializedArray);
        }
    }
    else if(error != nil)
    {
        NSLog(@"An error happened while deserializing the JSON data.");
    }
}

- (void)parseHeroData:(NSDictionary *)herosDict
{
    NSDictionary *resultDict = [herosDict objectForKey:@"result"];
    if ([(NSNumber *)[resultDict objectForKey:@"status"] longValue] == 200 &&
        [(NSNumber *)[resultDict objectForKey:@"count"] longValue] > 0)
    {
        NSArray *heroes = [resultDict objectForKey:@"heroes"];
        //保存英雄列表到文件
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        filePath = [filePath stringByAppendingPathComponent:@"heroes.plist"];
        if ([heroes writeToFile:filePath atomically:YES])
        {
            //加载英雄列表完成通知视图控制器
            NSDictionary *userInfoDict = @{@"eventType":[NSNumber numberWithInt:0]};
            [self notifcationViewController:userInfoDict andNotifyName:LOADHEROESEVENT];
            
            //下载英雄图片
            [self loadHeroIcon:heroes];
        }
        else
        {
            NSLog(@"write heroes data to file fail.");
        }
    }

}

- (void)parseItemData:(NSDictionary *)itemDict
{
    NSDictionary *itemesDict = [itemDict objectForKey:@"itemdata"];
    if (itemesDict)
    {
        //检查、保存物品数据，并下载物品图片
        [self chackAndSavaItemDate:itemesDict];
    }
}

- (void)getDota2DataFromURL:(Dota2DataType)dataType
{
    NSString *getDataURL = [self getDataUrl:dataType];
    
    //方法1：通过NSData直接获取
    //    NSData *herosData = [NSData dataWithContentsOfURL:[NSURL URLWithString:getHerosURL]];
    
    //方法2：通过NSURLConnection获取
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:getDataURL]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                            timeoutInterval:60.0f];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(data.length > 0 && connectionError == nil)
                               {
                                   [self ParseDota2Data:data forDataType:dataType];
                               }
                               else if(data.length == 0 && connectionError == nil)
                               {
                                   NSLog(@"Nothing was downloaded.");
                               }
                               else if(connectionError != nil)
                               {
                                   NSLog(@"Error happened = %@",connectionError);
                               }
                           }];
}


- (void)loadHeroIcon:(NSArray *)heroesArray
{
    if (_bHeroImageLoading)
    {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (heroesArray.count == 0)
        {
            return;
        }
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *heroesDir = [documentDir stringByAppendingPathComponent:@"heroes"];
        //创建英雄图片存放目录
        NSError *error;
        [fileMgr createDirectoryAtPath:heroesDir
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
        if (error != nil)
        {
            NSLog(@"Create heroes dir fail! error:%@",error.description);
            return;
        }
        for (int i = 0; i < heroesArray.count; i++)
        {
            NSDictionary *hero = heroesArray[i];
            NSString *heroName = [hero objectForKey:@"name"];
            NSRange range = [heroName rangeOfString:@"npc_dota_hero_"];
            if (range.length > 0)
            {
                heroName = [heroName substringFromIndex:range.length];
                
                NSString *filePath = [NSString stringWithFormat:@"%@.png",heroName];
                filePath = [heroesDir stringByAppendingPathComponent:filePath];
                
                if (![fileMgr fileExistsAtPath:filePath])
                {
                    @autoreleasepool
                    {
                        //从网络下载图片
                        NSString *heroIocnUrl = [NSString stringWithFormat:@"http://www.dota2.com.cn/images/heroes/%@_hphover.png",heroName];
                        UIImage *image = [self getImageFromUrl:heroIocnUrl];
                        //保存图片到本地
                        [self saveImage:image
                           withFileName:heroName
                                 ofType:@"png"
                        inDirectoryPath:heroesDir];
                    }
                    
                }
                
                //下载完成通知界面创新
                NSDictionary *userInfoDict = @{@"eventType":[NSNumber numberWithInt:1],
                                               @"row":[NSNumber numberWithInteger:i]};
                [self notifcationViewController:userInfoDict andNotifyName:LOADHEROESEVENT];
                
            }
        }
        
    });
}

- (void)notifcationViewController:(NSDictionary *)userInfoDict
                    andNotifyName:(NSString *)notifyName
{
    //一定要在主线程中通知界面创新，否则界面不会正常更新
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notifcationCenter = [NSNotificationCenter defaultCenter];
        //[notifcationCenter postNotificationName:LOADHEROESEVENT object:nil];
        [notifcationCenter postNotificationName:notifyName
                                         object:nil
                                       userInfo:userInfoDict];
    });
}

- (void)chackAndSavaItemDate:(NSDictionary *)itemesDict
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *itemesDir = [documentDir stringByAppendingPathComponent:@"itemes"];
    //创建物品图片存放目录
    NSError *error;
    [fileMgr createDirectoryAtPath:itemesDir
       withIntermediateDirectories:YES
                        attributes:nil
                             error:&error];
    if (error != nil)
    {
        NSLog(@"Create itemes dir fail! error:%@",error.description);
        return;
    }
    
    NSMutableDictionary *itemMutableDict = [[NSMutableDictionary alloc] initWithDictionary:itemesDict];
    
    //注意：在快速遍历和枚举遍历字典过程中修改值会引起崩溃。原因暂时未知，猜测是修改引起了字典中各健值对的地址发生变化，修改后继续访问下一个键值对时出错
    for (id key in [itemMutableDict allKeys])
    {
        NSDictionary *valueDict = [itemMutableDict objectForKey:key];
        if (valueDict)
        {
            NSArray *componentsArray = [valueDict objectForKey:@"components"];
            if ((NSNull *)componentsArray == [NSNull null])
            {
                NSMutableDictionary *valueDictTemp = [[NSMutableDictionary alloc] initWithDictionary:valueDict];
                [valueDictTemp removeObjectForKey:@"components"];
                [itemMutableDict setObject:valueDictTemp forKey:key];
            }
        }
        
        //下载物品图片
        NSString *filePath = [NSString stringWithFormat:@"%@.png",key];
        filePath = [itemesDir stringByAppendingPathComponent:filePath];
        
        BOOL bSendData = NO;
        
        if (![fileMgr fileExistsAtPath:filePath])
        {
            @autoreleasepool
            {
                //从网络下载图片
                NSString *itemImageUrl = [NSString stringWithFormat:@"http://www.dota2.com.cn/items/images/%@_lg.png",key];
                UIImage *image = [self getImageFromUrl:itemImageUrl];
                //保存图片到本地
                if (image)
                {
                    [self saveImage:image
                       withFileName:key
                             ofType:@"png"
                    inDirectoryPath:itemesDir];
                    bSendData = YES;
                }
                else
                {
                    //图片下载失败的则删除
                    [itemMutableDict removeObjectForKey:key];
                }
            }
            
        }
        else
        {
            bSendData = YES;
        }
        
        if (bSendData)
        {
            //加载物品列表完成通知视图控制器
            NSDictionary *userInfoDict = @{@"eventType":[NSNumber numberWithInt:1],
                                           @"key":key,
                                           @"itemesData":[itemMutableDict objectForKey:key]};
            [self notifcationViewController:userInfoDict andNotifyName:LOADITEMESEVENT];
        }
    }
    
    //保存物品列表到文件
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"Itemes.plist"];
    if ([itemMutableDict writeToFile:filePath atomically:YES])
    {
        NSLog(@"successfully!");
        
    }
    else
    {
        NSLog(@"write itemes data to file fail.");
    }
}

@end
