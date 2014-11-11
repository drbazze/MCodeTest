//
//  MCTrackCell.h
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCTrackCell : UITableViewCell
{
  IBOutlet UILabel *titleLabel,*subtitleLabel;
}

@property(nonatomic,strong) IBOutlet UIImageView *thumbnail;

- (void)addTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
