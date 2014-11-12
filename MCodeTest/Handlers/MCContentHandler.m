//
//  MCContentHandler.m
//  MCodeTest
//
//  Created by Zumpf Tamás on 2014. 11. 10..
//  Copyright (c) 2014 Legion Services Ltd. All rights reserved.
//

#import "MCContentHandler.h"
#import "MCStorageHandlerFile.h"
#import "MCAlbum.h"

//------------------------------------------------//

static NSString *kSearchUrl = @"http://itunes.apple.com/search?term=";
static NSString *kMyLikedInUrl = @"http://hu.linkedin.com/in/zumpf";
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
    
    [self initNotification];
  }
  return self;
}

//------------------------------------------------//

- (void)initNotification
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAboutPopup) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

//------------------------------------------------//

- (void)retrieveSearchResults:(NSString *)phrase resultBlock:(SearchResultBlock)resultBlock
{
  _RetrievePersonsResultBlock = [resultBlock copy];
  
  phrase = [phrase stringByReplacingOccurrencesOfString:@" " withString:@"+"];
  NSString *urlString = [NSString stringWithFormat:@"%@%@",kSearchUrl,phrase.lowercaseString];

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
  _RetrievePersonsResultBlock(ResponseRetry,nil);
}

//------------------------------------------------//

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSError *error = nil;
  NSDictionary *result = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error: &error];
  
  if(!result)
  {
    _RetrievePersonsResultBlock(ResponseRetry,nil);
  }
  else if([[result objectForKey:@"resultCount"] intValue] == 0)
  {
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
  
  /* @TODO iPad version
  if(IS_IPAD)
  {
    _max = 1.1;
    _min = 0.9;
  }
   */
  
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

- (void)cancelRetrieveImage:(NSString *)url
{
  NSOperation *operation = [_Operations objectForKey:url];
  
  if(operation)
  {
    [operation cancel];
    [_Operations removeObjectForKey:url];
  }
}

//------------------------------------------------//

- (void)showAboutPopup
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About" message:@"If you like my work, don't hesitate to contact with me" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Hell Yeah", nil];
  alert.tag = 1;
  alert.delegate = self;
  
  [alert show];
}

//------------------------------------------------//

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if(alertView.tag == 1 && buttonIndex == 1)
  {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMyLikedInUrl]];
  }
}

//------------------------------------------------//

- (void)dealloc
{

}

//------------------------------------------------//

@end
