//
//  StateView.m
//  AsyncKit ContactPicker
//
//  Created by Trần Đình Tôn Hiếu on 4/23/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "StateView.h"

@interface StateView ()

@property (nonatomic, strong) ASImageNode *imageNode;
@property (nonatomic, strong) ASTextNode *titleNode;
@property (nonatomic, strong) ASTextNode *textNode;
@property (nonatomic, strong) ASButtonNode *buttonNode;
@property (nonatomic, strong) dispatch_block_t buttonActionBlock;

@end

@implementation StateView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        
        _imageNode = [[ASImageNode alloc] init];
        _titleNode = [[ASTextNode alloc] init];
        _textNode = [[ASTextNode alloc] init];
        _buttonNode = [[ASButtonNode alloc] init];
        _buttonNode.backgroundColor = [UIColor colorWithRed:93/255.f
                                                      green:173/255.f
                                                       blue:226/255.f
                                                      alpha:1];
        [_buttonNode addTarget:self
                        action:@selector(buttonNodeTapped)
              forControlEvents:ASControlNodeEventTouchUpInside];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    CGSize maxContrainedSize = constrainedSize.max;
    float height = maxContrainedSize.height;
    float width = maxContrainedSize.width;
    
    _imageNode.style.preferredSize = CGSizeMake(height * 0.4, height * 0.4);
    _buttonNode.style.minSize = CGSizeMake(100, 50);
    [_buttonNode setTintColor:[UIColor blueColor]];
    
    _titleNode.style.maxWidth = ASDimensionMake(width - 30);
    _textNode.style.maxWidth = ASDimensionMake(width - 30);

    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                           spacing:15
                                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[_imageNode, _titleNode, _textNode, _buttonNode]];
    
    return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                      sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                              child:stackSpec];
}

- (void)buttonNodeTapped {
    if (self.buttonActionBlock) {
        self.buttonActionBlock();
    }
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image {
    if (image) {
        [self.imageNode setImage:image];
    }
}

- (void)setTitle:(NSString *)title {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:22],
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      NSForegroundColorAttributeName : [UIColor darkTextColor]
    };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title
                                                                 attributes:attributedText];
    [self.titleNode setAttributedText:string];
}

- (void)setDescription:(NSString *)description {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributedText = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:20],
                                      NSParagraphStyleAttributeName : paragraphStyle,
                                      NSForegroundColorAttributeName : [UIColor darkGrayColor]
    };
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:description
                                                                 attributes:attributedText];
    [self.textNode setAttributedText:string];
}

- (void)setButtonTitle:(NSString *)title {
    [_buttonNode setTitle:title
                 withFont:[UIFont boldSystemFontOfSize:17]
                withColor:[UIColor whiteColor]
                 forState:UIControlStateNormal];
}

- (void)setButtonTappedAction:(dispatch_block_t)action {
    if (action) {
        _buttonActionBlock = action;
    }
}


@end
