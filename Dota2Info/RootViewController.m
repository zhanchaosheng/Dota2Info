//
//  RootViewController.m
//  Dota2Info
//
//  Created by 詹朝圣 on 15/7/5.
//  Copyright (c) 2015年 cusen. All rights reserved.
//

#import "RootViewController.h"
#import "HeroViewController.h"
#import "ItemsViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
CGFloat const tabViewHeight = 49;
CGFloat const btnHeight = 45;

@interface RootViewController ()

@property (nonatomic,strong) UIView *tabBarView;
@property (nonatomic,strong) UIImageView *selectView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViewController];
    [self initTabBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViewController
{
    HeroViewController *heroViewCtrl = [[HeroViewController alloc] init];
    //heroViewCtrl.title = @"英雄";
    ItemsViewController *itemsViewCtrl = [[ItemsViewController alloc] init];
    //itemsViewCtrl.title = @"物品";
    NSArray *viewCtrlArray = @[heroViewCtrl,itemsViewCtrl];
    NSMutableArray *navCtrlArray = [[NSMutableArray alloc] initWithCapacity:viewCtrlArray.count];
    for (int i = 0; i < viewCtrlArray.count; i++)
    {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrlArray[i]];
        [navCtrlArray addObject:navCtrl];
    }
    self.viewControllers = navCtrlArray;
}

- (void)initTabBarView
{
    self.tabBar.hidden = YES;//隐藏系统默认的样式
    //创建自定义tabBar
    self.tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - tabViewHeight, kScreenWidth, tabViewHeight)];
    self.tabBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backcolor"]];
    [self.view addSubview:self.tabBarView];
    
    //创建tabBar上的选项按钮
    NSArray *imgArray = @[@"home_tab_icon_1",@"home_tab_icon_2"];
    CGFloat btnWidth = kScreenWidth/2;
    for (int i = 0; i < imgArray.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:imgArray[i]] forState:UIControlStateNormal];
        btn.frame = CGRectMake(btnWidth * i + (btnWidth - 64)/2, (tabViewHeight - btnHeight)/2, 64, btnHeight);
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarView addSubview:btn];
    }
    
    //初始化选中图片视图（倒三角型）
    _selectView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth - 64)/2, 0, 64, btnHeight)];
    _selectView.image = [UIImage imageNamed:@"home_bottom_tab_arrow"];
    [_tabBarView addSubview:_selectView];
}

- (void)btnAction:(UIButton *)button{
    //根据tag值判断当前索引
    self.selectedIndex = button.tag - 100;
    //添加一个倒三角型移动动画
    [UIView animateWithDuration:0.2 animations:^{
        _selectView.center = button.center;
    } completion:nil];
}

- (void)showTabBar:(BOOL)show
{
    CGRect frame = self.tabBarView.frame;
    if (show)
    {
        frame.origin.x = 0;
    }
    else
    {
        frame.origin.x = - kScreenWidth;
    }
    //重新赋值frame
    [UIView animateWithDuration:0.2 animations:^{
        self.tabBarView.frame = frame;
    } completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
