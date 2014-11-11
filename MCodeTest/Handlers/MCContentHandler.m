//
//  ContentHandler.m
//  TestUnitTesting
//
//  Created by Zumpf Tamás on 2014.08.03..
//  Copyright (c) 2014 Legion Services Ltd. All rights reserved.
//

#import "MCContentHandler.h"
#import "MCStorageHandlerFile.h"
#import "MCAlbum.h"

//------------------------------------------------//

static NSString *kSearchUrl = @"http://itunes.apple.com/search?term=";
static NSString *kMyLikedInUrl = @"http://hu.linkedin.com/in/zumpf";
const int maxCount = 20;
const int kTimeOut = 15;

//------------------------------------------------//

@interface MCContentHandler()

@property(nonatomic,strong) NSMutableData *responseData;
@property(nonatomic,copy) SearchResultBlock RetrievePersonsResultBlock;
@property(nonatomic,strong) NSOperationQueue *ImageDownloadQueue;
@property(nonatomic,strong) NSMutableDictionary *Operations;
@property(nonatomic,strong) id<MCIStorageHandler> storageHandler;

@end

//------------------------------------------------//

@implementation MCContentHandler
@synthesize BindUseDataFromStorage;

//------------------------------------------------//

+ (id)sharedClass
{
  static MCContentHandler *sharedContentHandler = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedContentHandler = [[self alloc] init];
  });
  
  return sharedContentHandler;
}

//------------------------------------------------//

- (id)init
{
  if(self = [super init])
  {
    _storageHandler = [MCStorageHandlerFile sharedClass];
    _ImageDownloadQueue = [[NSOperationQueue alloc] init];
    _ImageDownloadQueue.maxConcurrentOperationCount = 5;
    
    self.Operations = [[NSMutableDictionary alloc] init];
    
    self.BindUseDataFromStorage = NO;

    [self addObserver:self forKeyPath:@"BindUseDataFromStorage" options:NSKeyValueObservingOptionNew context:nil];
  }
  return self;
}

//------------------------------------------------//

- (void)retrieveSearchResults:(NSString *)phrase resultBlock:(SearchResultBlock)resultBlock
{
  _RetrievePersonsResultBlock = [resultBlock copy];
  
  phrase = [phrase stringByReplacingOccurrencesOfString:@" " withString:@"+"];
  NSString *urlString = [NSString stringWithFormat:@"%@%@",kSearchUrl,phrase.lowercaseString];
  NSLog(@"urlString %@",urlString);
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:kTimeOut];
  
  [NSURLConnection connectionWithRequest:request delegate:self];
}

//------------------------------------------------//

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  _responseData = [[NSMutableData alloc] init];
}

//------------------------------------------------//

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [_responseData appendData:data];
}

//------------------------------------------------//

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  UIAlertView *_Alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The connection is failed to the server. You have not downloaded any informations yet. Please retry the download." delegate:self cancelButtonTitle:@"Retry download" otherButtonTitles:@"Retry", nil];
  _Alert.tag = 2;
  [_Alert show];
  
  _RetrievePersonsResultBlock(ResponseFailed,nil);
}

//------------------------------------------------//

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSError *error = nil;
  NSDictionary *result = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error: &error];
  
  if(!result || [[result objectForKey:@"resultCount"] intValue] == 0)
  {
    //TODO show specific error
    UIAlertView *_Alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"There is no result for the search phrase." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    _Alert.tag = 1;
    [_Alert show];
    
    _RetrievePersonsResultBlock(ResponseFailed,nil);
  }
  else
  {    
    NSMutableArray *albumsCollection = [NSMutableArray new];
    
    for(NSDictionary *data in [result objectForKey:@"results"])
    {
      MCAlbum *album = [[MCAlbum alloc] initFromData:data];
      
      [albumsCollection addObject:album];
    }
    
    _RetrievePersonsResultBlock(ResponseSuccess,[albumsCollection copy]);
  }
}

//------------------------------------------------//

- (void)retrieveImage:(NSString *)url ImageView:(UIImageView *)imageView animation:(AnimationTypes)animation
{
  if(url && imageView)
  {
    
    NSData *data = [_storageHandler retrieveImageFromStore:url];
    
    if(data == nil)
    {
      NSBlockOperation *_Operation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
          [self showImage:imageData view:imageView animation:animation];
        }];
        
        [_storageHandler saveImageToStore:url Data:imageData];
        
        [_Operations removeObjectForKey:url];
      }];
      
      [_Operations setObject:_Operation forKey:url];
      [_ImageDownloadQueue addOperation:_Operation];
    }
    else
    {
      [self showImage:data view:imageView animation:animation];
    }
  }
}

//------------------------------------------------//

- (void)showImage:(NSData *)data view:(UIImageView *)imageView animation:(AnimationTypes)animation
{
  imageView.image = [UIImage imageWithData:data];
  
  if(animation == AnimationBounce)
  {
    [self bounceAnimation:imageView];
  }
  else
  {
    [self fadeAnimation:imageView];
  }
}

//------------------------------------------------//

- (void)bounceAnimation:(UIImageView *)imageView
{
  imageView.alpha = 0.0;
  
  float _max = 1.3;
  float _min = 0.8;
  
  if(IS_IPAD)
  {
    _max = 1.1;
    _min = 0.9;
  }
  
  [UIView animateWithDuration:0.3/1.5 animations:^{
    
    imageView.alpha = 1.0;
    imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, _max, _max);
    
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.3/2 animations:^{
      
      imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, _min, _min);
      
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.3/2 animations:^{
        
        imageView.transform = CGAffineTransformIdentity;
        
      }];
    }];
  }];
}

//------------------------------------------------//

- (void)fadeAnimation:(UIImageView *)imageView
{
  imageView.alpha = 0.0; 
  
  [UIView animateWithDuration:0.3 animations:^{
    imageView.alpha = 1.0;
  } completion:^(BOOL finished) {

  }];
}

//------------------------------------------------//

- (void)cancelRetrieveImage:(NSString *) _Url
{
  NSOperation *_Operation = [_Operations objectForKey:_Url];
  
  if(_Operation)
  {
    [_Operation cancel];
    [_Operations removeObjectForKey:_Url];
  }
}

//------------------------------------------------//

- (void)showAboutPopup
{
  UIAlertView *_Alert = [[UIAlertView alloc] initWithTitle:@"About" message:@"If you like my work, don't hesitate to contact with me" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Hell Yeah", nil];
  _Alert.tag = 1;
  
  [_Alert show];
}

//------------------------------------------------//

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if(buttonIndex == 1)
  {
    if(alertView.tag == 1)
    {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMyLikedInUrl]];
    }
    else if(alertView.tag == 2)
    {
      self.BindUseDataFromStorage = YES;
    }
  }
  else
  {
    if(alertView.tag == 2 || alertView.tag == 3)
    {
      
    }
  }
}

//------------------------------------------------//
#pragma mark - Observers -
//------------------------------------------------//

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if(object == self && [keyPath isEqualToString:@"BindUseDataFromStorage"])
  {

  }
}

//------------------------------------------------//

- (void)dealloc
{
  [self removeObserver:self forKeyPath:@"BindUseDataFromStorage"];
}

//------------------------------------------------//

@end
