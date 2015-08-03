//
//  AppDelegate.m
//  Dota2Info
//
//  Created by 詹朝圣 on 15/7/5.
//  Copyright (c) 2015年 cusen. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "PkRevealController.h"

@interface AppDelegate ()<PKRevealing>
@property (strong, nonatomic) PKRevealController *revealController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    //主视图控制器
    RootViewController *rootViewCtrl = [[RootViewController alloc] init];
    //左视图控制器
    UIViewController *leftViewCtrl = [[UIViewController alloc] init];
    leftViewCtrl.view.backgroundColor = [UIColor whiteColor];
    UIButton *localPushBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    localPushBtn.frame = CGRectMake(30, 30, 100, 25);
    [localPushBtn setTitle:@"本地推送" forState:UIControlStateNormal];
    [localPushBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftViewCtrl.view addSubview:localPushBtn];
    //右视图控制器
    UIViewController *rightViewCtrl = [[UIViewController alloc] init];
    rightViewCtrl.view.backgroundColor = [UIColor grayColor];
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:rootViewCtrl leftViewController:leftViewCtrl rightViewController:rightViewCtrl];
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    
    //IOS8以上系统需要注册推送通知
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    self.window.rootViewController = self.revealController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Application did receive local notifications");
    notification.applicationIconBadgeNumber--;
    [UIApplication sharedApplication].applicationIconBadgeNumber--;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"welcome" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)btnClicked:(UIButton *)sender
{
    // 初始化本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification)
    {
        // 设置通知的提醒时间
        NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [currentDate dateByAddingTimeInterval:5.0];
        
        // 设置重复间隔
        notification.repeatInterval = 0;//kCFCalendarUnitMinute;
        
        // 设置提醒的文字内容
        notification.alertBody   = @"Wake up, man";
        notification.alertAction = @"起床了";
        
        // 通知提示音 使用默认的
        notification.soundName= UILocalNotificationDefaultSoundName;
        
        // 设置应用程序右上角的提醒个数
        notification.applicationIconBadgeNumber++;
        
        // 设定通知的userInfo，用来标识该通知
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        aUserInfo[@"key"] = @"LocalNotificationID";
        notification.userInfo = aUserInfo;
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
