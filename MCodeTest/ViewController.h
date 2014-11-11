//
//  ViewController.h
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
  IBOutlet UITapGestureRecognizer *tapGesture;
  IBOutlet UITableView *contentTable;
  IBOutlet UIActivityIndicatorView *loader;
  IBOutlet UIView *searchView,*detailView;
}

@end

