//
//  MyDataManager.m
//  Giffy
//
//  Created by Jessica Smith on 12/4/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import "MyDataManager.h"
#import "DataManager.h"
#import "Gif.h"

@implementation MyDataManager

- (NSString *)xcDataModelName {
    return @"Gifs";
}

- (void)createDatabaseFor:(DataManager *)dataManager {
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    
    // Gifs
    NSString *plistPath = [bundle pathForResource:@"gifs" ofType:@"plist"];
    NSArray *gifsArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    for(NSDictionary *dictionary in gifsArray) {
        Gif *gif = [NSEntityDescription insertNewObjectForEntityForName:@"Gif" inManagedObjectContext:managedObjectContext];
        
        gif.tag = [dictionary objectForKey:@"tag"];
        gif.date = [dictionary objectForKey:@"date"];
        gif.url = [dictionary objectForKey:@"url"];
        
        NSURL *photoUrl = [NSURL URLWithString:gif.url];
        gif.photo = [NSData dataWithContentsOfURL:photoUrl];
        
    }
    
    [dataManager saveContext];
}

- (void)addGif:(NSDictionary *)dictionary {
    DataManager *dataManager = [DataManager sharedInstance];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    
    Gif *gif = [NSEntityDescription insertNewObjectForEntityForName:@"Gif" inManagedObjectContext:managedObjectContext];
    
    gif.tag = [dictionary objectForKey:@"tag"];
    gif.date = [dictionary objectForKey:@"date"];
    gif.url = [dictionary objectForKey:@"url"];
    
    NSURL *photoUrl = [NSURL URLWithString:gif.url];
    gif.photo = [NSData dataWithContentsOfURL:photoUrl];
    
    [dataManager saveContext];
    
}

@end
