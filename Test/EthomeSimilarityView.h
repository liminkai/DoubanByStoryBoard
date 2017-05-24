//
//  EthomeSimilarityView.h
//  KouHanDaJiBa
//
//  Created by edeco on 16/3/29.
//  Copyright © 2016年 edeco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETRoomDeviceModel.h"

@class EthomeSimilarityView;

@protocol EthomeSimilarityViewContentButtonDelegate <NSObject>

- (void)selectedHudImageModel:(ETRoomDeviceModel *) model;

- (void)selectedCameraImage;

- (void)selectedDetailCameraImage:(NSInteger)item model:(ETRoomDeviceModel *) model Did:(NSString *)did;

- (void)ReInputPWWithCID:(ETRoomDeviceModel *)model;

- (void)ReConnectWifiWithCID:(unsigned long long)cid;


@end


@interface EthomeSimilarityView : UIView
/**
 *  传几个
 */
@property (nonatomic,assign) NSInteger itemCounts;

@property (nonatomic, strong) NSMutableArray *deleteBtnArray;

/**
 *  scrollView
 */
@property (nonatomic,strong) UIScrollView *scrollView;
/**
 *  摄像机数组
 */

@property (nonatomic, assign) float cameraHeight;//摄像机高度

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray *cameraArray;

@property (nonatomic,assign) id <EthomeSimilarityViewContentButtonDelegate> delegate;

- (void)setupViewButtons;
/**
 *  添加新的camera
 */
- (void)addNewCameraButtonWithCount:(NSInteger)count;

/**
 *  删除原有的camera
 */

- (void)deleteOldCameraButtonWithIndex:(NSInteger)index WithType:(NSString *)type;


- (void)openAllCamera;

- (void)stopAllCamera;

@end
