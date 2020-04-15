//
//  main.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
