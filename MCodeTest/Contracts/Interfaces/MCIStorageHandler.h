//
//  MCIStorageHandler.h
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCIStorageHandler <NSObject>

@required
+ (id)sharedClass;
- (NSData *)retrieveImageFromStore:(NSString *)url;
- (void)saveImageToStore:(NSString *)url Data:(NSData *)data;

@end