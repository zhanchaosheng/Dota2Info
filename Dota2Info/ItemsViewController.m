//
//  ItemsViewController.m
//  Dota2Info
//
//  Created by 詹朝圣 on 15/7/5.
//  Copyright (c) 2015年 cusen. All rights reserved.
//

#import "ItemsViewController.h"
#import "BaseOperation.h"

@interface ItemsViewController ()
@property (nonatomic, strong) UITableView *itemTableView;
@property (nonatomic, strong) NSMutableArray *itemKeyArray;
@property (nonatomic, strong) NSMutableDictionary *itemDict;
@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"物品";
    [self.view setBackgroundColor:[UIColor purpleColor]];
    
    //创建ItemTableView
    self.itemTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.itemTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.itemTableView.backgroundColor = [UIColor brownColor];
    self.itemTableView.delegate = self;
    self.itemTableView.dataSource = self;
    
    [self.view addSubview:self.itemTableView];
    
    //注册物品数据加载完成通知
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(loadDataFinish:)
                               name:LOADITEMESEVENT
                             object:nil];
    [self loadItemData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LoadData
- (void)loadItemData
{
    //本地存在物品列表文件则从本地加载
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"Itemes.plist"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:filePath])
    {
        self.itemDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        self.itemKeyArray = [NSMutableArray arrayWithArray:[self.itemDict allKeys]];
    }
    else
    {
        [[BaseOperation sharedInstance] getDota2DataFromURL:Dota2DataTypeItemData];
    }
}

- (void)loadDataFinish:(NSNotification *)notify
{
    NSDictionary *userInfoDict = notify.userInfo;
    NSNumber *eventType = [userInfoDict objectForKey:@"eventType"];
    if ([eventType intValue] == 0)
    {
        //物品列表加载完成事件
        self.itemDict = [userInfoDict objectForKey:@"itemesData"];
        self.itemKeyArray = [NSMutableArray arrayWithArray:[self.itemDict allKeys]];
        [self.itemTableView reloadData];
    }
    else if ([eventType intValue] == 1)
    {
        //每加载完一个物品图片事件
        if (self.itemKeyArray == nil)
        {
            self.itemKeyArray = [NSMutableArray arrayWithCapacity:1];
        }
        if (self.itemDict == nil)
        {
            self.itemDict = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        NSString *itemKey = [userInfoDict objectForKey:@"key"];
        [self.itemKeyArray addObject:itemKey];
        [self.itemDict setObject:[userInfoDict objectForKey:@"itemesData"] forKey:itemKey];
        [self.itemTableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemKeyArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"itemTableViewCell";
    UITableViewCell *itemTableViewCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (itemTableViewCell == nil)
    {
        itemTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:identifier];
    }
    itemTableViewCell.backgroundColor = [UIColor orangeColor];
    itemTableViewCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    itemTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//cell右边小箭头
    //itemTableViewCell.detailTextLabel.tintColor = [UIColor blackColor];
    //itemTableViewCell.detailTextLabel.text = @"Info"; //cell右边小箭头前面文字，需要将UITableViewCellStyle设置为UITableViewCellStyleValue1
    //itemTableViewCell.textLabel.text = @"Item";
    NSString *key = self.itemKeyArray[indexPath.row];
    NSDictionary * item = [self.itemDict objectForKey:key];
    if (item)
    {
        //图片。物品名称。物品描述
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *itemName = [NSString stringWithFormat:@"itemes/%@.png",key];
        filePath = [filePath stringByAppendingPathComponent:itemName];
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        itemTableViewCell.imageView.layer.borderWidth = 2;
        itemTableViewCell.imageView.layer.borderColor = [[UIColor purpleColor] CGColor];
        itemTableViewCell.imageView.layer.cornerRadius = 10; //设置图片圆角
        itemTableViewCell.imageView.layer.masksToBounds = YES;
        if ([fileMgr fileExistsAtPath:filePath])
        {
            itemTableViewCell.imageView.image = [UIImage imageWithContentsOfFile:filePath];
        }
        else
        {
            itemTableViewCell.imageView.image = nil;
        }
        NSString *textLabelText = [item objectForKey:@"dname"];
        if (textLabelText == nil || textLabelText.length <= 0)
        {
            textLabelText = key;
        }
        NSRange range = [textLabelText rangeOfString:@"DOTA_Tooltip"];
        if (range.length > 0) {
            textLabelText = key;
        }
        itemTableViewCell.textLabel.text = textLabelText;
        NSString *detailText = [item objectForKey:@"desc"];
        if (detailText == nil || detailText.length <= 0)
        {
            detailText = [item objectForKey:@"lore"];
        }
        itemTableViewCell.detailTextLabel.text = detailText;
        itemTableViewCell.detailTextLabel.textColor = [UIColor blueColor];
        itemTableViewCell.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:11];
        itemTableViewCell.detailTextLabel.numberOfLines = 3;
    }
    return itemTableViewCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
