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
@property(nonatomic,strong) NSString *artistName,*trackName,*albumName,*artWorkUrl,*itunesUrl,*currency,*previewUrl;
@property(nonatomic,strong) NSDate *releaseDate;

- (id)initFromData:(NSDictionary *)data;

/*

 wrapperType: "track",
 kind: "song",
 artistId: 5040714,
 collectionId: 574050396,
 trackId: 574050602,
 artistName: "AC/DC",
 collectionName: "Back In Black",
 trackName: "Back In Black",
 collectionCensoredName: "Back In Black",
 trackCensoredName: "Back In Black",
 artistViewUrl: "https://itunes.apple.com/us/artist/ac-dc/id5040714?uo=4",
 collectionViewUrl: "https://itunes.apple.com/us/album/back-in-black/id574050396?i=574050602&uo=4",
 trackViewUrl: "https://itunes.apple.com/us/album/back-in-black/id574050396?i=574050602&uo=4",
 previewUrl: "http://a89.phobos.apple.com/us/r1000/118/Music/v4/e0/72/aa/e072aa95-f758-cf8c-7daf-ef18d8ad4d30/mzaf_567586272135364355.aac.m4a",
 artworkUrl30: "http://a2.mzstatic.com/us/r30/Music/v4/18/c1/a4/18c1a4f8-3f50-9ba4-bdf9-b4148efa0564/886443673441.30x30-50.jpg",
 artworkUrl60: "http://a4.mzstatic.com/us/r30/Music/v4/18/c1/a4/18c1a4f8-3f50-9ba4-bdf9-b4148efa0564/886443673441.60x60-50.jpg",
 artworkUrl100: "http://a5.mzstatic.com/us/r30/Music/v4/18/c1/a4/18c1a4f8-3f50-9ba4-bdf9-b4148efa0564/886443673441.100x100-75.jpg",
 collectionPrice: 6.99,
 trackPrice: 1.29,
 releaseDate: "2012-11-19T08:00:00Z",
 collectionExplicitness: "notExplicit",
 trackExplicitness: "notExplicit",
 discCount: 1,
 discNumber: 1,
 trackCount: 10,
 trackNumber: 6,
 trackTimeMillis: 256000,
 country: "USA",
 currency: "USD",
 primaryGenreName: "Rock",
 radioStationUrl: "https://itunes.apple.com/station/idra.574050602"
 },
 
*/

@end
