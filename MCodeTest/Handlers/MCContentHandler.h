//
//  MCContentHandler.h
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014 Legion Services Ltd. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//------------------------------------------------//

typedef NS_ENUM(NSInteger,ResponseTypes)
{
  ResponseFailed,
  ResponseRetry,
  ResponseSuccess
};

typedef NS_ENUM(NSInteger,AnimationTypes)
{
  AnimationBounce,
  AnimationFade
};

//------------------------------------------------//

typedef void(^SearchResultBlock)(ResponseTypes ResponseType, NSArray *TracksCollection);

//------------------------------------------------//

@interface MCContentHandler : NSObject <NSURLConnectionDelegate,UIAlertViewDelegate>

@property(nonatomic,assign) BOOL bindRetry;

+ (id)sharedClass;

- (void)retrieveSearchResults:(NSString *)phrase resultBlock:(SearchResultBlock)resultBlock;
- (void)retrieveImage:(NSString *)url ImageView:(UIImageView *)imageView animation:(AnimationTypes)animation;
- (void)cancelRetrieveImage:(NSString *) _Url;
- (void)showAboutPopup;

//------------------------------------------------//

@end
