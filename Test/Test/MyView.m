//
//  MyView.m
//  Test
//
//  Created by ethome on 16/4/6.
//  Copyright © 2016年 ethome. All rights reserved.
//

#import "MyView.h"

@interface MyView()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_dataArray;
    NSArray *_nameArray;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MyView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initTableView:frame];
        
        
        _dataArray = @[@"全天录像",@"报警录像",@"录像关闭"];
        
        [_tableView reloadData];
    }
    return self;
}

-(void)initTableView:(CGRect)frame{
    _tableView                 = [[UITableView alloc] initWithFrame:frame];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_id"];
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [_dataArray objectAtIndex:indexPath.row];
    
    NSLog(@"%@",title);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RecordBtnClick" object:nil userInfo:@{@"Title" : title}];

    
    
}


@end
