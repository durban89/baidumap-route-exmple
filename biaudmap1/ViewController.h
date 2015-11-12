//
//  ViewController.h
//  biaudmap1
//
//  Created by ZhangDaPeng on 15/11/12.
//  Copyright © 2015年 ZhangDaPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface ViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKRouteSearchDelegate>


@end

