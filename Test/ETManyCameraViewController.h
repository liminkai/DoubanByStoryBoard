//
//  ETManyCameraViewController.h
//  Ethome
//
//  Created by ethome on 16/5/10.
//  Copyright © 2016年 Whalefin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EthomeSimilarityView.h"

@interface ETManyCameraViewController : UIViewController

@property (nonatomic, assign) BOOL isAddNewCamera;

@property (nonatomic, strong) NSMutableArray *cameraArray;

@property (nonatomic, strong) EthomeSimilarityView *cameraView;

@end
