//
//  AppDelegate.m
//  SplashAnimationDemo
//
//  Created by James on 16/4/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UINavigationController *naVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    self.window.rootViewController = naVC;
    
    //这句话是在动画效果昨晚后写的,如果不设置背景颜色,会默认是黑色,效果不好
    self.window.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    [self.window makeKeyAndVisible];
    
    //logoMask
    /**
     
     跳进去可以看到layer.mask属性也是一个CALayer,所以在使用的时候需要单独创建一个CALayer作为mask
     
     写好如下几步,运行,就可以看到遮罩的效果已经出来了
    
     */
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
    maskLayer.position = naVC.view.center;
    maskLayer.bounds = CGRectMake(0, 0, 60, 60);
    naVC.view.layer.mask = maskLayer;
    
    /**
     写完如下几步,可以看到 logo中间的透明效果已经被遮盖,不能显示主界面的内容了
     */
    UIView *maskBackgroundView = [[UIView alloc]initWithFrame:naVC.view.bounds];
    maskBackgroundView.backgroundColor = [UIColor whiteColor];
    [naVC.view addSubview:maskBackgroundView];
    [naVC.view bringSubviewToFront:maskBackgroundView];
    
    
    //添加动画
    CAKeyframeAnimation *logoMaskAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];

    logoMaskAnimation.duration = 1.0f;
    logoMaskAnimation.beginTime = CACurrentMediaTime() + 1;  //增加一秒的延时
    //定义三种效果的logo的大小
    /**
     
     动画分为三步:
     1.logo显示在主界面
     2.logo会缩小
     3.logo会无限放大,显示出主界面
     
     */
    CGRect initalBounds = maskLayer.bounds;
    CGRect secondBounds = CGRectMake(0, 0, 50, 50);
    CGRect finalBounds = CGRectMake(0, 0, 2000, 2000);
    
    logoMaskAnimation.values = @[[NSValue valueWithCGRect:initalBounds],
                                 [NSValue valueWithCGRect:secondBounds],
                                 [NSValue valueWithCGRect:finalBounds],
                                 ];
    /**
     *  该属性是一个数组，用以指定每个子路径(AB,BC,CD)的时间

     */
    logoMaskAnimation.keyTimes = @[@(0),@(0.5),@(1)];
    /**
     kCAMediaTimingFunctionLinear选项创建了一个线性的计时函数，同样也是CAAnimation的timingFunction属性为空时候的默认函数。线性步调对于那些立即加速并且保持匀速到达终点的场景会有意义（例如射出枪膛的子弹），但是默认来说它看起来很奇怪，因为对大多数的动画来说确实很少用到。
     
     kCAMediaTimingFunctionEaseIn常量创建了一个慢慢加速然后突然停止的方法。对于之前提到的自由落体的例子来说很适合，或者比如对准一个目标的导弹的发射。
     
     kCAMediaTimingFunctionEaseOut则恰恰相反，它以一个全速开始，然后慢慢减速停止。它有一个削弱的效果，应用的场景比如一扇门慢慢地关上，而不是砰地一声。
     
     kCAMediaTimingFunctionEaseInEaseOut创建了一个慢慢加速然后再慢慢减速的过程。这是现实世界大多数物体移动的方式，也是大多数动画来说最好的选择。如果只可以用一种缓冲函数的话，那就必须是它了。那么你会疑惑为什么这不是默认的选择，实际上当使用UIView的动画方法时，他的确是默认的，但当创建CAAnimation的时候，就需要手动设置它了。
     */

    logoMaskAnimation.timingFunctions =@[
                                         [CAMediaTimingFunction functionWithName:                        kCAMediaTimingFunctionEaseInEaseOut],
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                                         ];
    logoMaskAnimation.removedOnCompletion = NO;
    logoMaskAnimation.fillMode = kCAFillModeForwards;
    [naVC.view.layer.mask addAnimation:logoMaskAnimation forKey:@"logoMaskAnimation"];
    
    /**
     *  ------------------------至此logo动画效果已经完成------------------------
     
     下面就是要处理动画执行完毕后,将maskBackgroundView移除
     */
    [UIView animateWithDuration:0.1 delay:1.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //首先将backgroundView的透明度置为0
        maskBackgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        //然后将其在父视图中移除
        [maskBackgroundView removeFromSuperview];
    }];
    
    //增加navigationController的bounce效果,不至于进入主界面时突兀
    [UIView animateWithDuration:0.25 delay:1.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        naVC.view.transform = CGAffineTransformMakeScale(1.05, 1.05);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            //恢复初始大小
            naVC.view.transform = CGAffineTransformIdentity;
            
        }];
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
