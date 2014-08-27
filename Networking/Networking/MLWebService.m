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
- (void)startFetchingItemsWithInput:(NSString*)input
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.mercadolibre.com/items/%@",input ];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    //Cada vez estoy allocando una queue
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self fetchingItemsFailedWithError:error];
        } else {
            [self receivedItemsJSON:data];
        }
    }];
}

- (void)receivedItemsJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    NSArray *items = [self itemsFromJSON:objectNotation error:&error];
    
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

- (NSArray *)itemsFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"results"];
    NSLog(@"Count %d", results.count);
    
    for (NSDictionary *itemDic in results) {
        MLSearchItem *item = [[MLSearchItem alloc] init];
        
        //        pseudo reflection
        //        for (NSString *key in itemDic) {
        //            if ([item respondsToSelector:NSSelectorFromString(key)]) {
        //                [item setValue:[itemDic valueForKey:key] forKey:key];
        //            }
        //        }
        
        item.identifier=[itemDic valueForKey:@"id"];
        item.title=[itemDic valueForKey:@"title"];
        item.subtitle=[itemDic valueForKey:@"subtitle"];
        item.price=[itemDic valueForKey:@"price"];
        item.thumbnail=[itemDic valueForKey:@"thumbnail"];
        item.permalink=[itemDic valueForKey:@"permalink"];
        item.sold_quantity=[[itemDic valueForKey:@"sold_quantity"] integerValue];
        NSArray *picturesResults = [parsedObject valueForKey:@"pictures"];
        NSMutab
        for (NSDictionary *pics in results) {
            //cargar los links en el array que hay que crear arriba
        }
        //asignar el array a la property pictures
        [attributes addObject:item];
    }
    
    return attributes;
}
@end
