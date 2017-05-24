//
//  EthomeSimilarityView.m
//  KouHanDaJiBa
//
//  Created by edeco on 16/3/29.
//  Copyright © 2016年 edeco. All rights reserved.
//

#import "EthomeSimilarityView.h"

#import "StreamAVRender.h"

#import "CIDInfoObject.h"

#import "ETOnlineSingleton.h"

#import "MBProgressHUD.h"

#import "ETInputPWTableViewController.h"

#import "LongPressControl.h"

#import "ETLongPreImgView.h"

#import "httpRequst.h"

#import "ETAPIList.h"

#import "ETRoomDeviceModel.h"

#import "GTMBase64.h"

#import "Masonry.h"

#import "UIView+SDAutoLayout.h"

#import "EZPlayer.h"

#import "EZOpenSDK.h"

#import "EZPlayer+ETPlayerTag.h"

#define screenWidth ([UIScreen mainScreen].bounds.size.width)

#define screenHeight ([UIScreen mainScreen].bounds.size.height)

//宽
#define ItemWidth ([UIScreen mainScreen].bounds.size.width - 45) / 2
//高
#define ItemHeight ItemWidth + 50

#define ItemHengWidth ([UIScreen mainScreen].bounds.size.height - 45) / 2

#define ItemHengHeight ItemHengWidth + 50

@interface EthomeSimilarityView ()<UIAlertViewDelegate,UIGestureRecognizerDelegate,ETImgLongPreDelegate,EZPlayerDelegate>{
    int presenceState;
    
    long long presencecid;
    
    NSInteger originIndex;
    
    NSInteger newIndex;
    
    CGPoint startPoint;
    
    CGPoint originPoint;
    
    BOOL contain;
    
    int count;
}


/**
 *  添加按钮
 */
@property (nonatomic,assign) NSInteger addonsCount;

@property (nonatomic, strong) UIAlertView *pwErrAlert;

@property (nonatomic, strong) UIAlertView *offlineAlert;

@property (nonatomic, strong) MBProgressHUD *hud;


@property(nonatomic,strong)NSMutableArray * myRects;//存放所有的view
@property(nonatomic,strong)NSMutableArray * frames;//存放view的标准位置

@property (nonatomic, strong) NSMutableArray *itemArray;



@end

@implementation EthomeSimilarityView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        //初始化两个数组
        self.myRects = [NSMutableArray arrayWithCapacity:10];
        self.frames = [NSMutableArray arrayWithCapacity:10];
        
        _itemArray = [NSMutableArray array];
        
        _deleteBtnArray = [NSMutableArray array];

        
        self.backgroundColor = [UIColor clearColor];
        
        [self setupScrollView];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetcidInfos:) name:@"willEnterBackground" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvEnterForeGround:) name:@"willEnterForeground" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvPresenceState:) name:K_APP_PRESENCE_STATE_UPDATE object:nil];

        
        
        
    }
    return self;
}


- (void)addNewCameraButtonWithCount:(NSInteger)count{
    
        UIView *view = [self.contentView.subviews lastObject];
    
        [_myRects removeLastObject];
    
        [_frames removeLastObject];
    
        [view removeFromSuperview];
    
    
    for (int i = (self.cameraArray.count - count); i < self.cameraArray.count + 1; i ++) {

            //背景
            ETLongPreImgView *backgroundView = [[ETLongPreImgView alloc] init];
            
            backgroundView.image = [UIImage imageNamed:@"HomeCollectionCellBackground"];
            
            backgroundView.backgroundColor = [UIColor clearColor];
            
            backgroundView.userInteractionEnabled = YES;
            
            backgroundView.tag = 40000 + i;
            
            backgroundView.delegate = self;
            
            if (i < self.cameraArray.count) {
                
                ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
                
                //button
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(2, 2, ItemWidth - 4, ItemHeight - 50);
                button.layer.cornerRadius = 2;
                button.layer.masksToBounds = YES;
                [backgroundView addSubview:button];
                
                button.tag = 3000 + i;
                button.sd_layout
                .leftSpaceToView(backgroundView, 2)
                .topEqualToView(backgroundView)
                .rightSpaceToView(backgroundView, 2)
                .bottomSpaceToView(backgroundView,50);
                /**
                 创建视频显示
                 */
                if ([cameraDevice.cameraFirm isEqualToString:@"Easycam"]) {
                    
                    [[Rvs_Viewer defaultViewer] connectStreamer:[cameraDevice.deviceId longLongValue] UserName:@"admin" Password:cameraDevice.devicePassword];
                    
                    cameraDevice.streamVideoRender = [[StreamAVRender alloc] initRealTimeStreamWithCID:[cameraDevice.deviceId longLongValue] CameraIndex:0 StreamIndex:0 TargetView:button];
                    
                    
                }else if ([cameraDevice.cameraFirm isEqualToString:@"HaiKang"]){
                    
                    cameraDevice.player = [EZOpenSDK createPlayerWithCameraId:cameraDevice.deviceId];
                    
                    cameraDevice.player.strFlag = cameraDevice.deviceId;
                    
                    cameraDevice.player.delegate = self;
                    [cameraDevice.player setPlayerView:button];
                    
                    [cameraDevice.player startRealPlay];
                    
                }
                
                _hud = [[MBProgressHUD alloc] initWithView:button];
                
                _hud.tag = 2000 + i;
                
                _hud.detailsLabelColor = [UIColor whiteColor];
                
                if (i < 4) {
                    
                    _hud.detailsLabelText = @"设备正在连接中请稍候";
                    
                }else{
                    
                    _hud.detailsLabelText = @"请移到前四个进行播放";
                    
                }
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reStartContect:)];
                
                [_hud addGestureRecognizer:tap];
                
                [_hud show:YES];
                
                if (i >= 4) {
                    _hud.activityIndicatorColor = [UIColor clearColor];
                    
                    _hud.backgroundColor = [UIColor blackColor];
                }
                
                [button insertSubview:_hud atIndex:0];
                
                for (UIView *view in button.subviews) {
                    if (![view isKindOfClass:[MBProgressHUD class]]) {
                        UITapGestureRecognizer *movieTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClickAction:)];
                        
                        [view addGestureRecognizer:movieTap];
                    }
                }
                
                //label
                
                UILabel *titelLabel = [[UILabel alloc] init];
                [titelLabel setFont:[UIFont systemFontOfSize:20]];
                titelLabel.textColor = [UIColor whiteColor];
                titelLabel.textAlignment = NSTextAlignmentCenter;
                titelLabel.text = cameraDevice.deviceName;
                [backgroundView addSubview:titelLabel];
                
                [titelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(button.mas_bottom);;
                    make.left.equalTo(backgroundView.mas_left);;
                    make.right.equalTo(backgroundView.mas_right);
                    make.height.equalTo(@50);
                }];
                
                UIImageView *deleteView = [[UIImageView alloc] init];
                deleteView.userInteractionEnabled = YES;
                deleteView.image = [UIImage imageNamed:@"room_delete"];
                deleteView.backgroundColor = [UIColor whiteColor];
                deleteView.layer.cornerRadius = 20;
                deleteView.layer.masksToBounds = YES;
                [backgroundView addSubview:deleteView];
                
                deleteView.tag = 4000 + i;
                
                deleteView.hidden = YES;
                
                [deleteView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(backgroundView.mas_top).with.offset(-10);;
                    make.left.equalTo(backgroundView.mas_left).with.offset(-10);;
                    make.width.equalTo(@40);
                    make.height.equalTo(@40);
                }];
                
                UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBtnClick:)];
                
                [deleteView addGestureRecognizer:deleteTap];
                
                [self.deleteBtnArray addObject:deleteView];
   
                [self.itemArray addObject:backgroundView];
                
            }else{
                
                //添加button
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                //            button.frame = CGRectMake( ItemWidth / 4, 50, ItemWidth / 2, ItemWidth /2);
                [button setImage:[UIImage imageNamed:@"room_add"] forState:UIControlStateNormal];
                
                button.layer.cornerRadius = ItemWidth / 4;
                button.layer.masksToBounds = YES;
                [button addTarget:self action:@selector(buttonCilckAddonsAction:) forControlEvents:UIControlEventTouchUpInside];
                button.backgroundColor = [UIColor clearColor];
                [backgroundView addSubview:button];
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(backgroundView);
                    make.height.equalTo(@100);
                    make.width.equalTo(@100);
                }];
                //label
                
                UILabel *titelLabel = [[UILabel alloc] init];
                titelLabel.textColor = [UIColor whiteColor];
                titelLabel.textAlignment = NSTextAlignmentCenter;
                titelLabel.text = @"添加摄像机";
                
                titelLabel.tag = 9000 + i;
                [backgroundView addSubview:titelLabel];
                
                [titelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(button.mas_bottom);;
                    make.left.equalTo(backgroundView.mas_left);;
                    make.right.equalTo(backgroundView.mas_right);
                    make.height.equalTo(@50);
                }];
            }
            
            [self.contentView addSubview:backgroundView];
            
            [self.myRects addObject:backgroundView];
            
            NSString * str = [NSString stringWithFormat:@"%@",NSStringFromCGRect(backgroundView.frame)];
            [self.frames addObject:str];
            
            
        
            
        }

    [self upadateCameraViewWithMasonry];

}

- (void)deleteOldCameraButtonWithIndex:(NSInteger)index WithType:(NSString *)type{

    ETRoomDeviceModel *cameraDevice = self.cameraArray[index];
    
    [cameraDevice.streamVideoRender stopStream];
    
    [[Rvs_Viewer defaultViewer] disconnectStreamer:[cameraDevice.deviceId longLongValue]];
    
    UIView *deleteView = self.itemArray[index];
    
    [deleteView removeFromSuperview];
    
    [self.cameraArray removeObjectAtIndex:index];
    
    [_itemArray removeObjectAtIndex:index];
    
    [_myRects removeObjectAtIndex:index];
    
    [_frames removeLastObject];
    

    
    for (NSInteger i = 0; i < _itemArray.count; i ++) {
        


        UIView *view = _itemArray[i];
        
        view.tag = 40000 + i;
        

        
        [view.subviews firstObject].tag = 3000 + i;
        
        
        [view.subviews lastObject].tag = 4000 + i;
        
        
        for (UIView *subView in view.subviews) {
            if ([subView isKindOfClass:[UILabel class]]) {
                
                subView.tag = 9000 + i;
            }
            
        }
        
        for (UIView *subview in [view.subviews firstObject].subviews) {
            if ([subview isKindOfClass:[MBProgressHUD class]]) {
                subview.tag = 2000 + i;
                
                if (i >= 4) {
                    subview.backgroundColor = [UIColor blackColor];
                    
                    ((MBProgressHUD *)subview).activityIndicatorColor = [UIColor clearColor];
                    
                    
                }else{
                    
                    subview.backgroundColor = [UIColor clearColor];
                    
                    ((MBProgressHUD *)subview).activityIndicatorColor = [UIColor grayColor];
                    
                    if ([((MBProgressHUD *)subview).detailsLabelText isEqualToString:@"设备在线,点击或移动到前四个进行播放"]) {
                        ((MBProgressHUD *)subview).detailsLabelText = @"设备在线,连接中请稍后";
                    }
                    
                   
                }
            }
            
         
        }
        
        

    
    }
    
    
    [self stopAllCamera];
    
    [self openAllCamera];
    
    [self upadateCameraViewWithMasonry];
    
    
}


- (void)resetcidInfos:(NSNotification *)notice{
  
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSString *isVC = [user valueForKey:@"isCameraVC"];
    
    if ([isVC isEqualToString:@"YES"]){
        
        [self stopAllCamera];
        
    }
}
- (void)recvEnterForeGround:(NSNotification *)notice{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSString *isVC = [user valueForKey:@"isCameraVC"];
    
    if ([isVC isEqualToString:@"YES"]){
        
        [self stopAllCamera];
        
        [self openAllCamera];
    }
}


#pragma mark ----断开视频流-----

- (void)stopAllCamera{
    
    for (ETRoomDeviceModel *cameraDevice in self.cameraArray) {
        if ([cameraDevice.cameraFirm isEqualToString:@"Easycam"]) {
            
            [cameraDevice.streamVideoRender stopStream];

        }else if ([cameraDevice.cameraFirm isEqualToString:@"HaiKang"]){
            
            [cameraDevice.player stopRealPlay];
            
            for (int i = 0; i < self.cameraArray.count; i ++) {
                
                UIView *button = [self viewWithTag:3000 + i];
                
                for (UIView *view in button.subviews) {
                    
                    if ([NSStringFromClass([view class])isEqualToString:@"HIK_DisplayView"]) {
                   
                        [view removeFromSuperview];
                        
                    }
                }
            }
            
        }
        
    }
}

#pragma mark ----打开视频流-----

- (void)openAllCamera{
    
    if (self.cameraArray.count < 4) {
        
        for (int i = 0; i < self.cameraArray.count; i ++) {
            ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
            if ([cameraDevice.cameraFirm isEqualToString:@"Easycam"]) {
                
                [cameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                    
                } FirstVideoFrameShow:^{
                    
                } PlayEnded:^(NSError *error) {
                    
                }];
            }else if ([cameraDevice.cameraFirm isEqualToString:@"HaiKang"]){
                
                cameraDevice.player = [EZOpenSDK createPlayerWithCameraId:cameraDevice.deviceId];
                
                cameraDevice.player.strFlag = cameraDevice.deviceId;
                
                cameraDevice.player.delegate = self;
                
                UIView *button = [self viewWithTag:3000 + i];
                
                [cameraDevice.player setPlayerView:button];
                
                [cameraDevice.player startRealPlay];
                
            }

            
        }
   
    }else{
        for (int i = 0;i < 4; i ++) {
            ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
            
            if ([cameraDevice.cameraFirm isEqualToString:@"Easycam"]) {
                
                [cameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                    
                } FirstVideoFrameShow:^{
                    
                } PlayEnded:^(NSError *error) {
                    
                }];
            }else if ([cameraDevice.cameraFirm isEqualToString:@"HaiKang"]){
                
                cameraDevice.player = [EZOpenSDK createPlayerWithCameraId:cameraDevice.deviceId];
                
                cameraDevice.player.strFlag = cameraDevice.deviceId;
                
                cameraDevice.player.delegate = self;
                
                UIView *button = [self viewWithTag:3000 + i];
                
                [cameraDevice.player setPlayerView:button];
                
                [cameraDevice.player startRealPlay];
                
            }
            
        }
        
    }
    
}



- (void)recvPresenceState:(NSNotification*)notice {
    
    
    NSDictionary* userinfo = [notice userInfo];
    
    presenceState = [[userinfo objectForKey:K_APP_PARAM_PRESENCE_STATE] intValue];
    presencecid = [[userinfo objectForKey:K_APP_PARAM_CID] longLongValue];
    
    NSLog(@"%lld",presencecid);
    for (int i = 0; i < self.cameraArray.count; i ++) {
        ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
        if ([cameraDevice.deviceId longLongValue] == presencecid) {
            NSString *presenceStateStr = @"长时间未连接点击重试";
            
            NSString *botPreseceStateStr = @"移动到前四个进行播放";

            switch (presenceState) {
            case 0:
                presenceStateStr = @"初始化摄像机,请稍后";
                botPreseceStateStr = @"移动到前四个进行播放";
                break;
                
            case 1:
                presenceStateStr = @"设备在线,连接中请稍后";
                botPreseceStateStr = @"设备在线,点击或移动到前四个进行播放";

                break;
                
            case 2:
                presenceStateStr = @"设备离线,点击重新连接";
                botPreseceStateStr =@"设备离线,点击重新连接";
    
                break;
            case 3:
                
                presenceStateStr = @"摄像机用户名密码错误，点击修改";
                botPreseceStateStr = @"摄像机用户名密码错误，点击修改";
    
                break;
                
            default:
                    
                presenceStateStr = @"长时间未连接点击重试";
                    
                botPreseceStateStr = @"移动到前四个进行播放";
                break;
            }

            cameraDevice.presenceState = presenceStateStr;
            
            MBProgressHUD *presenceHud = [self viewWithTag:2000 + i];

            if (i < 4) {
                
                presenceHud.detailsLabelText = presenceStateStr;

            }else{
                
                presenceHud.detailsLabelText = botPreseceStateStr;

            }
            
            if ([presenceHud.detailsLabelText isEqualToString:@"设备在线,连接中请稍后"]) {
                
                [cameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                    
                } FirstVideoFrameShow:^{
                    
                } PlayEnded:^(NSError *error) {
                    
                }];
                
            }


        }
    }
    
   
    
    
    }

/**
 *  scrollView
 */
- (void)setupScrollView{
    
    _scrollView = [[UIScrollView alloc] init];

    _scrollView.backgroundColor = [UIColor clearColor];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBtnDismiss:)];
    
    [_scrollView addGestureRecognizer:tap];
    
    [self addSubview:_scrollView];
    
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];

    

}


- (void)deleteBtnDismiss:(UIButton *)sender{
    
    for (UIImageView *deleteView in self.deleteBtnArray) {
        deleteView.hidden = YES;
    }
    
    
}

/**
 *  放置button
 */
- (void)setupViewButtons{
    
    
    if (self.cameraArray.count != 0) {
        
        _addonsCount = self.cameraArray.count + 1;

    }else{
        
        _addonsCount = 1;
        
    }
    self.contentView = [[UIView alloc] init];
    

    
    [self.scrollView addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView).insets(UIEdgeInsetsZero);
        make.centerX.equalTo(self.scrollView.mas_centerX);
    }];
    
    

    
    for (NSInteger i = 0; i < _addonsCount; i ++) {
        

        
        //背景
        ETLongPreImgView *backgroundView = [[ETLongPreImgView alloc] init];
        
        backgroundView.image = [UIImage imageNamed:@"HomeCollectionCellBackground"];
        
        backgroundView.backgroundColor = [UIColor clearColor];
        
        backgroundView.userInteractionEnabled = YES;
        
        backgroundView.tag = 40000 + i;
        
        backgroundView.delegate = self;
        
        if (i < self.cameraArray.count) {
            
            ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
 
            //button
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(2, 2, ItemWidth - 4, ItemHeight - 50);
            button.layer.cornerRadius = 2;
            button.layer.masksToBounds = YES;
            [backgroundView addSubview:button];
            
            button.tag = 3000 + i;
            
            button.sd_layout
            .leftSpaceToView(backgroundView, 2)
            .topEqualToView(backgroundView)
            .rightSpaceToView(backgroundView, 2)
            .bottomSpaceToView(backgroundView,50);
            /**
             创建视频显示
             
             */

            if ([cameraDevice.cameraFirm isEqualToString:@"Easycam"]) {
                
                [[Rvs_Viewer defaultViewer] connectStreamer:[cameraDevice.deviceId longLongValue] UserName:@"admin" Password:cameraDevice.devicePassword];
                
                cameraDevice.streamVideoRender = [[StreamAVRender alloc] initRealTimeStreamWithCID:[cameraDevice.deviceId longLongValue] CameraIndex:0 StreamIndex:0 TargetView:button];
                

            }else if ([cameraDevice.cameraFirm isEqualToString:@"HaiKang"]){
                
                cameraDevice.player = [EZOpenSDK createPlayerWithCameraId:cameraDevice.deviceId];
                
                cameraDevice.player.strFlag = cameraDevice.deviceId;
                
                cameraDevice.player.delegate = self;
                [cameraDevice.player setPlayerView:button];
                
            }

            _hud = [[MBProgressHUD alloc] initWithView:button];
            
            _hud.tag = 2000 + i;
            
            _hud.detailsLabelColor = [UIColor whiteColor];
            
            if (i < 4) {
                _hud.detailsLabelText = @"设备正在连接中请稍候";

                [cameraDevice.player startRealPlay];
                
            }else{
                
                _hud.detailsLabelText = @"请移到前四个进行播放";
                
            }
            
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reStartContect:)];
            
            [_hud addGestureRecognizer:tap];
            
            [_hud show:YES];
            
            if (i >= 4) {
                _hud.activityIndicatorColor = [UIColor clearColor];
                
                _hud.backgroundColor = [UIColor blackColor];
            }
            
            [button insertSubview:_hud atIndex:0];
            
            for (UIView *view in button.subviews) {
                
                if (![view isKindOfClass:[MBProgressHUD class]]) {
                    UITapGestureRecognizer *movieTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClickAction:)];
                    
                    [view addGestureRecognizer:movieTap];
                    
                }
            }
            
            //label

            UILabel *titelLabel = [[UILabel alloc] init];
            [titelLabel setFont:[UIFont systemFontOfSize:20]];
            titelLabel.textColor = [UIColor whiteColor];
            titelLabel.textAlignment = NSTextAlignmentCenter;
            titelLabel.text = cameraDevice.deviceName;
            
            titelLabel.tag = 9000 + i;
            [backgroundView addSubview:titelLabel];
            
            [titelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(backgroundView.mas_bottom);;
                make.left.equalTo(backgroundView.mas_left);;
                make.right.equalTo(backgroundView.mas_right);
                make.height.equalTo(@50);
            }];

            UIImageView *deleteView = [[UIImageView alloc] init];
            deleteView.userInteractionEnabled = YES;
            deleteView.image = [UIImage imageNamed:@"room_delete"];
            deleteView.backgroundColor = [UIColor whiteColor];
            deleteView.layer.cornerRadius = 20;
            deleteView.layer.masksToBounds = YES;
            [backgroundView addSubview:deleteView];
            
            deleteView.tag = 4000 + i;
            
            deleteView.hidden = YES;

            [deleteView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(backgroundView.mas_top).with.offset(-10);;
                make.left.equalTo(backgroundView.mas_left).with.offset(-10);;
                make.width.equalTo(@40);
                make.height.equalTo(@40);
            }];
            
            UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBtnClick:)];
            
            [deleteView addGestureRecognizer:deleteTap];
            
            [self.deleteBtnArray addObject:deleteView];

            [self.itemArray addObject:backgroundView];
            
            

        }else{
            
            //添加button
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"room_add"] forState:UIControlStateNormal];

            [button addTarget:self action:@selector(buttonCilckAddonsAction:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            [backgroundView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(backgroundView);
                make.height.equalTo(@100);
                make.width.equalTo(@100);
            }];
            //label
            
            UILabel *titelLabel = [[UILabel alloc] init];
            titelLabel.textColor = [UIColor whiteColor];
            titelLabel.textAlignment = NSTextAlignmentCenter;
            titelLabel.text = @"添加摄像机";
            [backgroundView addSubview:titelLabel];
            
            [titelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(button.mas_bottom);;
                make.left.equalTo(backgroundView.mas_left);;
                make.right.equalTo(backgroundView.mas_right);
                make.height.equalTo(@50);
            }];
        }
        
        [self.contentView addSubview:backgroundView];
        
        [self.myRects addObject:backgroundView];
        
        NSString * str = [NSString stringWithFormat:@"%@",NSStringFromCGRect(backgroundView.frame)];
        [self.frames addObject:str];
        
     
       

    }
    
    [self constraintCameraViewWithMasonry];

}

- (void)constraintCameraViewWithMasonry{
    
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        UIView *view = self.contentView.subviews[i];

        if (i == 0) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top).offset(10);
                make.left.equalTo(self.scrollView.mas_left).offset(20);
                make.height.equalTo(@(self.cameraHeight));
                make.width.equalTo(self.scrollView.mas_width).multipliedBy(0.5).offset(-30);
            }];
        } else if (i == 1) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top).offset(10);
                make.width.equalTo([self.contentView.subviews firstObject].mas_width);
                make.right.equalTo(self.scrollView.mas_right).offset(-20);
                make.height.equalTo(@(self.cameraHeight));
            }];
        } else if (i % 2 == 0){
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.subviews[i - 2].mas_bottom).offset(20);
                make.left.equalTo(self.contentView.mas_left).offset(20);
                make.height.equalTo(@(self.cameraHeight));
                make.width.equalTo([self.contentView.subviews firstObject].mas_width);
            }];
        } else {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.subviews[i - 2].mas_bottom).offset(20);
                make.width.equalTo([self.contentView.subviews firstObject].mas_width);
                make.right.equalTo(self.contentView.mas_right).offset(-20);
                make.height.equalTo(@(self.cameraHeight));
            }];
        }
    }
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo([[self.contentView subviews] lastObject].mas_bottom).offset(20);
    }];
 
    
    
}

- (void)upadateCameraViewWithMasonry{
    

    for (int i = 0; i < self.contentView.subviews.count; i++) {
        UIView *view = self.contentView.subviews[i];
        
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            
        }];
        if (i == 0) {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top).offset(10);
                make.left.equalTo(self.scrollView.mas_left).offset(20);
                make.height.equalTo(@(self.cameraHeight));
                make.width.equalTo(self.scrollView.mas_width).multipliedBy(0.5).offset(-30);
            }];
        } else if (i == 1) {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top).offset(10);
                make.width.equalTo([self.contentView.subviews firstObject].mas_width);
                make.right.equalTo(self.scrollView.mas_right).offset(-20);
                make.height.equalTo(@(self.cameraHeight));
            }];
        } else if (i % 2 == 0){
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.subviews[i - 2].mas_bottom).offset(20);
                make.left.equalTo(self.contentView.mas_left).offset(20);
                make.height.equalTo(@(self.cameraHeight));
                make.width.equalTo([self.contentView.subviews firstObject].mas_width);
            }];
        } else {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.subviews[i - 2].mas_bottom).offset(20);
                make.width.equalTo([self.contentView.subviews firstObject].mas_width);
                make.right.equalTo(self.contentView.mas_right).offset(-20);
                make.height.equalTo(@(self.cameraHeight));
            }];
        }
    }
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo([[self.contentView subviews] lastObject].mas_bottom).offset(20);
    }];
    
}



/**
 *  摄像头的
 */
- (void)buttonClickAction:(UITapGestureRecognizer *)gesture{
    
    NSInteger tag = gesture.view.superview.tag - 3000;
    
    ETRoomDeviceModel *cameraDevice = self.cameraArray[tag];


    if (_delegate && [_delegate respondsToSelector:@selector(selectedDetailCameraImage:model:Did:)]) {
        [_delegate selectedDetailCameraImage:tag model:cameraDevice Did:cameraDevice.id];
    }
}

/**
 *  添加
 */
- (void)buttonCilckAddonsAction:(UIButton *)btn{
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectedCameraImage)]) {
        [_delegate selectedCameraImage];
    }
}

/**
 *  删除
 *
 */

- (void)deleteBtnClick:(UITapGestureRecognizer *)sender{
    
    NSInteger tag = sender.view.tag - 4000;
    
    NSString *did = [self.cameraArray[tag] id];
    NSString *url = [ETAPIList getAPIList].deviceDeleteAPI;
    if (!did) {
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{@"sid":[settingManager getInstance].sessionId,@"did":did}];
    [httpRequst POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *processResult = responseObject[@"processResult"];
        if ([processResult intValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self deleteOldCameraButtonWithIndex:tag WithType:@"影像"];

                
                
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errorMsg = responseObject[@"errorMsg"];
                [HUD showTimedAlertWithTitle:@"提示" text:errorMsg withTimeout:1.2];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        kFailureAlertView;
    }];


}

/**
 *  hud
 E_RVS_STREAMER_PRESENCE_STATE_INIT = 0,
 E_RVS_STREAMER_PRESENCE_STATE_ONLINE,
 E_RVS_STREAMER_PRESENCE_STATE_OFFLINE,
 E_RVS_STREAMER_PRESENCE_STATE_ERRUSERPWD
 */

- (void)reStartContect:(UITapGestureRecognizer *)gesture{
    NSInteger tag = gesture.view .tag - 2000;
    
    unsigned long long CID = [[self.cameraArray[tag] deviceId] longLongValue];
    
    ETRoomDeviceModel *model = self.cameraArray[tag];
    
    int presence = [[ETOnlineSingleton shareOnline] getOnlineState:CID];
    
    if (presence == E_RVS_STREAMER_PRESENCE_STATE_ONLINE) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectedHudImageModel:)]) {
            [_delegate selectedHudImageModel:model];
        }
    }else if (presence == E_RVS_STREAMER_PRESENCE_STATE_OFFLINE){
        
        
        _offlineAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备离线" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新配置WIFI", nil];
        _offlineAlert.tag = tag + 20000;

        [_offlineAlert show];
    }else if (presence == E_RVS_STREAMER_PRESENCE_STATE_ERRUSERPWD){
        
        _pwErrAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名密码错误" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新输入密码", nil];
        
        
        _pwErrAlert.tag = tag + 30000;
        
        [_pwErrAlert show];
        
    }
   
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView == _pwErrAlert) {
        if (buttonIndex == 1) {
            
            if (_delegate && [_delegate respondsToSelector:@selector(ReInputPWWithCID:)]) {
                [_delegate ReInputPWWithCID:self.cameraArray[_pwErrAlert.tag - 30000]];
            }
                        
        }
    }else if (alertView == _offlineAlert){
        
        if (buttonIndex == 1) {
            if (_delegate && [_delegate respondsToSelector:@selector(ReConnectWifiWithCID:)]) {
                [_delegate ReConnectWifiWithCID:[self.cameraArray[_offlineAlert.tag - 20000] longLongValue]];
            }
        }
        
    }
    
    
    
}


- (void)longPress:(UILongPressGestureRecognizer *)sender{
    
    
    UIImageView *btn =(UIImageView *)sender.view;
    
    if (btn.tag - 40000 != self.cameraArray.count) {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            startPoint = [sender locationInView:sender.view];
            originPoint = btn.center;
            
            originIndex = btn.tag - 40000;
            
            UIButton *deleteBtn = [btn viewWithTag:4000 + originIndex];
            
            deleteBtn.hidden = NO;

            [UIView animateWithDuration:1 animations:^{
                btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
                btn.alpha = 0.7;
            }];
        }
        else if (sender.state == UIGestureRecognizerStateChanged)
        {
            CGPoint newPoint = [sender locationInView:sender.view];
            CGFloat deltaX = newPoint.x-startPoint.x;
            CGFloat deltaY = newPoint.y-startPoint.y;
            
            
            btn.center = CGPointMake(btn.center.x+deltaX,btn.center.y+deltaY);
            
            
        }
        else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed)
        {
            
            
            [[LongPressControl shareInfo] removeLongPressAction:LONG_PRESS_VIEW_DEMO];
            
            
            for (NSInteger i = 0;i<_itemArray.count;i++)
            {
                UIImageView *button = _itemArray[i];
                if (button != btn)
                {
                    button.userInteractionEnabled = YES;
                }
            }
            
            NSInteger index = [self indexOfPoint:btn.center withView:btn];
            
            
            
            if (index<0)
            {
                contain = NO;
                
                newIndex = originIndex;
            }
            else
            {
                
                newIndex = index;
                
                [UIView animateWithDuration:1 animations:^{
                    CGPoint temp = CGPointZero;
                    UIImageView *button = _itemArray[index];
                    temp = button.center;
                    button.center = originPoint;
                    btn.center = temp;
                    originPoint = btn.center;
                    contain = YES;
                }];
            }
            
            [UIView animateWithDuration:1 animations:^{
                btn.transform = CGAffineTransformIdentity;
                btn.alpha = 1.0;
                if (!contain)
                {
                    btn.center = originPoint;
                }
            }];
            
            NSLog(@"开始%ld,结束%ld",(long)originIndex,(long)newIndex);
            
            
            if (originIndex >= 4 && newIndex < 4) {
                
                
                UIImageView *oriImage = _itemArray[originIndex];
                
                for (UIView *view in [oriImage.subviews firstObject].subviews) {
                    if ([view isKindOfClass:[MBProgressHUD class]]) {
                        view.backgroundColor = [UIColor clearColor];
                        
                        ((MBProgressHUD *)view).activityIndicatorColor = [UIColor grayColor];
                        
                        if ([((MBProgressHUD *)view).detailsLabelText isEqualToString:@"设备在线,点击或移动到前四个进行播放"]) {
                            ((MBProgressHUD *)view).detailsLabelText = @"设备在线,连接中请稍后";
                        }
                    }
                }
                
                
                UIImageView *newImage = _itemArray[newIndex];
                
                for (UIView *view in [newImage.subviews firstObject].subviews) {
                    if ([view isKindOfClass:[MBProgressHUD class]]) {
                        view.backgroundColor = [UIColor blackColor];
                        
                        ((MBProgressHUD *)view).activityIndicatorColor = [UIColor clearColor];
                        
                        if ([((MBProgressHUD *)view).detailsLabelText isEqualToString:@"设备在线,连接中请稍后"]) {
                            ((MBProgressHUD *)view).detailsLabelText = @"设备在线,点击或移动到前四个进行播放";
                        }
                    }
                }
                
                
                ETRoomDeviceModel *oriCameraDevice = self.cameraArray[originIndex];
                
                if ([oriCameraDevice.cameraFirm isEqualToString:@"HaiKang"]) {
                    
                    oriCameraDevice.player = [EZOpenSDK createPlayerWithCameraId:oriCameraDevice.deviceId];
                    
                    oriCameraDevice.player.strFlag = oriCameraDevice.deviceId;
                    
                    oriCameraDevice.player.delegate = self;
                    
                    UIView *button = [self viewWithTag:3000 + originIndex];
                    
                    [oriCameraDevice.player setPlayerView:button];
                    
                    [oriCameraDevice.player startRealPlay];
                    
                }else{
                    [oriCameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                        
                    } FirstVideoFrameShow:^{
                        
                    } PlayEnded:^(NSError *error) {
                        
                    }];
                    
                }
                
              
                
                
                ETRoomDeviceModel *newCameraDevice = self.cameraArray[newIndex];
                
                if ([newCameraDevice.cameraFirm isEqualToString:@"HaiKang"]) {
                    
                    [newCameraDevice.player stopRealPlay];
                    
                    UIView *button = [self viewWithTag:3000 + newIndex];
                    
                    for (UIView *view in button.subviews) {
                        
                        if ([NSStringFromClass([view class])isEqualToString:@"HIK_DisplayView"]) {
                            
                            [view removeFromSuperview];
                            
                        }
                    }
                    

                    
                }else{
                    
                    [newCameraDevice.streamVideoRender stopStream];

                }
                
                
                
                
                
                
            }else if(originIndex < 4 && newIndex >= 4){
                
                UIImageView *oriImage = _itemArray[originIndex];
                
                for (UIView *view in [oriImage.subviews firstObject].subviews) {
                    if ([view isKindOfClass:[MBProgressHUD class]]) {
                        
                        view.backgroundColor = [UIColor blackColor];
                        
                        ((MBProgressHUD *)view).activityIndicatorColor = [UIColor clearColor];
                        
                        if ([((MBProgressHUD *)view).detailsLabelText isEqualToString:@"设备在线,连接中请稍后"]) {
                            ((MBProgressHUD *)view).detailsLabelText = @"设备在线,点击或移动到前四个进行播放";
                        }
                    }
                }
                
                
                UIImageView *newImage = _itemArray[newIndex];
                
                for (UIView *view in [newImage.subviews firstObject].subviews) {
                    if ([view isKindOfClass:[MBProgressHUD class]]) {
                        
                        view.backgroundColor = [UIColor clearColor];
                        
                        ((MBProgressHUD *)view).activityIndicatorColor = [UIColor grayColor];
                        
                        if ([((MBProgressHUD *)view).detailsLabelText isEqualToString:@"设备在线,点击或移动到前四个进行播放"]) {
                            ((MBProgressHUD *)view).detailsLabelText = @"设备在线,连接中请稍后";
                        }
                        
                    }
                }
                
                ETRoomDeviceModel *oriCameraDevice = self.cameraArray[originIndex];
                
                if ([oriCameraDevice.cameraFirm isEqualToString:@"HaiKang"]) {
                    
                    [oriCameraDevice.player stopRealPlay];
                    
                    UIView *button = [self viewWithTag:3000 + originIndex];
                    
                    for (UIView *view in button.subviews) {
                        
                        if ([NSStringFromClass([view class])isEqualToString:@"HIK_DisplayView"]) {
                            
                            [view removeFromSuperview];
                            
                        }
                    }
                    

                    
                }else{
                    
                    [oriCameraDevice.streamVideoRender stopStream];
                    
                    
                }
                
                
                ETRoomDeviceModel *newCameraDevice = self.cameraArray[newIndex];
                
                if ([newCameraDevice.cameraFirm isEqualToString:@"HaiKang"]) {
                    
                    newCameraDevice.player = [EZOpenSDK createPlayerWithCameraId:newCameraDevice.deviceId];
                    
                    newCameraDevice.player.strFlag = newCameraDevice.deviceId;
                    
                    newCameraDevice.player.delegate = self;
                    
                    UIView *button = [self viewWithTag:3000 + newIndex];
                    
                    [newCameraDevice.player setPlayerView:button];
                    
                    [newCameraDevice.player startRealPlay];
                    
                }else{
                    
                    [newCameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                        
                    } FirstVideoFrameShow:^{
                        
                    } PlayEnded:^(NSError *error) {
                        
                    }];
                    
                }
                
                
                
            }
            
            
            [self.cameraArray exchangeObjectAtIndex:newIndex withObjectAtIndex:originIndex];
            
            
            UIImageView * oriView = _itemArray[originIndex];
            
            oriView.tag = 40000 + newIndex;
            
            [oriView.subviews lastObject].tag = 4000 + newIndex;
            
            
            
            UIImageView * newView = _itemArray[newIndex];
            
            newView.tag = 40000 + originIndex;
            
            [newView.subviews lastObject].tag = 4000 + originIndex;

            
            [oriView.subviews firstObject].tag = 3000 + newIndex;
            
            for (UIView *subview in [oriView.subviews firstObject].subviews) {
                if ([subview isKindOfClass:[MBProgressHUD class]]) {
                    subview.tag = 2000 + newIndex;
                }
            }
            for (UIView *subView in oriView.subviews) {
                if ([subView isKindOfClass:[UILabel class]]) {
                    
                    subView.tag = 9000 + newIndex;
                }
                
            }
            [newView.subviews firstObject].tag = 3000 + originIndex;
            
            for (UIView *subview in [newView.subviews firstObject].subviews) {
                if ([subview isKindOfClass:[MBProgressHUD class]]) {
                    subview.tag = 2000 + originIndex;
                }
            }
            for (UIView *subView in newView.subviews) {
                if ([subView isKindOfClass:[UILabel class]]) {
                    
                    subView.tag = 9000 + originIndex;
                }
                
            }
            
            [_itemArray exchangeObjectAtIndex:newIndex withObjectAtIndex:originIndex];
            
            
            
            if (originIndex != newIndex) {
                
                NSDictionary *params = @{@"sid":[settingManager getInstance].sessionId,@"fromDid":[self.cameraArray[originIndex] id],@"toDid":[self.cameraArray[newIndex] id]};
                NSString *url = [ETAPIList getAPIList].modifyCameraOrderAPI;
                AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
                manager.requestSerializer.timeoutInterval = 15.f;
                
                [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *processResult = responseObject[@"processResult"];
                    if ([processResult intValue]==1)
                    {
                        //成功
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *errorMsg = responseObject[@"errorMsg"];
                            [HUD showTimedAlertWithTitle:@"提示" text:errorMsg withTimeout:1.2];
                        });
  
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     kFailureAlertView;
                 }];
                
                
                
            }
            
            
        }
        

    }else{
        
        [[LongPressControl shareInfo] removeLongPressAction:LONG_PRESS_VIEW_DEMO];

        
    }
    
  }


- (NSInteger)indexOfPoint:(CGPoint)point withView:(UIImageView *)btn
{
    for (NSInteger i = 0;i<_itemArray.count;i++)
    {
        UIImageView *button = _itemArray[i];
        if (button != btn)
        {
            if (CGRectContainsPoint(button.frame, point))
            {
                return i;
            }
        }
    }
    return -1;
}

#pragma mark - PlayerDelegate Methods

- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error
{
    NSLog(@"player: %@, didPlayFailed: %@", player, error);
    
    for (int i = 0; i < self.cameraArray.count; i ++) {
        ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
        if (cameraDevice.deviceId == player.strFlag) {
            NSString *presenceStateStr = @"连接失败请检查网络";
            
            NSString *botPreseceStateStr = @"移动到前四个进行播放";
            
            cameraDevice.presenceState = presenceStateStr;
            
            MBProgressHUD *presenceHud = [self viewWithTag:2000 + i];
            
            if (i < 4) {
                
                presenceHud.detailsLabelText = presenceStateStr;
                
            }else{
                
                presenceHud.detailsLabelText = botPreseceStateStr;
                
            }
        }
    
    
    }
}

- (void)player:(EZPlayer *)player didReceviedMessage:(NSInteger)messageCode
{
    NSLog(@"player: %@, didReceviedMessage: %d", player, (int)messageCode);
    
    [player closeSound];
    

    for (int i = 0; i < self.cameraArray.count; i ++) {
        ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
        
        UIView *button = [self viewWithTag:3000 + i];
        
        for (UIView *view in button.subviews) {
            
            if (![view isKindOfClass:[MBProgressHUD class]]) {
                UITapGestureRecognizer *movieTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClickAction:)];
                
                [view addGestureRecognizer:movieTap];
                
            }
        }
        if (cameraDevice.deviceId == player.strFlag) {
            NSString *presenceStateStr = @"设备在线,连接中请稍后";
            
            NSString *botPreseceStateStr = @"移动到前四个进行播放";
            
            cameraDevice.presenceState = presenceStateStr;
            
            MBProgressHUD *presenceHud = [self viewWithTag:2000 + i];
            
            if (i < 4) {
                
                presenceHud.detailsLabelText = presenceStateStr;
                
            }else{
                
                presenceHud.detailsLabelText = botPreseceStateStr;
                
            }
        }
        
        
    }
    
    NSLog(@"%@",player.strFlag);
    
}


-(void)dealloc
{
    for (int i = 0; i < self.cameraArray.count; i ++) {
        ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
     
        [cameraDevice.player destoryPlayer];
    }

    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}



@end
