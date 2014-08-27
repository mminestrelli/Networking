//
//  MLDaoManager.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/26/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLDaoDelegate.h"

@interface MLDaoManager : NSObject<MLDaoDelegate>
+ (id)sharedManager;
-(void)saveThumbnail:(UIImage*)image withId:(NSString*)identification;
-(BOOL)isImageCachedWithId:(NSString*) identification;
-(UIImage*) getThumbnailWithId:(NSString*) identification;
-(NSMutableArray*) getHistory;
-(void)saveHistory:(NSMutableArray*) history;
-(void) deleteHistory;
@end
