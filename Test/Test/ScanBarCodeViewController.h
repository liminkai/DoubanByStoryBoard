//
//  ScanBarCodeViewController.h
//  iPhoneDS
//
//  Created by pro on 16/4/15.
//  Copyright © 2016年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ScanBarCodeDelegate <NSObject>

- (void)scanCallback:(NSString *)dimensionCode;

@end

@interface ScanBarCodeViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>


//扫描完成的回调
@property (strong,nonatomic)     id<ScanBarCodeDelegate>    delegate;

//介绍标签
@property (strong,nonatomic)     UILabel                   *introduceLabel;
//取消按钮
@property (strong,nonatomic)     UIButton                  *cancelBtn;
//扫描框
@property (strong,nonatomic)     UIImageView               *previewImageView;
//扫描线
@property (nonatomic,retain)     UIImageView               *scanLine;
//扫描框区域大小
@property (nonatomic,readwrite)  CGRect                    previewFrame;

/**
 *  获取相机设备进行扫描
 */
@property (strong,nonatomic)     AVCaptureDevice            *device;
@property (strong,nonatomic)     AVCaptureDeviceInput       *input;
@property (strong,nonatomic)     AVCaptureMetadataOutput    *output;
@property (strong,nonatomic)     AVCaptureSession           *session;
@property (strong,nonatomic)     AVCaptureVideoPreviewLayer *preview;

@end


