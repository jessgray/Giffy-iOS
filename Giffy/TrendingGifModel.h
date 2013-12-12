//
//  TrendingGifModel.h
//  Giffy
//
//  Created by Jessica Smith on 12/10/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrendingGifModel : NSObject <NSURLConnectionDataDelegate>

- (void)downloadData;
- (NSInteger)count;
- (NSString *)urlForIndex:(NSInteger)index;
-(UIImage*)photoForIndex:(NSInteger)index;
- (NSData *)dataForIndex:(NSInteger)index;
@end
