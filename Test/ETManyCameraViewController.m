//
//  ETManyCameraViewController.m
//  Ethome
//
//  Created by ethome on 16/5/10.
//  Copyright © 2016年 Whalefin. All rights reserved.
//

#import "ETManyCameraViewController.h"
#import "ETCameraWifiViewController.h"
#import "ETRoomDeviceModel.h"
#import "ETInputPWTableViewController.h"
#import "ETWIFITableViewController.h"
#import "ETAPIList.h"
#import "httpRequst.h"
#import <Rvs_Viewer/Rvs_Viewer_API.h>
#import "GTMBase64.h"
#import "ETRoomDeviceModel.h"
#import "ETOnlineSingleton.h"
#import "Masonry.h"
#import "UIView+SDAutoLayout.h"
#import "ETPlayerViewController.h"


#define screenWidth ([UIScreen mainScreen].bounds.size.width)
//宽
#define ItemWidth ([UIScreen mainScreen].bounds.size.width - 45) / 2
//高
#define IPADItemHeight ItemHengWidth + 80

#define IPHONEItemHeight ItemWidth + 50


#define ItemHengWidth ([UIScreen mainScreen].bounds.size.height - 45) / 2

#define IPADItemHengHeight ItemHengWidth + 80

@interface ETManyCameraViewController ()<EthomeSimilarityViewContentButtonDelegate>


@end

@implementation ETManyCameraViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user setValue:@"YES" forKey:@"isCameraVC"];
    
    
    
    if (self.cameraView) {
        
        [self.cameraView openAllCamera];

    }

    [self loadData];

    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(addNewCamera)
                                                name:@"addCameraNotification"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(deleteOldCamera:)
                                                name:@"deleteCameraNotification"
                                              object:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    

    
}


- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user setValue:@"NO" forKey:@"isCameraVC"];
    
    if (self.cameraView) {
        
        [self.cameraView stopAllCamera];
        
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

 


- (void)loadData {
    
    
    NSString *url = [ETAPIList getAPIList].getAllUserCameraAPI;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15.f;
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:[settingManager getInstance].sessionId forKey:@"sid"];
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *processResult = responseObject[@"processResult"];
        if ([processResult intValue]==1)
        {   //网络请求成功
            NSDictionary *dic = responseObject[@"resultMap"];
            NSArray *array = dic[@"content"];
            NSMutableArray *dataArray = [NSMutableArray new];
            for (NSDictionary *dic in array) {
                ETRoomDeviceModel *model = [ETRoomDeviceModel objectWithKeyValues:dic];
                
                model.devicePassword = [GTMBase64 decodeBase64String:model.devicePassword];
                
                [dataArray addObject:model];
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cameraOrder" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
            [dataArray sortUsingDescriptors:sortDescriptors];
                
                if (self.cameraArray.count == 0 && self.cameraView == nil) {
                
                    float cameraHeight = IPHONEItemHeight;
                    
                    if (UIDeviceOrientationLandscapeLeft ==  self.interfaceOrientation || UIDeviceOrientationLandscapeRight == self.interfaceOrientation)
                    {
                        
                        cameraHeight = IPHONEItemHeight;
                        
                    }else if(UIDeviceOrientationPortrait ==  self.interfaceOrientation || UIDeviceOrientationPortraitUpsideDown == self.interfaceOrientation)
                    {
                        if (IPAD) {
                            
                            cameraHeight = IPADItemHeight;

                        }else{
                            
                            cameraHeight = IPHONEItemHeight;

                        }
                        
                    }
                    
                    self.cameraArray = dataArray;
                    
                    self.cameraView = [[EthomeSimilarityView alloc] init];
                    
                    self.cameraView.delegate = self;
                    
                    self.cameraView.cameraArray = self.cameraArray;
                    
                    self.cameraView.cameraHeight = cameraHeight;
                    
                    [self.cameraView setupViewButtons];
                    
                    [self.view addSubview:self.cameraView];
                    
                    
                    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
                    }];
                    
                }
                else if(self.cameraArray.count > dataArray.count){
                    
                    NSMutableArray *dataOrderArr = [NSMutableArray array];
                    
                    NSMutableArray *cameraOrderArr = [NSMutableArray array];


                    for (ETRoomDeviceModel *cameraDevice in self.cameraArray) {
                        
                        [cameraOrderArr addObject:cameraDevice.cameraOrder];

                    }

                    for (ETRoomDeviceModel *dataDevice in dataArray) {
                            
                            
                        [dataOrderArr addObject:dataDevice.cameraOrder];
                            
                            
                    }
                    
                    int i = (int)[dataOrderArr count]-1;
                    for(;i >= 0;i --){
                        //containsObject 判断元素是否存在于数组中(根据两者的内存地址判断，相同：YES  不同：NO）
                        if([cameraOrderArr containsObject:[dataOrderArr objectAtIndex:i]]) {
                            [cameraOrderArr removeObjectAtIndex:i];
                        }
                    }
                        
                    
                    //过滤数组
                    
    
                    for (NSString *cameraOrder in [[[cameraOrderArr reverseObjectEnumerator] allObjects] mutableCopy]) {
                        
                        [self.cameraView deleteOldCameraButtonWithIndex:[cameraOrder integerValue] WithType:@""];
                        
                    }
                    
                    
                    
                }else if(self.cameraArray.count < dataArray.count){
                    NSInteger cameraCount = self.cameraArray.count;
                    
                    NSInteger dataArrayCount = dataArray.count;
                    
                    NSInteger addCount = dataArrayCount - cameraCount;
                    
                    for (int i = (int)(dataArrayCount - addCount); i < dataArrayCount; i ++) {
                        
                        ETRoomDeviceModel *cidObj = dataArray[i];
                        
                        [self.cameraView.cameraArray addObject:cidObj];

                    }
                    
                    [self.cameraView addNewCameraButtonWithCount:addCount];

                    
                    
                }else{
                    
                    for (int i = 0 ; i < dataArray.count; i ++) {
                        
                        ETRoomDeviceModel *model = dataArray[i];
                        
                        UILabel *label = [self.cameraView viewWithTag:9000 + i];
                        
                        label.text = model.deviceName;
                        
                    }
                    
                }
            
            
            
            
        }
        else
        {
            
            
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        
    }];
    
    
    
}



- (void)addNewCamera{
    
    
    NSString *url = [ETAPIList getAPIList].getAllUserCameraAPI;
    
    [httpRequst POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *processResult = responseObject[@"processResult"];
        if ([processResult intValue]==1)
        {   //网络请求成功
            
            NSDictionary *dic = responseObject[@"resultMap"];
            NSArray *array = dic[@"content"];
            NSMutableArray *dataArray = [NSMutableArray new];
            for (NSDictionary *dic in array) {
                ETRoomDeviceModel *model = [ETRoomDeviceModel objectWithKeyValues:dic];
                
                model.devicePassword = [GTMBase64 decodeBase64String:model.devicePassword];
                
                [dataArray addObject:model];
            }
            
            
        
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
              
            });
            
        }
        else
        {
            
            
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        
    }];
    
}

- (void)deleteOldCamera:(NSNotification *)notice{
    
    NSDictionary* userinfo = [notice userInfo];

    NSInteger index = [userinfo[@"index"] integerValue];

    
    [self.cameraView deleteOldCameraButtonWithIndex:index WithType:@"房间"];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -EthomeSimilarityViewContentButtonDelegate

- (void)selectedCameraImage{
    
    
    ETCameraWifiViewController *controller = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"ETCameraWifiViewController"];
    
    
    
    [self.navigationController pushViewController:controller animated:YES];
    
    
}

- (void)selectedHudImageModel:(ETRoomDeviceModel *)model{
    
    
    
    for (int i = 0; i < self.cameraView.cameraArray.count; i ++) {
        ETRoomDeviceModel *cameraDevice = self.cameraView.cameraArray[i];
        
        if ([cameraDevice.deviceId isEqualToString:model.deviceId]  && i < 4) {
            
            [cameraDevice.streamVideoRender stopStream];
            
            [cameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                
            } FirstVideoFrameShow:^{
                
            } PlayEnded:^(NSError *error) {
                
            }];
        }else if([cameraDevice.deviceId isEqualToString:model.deviceId] && i >= 4){
            
            ETPlayerViewController  *controller = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"ETPlayerViewController"];
            
            controller.index = [model.cameraOrder  integerValue];
            
            controller.CID = [model.deviceId  longLongValue];

            controller.did = model.id;
            
            controller.model = model;
            
            [self.navigationController pushViewController:controller animated:NO];
            
            
            
            
        }
        
    }
    
    
    
}

-(void)selectedDetailCameraImage:(NSInteger)item model:(ETRoomDeviceModel *)model Did:(NSString *)did{
    
    
    ETPlayerViewController  *controller = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"ETPlayerViewController"];
    
    controller.index = item;
    
    controller.did = did;
    
    controller.model = model;
    
    [self.navigationController pushViewController:controller animated:NO];

    
}

- (void)ReInputPWWithCID:(ETRoomDeviceModel *)model{
    
    ETInputPWTableViewController *controller = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"ETInputPWTableViewController"];
    
    controller.title = @"重连摄像机";
    
    controller.isPassError = @"密码错误";
    
    controller.CID = [model.deviceId longLongValue];
    
    controller.deviceModel = model;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    
}

- (void)ReConnectWifiWithCID:(unsigned long long)cid{
    ETWIFITableViewController *controller = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"ETWIFITableViewController"];
    
    controller.title = @"WIFI配置";
    
    controller.CID = cid;
    
    controller.isReconnect = @"重新连接";
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark ----断开视频流-----

- (void)stopAllCamera{
    
    for (ETRoomDeviceModel *cameraDevice in self.cameraArray) {
        if ([cameraDevice.cameraFirm isEqualToString:@"Easycam"]) {
            
            [cameraDevice.streamVideoRender stopStream];

        }else if ([cameraDevice.cameraFirm isEqualToString:@"HaiKang"]){
            
            [cameraDevice.player stopRealPlay];
        }
        
    }
}

#pragma mark ----打开视频流-----

- (void)openAllCamera{
    
    [self stopAllCamera];
    
   
    if (self.cameraArray.count < 4) {
        for (ETRoomDeviceModel *cameraDevice in self.cameraArray) {
            
            [cameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                
            } FirstVideoFrameShow:^{
                
            } PlayEnded:^(NSError *error) {
                
            }];
        }
    }else{
        for (int i = 0;i < 4; i ++) {
            ETRoomDeviceModel *cameraDevice = self.cameraArray[i];
            
            [cameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
                
            } FirstVideoFrameShow:^{
                
            } PlayEnded:^(NSError *error) {
                
            }];
            
        }
        
    }
    
}



- (void)openLastCamera{
    
    
        
    ETRoomDeviceModel *cameraDevice = [self.cameraArray lastObject];
    
    [cameraDevice.streamVideoRender stopStream];
    
    [cameraDevice.streamVideoRender startStreamOnStreamChannelCreated:^{
            
        } FirstVideoFrameShow:^{
            
        } PlayEnded:^(NSError *error) {
            
    }];
        
    
    
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
