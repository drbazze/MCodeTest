//
//  ViewController.m
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014. Legion Services Ltd. All rights reserved.
//

#import "Constants.h"

#import "ViewController.h"
#import "MCDetailView.h"

#import "MCContentHandler.h"
#import "MCTrackCell.h"
#import "MCAlbum.h"

static int minSearchPhraseLength = 3;
static NSString *latestSearchPhrase = @"";
static AnimationTypes defaultAnimation = AnimationSize;

//------------------------------------------------//

@interface ViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property(nonatomic,strong) NSArray *albumsCollection;
@property(nonatomic,strong) MCDetailView *detailContentView;

@end

//------------------------------------------------//

@implementation ViewController

//------------------------------------------------//
#pragma mark - Start methods -
//------------------------------------------------//

- (void)start
{
  self.albumsCollection = [NSArray new];
  [self setupNotifications];
}

//------------------------------------------------//

- (void)setAutoFocus
{
  UISearchBar *searchBar = [self findSearchBar:self.view];
  
  if(searchBar)
  {
    [searchBar becomeFirstResponder];
  }
}

//------------------------------------------------//

- (void)retrieveSearchResults:(NSString *)phrase
{
  /* If we want to clear the results */
  //[self clearResults];
  
  if(phrase.length >= minSearchPhraseLength)
  {
    latestSearchPhrase = phrase;
    
    [contentTable setContentOffset:CGPointZero animated:YES];
    [self showLoader:YES];
    
    [[MCContentHandler sharedClass] retrieveSearchResults:phrase resultBlock:^(ResponseTypes ResponseType, NSArray *TracksCollection) {
      if(ResponseType == ResponseSuccess)
      {
        self.albumsCollection = TracksCollection;
        
        [contentTable reloadData];
      }
      else if(ResponseType == ResponseRetry)
      {
        [self showRetryAlert];
      }
      else if(ResponseType == ResponseFailed)
      {
        [self showAlert:@"Information" message:[NSString stringWithFormat:@"There is no result for \"%@\" search phrase.",latestSearchPhrase]];
      }
      
      [self showLoader:NO];
    }];
  }
  else
  {
    [self showAlert:@"Error" message:[NSString stringWithFormat:@"Minimum search phrase length is %d",minSearchPhraseLength]];
  }
}

//------------------------------------------------//

- (void)setupNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidShow:)
                                               name: UIKeyboardDidShowNotification object:nil];
}

//------------------------------------------------//

- (void)showDetail:(MCAlbum *)track show:(BOOL)show animation:(AnimationTypes)animation
{
  if(animation == AnimationFlip)
  {
    [self showDetailFlipAnimation:track show:show];
  }
  else if(animation == AnimationSize)
  {
    [self showDetailSizeAnimation:track show:show];
  }
  else
  {
    [self showDetailSizeAnimation:track show:show];
  }
}

//------------------------------------------------//

- (void)showDetailFlipAnimation:(MCAlbum *)track show:(BOOL)show
{
  [UIView transitionWithView:self.view
                    duration:0.3
                     options:UIViewAnimationOptionTransitionFlipFromLeft
                  animations:^{
                    searchView.hidden = show;
                    detailView.hidden = !show;
                  } completion:^(BOOL finished) {
                    if(show)
                    {
                      NSArray *_xibs = [[NSBundle mainBundle] loadNibNamed:@"MCDetailView" owner:self options:nil];
                      _detailContentView = (MCDetailView *)[_xibs objectAtIndex:0];
                      _detailContentView.frame = CGRectMake(0,0,detailView.bounds.size.width,detailView.bounds.size.height);
                                            
                      [detailView addSubview:_detailContentView];
                      [_detailContentView addTrack:track];
                      
                      [_detailContentView addObserver:self forKeyPath:@"bindClose" options:NSKeyValueObservingOptionNew context:nil];
                    }
                    else
                    {
                      [_detailContentView removeObserver:self forKeyPath:@"bindClose"];
                      [_detailContentView removeFromSuperview];
                      _detailContentView = nil;
                    }
                  }];
}

//------------------------------------------------//

- (void)showDetailSizeAnimation:(MCAlbum *)track show:(BOOL)show
{
  float size = 1.0;
  float alpha = 1.0;
  
  if(!show)
  {
    size = 0.1;
    alpha = 1.0;
  }
  else
  {
    NSArray *_xibs = [[NSBundle mainBundle] loadNibNamed:@"MCDetailView" owner:self options:nil];
    _detailContentView = (MCDetailView *)[_xibs objectAtIndex:0];
    _detailContentView.frame = CGRectMake(0,0,detailView.bounds.size.width,detailView.bounds.size.height);
    
    [self.view addSubview:_detailContentView];
    [_detailContentView addTrack:track];
    
    _detailContentView.alpha = 0.0;
    _detailContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
    
    [_detailContentView addObserver:self forKeyPath:@"bindClose" options:NSKeyValueObservingOptionNew context:nil];
  }
  
  [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    _detailContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, size, size);
    _detailContentView.alpha = alpha;
  } completion:^(BOOL finished) {
    if(!show)
    {
      [_detailContentView removeObserver:self forKeyPath:@"bindClose"];
      [_detailContentView removeFromSuperview];
      _detailContentView = nil;
    }
  }];
}

//------------------------------------------------//

- (void)showAlert:(NSString *)title message:(NSString *)message
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
  [alert show];
}

//------------------------------------------------//

- (void)showRetryAlert
{
  UIAlertView *_Alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Cannot dowload the information from the server. Please try again" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel",nil];
  _Alert.tag = 1;
  [_Alert show];
}

//------------------------------------------------//

- (void)showAboutPopup
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About" message:@"If you like my work, don't hesitate to contact with me" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Hell Yeah", nil];
  alert.tag = 2;
  alert.delegate = self;
  
  [alert show];
}

//------------------------------------------------//
#pragma mark - Table methods -
//------------------------------------------------//

- (void)clearResults
{
  self.albumsCollection = nil;
  [contentTable reloadData];
}

//------------------------------------------------//

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _albumsCollection.count;
}

//------------------------------------------------//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_cellID = @"MCTrackCell";
  MCTrackCell *_cell = (MCTrackCell *)[tableView dequeueReusableCellWithIdentifier:_cellID];
  
  if(_cell == nil)
  {
    NSArray *_xibs = [[NSBundle mainBundle] loadNibNamed:_cellID owner:self options:nil];
    
    for (id currentObject in _xibs) {
      if ([currentObject isKindOfClass:[UITableViewCell class]]) {
        _cell =  (MCTrackCell *)currentObject;
        break;
      }
    }
  }
  
  MCAlbum *album = [_albumsCollection objectAtIndex:indexPath.row];
  
  [_cell addTitle:album.trackName subtitle:album.artistName];
  
  [[MCContentHandler sharedClass] retrieveImage:album.artWorkUrl ImageView:_cell.thumbnail animation:AnimationBounce];
  
  _cell.backgroundColor = [UIColor clearColor];
  
  if(indexPath.row % 2)
  {
    _cell.backgroundColor = RGB(247,247,247);
  }
  else
  {
    _cell.backgroundColor = RGB(255,255,255);
  }
  
  return _cell;
}

//------------------------------------------------//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  MCAlbum *album = [_albumsCollection objectAtIndex:indexPath.row];
  
  [self showDetail:album show:YES animation:defaultAnimation];
}

//------------------------------------------------//

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  MCAlbum *album = [_albumsCollection objectAtIndex:indexPath.row];
  
  float height = [self calculateCellHeight:album.artistName];
  
  /*TODO iPad version
  if(IS_IPAD && height < 200)
  {
    height = 200;
  }
  else if(!IS_IPAD && height < 50)
  {
    height = 50;
  }*/
  
  if(height < 50)
  {
    height = 50;
  }
  
  return height;
}

//------------------------------------------------//

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  MCAlbum *album = [_albumsCollection objectAtIndex:indexPath.row];
  
  [[MCContentHandler sharedClass] cancelRetrieveImage:album.artWorkUrl];
  
  MCTrackCell *_cell = (MCTrackCell *)[tableView cellForRowAtIndexPath:indexPath];
  _cell.thumbnail.image = nil;
}

//------------------------------------------------//

- (float)calculateCellHeight :(NSString *)string
{
  CGRect textRect = [string boundingRectWithSize:CGSizeMake(260.0f, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:14.0]}
                                          context:nil];
  
  return textRect.size.height + 35;
}

//------------------------------------------------//
#pragma mark - Other -
//------------------------------------------------//

- (void)showLoader:(BOOL)state
{
  float alpha = 1.0;
  
  if(!state)
  {
    alpha = 0.0;
  }
  
  [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    loader.alpha = alpha;
  } completion:^(BOOL finished) {
    
  }];
}

//------------------------------------------------//

- (UISearchBar *)findSearchBar:(UIView *)view
{
  id result = nil;
  
  for(UIView *innerView in view.subviews)
  {
    if([innerView isKindOfClass:[UISearchBar class]])
    {
      result = innerView;
      break;
    }
    else if(innerView.subviews.count > 0)
    {
      result = [self findSearchBar:innerView];
      break;
    }
  }
  
  return result;
}

//------------------------------------------------//
#pragma mark - Keyboard -
//------------------------------------------------//

- (void)keyboardWillHide:(NSNotification*)notification
{
  tapGesture.enabled = NO;
}

//------------------------------------------------//

- (void)keyboardDidShow:(NSNotification*)notification
{
  tapGesture.enabled = YES;
}

//------------------------------------------------//

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [self retrieveSearchResults:searchBar.text];
  
  [searchBar resignFirstResponder];
}

//------------------------------------------------//

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
}

//------------------------------------------------//

- (IBAction)actionHideKeyboard:(id)sender
{
  [self.view endEditing:YES];
}

//------------------------------------------------//

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if(alertView.tag == 1 && buttonIndex != alertView.cancelButtonIndex)
  {
    [self retrieveSearchResults:latestSearchPhrase];
  }
}

//------------------------------------------------//
#pragma mark - Observers -
//------------------------------------------------//

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if(object == _detailContentView && [keyPath isEqualToString:@"bindClose"])
  {
    if(_detailContentView.bindClose)
    {
      [self showDetail:nil show:NO animation:defaultAnimation];
    }
  }
}

//------------------------------------------------//

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self start];
  [self setAutoFocus];
}

//------------------------------------------------//

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

//------------------------------------------------//

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------//

@end
