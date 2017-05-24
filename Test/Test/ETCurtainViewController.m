//
//  ETCurtainViewController.m
//  Test
//
//  Created by ethome on 16/9/19.
//  Copyright © 2016年 ethome. All rights reserved.
//

#import "ETCurtainViewController.h"

#import "LoadingHUD.h"


@interface ETCurtainViewController ()
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWidth;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (nonatomic, assign) CGPoint oriPoint;

@property (nonatomic, assign) CGFloat oriWidth;

@property (nonatomic, assign) CGFloat allWidth;

@property (nonatomic, assign) CGFloat centerWidth;

@property (nonatomic, assign) CGFloat screenWidth;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, assign) CGFloat distance;

@end

#define ORIWIDTH 50


@implementation ETCurtainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LoadingHUD showHUD];
    
    _oriWidth = self.leftWidth.constant;
    
    _allWidth = self.view.center.x;
    
    [self.mySlider setThumbImage:[UIImage imageNamed:@"huakuai"] forState:UIControlStateNormal];
    [self.mySlider setThumbImage:[UIImage imageNamed:@"huakuai"] forState:UIControlStateHighlighted];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)panAction:(UIPanGestureRecognizer *)sender {
    
    CGFloat allWidth = self.view.center.x;
    
    NSLog(@"约束%f,%f",self.leftWidth.constant,allWidth);
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            
            _oriPoint = [sender locationInView:sender.view];
            
            NSLog(@"%f,%f",_oriPoint.x,_oriPoint.y);
            
        }
            break;
            
        case UIGestureRecognizerStateChanged:{
            
            CGPoint newPoint = [sender locationInView:sender.view];
            
            if (sender.view == _leftView) {
                
                _distance = _oriWidth + newPoint.x - _oriPoint.x;

            }else{
                
                _distance = _oriWidth - (newPoint.x - _oriPoint.x);

            }
            
            NSLog(@"距离%f，现在的距离%f",newPoint.x - _oriPoint.x,_distance);
            
            [UIView animateWithDuration:0.1 animations:^{
                
                if (_distance <= allWidth && _distance >= ORIWIDTH) {
                    
                    self.leftWidth.constant = _distance;
                    
                    self.rightWidth.constant = _distance;
                
                    [self.view layoutIfNeeded];
                }else{
                    
                    NSLog(@"超出了范围");
                }
                
            }];
            
            
        }
            break;
        case UIGestureRecognizerStateEnded:{
            
            CGPoint endPoint = [sender locationInView:sender.view];
            CGFloat distance;
            if (sender.view == _leftView) {
                
                distance = endPoint.x - _oriPoint.x;

            }else{
                
                distance = _oriPoint.x - endPoint.x;

            }
            
            if (self.leftWidth.constant > allWidth) {
                
                _oriWidth = allWidth;
                _distance = allWidth;
                
                self.leftWidth.constant = allWidth;
                self.rightWidth.constant = allWidth;
                
                _value = @"10";
                
                
            }else if(self.leftWidth.constant < ORIWIDTH){
                
                _oriWidth = ORIWIDTH;
                _distance = ORIWIDTH;
                self.leftWidth.constant = ORIWIDTH;
                self.rightWidth.constant = ORIWIDTH;
                
                _value = @"0";
                
            }else{
                
                _oriWidth += distance;
                
                int value = (int)(_oriWidth - 50)/(allWidth - 20 - ORIWIDTH) * 10;
                
                _value = [NSString stringWithFormat:@"%d",value > 10?10:value];
                
                _value = [NSString stringWithFormat:@"%d",value < 0?0:value];

                
                if ([_value isEqualToString:@"10"]) {
                    
                    _oriWidth = allWidth;
                    
                    _distance = allWidth;
                    
                    self.leftWidth.constant = allWidth;
                    self.rightWidth.constant = allWidth;
                    
                }else if ([_value integerValue] <= 0){
                    
                    _oriWidth = ORIWIDTH;
                    _distance = ORIWIDTH;
                    self.leftWidth.constant = ORIWIDTH;
                    self.rightWidth.constant = ORIWIDTH;
                    
                }
                
            }
            
            NSLog(@"距离%f,总距离%f,百分比%@",_oriWidth,(allWidth - 70),_value);
            
        }
            break;
            
        default:
            break;
    }
    
    
}

- (IBAction)valueChangeAction:(UISlider *)sender {
    CGFloat allWidth = self.view.center.x - 20 - ORIWIDTH;
    
    [UIView animateWithDuration:0.1 animations:^{
        if (sender.value == 0) {
            self.leftWidth.constant = ORIWIDTH + allWidth * sender.value;
            
            self.rightWidth.constant = ORIWIDTH + allWidth * sender.value;
        }else{
            
            self.leftWidth.constant = ORIWIDTH + allWidth * sender.value + 20;
            
            self.rightWidth.constant = ORIWIDTH + allWidth * sender.value + 20;
        }
        
        
        [self.view layoutIfNeeded];
        
    }];
}

- (IBAction)touchAction:(UISlider *)sender {
    //    CGFloat allWidth = self.view.center.x - 20 - ORIWIDTH;
    //
    //    [UIView animateWithDuration:0.5 animations:^{
    //
    //        self.leftWidth.constant = ORIWIDTH + allWidth * sender.value;
    //
    //        self.rightWidth.constant = ORIWIDTH + allWidth * sender.value;
    //
    //        [self.view layoutIfNeeded];
    //
    //    }];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    
    
    CGPoint touchPoint = [sender locationInView:self.mySlider];
    CGFloat value = (self.mySlider.maximumValue - self.mySlider.minimumValue) * (touchPoint.x / self.mySlider.frame.size.width );
    [self.mySlider setValue:value animated:YES];
    CGFloat allWidth = self.view.center.x - 20 - ORIWIDTH;
    
    
    [UIView animateWithDuration:1. animations:^{
        
        self.leftWidth.constant = ORIWIDTH + allWidth * value + 20;
        
        self.rightWidth.constant = ORIWIDTH + allWidth * value + 20;
        
        [self.view layoutIfNeeded];
        
    }];
    
}
- (IBAction)closeAction:(UIButton *)sender {
    [UIView animateWithDuration:1. animations:^{
        
        self.leftWidth.constant = ORIWIDTH;
        
        self.rightWidth.constant = ORIWIDTH;
        
        self.mySlider.value = 0.f;
        
        [self.view layoutIfNeeded];
        
    }];
}
- (IBAction)openAction:(UIButton *)sender {
    CGFloat allWidth = self.view.center.x - 20 - ORIWIDTH;
    
    [UIView animateWithDuration:1. animations:^{
        
        self.leftWidth.constant = ORIWIDTH + allWidth + 20;
        
        self.rightWidth.constant = ORIWIDTH + allWidth + 20;
        
        self.mySlider.value = 1.f;
        
        [self.view layoutIfNeeded];
        
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%ld",(long)[[UIApplication sharedApplication] statusBarOrientation]);
    CGFloat allWidth;
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        
        allWidth = MIN(self.view.frame.size.width, self.view.frame.size.height)/2;
    }else{
        
        allWidth = MAX(self.view.frame.size.height, self.view.frame.size.width)/2 ;
        
    }
    if (_screenWidth != allWidth) {
        if (allWidth - _allWidth > 0) {
            
            _centerWidth = allWidth - _allWidth;
            
            self.leftWidth.constant += _centerWidth;
            
            self.rightWidth.constant += _centerWidth;
            
            _oriWidth = self.leftWidth.constant;
            
        }else{
            _oriWidth -= _centerWidth;
            self.leftWidth.constant = _oriWidth;
            
            self.rightWidth.constant = _oriWidth;
        }
        
        
        [self.view layoutIfNeeded];
    }
    
    
    _screenWidth = allWidth;
    
}

@end
