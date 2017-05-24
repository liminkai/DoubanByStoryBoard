//
//  RoomDetailViewController.m
//  Test
//
//  Created by ethome on 16/6/22.
//  Copyright © 2016年 ethome. All rights reserved.
//

#import "RoomDetailViewController.h"

#import "NameTableViewCell.h"

#import "PushTableViewCell.h"

#import "NameHeadView.h"

#import "pushHeadView.h"

@interface RoomDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (weak, nonatomic) IBOutlet UIImageView *roomImg;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)NSMutableArray<NSNumber *> *isExpland;//这里用到泛型，防止存入非数字类型
@end

@implementation RoomDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomImg.userInteractionEnabled = YES;
    
    [self loadData];

    // Do any additional setup after loading the view.
}

- (void)loadData {
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    if (!self.isExpland) {
        self.isExpland = [NSMutableArray array];
    }
    
    self.dataArray = [NSArray arrayWithObjects:@[],@[],@[@"h",@"i",@"j",@"m",@"n"],nil].mutableCopy;
    //用0代表收起，非0代表展开，默认都是收起的
    for (int i = 0; i < self.dataArray.count; i++) {
        [self.isExpland addObject:@0];
    }
    [self.detailTableView reloadData];
}

- (IBAction)selectRoomAction:(UITapGestureRecognizer *)sender {
    
     [self.navigationController pushViewController:[UIViewController new] animated:YES];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *array = self.dataArray[section];
    if ([self.isExpland[section] boolValue]) {
        return array.count;
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController pushViewController:[UIViewController new] animated:YES];
        
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"nameHeadView" owner:nil options:nil];
        
        NameHeadView *nameHeadView = [nibContents lastObject];
        
        nameHeadView.tag = 10000 + section;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushAction:)];
        
        [nameHeadView addGestureRecognizer:tap];
        return nameHeadView;
        
    }else{
        
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"pushHeadView" owner:nil options:nil];
        
        pushHeadView *pushHeadView = [nibContents lastObject];
        pushHeadView.tag = 10000 + section;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushAction:)];
        
        [pushHeadView addGestureRecognizer:tap];
        return pushHeadView;
        
    }

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 44.f;
    
}

- (void)pushAction:(UITapGestureRecognizer *)sender{
    
    NSInteger section = sender.view.tag - 10000;
    
    //纪录展开的状态
    self.isExpland[section] = [self.isExpland[section] isEqual:@0]?@1:@0;

    if (section == 1) {
        
        [self.navigationController pushViewController:[UIViewController new] animated:YES];

    }else{
        
        //刷新点击的section
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
        [self.detailTableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
