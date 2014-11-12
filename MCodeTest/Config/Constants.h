//
//  Constants.h
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStoragePersons @"Persons"
#define kiTunesDateFormat @"yyyy-MM-dd'T'HH:mm:ssZ"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD (false)
#endif

typedef NS_ENUM(NSInteger,ResponseTypes)
{
  ResponseFailed,
  ResponseRetry,
  ResponseSuccess
};

typedef NS_ENUM(NSInteger,AnimationTypes)
{
  AnimationBounce,
  AnimationFade,
  AnimationFlip,
  AnimationSize
};