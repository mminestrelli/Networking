//
//  MLWebService.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/27/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchCommunicatorDelegate.h"
#import "MLWebServiceDelegate.h"

@interface MLWebService : NSObject<MLSearchCommunicatorDelegate>

@property (weak, nonatomic) id<MLWebServiceDelegate> delegate;

- (void)startFetchingItemsWithUrl:(NSURL*)url;
@end
