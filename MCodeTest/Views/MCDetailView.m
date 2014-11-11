//
//  MCDetailView.m
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "Constants.h"
#import "MCContentHandler.h"
#import "MCDetailView.h"

//------------------------------------------------//

@interface MCDetailView()

@property(nonatomic,strong) MCAlbum *track;
@property(nonatomic,strong) AVPlayer *player;

@end

//------------------------------------------------//

@implementation MCDetailView
@synthesize bindClose;

//------------------------------------------------//

- (void)awakeFromNib
{
  thumbnail.layer.borderColor = RGB(0,0,0).CGColor;
  thumbnail.layer.borderWidth = 1.0;
  thumbnail.layer.cornerRadius = thumbnail.frame.size.height / 3;
  thumbnail.layer.masksToBounds = YES;
}

//------------------------------------------------//

- (void)drawRect:(CGRect)rect
{
  [self alignButtons];
}

- (void)addTrack:(MCAlbum *)track
{
  self.track = track;
  artistNameLabel.text = _track.artistName;
  trackNameLabel.text = _track.trackName;
  albumNameLabel.text = _track.albumName;
  releaseDate.text = [NSString stringWithFormat:@"%@",_track.releaseDate];
  
  if(_track.price <= 0)
  {
    priceLabel.text = @"Free";
  }
  else
  {
    priceLabel.text = [NSString stringWithFormat:@"%.2f %@",_track.price,_track.currency];
  }
    
  [self addPlayer];
  
  [[MCContentHandler sharedClass] retrieveImage:_track.artWorkUrl ImageView:thumbnail animation:AnimationFade];
}

//------------------------------------------------//

- (void)alignButtons
{
  buttonsView.frame = CGRectMake(buttonsView.frame.origin.x,self.frame.size.height - buttonsView.frame.size.height - 10,buttonsView.frame.size.width,buttonsView.frame.size.height);
}

//------------------------------------------------//

- (void)addPlayer
{
  _player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:_track.previewUrl]];
  
  [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(playbackFinished)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:_player.currentItem];
}

//------------------------------------------------//

- (void)playbackFinished
{
  [_player seekToTime:kCMTimeZero];
  playButton.selected = NO;
}

//------------------------------------------------//

- (IBAction)actionClose:(id)sender
{
  [_player pause];
  
  self.bindClose = YES;
  
  thumbnail.image = nil;
}

//------------------------------------------------//

- (IBAction)actionShowItunes:(id)sender
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_track.itunesUrl]];
}

//------------------------------------------------//

- (IBAction)actionPlay:(id)sender
{
  if(_player.rate > 0)
  {
    [_player pause];
    playButton.selected = NO;
  }
  else
  {
    [_player play];
    playButton.selected = YES;
  }
}

//------------------------------------------------//
#pragma mark - Observers -
//------------------------------------------------//

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if(object == _player && [keyPath isEqualToString:@"status"])
  {
    if(_player.status == AVPlayerStatusReadyToPlay)
    {
      Loader.hidden = YES;
      
      [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        playButton.alpha = 1.0;
      } completion:^(BOOL finished) {
        
      }];
    }
    else
    {
      Loader.hidden = YES;
      
      [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        playButton.alpha = 1.0;
      } completion:^(BOOL finished) {
        playButton.enabled = NO;
      }];
    }
  }
}

//------------------------------------------------//

- (void)dealloc
{
  [_player removeObserver:self forKeyPath:@"status"];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------//

@end
