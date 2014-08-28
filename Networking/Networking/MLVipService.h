//
//  MLVipService.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/28/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLWebService.h"

@interface MLVipService : MLWebService<MLSearchCommunicatorDelegate>

@property (weak, nonatomic) id<MLWebServiceDelegate> delegate;
- (void)startFetchingItemsWithInput:(NSString*)input;
@end

