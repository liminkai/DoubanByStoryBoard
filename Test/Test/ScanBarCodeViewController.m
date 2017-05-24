//
//  ScanBarCodeViewController.h
//  iPhoneDS
//
//  Created by pro on 16/4/15.
//  Copyright © 2016年 . All rights reserved.
//

#import "ScanBarCodeViewController.h"

#define SCREEN_FRAME [UIScreen mainScreen].bounds
@interface ScanBarCodeViewController ()
{
    int        _num;        //扫描线移动偏移
    BOOL       _upOrdown;   //扫描线移动方向
    NSTimer    *_timer;     //动画计时器
}

@end

@implementation ScanBarCodeViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.previewFrame = CGRectMake((SCREEN_FRAME.size.width-200)/2, (SCREEN_FRAME.size.height-200)/2, 200, 200);
        
    }
    return self;
}

/**
 * 视图将要显示时，准备摄像头
 * 注意：模拟器会报错，必须真机
 */
-(void)viewWillAppear:(BOOL)animated
{
    NSString *device = [UIDevice currentDevice].model;
    if ([device rangeOfString:@"Simulator"].location > device.length) {
        [self setupCamera];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //信息展示框
    self.introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.previewFrame.origin.y-50, SCREEN_FRAME.size.width, 30)];
    self.introduceLabel.backgroundColor = [UIColor clearColor];
    self.introduceLabel.numberOfLines = 2;
    self.introduceLabel.textColor = [UIColor redColor];
    self.introduceLabel.text = @"将二维码/条码放入框内,即可自动扫描.";
    self.introduceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.introduceLabel];
    
    //取消按钮
	self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.cancelBtn setBackgroundColor:[UIColor blueColor];
    [self.cancelBtn.layer setMasksToBounds:YES];
    [self.cancelBtn.layer setCornerRadius:5.0];
    self.cancelBtn.frame = CGRectMake((SCREEN_FRAME.size.width-120)/2,SCREEN_FRAME.size.height - 100, 120, 40);
    [self.cancelBtn addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];

    //设置扫描框图片
    self.previewImageView = [[UIImageView alloc] initWithFrame:self.previewFrame];
    self.previewImageView.image = [UIImage imageNamed:@"扫描框图片名"];
    [self.view addSubview:self.previewImageView];
    
    //初始化扫描线
    _upOrdown = NO;
    _num = 0;
    self.scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.previewFrame.origin.x+20, self.previewFrame.origin.y+20, self.previewFrame.size.width-40, 2)];
    self.scanLine.image = [UIImage imageNamed:@"patientNotesCardLine"];//临时用的扫描线：
    [self.view addSubview:self.scanLine];
    //计时动画
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scanLineAnimation) userInfo:nil repeats:YES];
}

/**
 * 扫描线上下移动动画
 */
-(void)scanLineAnimation
{
    if (_upOrdown == NO) {
        _num ++;
        self.scanLine.frame = CGRectMake(self.previewFrame.origin.x+20, self.previewFrame.origin.y+20+2*_num, self.previewFrame.size.width-40, 2);
        if (2*_num == self.previewFrame.size.width-40) {
            _upOrdown = YES;
        }
    }else {
        _num --;
        self.scanLine.frame = CGRectMake(self.previewFrame.origin.x+20, self.previewFrame.origin.y+20+2*_num, self.previewFrame.size.width-40, 2);
        if (_num == 0) {
            _upOrdown = NO;
        }
    }
}

/**
 * 取消按钮事件
 */
-(void)cancelButtonPress:(UIButton *)button
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        [_timer invalidate];
        [self.delegate scanCallback:nil];
    }];
}


/**
 * 准备摄像头
 */
- (void)setupCamera
{
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeUPCECode,
                                   AVMetadataObjectTypeCode39Code,
                                   AVMetadataObjectTypeCode39Mod43Code,
                                   AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeEAN8Code,
                                   AVMetadataObjectTypeCode93Code,
                                   AVMetadataObjectTypeCode128Code,
                                   AVMetadataObjectTypePDF417Code,
                                   AVMetadataObjectTypeQRCode,
                                   AVMetadataObjectTypeAztecCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.previewFrame;
    [_preview.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [self.view.layer insertSublayer:self.preview atIndex:0];

    // Start
    [_session startRunning];
    
}

/**
 * 扫描完成实现代理
 */
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        [_timer invalidate];
        [self.preview removeFromSuperlayer];
        [self.view removeFromSuperview];
        [self.delegate scanCallback:stringValue];
    }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
