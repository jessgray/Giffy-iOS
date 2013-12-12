//
//  TrendingGifModel.m
//  Giffy
//
//  Created by Jessica Smith on 12/10/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "TrendingGifModel.h"
#import "Constants.h"


static NSString *const TrendingGifsFeed = @"http://api.giffy.co/gifs/100";

@interface TrendingGifModel ()

@property (nonatomic, strong) NSMutableArray *workingGifs;
@property (nonatomic, strong) NSArray *trendingGifs;

@property (nonatomic, assign) BOOL waitingForImageURL;

@property (nonatomic, strong) UIImage *blankImage;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation TrendingGifModel

-(id)init {
    self = [super init];
    if (self) {
        [self downloadData];
    }
    
    return self;
}

- (void)downloadData {
    _workingGifs = [[NSMutableArray alloc] initWithCapacity:20];
    _blankImage = [[UIImage alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:TrendingGifsFeed]];
    _downloadQueue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.downloadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to get data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            [self parseDownloadedData:data];
        }
    }];
}

- (void)parseDownloadedData:(NSData *)data {
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSArray *gifsArray = jsonDict[@"gifs"];
    for (int i = 0; i < gifsArray.count; i++) {
        NSDictionary *gifEntryDict = gifsArray[i];
        NSString *url = gifEntryDict[@"url"];
        
        NSDictionary *appDictionary = @{@"url":url, @"photo":[NSNull null], @"data":[NSNull null]};
        [self.workingGifs addObject:[appDictionary mutableCopy]];
    }
    
    self.trendingGifs = self.workingGifs;
    
}

# pragma mark - Public Methods
- (NSInteger)count {
    return [self.trendingGifs count];
}

- (NSString *)urlForIndex:(NSInteger)index {
    NSDictionary *dict = [self.trendingGifs objectAtIndex:index];
    return dict[@"url"];
}

-(UIImage*)photoForIndex:(NSInteger)index {
    __block NSDictionary *dict = [self.trendingGifs objectAtIndex:index];
    if ([dict objectForKey:@"photo"] == [NSNull null]) {
        __block NSNumber *number = [NSNumber numberWithInt:index];
        NSString *urlString = [dict objectForKey:@"url"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.downloadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSData *imageData = data;
            UIImage *image = [UIImage imageWithData:data];
            [dict setValue:imageData forKey:@"data"];
            [dict setValue:image forKey:@"photo"];
            [self performSelectorOnMainThread:@selector(notifyImageReadyAtIndex:) withObject:number waitUntilDone:NO];
        }];
        
        return self.blankImage;
    } else {
        return [dict objectForKey:@"photo"];
    }
}

- (NSData *)dataForIndex:(NSInteger)index {
    NSDictionary *dict = [self.trendingGifs objectAtIndex:index];
    if(!([dict objectForKey:@"data"] == [NSNull null])) {
        return dict[@"data"];
    } else {
        return nil;
    }
}

-(void)notifyImageReadyAtIndex:(NSNumber*)indexNumber {
    [[NSNotificationCenter defaultCenter] postNotificationName:GifPhotoDownlodCompleted object:self userInfo:@{@"index":indexNumber}];
}

- (void)notify {
    [[NSNotificationCenter defaultCenter] postNotificationName:GifDataDownloadCompleted object:self];
}

@end
