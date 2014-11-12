//
//  MCAlbum.h
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCAlbum : NSObject

@property(nonatomic,assign) id artistId,trackId;
@property(nonatomic,assign) float price;
@property(nonatomic,strong) NSString *artistName,*trackName,*albumName,*artWorkUrl,*itunesUrl,*currency,*previewUrl,*releaseDate;

- (id)initFromData:(NSDictionary *)data;

@end
