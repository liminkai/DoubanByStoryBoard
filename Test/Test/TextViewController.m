//
//  TextViewController.m
//  Test
//
//  Created by ethome on 16/7/29.
//  Copyright © 2016年 ethome. All rights reserved.
//

#import "TextViewController.h"
#import "TextTableViewCell.h"
#import "NSString+Md5.h"


@interface TextViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *statusArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayout;

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSMutableArray *array1 = [NSMutableArray arrayWithObjects:@"0",@"1",@"2",@"3", nil];
    
//    NSMutableArray *array2 = [NSMutableArray arrayWithObjects:@"1",@"2", nil];

    for (NSString *string1 in array1) {

        NSLog(@"%p,%@",string1,string1);
    }
    
//    for (NSString *string1 in array1) {
//        
//        if ([string1 isEqualToString:@"1"]) {
//            [array1 removeObject:string1];
//            
//            [array1 addObject:@"1"];
//        }
//        NSLog(@"%p,%@",string1,string1);
//    }
    
    for (int i = 0; i < array1.count; i ++) {
        
        NSString *string1 = array1[i];
        
        if ([string1 isEqualToString:@"1"]) {
            [array1 removeObject:string1];
            
            [array1 addObject:@"2"];
            i --;

        }
        

        NSLog(@"%p,%@",string1,string1);
        
    }
    

    
    NSString *str = @"lmk";
    
    
    
//    NSLog(@"%@",[str md5Digest]);
//    
//    NSLog(@"%f",[[NSDate date] timeIntervalSince1970]);
//    
//    NSLog(@"%@",[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]]);
    
    _statusArray = [NSMutableArray array];
    
    for (int i = 0; i < 5; i ++) {
        
        [_statusArray addObject:@"0"];
        
    }
    
    
    
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChangeAction:) name: UITextFieldTextDidChangeNotification object:self.textField];
    
    [self.textField addTarget:self action:@selector(changAction:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)changAction:(UITextField *)sender{
    
    NSString *text = sender.text;
    
    if (text.length == 0) {
        
        NSLog(@"没了");
        [UIView animateWithDuration:.5 animations:^{
            
            self.tableView.alpha = 1.f;

        }];
        
    }else{
        
        NSLog(@"有了");
        [UIView animateWithDuration:.5 animations:^{
            
            self.tableView.alpha = 0.f;
            
        }];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
    NSInteger status = [_statusArray[indexPath.row] integerValue];
    if (status == 0) {
        
        cell.selectImg.image = [UIImage imageNamed:@"RoomSelect9"];
    }else{
        cell.selectImg.image = [UIImage imageNamed:@"RoomSelect10"];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger status = [_statusArray[indexPath.row] integerValue];

    [_statusArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%d",!status]];
    
    NSInteger count = 0;
    for (NSString *statusStr in _statusArray) {
        
        if ([statusStr integerValue] == 1) {
            
            count ++;
        }
    }
    
    if (count > 0) {
        
        [UIView animateWithDuration:.5 animations:^{
            self.topLayout.constant = 0.f;
            [self.view layoutIfNeeded];
        }];
        
    }else{
        
        [UIView animateWithDuration:.5 animations:^{
            self.topLayout.constant = 200.f;
            [self.view layoutIfNeeded];
        }];
    }
    
//    if (status == 0) {
//        [UIView animateWithDuration:.5 animations:^{
//            self.topLayout.constant = 0.f;
//            [self.view layoutIfNeeded];
//        }];
//    }else{
//        [UIView animateWithDuration:.5 animations:^{
//            self.topLayout.constant = 200.f;
//            [self.view layoutIfNeeded];
//        }];
//        
//    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

@end
