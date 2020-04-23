//
//  StateView.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/23/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StateView : ASDisplayNode

- (void)setImage:(UIImage *)image;

- (void)setTitle:(NSString *)title;

- (void)setDescription:(NSString *)description;

- (void)setButtonTitle:(NSString *)title;

- (void)setButtonTappedAction:(dispatch_block_t)action;

@end

NS_ASSUME_NONNULL_END
