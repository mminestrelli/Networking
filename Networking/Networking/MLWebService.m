//
//  MLWebService.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/27/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLWebService.h"
#import "MLSearchItem.h"

@implementation MLWebService
/*Url request with input. Spaces are replaced by %20. Error and success callbacks*/
- (void)startFetchingItemsWithUrl:(NSURL*)url
{
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self fetchingItemsFailedWithError:error];
        } else {
            [self receivedItemsJSON:data];
        }
    }];
}


- (void)fetchingItemsFailedWithError:(NSError *)error
{
    [self.delegate fetchingItemsFailedWithError:error];
}

@end
