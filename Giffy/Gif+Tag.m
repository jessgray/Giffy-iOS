//
//  Gif+Tag.m
//  Giffy
//
//  Created by Jessica Smith on 12/4/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "Gif+Tag.h"

@implementation Gif (Tag)

- (NSString *)tagName {
    
    NSString *tag = [self.tag substringToIndex:1];
    return tag;
}

@end
