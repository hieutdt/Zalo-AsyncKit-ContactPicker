//
//  IGLKPickerTableCell.h
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 5/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGLKPickerTableCell : UICollectionViewCell <IGListBindable>

- (void)setName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
