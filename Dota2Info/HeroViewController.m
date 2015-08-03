//
//  HeroViewController.m
//  Dota2Info
//
//  Created by 詹朝圣 on 15/7/5.
//  Copyright (c) 2015年 cusen. All rights reserved.
//

#import "HeroViewController.h"
#import "BaseOperation.h"
#import "myCollectionViewCell.h"

@interface HeroViewController ()
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *herosArray;
@end

@implementation HeroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"英雄";
    [self.view setBackgroundColor:[UIColor orangeColor]];
    
    //创建导航条右边自定义按钮
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.frame = CGRectMake(0, 0, 33, 32);
    [btnRight setBackgroundImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
    [btnRight addTarget:self
                 action:@selector(heroSort)
       forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = barBtn;
    
    //创建CollectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_collectionView];
    
    //注册collectionViewCell类
    [self.collectionView registerClass:[myCollectionViewCell class]
            forCellWithReuseIdentifier:@"myCollectionViewCell"];
    
    //注册图片下载完成通知
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(ReloadView:)
                               name:LOADHEROESEVENT
                             object:nil];
    [self loadData];
    
    //[[BaseOperation sharedInstance] getDota2DataFromURL:Dota2DataTypeHeroData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)heroSort
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"属性分类"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"力量",@"敏捷",@"智力",nil];
    [actionSheet showInView:self.view];
}

- (void)ReloadView:(NSNotification *)sender
{
    NSDictionary *userInfoDict = sender.userInfo;
    NSNumber *eventType = [userInfoDict objectForKey:@"eventType"];
    if ([eventType intValue] == 0)
    {
        //英雄列表加载完成事件
        [self loadData];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    else if ([eventType intValue] == 1)
    {
        //英雄图片加载完成事件
        //[self.collectionView reloadData];
        //可以考虑一下创新具体某一个cell，而不是全部创新
        //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        NSInteger row = [[userInfoDict objectForKey:@"row"] integerValue];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
    }
}

- (void)loadData
{
    //本地存在英雄列表文件则从本地加载
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"heroes.plist"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:filePath])
    {
        self.herosArray = [NSArray arrayWithContentsOfFile:filePath];
    }
    else
    {
        [[BaseOperation sharedInstance] getDota2DataFromURL:Dota2DataTypeHeroData];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"力量");
            break;
        case 1:
            NSLog(@"敏捷");
            break;
        case 2:
            NSLog(@"智力");
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.herosArray.count;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    myCollectionViewCell *myCell = (myCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"myCollectionViewCell" forIndexPath:indexPath];
    
    //加载图片
    NSDictionary *hero = self.herosArray[indexPath.row];
    if (hero)
    {
        NSString *heroName = [hero objectForKey:@"name"];
        NSRange range = [heroName rangeOfString:@"npc_dota_hero_"];
        if (range.length > 0)
        {
            heroName = [heroName substringFromIndex:range.length];
            NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            heroName = [NSString stringWithFormat:@"heroes/%@.png",heroName];
            filePath = [filePath stringByAppendingPathComponent:heroName];
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            if ([fileMgr fileExistsAtPath:filePath])
            {
                myCell.ImageView.image = [UIImage imageWithContentsOfFile:filePath];
                myCell.heroNameLabel.text = [hero objectForKey:@"localized_name"];
            }
            else
            {
                myCell.ImageView.image = nil;
                myCell.heroNameLabel.text = nil;
            }
        }
    }
    else
    {
        myCell.ImageView.image = nil;
        myCell.heroNameLabel.text = nil;
    }
    //[myCell setNeedsLayout];
    return myCell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *msg = [NSString stringWithFormat:@"Select Item At %ld ",(long)indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"yes,I do"
                                          otherButtonTitles:nil];
    [alert show];
    return;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UICollectViewDelegeteLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = self.view.bounds;
    CGFloat cellWidth = (rect.size.width-20)/4;
    return CGSizeMake(cellWidth, 55+15);
}

//定义每个UICollectionView 的间距（返回UIEdgeInsets：上、左、下、右）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//定义每个UICollectionView 纵向的间距（同一行相邻cell之间的距离）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//定义每个UICollectionView 横向的间距（同一列相邻cell之间的距离）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
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
