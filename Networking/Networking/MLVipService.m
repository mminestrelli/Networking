//
//  MLVipService.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/28/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLVipService.h"

@implementation MLVipService
/*Url request with input. Spaces are replaced by %20. Error and success callbacks*/
- (void)startFetchingItemsWithInput:(NSString*)input
{
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.mercadolibre.com/items/%@",input ];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    [super startFetchingItemsWithUrl:url];
    //Cada vez estoy allocando una queue
//    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        
//        if (error) {
//            [self fetchingItemsFailedWithError:error];
//        } else {
//            [self receivedItemsJSON:data];
//        }
//    }];
}

- (void)receivedItemsJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    MLSearchItem *item = [self itemsFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        [self.delegate fetchingItemsFailedWithError:error];
        
    } else {
        if (item==nil) {
            [self.delegate didNotReceiveItem];
        }else{
            [self.delegate didReceiveItem:item];
        }
        
    }
}

- (void)fetchingItemsFailedWithError:(NSError *)error
{
    [self.delegate fetchingItemsFailedWithError:error];
}

- (MLSearchItem *)itemsFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    MLSearchItem *item = [[MLSearchItem alloc] init];
    item.identifier=[parsedObject valueForKey:@"id"];
    item.title=[parsedObject valueForKey:@"title"];
    item.subtitle=[parsedObject valueForKey:@"subtitle"];
    item.price=[parsedObject valueForKey:@"price"];
    item.thumbnail=[parsedObject valueForKey:@"thumbnail"];
    item.permalink=[parsedObject valueForKey:@"permalink"];
    item.sold_quantity=[[parsedObject valueForKey:@"sold_quantity"] integerValue];
    NSArray * picturesResults = [parsedObject valueForKey:@"pictures"];
    NSMutableArray * picturesUrls= [[NSMutableArray alloc]init];
    for (NSDictionary *pics in picturesResults) {
        //cargar los links en el array que hay que crear arriba
        [picturesUrls addObject: [pics valueForKey:@"secure_url" ]];
    }
    //asignar el array a la property pictures
    item.pictures=picturesUrls;
    return item;
}
@end
