//
//  MCStorageHandler.m
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCStorageHandlerFile.h"

@implementation MCStorageHandlerFile

//------------------------------------------------//

+(id)sharedClass
{
  static MCStorageHandlerFile *sharedStorageHandler = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedStorageHandler = [[self alloc] init];
  });
  
  return sharedStorageHandler;
}

//------------------------------------------------//

- (NSData *)retrieveImageFromStore:(NSString *)url
{
  NSString *fileName = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",[url lastPathComponent]];
  NSData *result = [NSData dataWithContentsOfFile:fileName];
  return result;
}

//------------------------------------------------//

- (void)saveImageToStore:(NSString *)url Data:(NSData *)data
{
  if(url && data)
  {
    UIImage *image = [UIImage imageWithData:data];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *fileName = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",[url lastPathComponent]];
    [imageData writeToFile:fileName atomically:YES];
  }
}

//------------------------------------------------//


@end
