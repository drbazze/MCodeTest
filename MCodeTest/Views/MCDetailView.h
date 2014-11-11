//
//  MCDetailView.h
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCAlbum.h"

@interface MCDetailView : UIView
{
  IBOutlet UILabel *trackNameLabel,*artistNameLabel,*albumNameLabel,*priceLabel,*releaseDate;
  IBOutlet UIImageView *thumbnail;
  IBOutlet UIButton *playButton;
  IBOutlet UIActivityIndicatorView *Loader;
  IBOutlet UIView *buttonsView;
}

@property(nonatomic,assign) BOOL bindClose;

- (void)addTrack:(MCAlbum *)track;

@end
