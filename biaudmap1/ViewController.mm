//
//  ViewController.m
//  biaudmap1
//
//  Created by ZhangDaPeng on 15/11/12.
//  Copyright © 2015年 ZhangDaPeng. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "UIImage+Rotate.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface ViewController (){
    BMKLocationService* _locService;
    BMKMapView* mapView;
    BMKPoiSearch* _poisearch;
    BMKRouteSearch* _routesearch;
    
    CLLocationCoordinate2D mylocation;
    
    int _cacheAnnotationTag;
    NSMutableDictionary *_cacheAnnotationMDic;
    
}

@end

@implementation ViewController

- (NSString*)getMyBundlePath1:(NSString *)filename
{
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    mapView.delegate=self;
    self.view = mapView;
    
    _routesearch = [[BMKRouteSearch alloc]init];
    _routesearch.delegate = self;
    
    _locService = [[BMKLocationService alloc]init];
    [self startLocation];
    
    
    _poisearch = [[BMKPoiSearch alloc]init];
    // 设置地图级别
    [mapView setZoomLevel:13];
    //设定是否总让选中的annotaion置于最前面
    mapView.isSelectedAnnotationViewFront = YES;
    
    UIButton *mybutton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    mybutton=[UIButton buttonWithType:UIButtonTypeCustom];
    mybutton.frame=CGRectMake(190, 20,80, 38);
    mybutton.backgroundColor=[UIColor blueColor];
    [mybutton setTitle:@"驾车路线" forState:UIControlStateNormal];
    [mybutton addTarget:self action:@selector(onClickDriveSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mybutton];
    
    
    _cacheAnnotationMDic=[[NSMutableDictionary alloc]init];
    BMKPointAnnotation* annotation;
    BMKPointAnnotation* annotation1;
    // 添加一个PointAnnotation
    annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = 39.915;
    coor.longitude = 116.404;
    annotation.coordinate = coor;
    annotation.title = @"test";
    annotation.subtitle = @"this is a test!";
    [mapView addAnnotation:annotation];
    
    annotation1 = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor1;
    coor1.latitude = 41.015;
    coor1.longitude = 116.404;
    annotation1.coordinate = coor1;
    annotation1.title = @"test1";
    annotation1.subtitle = @"this is a test!";
    [mapView addAnnotation:annotation1];
    
    
}
-(void)viewWillAppear:(BOOL)animated {
    [mapView viewWillAppear];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _routesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [mapView viewWillDisappear];
    mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _poisearch.delegate = nil; // 不用时，置nil
    _routesearch.delegate = nil; // 不用时，置nil
}
-(void)startLocation
{
    [_locService startUserLocationService];
    mapView.showsUserLocation = NO;//先关闭显示的定位图层
    mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    mapView.showsUserLocation = YES;//显示定位图层
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [mapView updateLocationData:userLocation];
    //    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    mylocation=(CLLocationCoordinate2D){userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude};
    [mapView updateLocationData:userLocation];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

-(void)onClickOk
{
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = 0;//如果要获取多页的数据，只需更改pageIndex的值
    citySearchOption.pageCapacity = 10;
    citySearchOption.city= @"深圳";
    citySearchOption.keyword = @"餐馆";
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }
}

-(void)NearbySearchAction{
    BMKNearbySearchOption *NearbySearchOption = [[BMKNearbySearchOption alloc]init];
    //    NearbySearchOption.location=CLLocationCoordinate2DMake(39.9255, 116.3995);
    NearbySearchOption.location=mylocation;
    NearbySearchOption.pageIndex = 0;//如果要获取多页的数据，只需更改pageIndex的值
    NearbySearchOption.pageCapacity = 10;
    NearbySearchOption.keyword = @"酒店";
    NearbySearchOption.radius=10000;
    NearbySearchOption.sortType=BMK_POI_SORT_BY_DISTANCE;//BMK_POI_SORT_BY_COMPOSITE = 0,//综合排序BMK_POI_SORT_BY_DISTANCE,//距离由近到远排序
    BOOL flag = [_poisearch poiSearchNearBy:NearbySearchOption];
    if(flag)
    {
        NSLog(@"附近检索发送成功");
    }
    else
    {
        NSLog(@"附近检索发送失败");
    }
}

#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        //当操作是路线规划时，不使用自定义图标
        return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
    }
    
    //---------------------------这个方法中的下面代码是随意测试-------------------------------------------
    
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;//头钉颜色
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;// 设置重天上掉下的效果(annotation)
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location.png"]];//气泡框左侧显示的View,可自定义
        
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectButton setFrame:(CGRect){260,0,50,40}];
        [selectButton setTitle:@"确定" forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView =selectButton;//气泡框右侧显示的View 可自定义
        [selectButton setBackgroundColor:[UIColor redColor]];
        [selectButton setShowsTouchWhenHighlighted:YES];
        //        [selectButton addTarget:self action:@selector(Location_selectPointAnnotation) forControlEvents:UIControlEventTouchUpInside];
        
    }
    //以下三行代码用于将自定义视图和标记绑定,一一对应,目的是当点击,右侧自定义视图时,能够知道点击的是那个标记
    annotationView.rightCalloutAccessoryView.tag = _cacheAnnotationTag;
    [_cacheAnnotationMDic setObject:annotation forKey:[NSNumber numberWithInteger:_cacheAnnotationTag]];
    _cacheAnnotationTag++;
    
    
    //如果是我的位置标注,则允许用户拖动改标注视图,并赋予绿色样式 处于
    if ([annotation.title isEqualToString:@"test"]) {
        
        ((BMKPinAnnotationView *)annotationView).pinColor = BMKPinAnnotationColorGreen;//标注呈绿色样式
        [annotationView setDraggable:YES];//允许用户拖动
        [annotationView setSelected:YES animated:YES];//让标注处于弹出气泡框的状态
    }else{
        
        //        ((BMKPinAnnotationView *)annotationView).pinColor = BMKPinAnnotationColorRed;
        UIView *viewForImage=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 132, 64)];
        UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 64)];
        [imageview setImage:[UIImage imageNamed:@"车位置.png"]];
        [viewForImage addSubview:imageview];
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(32, 0, 100, 64)];
        label.text=@"陈双超";
        label.backgroundColor=[UIColor clearColor];
        [viewForImage addSubview:label];
        
        annotationView.image=[self getImageFromView:viewForImage];
    }
    
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}
- (void)mapView:(BMKMapView *)bmapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [bmapView bringSubviewToFront:view];
    [bmapView setNeedsDisplay];
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"didAddAnnotationViews");
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:mapView.annotations];
    [mapView removeAnnotations:array];
    NSLog(@"===================");
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
        }
        [mapView addAnnotations:annotations];
        [mapView showAnnotations:annotations animated:YES];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else if (error == BMK_SEARCH_RESULT_NOT_FOUND){
        NSLog(@"没有搜索到结果");
    }else {
        
        // 各种情况的判断。。。
    }
}
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
    
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}

/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 取消选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"取消选中一个annotation views");
}

-(UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi{
    
}
-(void)onClickDriveSearch{
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = @"天安门";
    start.cityName = @"北京市";
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = @"鸟巢";
    end.cityName = @"北京市";
    
    //路线规划支持两种方式，一种是关键字，一种是经纬度坐标
    //    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //    //指定起点经纬度
    //    CLLocationCoordinate2D coor1;
    //    coor1.latitude = 39.90868;
    //    coor1.longitude = 116.204;
    //    start.pt = coor1;
    //    //指定起点名称
    //    start.name = @"我的位置";
    //    //指定起点
    //    para.startPoint = start;
    //
    //    //初始化终点节点
    //    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    //    //指定终点经纬度
    //    CLLocationCoordinate2D coor2;
    //    coor2.latitude = 39.90868;
    //    coor2.longitude = 116.3956;
    //    end.pt = coor2;
    //指定终点名称
    //    end.name = @"天安门";
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        NSLog(@"car检索发送失败");
    }
}
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"驾车路线结果：%@",result);
    NSLog(@"Error:%u",error);
    NSArray* array = [NSArray arrayWithArray:mapView.annotations];
    [mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:mapView.overlays];
    [mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [mapView addAnnotation:item];
            }
        }
        //轨迹点
#warning 这里报错,new报错
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}
//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [mapView setVisibleMapRect:rect];
    mapView.zoomLevel = mapView.zoomLevel - 0.3;
}
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 6.0;//调节地图上规划路线的宽度
        return polylineView;
    }
    return nil;
}
@end
