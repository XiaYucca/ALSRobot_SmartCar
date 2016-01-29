//
//  MainViewController.m
//  XYCoreBlueToothDemo
//
//  Created by RainPoll on 15/12/29.
//  Copyright © 2015年 RainPoll. All rights reserved.
//

#import "MainViewController.h"
#import "SerialGATT.h"
#import <AVFoundation/AVFoundation.h>
#import "XYAudio.h"
#import "XYMotionManager.h"
#import "XYDirectionCalculate.h"
#import "SetMaskView.h"

#define URL_bj [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"bj" ofType:@"mp3"]]
#define URL_ok [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"ok" ofType:@"mp3"]]
#define URL_ok1 [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"ok1" ofType:@"mp3"]]
#define URL_an [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"an" ofType:@"mp3"]]

//蓝牙字第哦那个链接的距离
#define autoConectDistence -50

//动画移动的距离
#define left_Distance  200
#define bottom_Distance 50
#define right_1_Distance  180
#define right_2_Distance   200
#define  right_3_Distance  200



@interface MainViewController ()<BTSmartSensorDelegate,CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UIButton *derictionBtn;
@property (weak, nonatomic) IBOutlet UIButton *musicBtn;

@property (weak, nonatomic) IBOutlet UIImageView *wheelImageView;
@property (weak, nonatomic) IBOutlet UILabel *derationLab;
@property (weak, nonatomic) IBOutlet UIImageView *derationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;

@property (nonatomic,strong) CBPeripheralManager * centralManager;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;
//lib
@property (strong ,nonatomic) SerialGATT *serial;
@property (strong ,nonatomic)XYAudio *xyAudio;
@property (weak ,nonatomic)SetMaskView *setMaskView;
@property (strong ,nonatomic)NSTimer *scanTimer;


@property (assign ,nonatomic)BOOL blueToothStatus;
@property (assign ,nonatomic)BOOL musicStatus;
@property (assign ,nonatomic)BOOL motionStatus;

@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *test;  //修改约束
@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *setBtnLayout;
@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *musicBtnLayout;
@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *leftBtn_1Layout;
@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *letfBtn_2Layout;
@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *letfBtn_3Layout;

@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *stateBtnLayout;  //没用
@property (nonatomic ,weak) IBOutlet NSLayoutConstraint *motionBtnLayout;

@property (nonatomic, copy)NSMutableArray *discoverPeripheral;
@property (nonatomic, assign)BOOL autoConnect;

@property (assign ,nonatomic) CGRect oregionRect;
@property (assign ,nonatomic) CGPoint origionCenter;

@end

@implementation MainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self serialSetUp];
    [self audioSetUp];
//  [self testGif];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self uiSetUp];
//  [self.audio play];
    [self.xyAudio playMusicAtIndex:0];
//  [self motionStart];
//  [self UIanimation:YES];
    
//  [CircleView shareCircleView];
}
-(void)UIanimation:(BOOL)isExpand
{
    CGFloat  leftDistance = 0;
    CGFloat  bottomDistance = 10;
    CGFloat  right1_Distance = 0;
    CGFloat  right2_Distance = 89 ;
    CGFloat  right3_Distance = 65;
    if(isExpand)
    {
        leftDistance = - left_Distance;
        bottomDistance = - bottom_Distance;
        right1_Distance = - right_1_Distance;
        right2_Distance = - right_2_Distance;
        right3_Distance = - right_3_Distance;
    }
    self.test.constant = leftDistance;
    self.setBtnLayout.constant = bottomDistance;
    self.musicBtnLayout.constant = bottomDistance;
    self.leftBtn_1Layout.constant = right1_Distance;
    self.letfBtn_2Layout.constant = right2_Distance;
    self.letfBtn_3Layout.constant = right3_Distance;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - mutableArr get method
-(NSMutableArray *)discoverPeripheral
{
    if (!_discoverPeripheral) {
       _discoverPeripheral = [@[]mutableCopy];
       [self addObserver:self forKeyPath:@"discoverPeripheral" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _discoverPeripheral;
}

#pragma mark -图片切换

-(void)changleImage:(NSString *)imageName
{
   UIImageView *derationImageV = [self.view viewWithTag:1000];
//        NSString * imagePath = [[NSBundle mainBundle]pathForResource:imageName ofType:@"png"];
//    UIImage *derationImage = [UIImage imageWithContentsOfFile: imagePath];
//    derationImageV.image = derationImage;
    derationImageV.image = [UIImage imageNamed:@"youqian"];
}
-(void)changleImageAuto:(NSInteger)index
{
    static NSInteger oldIndex;
    if (oldIndex != index) {
        
        switch (index) {
            case 0:
                self.derationLab.text = @"停止";
                self.derationImageView.image = [UIImage imageNamed:@"tingzhi"];
                break;
            case 1:
                 self.derationLab.text = @"右转";
                 self.derationImageView.image = [UIImage imageNamed:@"youzhuan"];
                break;
            case 2:
                 self.derationLab.text = @"右前";
                 self.derationImageView.image = [UIImage imageNamed:@"youqian"];
                break;
            case 3:
                 self.derationLab.text = @"前进";
                 self.derationImageView.image = [UIImage imageNamed:@"qianjin"];
                break;
            case 4:
                 self.derationLab.text = @"左前";
                 self.derationImageView.image = [UIImage imageNamed:@"zuoqian"];
                break;
            case 5:
                 self.derationLab.text = @"左转";
                 self.derationImageView.image = [UIImage imageNamed:@"zuozhuan"];
                break;
            case 6:
                 self.derationLab.text = @"左后";
                 self.derationImageView.image = [UIImage imageNamed:@"zuohou"];
                break;
            case 7:
                 self.derationLab.text = @"后退";
                 self.derationImageView.image = [UIImage imageNamed:@"houtui"];
                break;
            case 8:
                 self.derationLab.text = @"右后";
                 self.derationImageView.image = [UIImage imageNamed:@"youhou"];
                break;
     
                
            default:
                break;
        }
        
    }
    oldIndex = index;
}
#pragma mark - 测试gif动画初始化
//-(void)testGif
//{
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
//    
//    imageView.image = [UIImage sd_animatedGIFNamed:@"about"];
//    
//    [self.view addSubview:imageView];
//}

#pragma mark - 设置蓝牙启动项
-(void)serialSetUp
{
    SerialGATT *serial = [[SerialGATT alloc]init];
    self.centralManager = [[CBPeripheralManager alloc]init];
    [serial setup];
    serial.delegate = self;
    self.serial = serial;
}

-(void)uiSetUp
{
    self.derictionBtn.alpha = 0.4;
    self.origionCenter = self.derictionBtn.center;
    self.oregionRect = self.derictionBtn.frame;
  
}


#pragma mark - 播放器初始化
-(void)audioSetUp
{
     self.xyAudio = [XYAudio shareXYAudion];
    [self.xyAudio addMusicFileURL:URL_bj];
    [self.xyAudio addMusicFileURL:URL_ok];
    [self.xyAudio addMusicFileURL:URL_ok1];
    [self.xyAudio addMusicFileURL:URL_an];
    [self.xyAudio setMusicPlayTime:INT16_MAX AtIndex:0];
    [self.xyAudio playMusicAtIndex:0];
    self.musicStatus = YES;
}

#pragma mark - 设置界面初始化

-(void)loadXib
{
    __block NSString *perName;
    
    __weak MainViewController *weakSelf = self;
    SetMaskView *setView = [ SetMaskView setMaskView];
    self.setMaskView = setView;
    
    self.discoverPeripheral = nil  ;
     self.stateImageView.image = [UIImage imageNamed:@"tishi1"];
    
    [setView maskViewEasyLinkCallBack:^{
        [weakSelf blueToothAutoScaning:1.1 withTimeOut:10];
    }];
    
    [setView maskViewSeachCallBack:^{
        [weakSelf blueToothScaning:10];
    }];
    
    [setView maskViewLinkCallBack:^{
        [weakSelf.discoverPeripheral enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([((NSString *)perName) isEqualToString: ((CBPeripheral *)obj).name]) {
                [weakSelf.serial connect:obj];
            }
        }];
    }];
    
    [setView maskViewStatueCallBack:^(BOOL *state){
        *state = _blueToothStatus;   //设置界面的蓝牙状态
        [weakSelf blueToothScaning:1]; //进去第一次 默认第一次进去就扫描一次
    }];
    
    
   [setView maskViewTableViewDidSelectRowAtIndexPath:^(NSIndexPath *index, id itemInArray) {
        
        perName = [((NSString *)itemInArray)copy];
  
    }];
    
    [setView maskViewShowWithComplement:^(BOOL *state){
          *state = _blueToothStatus;
        [weakSelf blueToothScaning:1];
        [weakSelf UIanimation:YES];
        }];
    [setView maskViewBackBtnCallBack:^{
        [weakSelf UIanimation:NO];
    }];
    

//   [setView showWithComplement:nil];
    
//    [setView initWithComplement:^(CGFloat *volNum,BOOL *musicStatus,BOOL *motionStatus,BOOL *blueToothStatus) {
//        *musicStatus = self.musicStatus;
//        *motionStatus = self.motionStatus;
//        *blueToothStatus = self.blueToothStatus ;
//        
//    }];
//    
//    //音量控制
//    [setView sliderValueDidChangle:^(CGFloat value) {
//        NSLog(@"音量%f",value);
//        [XYAudio shareXYAudion].volume = value;
//   
//    }];
//
//    //音乐开关
//    [setView switchValueDidChangle:^(BOOL status) {
//        if (status == YES) {
//            [XYAudio shareXYAudion].enable = YES;
//            self.musicBtn.selected = NO;
//            [[XYAudio shareXYAudion]playMusicAtIndex:0];
//        }else
//        {
//            self.musicBtn.selected = YES;
//            [XYAudio shareXYAudion].enable = NO;
//        }
//        self.musicStatus = status;
//  
//    }];
//    
//    //重力感应开关
//    [setView motionValueDidChangle:^(BOOL status) {
//        if (status == YES) {
//            
//            [self motionStart];
//        }else{
//            [self motionStop];
//        }
//        
//        self.motionStatus = status;
//     
//    }];
//    //蓝牙开关
//    [setView statusValueDidChangle:^(BOOL status) {
//        
//        if (status == YES) {
//            [self blueToothScaning];
//        }
//        if (status == NO) {
//            [self.serial.manager stopScan];
//            !self.serial.activePeripheral ?: [self.serial disconnect:self.serial.activePeripheral];
//        }
//        self.blueToothStatus = status;
//        NSLog(@"蓝牙开启");
//    
//    }];
    
    
//    centerBulletView *center = [centerBulletView centerBulletViewWithContentView: setView]; 
//  
//    [center showCentViewWithCompliment:^{
//         [self.xyAudio replayMusicAtIndex:1];
//    }];
//    
//    [center dismissCenterBulletWithCallBack:^{
//           [self.xyAudio replayMusicAtIndex:3];
//    
//         //   [CircleView dismissCircleViewWithComplent:nil];
//        
//            self.discoverPeripheral = nil;
//        
//            [self unenableAutoScaning];
//        }];
    
    
//    [self.xyAudio replayMusicAtIndex:3];
//    [center dismissCenterBulletWithCallBack:^{
//        [self.xyAudio replayMusicAtIndex:3];
//        
//        [CircleView dismissCircleViewWithComplent:nil];
//    }];
//    [center imagePlayerViewDidTapWithBlock:^(NSInteger index) {
//        [self.xyAudio replayMusicAtIndex:1];
//        
//        [CircleView shareCircleView];
//    }];
}
#pragma mark - 加载左视图界面
//-(void)loadLeftView
//{
//    XYLeftBall *letf = [[XYLeftBall alloc]initWithFrame:CGRectMake(0, 20, 100, 300)];
//    self.leftBall = letf;
//    
//    [letf bullDidSelectTableViewCellWithIndexPath:^(NSIndexPath *indexPath) {
//        
//        [self.leftBall viewChangleFrame:CGRectMake(0, 20, 200, 300)];
//        
//    }];
//    
//    [self.leftBall leftButtonClick:^{
//        if (self.leftBall.frame.size.width >100) {
//            [self.leftBall viewChangleFrame:CGRectMake(0, 20, 100, 300)];
//        }
//        else if(self.leftBall.frame.origin.x < 0)
//        {
//            [self.leftBall viewChangleFrame:CGRectMake(0, 20, 100, 300)];
//        }else
//            [self.leftBall viewhideOnLeft];
//        
//        NSLog(@"left click");
//    }];
//}

#pragma mark - 开启重力感应
-(void)motionStart
{
    [[XYMotionManager shareMotionManager]accelerometerUpdateInterval:0.1 CallBack:^(XYacceleration acceleration, NSError *error) {

        CGPoint deration = CGPointMake(acceleration.Y * 80, acceleration.X * 80);
        
        self.derictionBtn.center = getLocationWithTranslation(self.origionCenter, deration, 10, 40);
        
        NSLog(@"++++>%d", getDeriction(getAngleWithVector(CGPointMake(self.derictionBtn.center.x - self.origionCenter.x, self.derictionBtn.center.y - self.origionCenter.y))));
        
       NSLog(@"------>%ld", [self autoSendOrderWithTranslation:CGPointMake(self.derictionBtn.center.x - self.origionCenter.x, self.derictionBtn.center.y - self.origionCenter.y)]);
//        static int oldResult = 0;
//        
//        if(oldResult == )
//        
   }];
}
#pragma mark 关闭重力感应
-(void)motionStop
{
    [[XYMotionManager shareMotionManager]stopAccelerometerUpdates];
}


#pragma mark  计算坐标 并发送数据
-(NSInteger)autoSendOrderWithTranslation:(CGPoint)translation
{   static BOOL stop = NO;
    int result = getDeriction(getAngleWithVector(translation));
    //只运行一次
    if (result == 0) {
        if (stop == NO) {
            [self sendStr:@"s"];
            stop = YES;
        }
    }
    else{
        stop = NO;
       switch (result) {
        case 0:
//       [self sendStr:@"s"];
        case 1:
            [self sendStr:@"d"];
            break;
        case 2:
            [self sendStr:@"e"];
            break;
        case 3:
            [self sendStr:@"w"];
            break;
        case 4:
            [self sendStr:@"q"];
            break;
        case 5:
            [self sendStr:@"a"];
            break;
        case 6:
            [self sendStr:@"z"];
            break;
        case 7:
            [self sendStr:@"x"];
            break;
        case 8:
            [self sendStr:@"c"];
            break;
            
        default:
            break;
    }
    }
    return result;
}

#pragma mark - 触摸手势
/*-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
 //   [self.setView dismissViewWithComplement:nil];
//    [self.leftBall viewDissmissAnimationWithComplement:nil];
    
    NSLog(@"touch began%@",touches);
    UITouch *touch = [touches anyObject];
    UIView *view1 = (UIImageView*)[self.view  viewWithTag:100];
    CGPoint point = [touch  locationInView:self.view];
    if ( point.x <= self.view.frame.size.width * 0.5 ) {
        CGPoint center = CGPointMake(point.x - view1.frame.size.width * 0.5, point.y - view1.frame.size.height * 0.5);
        CGRect  frame = view1.frame;
        CGSize  originSize = frame.size;
        frame.origin = center;
        
        if (frame.origin.x <= 0) {
            frame.origin.x = 0;
        }
        if ((frame.origin.y + frame.size.height) >= [UIScreen mainScreen].bounds.size.height ) {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height ;
        }
        view1.frame = CGRectMake([UIScreen mainScreen].bounds.size.width *0.5-frame.size.width * 0.5, [UIScreen mainScreen].bounds.size.height *0.5-frame.size.height * 0.5, 0, 0);
        
     //   [self playMusic:URL_an];
        [self.xyAudio playMusicAtIndex:3];
        
        [UIView animateWithDuration:0.25 animations:^{
         view1.frame = frame;
         view1.transform = CGAffineTransformScale(view1.transform, 0.1, 0.1);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.25 animations:^{
                  view1.transform = CGAffineTransformScale(view1.transform, 10, 10);
                
            } completion:^(BOOL finished) {

                self.derictionBtn.bounds = CGRectMake(0, 0, 50, 50);
                self.derictionBtn.layer.cornerRadius = self.derictionBtn.frame.size.width * 0.5;
             
            }];
           
            }];
    }else
    {
        //  BulletView *bulleView = [BulletView bulletView];
        
#warning 这个是弹窗的函数
        /*
          centerBulletView *center = [centerBulletView shareCenterBulletView];
         [self.xyAudio replayMusicAtIndex:3];
         [center dismissCenterBulletWithCallBack:^{
             [self.xyAudio replayMusicAtIndex:3];
             
             [CircleView dismissCircleViewWithComplent:nil];
         }];
        [center imagePlayerViewDidTapWithBlock:^(NSInteger index) {
             [self.xyAudio replayMusicAtIndex:1];
            
             [CircleView shareCircleView];
        }];
 
        
    }
}
*/

#warning 暂时不需要
/*
//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    
//    UIView *view1 = (UIImageView*)[self.view  viewWithTag:100];
//    CGPoint point = [touch  locationInView:self.view];
//
//    NSLog(@"point ---%f -- %f",point.x,point.y);
//    
//    CGPoint center = CGPointMake(point.x - view1.frame.size.width * 0.5, point.y - view1.frame.size.height * 0.5);
//    CGPoint translation = CGPointMake(point.x - center.x, point.y - center.y);
//    
//    self.derictionBtn.center = [self calculateDeriction:center Deriction:translation];
//}
 */

#pragma mark - 按钮点击事件
- (IBAction)setBtnTap:(id)sender {
     NSLog(@"%s",__func__);
    
    [self loadXib];
    
//  [self blueToothScaning];

}

- (IBAction)musicBtnTap:(id)sender {
     NSLog(@"%s",__func__);
 
    UIButton *musicBtn = (UIButton *)sender;
    musicBtn.selected = !musicBtn.isSelected;
    
//    !musicBtn.isSelected ? {[self.xyAudio playMusicAtIndex:0]; self.XYAudio.enable = YES;}:[self.xyAudio stopMusicAtIndex:0];
    
    if (musicBtn.isSelected) {
        self.xyAudio.enable = NO;
        self.musicStatus = NO;
    }else
    {
        self.xyAudio.enable = YES;
        [self.xyAudio playMusicAtIndex:0];
         self.musicStatus = YES;
    }

    
}
- (IBAction)setBtnTouchDown:(id)sender {
    NSLog(@"down");
}

-(IBAction)obstacleBtnTap :(id)sender
{
    [self sendStr:@"q"];
}
-(IBAction)followBtnTap:(id)sender
{
    [self sendStr:@"e"];
}

#pragma mark - 小圆圈手势识别器
-(IBAction)dericionDown:(id)sender
{
    self.derictionBtn.bounds = CGRectMake(0, 0, 70, 70);
}

- (IBAction)derictionDrag:(UIPanGestureRecognizer *)sender {
    static int i = 0;
    static NSInteger oldresult = 0;
        switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"开始拖拽");
            break;
            
        case UIGestureRecognizerStateEnded:
            NSLog(@"结束拖拽");
            self.derictionBtn.bounds = CGRectMake(0, 0, 50, 50);
//            self.derictionBtn.layer.cornerRadius = self.derictionBtn.frame.size.width * 0.5;
            [sender setTranslation:CGPointZero inView:sender.view];
            [UIView animateWithDuration:0.5 animations:^{
                self.derictionBtn.frame = self.oregionRect;
            }];
                
            [self sendStr:@"s"];
            self.derationImageView.image = [UIImage imageNamed:@"tingzhi"];
            self.derationLab.text = @"停止";
                
            break;
                
         }

// 1.在view上面挪动的距离
    CGPoint translation = [sender translationInView:sender.view];
    
    CGPoint center = self.origionCenter;
    
    sender.view.center = getLocationWithTranslation(center, translation, 20, 40);


    if (!(i % 10)) {
        NSInteger result = [self autoSendOrderWithTranslation:translation];
        if (oldresult != result) {
            [self.xyAudio replayMusicAtIndex:2];
           [self changleImageAuto:result];
        }
        oldresult = result;
    }i++;
    
}

//-(void)setBtnRediex:(CGFloat)
#pragma mark - serialDelegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            self.blueToothStatus = YES;
            NSLog(@"蓝牙打开");
            break;
            
        default: self.blueToothStatus = NO;
            break;
    }
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    switch (peripheral.state) {
            //蓝牙开启且可用
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"蓝牙设备可用");
            break;
        default:
            break;
    }
}


-(void) peripheralFound:(CBPeripheral *)peripheral
{
  //    NSLog(@"array --->%@",peripheral);
  //  [self.discoverPeripheral addObject:peripheral];
    if (![self.discoverPeripheral containsObject:peripheral]) {
        
         [[self mutableArrayValueForKey:@"discoverPeripheral"] addObject:peripheral];
    }
    
   
}

-(void)peripheralFound:(CBPeripheral *)peripheral andRSSI:(NSNumber *)RSSI
{
    NSLog(@"peripheral-->%@  //// %d  autoConnect****%@",peripheral, RSSI.intValue,[NSString stringWithFormat:@"%i", self.autoConnect]);
    
    if (RSSI.intValue > -50 && self.autoConnect) {
       //  self.serial.activePeripheral = peripheral;
        [self unenableAutoScaning];
        [self.serial.manager stopScan];
        [self.serial connect:peripheral];
       
      
    }
    
}
- (void) periphereDidConnect:(CBPeripheral *)peripheral
{
    
    self.stateImageView.image = [UIImage imageNamed:@"tishi2"];
    
}
- (void) peripheralMissConnect:(CBPeripheral *)peripheral
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙断开连接" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIPreviewActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [[alert.view superview]bringSubviewToFront:alert.view];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    self.stateImageView.image = [UIImage imageNamed:@"tishi1"];
}

-(void)serialGATTCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到的数据有%@",str );
}


#pragma mark - 蓝牙
-(void)blueToothConnect
{
    if (self.serial.activePeripheral) {
        [self.serial disconnect:self.serial.activePeripheral];
    }
    
    //  self.serial.activePeripheral = controller.peripheral;
    NSLog(@"%@",self.serial.activePeripheral);
    
    [self.serial connect:self.serial.activePeripheral];
}


// scan peripher onece time
-(void)blueToothScaning:(int)timerOut
{

    [self.serial.manager stopScan];
    if ([self.serial activePeripheral]) {
        if (self.serial.activePeripheral.state == CBPeripheralStateConnected) {
            [self.serial.manager cancelPeripheralConnection:self.serial.activePeripheral];
            self.serial.activePeripheral = nil;
        }
    }
    if ([self.serial peripherals]) {
        self.serial.peripherals = nil;
    }
    printf("now we are searching device...\n");
    
    //  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    // [self.serial findBLKSoftPeripherals:5];
    [self.serial findBLKSoftPeripherals:timerOut];
}


-(void)blueToothAutoScaning:(float)interval withTimeOut:(int)timeOut
{
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(autoscaning:) userInfo:[NSNumber numberWithInt:interval] repeats:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self unenableAutoScaning];
       
    });
    self.scanTimer = timer;
    self.autoConnect = YES;
}

-(void)autoscaning:(NSTimer *)timer
{
    int timerOut =  [((NSNumber *)timer.userInfo)intValue];
    [self blueToothScaning:timerOut];
}
-(void)unenableAutoScaning
{
    self.autoConnect = NO;
    [self.serial.manager stopScan];
    [self.scanTimer invalidate];
     self.scanTimer = nil;
    
}
-(void)sendStr:(NSString *)str
{
    [self.serial write:self.serial.activePeripheral data:[str dataUsingEncoding:NSUTF8StringEncoding]];
}




#pragma mark - obser method

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    __weak MainViewController *weakSelf = self;
    if ([keyPath isEqualToString:@"discoverPeripheral"]) {
    
        CBPeripheral *per = [change[@"new"]lastObject];
        
        if (per.name) {
            
            NSMutableArray *perM = [@[]mutableCopy];
            [self.discoverPeripheral enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CBPeripheral *per = obj;
                ! per.name ?:[perM addObject:per.name];
            }];
            weakSelf.setMaskView.dataSource = [perM copy];
        }
//       else
//        {
//            NSMutableArray *perM = [@[]mutableCopy];
//            [self.discoverPeripheral enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                CBPeripheral *per = obj;
//                ! per.name ?:[perM addObject:per.name];
//            }];
//            weakSelf.setMaskView.dataSource = [perM copy];
//        }
//        
   }
}

#pragma mark - override delloc
-(void)dealloc{
    
    [self removeObserver:self forKeyPath:@"discoverPeripheral"];

}

@end
