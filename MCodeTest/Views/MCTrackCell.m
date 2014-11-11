//
//  MCTrackCell.m
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import "Constants.h"
#import "MCTrackCell.h"

@implementation MCTrackCell

- (void)awakeFromNib
{
  self.thumbnail.layer.borderColor = RGB(0,0,0).CGColor;
  self.thumbnail.layer.borderWidth = 1.0;
  self.thumbnail.layer.cornerRadius = 9.0;
  self.thumbnail.layer.masksToBounds = YES;
}

- (void)addTitle:(NSString *)title subtitle:(NSString *)subtitle
{
  titleLabel.text = title;
  subtitleLabel.text = subtitle;
  
  //TODO placeholder image
  //self.thumbnail = [UIImage imageNamed:@"placeholder"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}

@end
