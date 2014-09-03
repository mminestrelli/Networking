//
//  MLDaoImageManager.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/26/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLDaoImageManager : NSObject
+ (id)sharedManager;
-(void)saveThumbnail:(UIImage*)image withId:(NSString*)identification;
-(BOOL)isImageCachedWithId:(NSString*) identification;
-(UIImage*) getThumbnailWithId:(NSString*) identification;

@end
