//
//  MLSearchService.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLSearchService.h"
#import "MLItemBuilder.h"
#define kOffsetIncrement 50
@interface MLSearchService()
@property (nonatomic) NSInteger currentOffset;
@property (nonatomic,copy) NSString* lastSearch;
@end
@implementation MLSearchService

/*Url request with input. Spaces are replaced by %20. Error and success callbacks*/
- (void)startFetchingItemsWithInput:(NSString*)input andOffset:(NSInteger)offset
{
    self.lastSearch=input;
    self.currentOffset=offset;
    NSString * planeInput=[input stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.mercadolibre.com/sites/MLA/search?q=%@&limit=%d&offset=%d",planeInput,kOffsetIncrement,offset ];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    

    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self fetchingItemsFailedWithError:error];
        } else {
            [self receivedItemsJSON:data];
        }
    }];
}
-(void)fetchNextPage{
    self.currentOffset+=kOffsetIncrement;
    [self startFetchingItemsWithInput:self.lastSearch andOffset:self.currentOffset];
    
}
- (void)receivedItemsJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    NSArray *items = [MLItemBuilder itemsFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        [self.delegate fetchingItemsFailedWithError:error];
        
    } else {
        if ([items count]==0) {
            [self.delegate didNotReceiveItems];
        }else{
            [self.delegate didReceiveItems:items];
        }
        
    }
}

- (void)fetchingItemsFailedWithError:(NSError *)error
{
    [self.delegate fetchingItemsFailedWithError:error];
}
@end
