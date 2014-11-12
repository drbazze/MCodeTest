//
//  NSString+MCExtension.m
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 12..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import "NSString+MCExtension.h"

@implementation NSString (MCExtension)

//------------------------------------------------//

- (NSDate *)getDateWithFormat:(NSString *)format
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [NSLocale currentLocale];
  dateFormatter.dateFormat = format;
  NSDate *date = [dateFormatter dateFromString:self];
  
  return date;
}

//------------------------------------------------//

@end
