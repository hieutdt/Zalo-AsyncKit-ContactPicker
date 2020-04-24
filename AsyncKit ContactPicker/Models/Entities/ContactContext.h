//
//  ContactContext.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/24/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactContext : NSObject

- (instancetype)initWithImages:(NSSet<UIImage *> *)images;

- (UIImage *)imageByIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
