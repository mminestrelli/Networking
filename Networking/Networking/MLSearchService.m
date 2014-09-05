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
@property (nonatomic,strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData *responseData;
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
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate didNotReceiveItems];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.delegate didReceiveItems:items];
            });
        }
        
    }
}

- (void)fetchingItemsFailedWithError:(NSError *)error
{
    [self.delegate fetchingItemsFailedWithError:error];
}

//types of the block should be defined.
- (void)startFetchingItemsWithInput:(NSString*)input andOffset:(NSInteger)offset withCompletionBlock:(void (^)(NSArray *items))completionBlock errorBlock:(void (^)(NSError* err)) error{
    
    self.lastSearch=input;
    self.currentOffset=offset;
    self.successBlock=completionBlock;
    self.errorBlock=error;
    NSString * planeInput=[input stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.mercadolibre.com/sites/MLA/search?q=%@&limit=%d&offset=%d",planeInput,kOffsetIncrement,offset ];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.connection=[NSURLConnection connectionWithRequest:request delegate:self];
}

- (NSArray*)receivedItemsFromJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    NSArray *items = [MLItemBuilder itemsFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        self.errorBlock(error);
        return nil;
    }
    return items;
}
#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData {
	[self.responseData appendData:someData];
}

-(void)connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse *)response{
    self.responseData = [[NSMutableData alloc] init];
}
-(void) connectionDidFinishLoading:(NSURLConnection *)aConnection {
    NSArray* items=[self receivedItemsFromJSON:self.responseData];
    self.successBlock(items);
}

-(void)connection:(NSURLConnection*) connection didFailWithError:(NSError *)error{
    self.errorBlock(error);
}

#pragma mark - Connection cancelling

-(void)cancel{
    [self.connection cancel];
}

-(void) dealloc{
    [self.connection cancel];
}

@end
