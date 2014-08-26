//
//  MLHistoryItem.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/22/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLHistoryItem.h"

@implementation MLHistoryItem

-(id)initWithItem:(NSString*)item andDate:(NSDate*)date{
    if([super init]){
        self.searchedItem=item;
        self.searchDate=date;
    }
    return self;
}
@end
