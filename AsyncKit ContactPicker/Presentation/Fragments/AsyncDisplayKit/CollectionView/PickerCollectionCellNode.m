//
//  PickerCollectionCellNode.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/16/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerCollectionCellNode.h"
#import "PickerViewModel.h"

#import "StringHelper.h"
#import "AppConsts.h"
#import "UIImage+Addtions.h"

@interface PickerCollectionCellNode ()

@property (nonatomic, strong) ASImageNode *imageNode;
@property (nonatomic, strong) ASButtonNode *removeButton;
@property (nonatomic, strong) ASTextNode *shortNameLabel;

@property (nonatomic, assign) PickerViewModel *model;
@property (nonatomic, assign) CGFloat avatarCollectionImageHeight;

@end

@implementation PickerCollectionCellNode

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        _avatarCollectionImageHeight = [UIScreen mainScreen].bounds.size.width / 7.f;
        
        _imageNode = [[ASImageNode alloc] init];
        _imageNode.contentMode = UIViewContentModeScaleToFill;
        _imageNode.style.preferredSize = CGSizeMake(_avatarCollectionImageHeight, _avatarCollectionImageHeight);
        _imageNode.cornerRadius = _avatarCollectionImageHeight/2.f;
        
        _shortNameLabel = [[ASTextNode alloc] init];
        _shortNameLabel.maximumNumberOfLines = 1;
        
        _removeButton = [[ASButtonNode alloc] init];
        [_removeButton setTitle:@"X"
                       withFont:[UIFont boldSystemFontOfSize:14]
                      withColor:[UIColor blackColor]
                       forState:UIControlStateNormal];
        [_removeButton setBackgroundColor:[UIColor colorWithRed:240/255.f green:241/255.f blue:242/255.f alpha:1]];
        [_removeButton addTarget:self
                          action:@selector(removeButtonTapped)
                forControlEvents:ASControlNodeEventTouchUpInside];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    _removeButton.style.preferredSize = CGSizeMake(20, 20);
    _removeButton.cornerRadius = 10;
    _removeButton.borderWidth = 3;
    _removeButton.borderColor = [UIColor whiteColor].CGColor;
    
    ASCenterLayoutSpec *centerNameSpec = [ASCenterLayoutSpec
                                          centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                          sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                          child:_shortNameLabel];
    
    
    ASInsetLayoutSpec *insetNameSpec = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsZero
                                                                              child:centerNameSpec];
    ASOverlayLayoutSpec *overlaySpec = [ASOverlayLayoutSpec overlayLayoutSpecWithChild:_imageNode
                                                                               overlay:insetNameSpec];
    
    ASInsetLayoutSpec *insetRemoveButtonSpec = [ASInsetLayoutSpec
                                                insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, INFINITY, INFINITY, 0)
                                                child:_removeButton];
    ASOverlayLayoutSpec *removeButtonOverlaySpec = [ASOverlayLayoutSpec
                                                    overlayLayoutSpecWithChild:overlaySpec
                                                    overlay:insetRemoveButtonSpec];
    
    return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                      sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                              child:removeButtonOverlaySpec];
}


#pragma mark - Setters

- (void)setUpPickerModelForCell:(PickerViewModel *)pickerModel {
    if (!pickerModel)
        return;
    
    self.model = pickerModel;
    
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:20],
                                      NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[StringHelper getShortName:pickerModel.name]
                                                                 attributes:attributedText];
    self.shortNameLabel.attributedText = string;
    self.shortNameLabel.hidden = NO;
    
    switch (pickerModel.gradientColorCode) {
        case GRADIENT_COLOR_RED: {
            self.imageNode.image = [UIImage imageNamed:@"gradientRed"];
            break;
        }
        case GRADIENT_COLOR_BLUE: {
            self.imageNode.image = [UIImage imageNamed:@"gradientBlue"];
            break;
        }
        case GRADIENT_COLOR_GREEN: {
            self.imageNode.image = [UIImage imageNamed:@"gradientGreen"];
            break;
        }
        case GRADIENT_COLOR_ORANGE: {
            self.imageNode.image = [UIImage imageNamed:@"gradientOrange"];
            break;
        }
        default:
            break;
    }
}

- (void)setUpImageForCell:(UIImage *)image {
    if (image) {
        self.shortNameLabel.hidden = YES;
        self.imageNode.image = image;
    }
}

#pragma mark - Action

- (void)removeButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionCellNode:removeButtonTappedAtElement:)]) {
        [self.delegate collectionCellNode:self removeButtonTappedAtElement:self.model];
    }
}

@end
