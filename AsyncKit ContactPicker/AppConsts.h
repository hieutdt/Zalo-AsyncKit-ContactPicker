//
//  AppConsts.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef AppConsts_h
#define AppConsts_h

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

#define ASYNC_MAIN(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ })

typedef NS_ENUM(NSInteger, ContactAuthorState) {
    ContactAuthorStateDefault,
    ContactAuthorStateAuthorized,
    ContactAuthorStateDenied,
    ContactAuthorStateNotDetermined
};

#define AVATAR_IMAGE_HEIHGT     60
#define CHECKER_IMAGE_HEIGHT    30

#define AVATAR_COLLECTION_IMAGE_HEIGHT 60

#define GRADIENT_COLOR_BLUE     0
#define GRADIENT_COLOR_RED      1
#define GRADIENT_COLOR_ORANGE   2
#define GRADIENT_COLOR_GREEN    3

#define NEXT_BUTTON_HEIGHT 50

static const int FIRST_ALPHABET_ASCII_CODE = 97;
static const int ALPHABET_SECTIONS_NUMBER = 27;

static const int PICKER_COLLECTION_CELL_WIDTH = 70;
static const int PICKER_COLLECTION_CELL_HEIGHT = 80;

static const int MAX_PICK = 5;

static const int SECTION_HEADER_HEIGHT = 35;

static const int MAX_IMAGES_CACHE_SIZE = 20;

#endif /* AppConsts_h */
