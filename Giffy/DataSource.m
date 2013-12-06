//
//  DataSource.m
//
//  Created by John Hannan on 7/19/12.
//  Copyright (c) 2012, 2013 Penn State University. All rights reserved.
//

#import "DataSource.h"
#import "DataManager.h"
#import "DataManagerDelegate.h"
#import "DataSourceCellConfigurer.h"
#import <CoreData/CoreData.h>
#import "HomeCollectionHeaderView.h"

@interface DataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSFetchRequest *fetchRequest;

@property (nonatomic, strong) NSMutableArray *objectChanges;
@property (nonatomic, strong) NSMutableArray *sectionChanges;

@end;

@implementation DataSource
@synthesize fetchedResultsController, fetchRequest;
@synthesize delegate;


-(id)initForEntity:(NSString *)name
          sortKeys:(NSArray*)sortKeys
         predicate:(NSPredicate*)predicate
sectionNameKeyPath:(NSString*)keyPath
dataManagerDelegate:(id<DataManagerDelegate>)dataManagerDelegate {
    self = [super init];
    if (self) {
        // get the Data Manager and set its delegate - only created once
        DataManager *dataManager = [DataManager sharedInstance];
        dataManager.delegate = dataManagerDelegate;
        
        // create array of sort descriptors from array of sort keys
        NSMutableArray *sortDescriptors = [[NSMutableArray alloc]init];
        for (NSString *key in sortKeys) {
            
            NSSortDescriptor *sortDescriptor;
            
            // Sort ascending or descending depending on key path
            if([keyPath isEqualToString:@"date"]) {
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
            } else {
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
            }
            
            [sortDescriptors addObject:sortDescriptor];
        }
        
        // create the fetch request
        self.fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
        self.fetchRequest.sortDescriptors = sortDescriptors;
        self.fetchRequest.predicate = predicate;
        
        //cache name
        NSString *cacheName = [NSString stringWithFormat:@"%@.cache", [dataManagerDelegate xcDataModelName]];
        
        // create the Fetched Results Controller
        NSManagedObjectContext *context = [dataManager managedObjectContext];
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:self.fetchRequest
                                         managedObjectContext:context
                                         sectionNameKeyPath:keyPath
                                         cacheName:cacheName];
        
        // Perform the fetch.  Just in case, check for errors
        NSError *error;
        BOOL result = [self.fetchedResultsController performFetch:&error];
        if (!result) {
            NSLog(@"Fetch failed: %@", [error description]);
        }
    }
    return self;
}



// if we set a collectionView, then we want to support the delegate methods for
// the fetched results controller
-(void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    if (collectionView) {
        self.fetchedResultsController.delegate = self;
    } else {
        self.fetchedResultsController.delegate = nil;
    }
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of collection view cells

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // get the object for this index path
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // ask delegate for the cell identifier of this object
    NSString *CellIdentifier = [self.delegate cellIdentifierForObject:managedObject];
    // get the cell
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // ask delegate to configure the cell
    [self.delegate configureCell:cell withObject:managedObject];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionHeader) {
        HomeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        
        // Set section title
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][[indexPath section]];
        
       if([[self.fetchedResultsController sectionNameKeyPath] isEqualToString:@"date"]) {
           
           // Create date formatter
           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
           
           // Get date string from section name
           NSString *dateString = (NSString *)[sectionInfo name];
           NSDate *date = [dateFormatter dateFromString:dateString];
           
           // Format date so it displays as month day
           [dateFormatter setDateFormat:@"MMM dd"];
           NSString *newDate = [dateFormatter stringFromDate:date];
            
            headerView.headerTitle.text = newDate;
        } else {
            headerView.headerTitle.text = [sectionInfo name];

        }

        reusableView = headerView;
    }
    
    return reusableView;
}

-(void)update {
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Fetch update failed: %@", [error description]);
    }
}

-(void)updateWithPredicate:(NSPredicate*)predicate {
    self.fetchRequest.predicate = predicate;
    
    // Perform the fetch again.  Just in case, check for errors
    NSError *error;
    BOOL result = [self.fetchedResultsController performFetch:&error];
    if (!result) {
        NSLog(@"Fetch failed: %@", [error description]);
    }
}


#pragma mark - Fetched Results Controller delegate

/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

@end
