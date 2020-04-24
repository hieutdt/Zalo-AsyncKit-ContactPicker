//
//  ImageHelper.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/24/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageHelper : NSObject

+ (UIImage *)makeRoundedImage:(UIImage *)image
                       radius:(float)radius;

@end

NS_ASSUME_NONNULL_END
