#import "SceneDelegate.h"
#import "ASDKViewController.h"
#import "CKViewController.h"
#import "IGLKViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session
                                            options:(UISceneConnectionOptions *)connectionOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    ASDKViewController *ASDK = [[ASDKViewController alloc] init];
    CKViewController *CK = [[CKViewController alloc] init];
    IGLKViewController *IGLK = [[IGLKViewController alloc] init];
    
    UITabBarItem *ASDKTabBarItem = [[UITabBarItem alloc] initWithTitle:@"ASDK"
                                                                 image:[UIImage imageNamed:@""]
                                                                   tag:0];
    UITabBarItem *CKTabBarItem = [[UITabBarItem alloc] initWithTitle:@"CK"
                                                               image:[UIImage imageNamed:@""]
                                                                 tag:1];
    UITabBarItem *IGLKTabBarItem = [[UITabBarItem alloc] initWithTitle:@"IGLK"
                                                                 image:[UIImage imageNamed:@""]
                                                                   tag:2];
    
    ASDK.tabBarItem = ASDKTabBarItem;
    CK.tabBarItem = CKTabBarItem;
    IGLK.tabBarItem = IGLKTabBarItem;
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[ASDK, CK, IGLK];
    tabBarController.selectedViewController = ASDK;
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:tabBarController];
    
    _window.rootViewController = navigationController;
    _window.windowScene = (UIWindowScene *)scene;
    [_window makeKeyAndVisible];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
