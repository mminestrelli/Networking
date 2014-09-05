//
//  MLSearchService.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchCommunicatorDelegate.h"
#import "MLSearchManagerDelegate.h"

@interface MLSearchService : NSObject<MLSearchCommunicatorDelegate>

-(void) startFetchingItemsWithInput:(NSString*)input andOffset:(NSInteger)offset;
-(void) fetchNextPage;
/*Blocks for holding response*/
@property (copy)void (^errorBlock)(NSError* err);
@property (copy)void (^successBlock)(NSArray *items);
- (void)startFetchingItemsWithInput:(NSString*)input andOffset:(NSInteger)offset withCompletionBlock:(void (^)(NSArray *items))completionBlock errorBlock:(void (^)(NSError* err)) error;
-(void)cancel;
@property (weak, nonatomic) id<MLSearchManagerDelegate> delegate;
@end
