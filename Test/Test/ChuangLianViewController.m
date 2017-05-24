               //
//  ChuangLianViewController.m
//  Test
//
//  Created by ethome on 16/9/19.
//  Copyright © 2016年 ethome. All rights reserved.
//

#import "ChuangLianViewController.h"

@interface ChuangLianViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWidth;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (nonatomic, assign) BOOL isHengping;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@end

@implementation ChuangLianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.bottomView bringSubviewToFront:self.mySlider];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {

    CGPoint touchPoint = [sender locationInView:self.mySlider];
    CGFloat value = (self.mySlider.maximumValue - self.mySlider.minimumValue) * (touchPoint.x / self.mySlider.frame.size.width );
    [self.mySlider setValue:value animated:YES];
    CGFloat allWidth = self.view.center.x - 20 - 50;
    
    
    [UIView animateWithDuration:1. animations:^{
        
        self.leftWidth.constant = 50 + allWidth * value;
        
        self.rightWidth.constant = 50 + allWidth * value;
        
        [self.view layoutIfNeeded];
        
    }];
    

}

- (IBAction)changeAction:(UISlider *)sender {
    CGFloat allWidth = self.view.center.x - 20 - 50;
    
    [UIView animateWithDuration:0.1 animations:^{
        
        self.leftWidth.constant = 50 + allWidth * sender.value;
        
        self.rightWidth.constant = 50 + allWidth * sender.value;
        
        [self.view layoutIfNeeded];
        
    }];
    
    
}



- (IBAction)upInsideAction:(UISlider *)sender {
    
    
    CGFloat allWidth = self.view.center.x - 20 - 50;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.leftWidth.constant = 50 + allWidth * sender.value;
        
        self.rightWidth.constant = 50 + allWidth * sender.value;
        
        [self.view layoutIfNeeded];
        
    }];
    
    NSLog(@"%f,%f,%f",sender.value,self.leftWidth.constant,self.rightWidth.constant);

}


- (IBAction)closeAction:(UIButton *)sender {
    
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.leftWidth.constant = 50;
        
        self.rightWidth.constant = 50;
        
        self.mySlider.value = 0.f;

        [self.view layoutIfNeeded];
        
    }];
    
}
- (IBAction)openAction:(UIButton *)sender {
    CGFloat allWidth = self.view.center.x - 20 - 50;

    [UIView animateWithDuration:1. animations:^{
        
        self.leftWidth.constant = 50 + allWidth;
        
        self.rightWidth.constant = 50 + allWidth;
        
        self.mySlider.value = 1.f;
        
        [self.view layoutIfNeeded];
        
    }];
    
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%ld",(long)[[UIApplication sharedApplication] statusBarOrientation]);
    CGFloat allWidth;
    if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        allWidth = self.view.frame.size.width/2 - 20 - 50;
    }else{
        
        allWidth = self.view.frame.size.height/2 - 20 - 50;

    }
    
//    [UIView animateWithDuration:0.5 animations:^{
    
        self.leftWidth.constant = 50 + allWidth * self.mySlider.value;
        
        self.rightWidth.constant = 50 + allWidth * self.mySlider.value;
        
        [self.view layoutIfNeeded];
        
//    }];
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
