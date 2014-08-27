//
//  MLDaoFilesystem.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/26/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLDaoFilesystem.h"

@implementation MLDaoFilesystem

-(UIImage*) getThumbnailWithId:(NSString*) identification andPath:(NSString*)path{
    UIImage * thumbnail=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return thumbnail;
}
-(BOOL)isImageCachedWithId:(NSString*) identification andPath:(NSString*)path{
    return ([self getThumbnailWithId:identification andPath:path]==nil)? NO :YES;
}
-(void)saveThumbnail:(UIImage*)image withId:(NSString*)identification andPath:(NSString*)path{
    [NSKeyedArchiver archiveRootObject:image toFile:path];
}

-(NSMutableArray*) getHistoryFromPath:(NSString*)path{
    NSMutableArray* history=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return history;
}

-(void)saveHistory:(NSMutableArray*) history inPath:(NSString*)path{
    [NSKeyedArchiver archiveRootObject:history toFile:path];
}
@end
