//
//  MCAlbum.m
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import "MCAlbum.h"

@implementation MCAlbum

- (id)initFromData:(NSDictionary *)data
{
  self = [super init];
  if (self)
  {
    self.albumName = [data objectForKey:@"collectionName"];
    self.trackName = [data objectForKey:@"trackName"];
    self.artistName = [data objectForKey:@"artistName"];
    self.artWorkUrl = [data objectForKey:@"artworkUrl100"];
    self.itunesUrl = [data objectForKey:@"trackViewUrl"];
    self.price = [[data objectForKey:@"trackPrice"] floatValue];
    self.releaseDate = [data objectForKey:@"releaseDate"];
    self.currency = [data objectForKey:@"currency"];
    self.previewUrl = [data objectForKey:@"previewUrl"];;
  }
  
  return self;
}

@end
