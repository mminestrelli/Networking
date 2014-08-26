//
//  MLSearchService.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchCommunicatorDelegate.h"
#import "SearchManagerDelegate.h"

@interface MLSearchService : NSObject<SearchCommunicatorDelegate>
- (void)startFetchingItemsWithInput:(NSString*)input andOffset:(NSInteger)offset;
-(void) fetchNextPage;
@property (weak, nonatomic) id<SearchManagerDelegate> delegate;
@end
