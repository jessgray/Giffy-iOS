//
//  Gif.h
//  Giffy
//
//  Created by Jessica Smith on 12/4/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface Gif : NSManagedObject

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSData *photo;

@end
