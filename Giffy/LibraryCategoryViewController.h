//
//  LibraryCategoryViewController.h
//  Giffy
//
//  Created by Jessica Smith on 12/9/13.
//  Copyright (c) 2013 Jessica Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSourceCellConfigurer.h"

@interface LibraryCategoryViewController : UICollectionViewController <DataSourceCellConfigurer, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSString *sectionName;

@end
