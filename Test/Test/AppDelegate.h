//
//  AppDelegate.h
//  Test
//
//  Created by ethome on 16/3/8.
//  Copyright © 2016年 ethome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
@private
    Reachability *hostReach;
}
- (void) reachabilityChanged: (NSNotification* )note;//网络连接改变
- (void) updateInterfaceWithReachability: (Reachability*) curReach;//处理连接改变后的情况



@property (strong, nonatomic) UIWindow *window;


@end

