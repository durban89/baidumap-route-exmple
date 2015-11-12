//
//  AppDelegate.h
//  biaudmap1
//
//  Created by ZhangDaPeng on 15/11/12.
//  Copyright © 2015年 ZhangDaPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;


@end

