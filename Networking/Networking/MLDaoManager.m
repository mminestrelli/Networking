//
//  MLDaoManager.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/26/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLDaoManager.h"
#import "MLDaoFilesystem.h"
#import "MLDaoMemory.h"

@interface MLDaoManager()

@property (nonatomic) BOOL initializedFromCache;
@property (nonatomic,strong) MLDaoMemory * daoMemory;
@property (nonatomic,strong) MLDaoFilesystem * daoFileSystem;

@end

@implementation MLDaoManager
#pragma mark Singleton Methods

+ (id)sharedManager {
    static MLDaoManager *sharedDaoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDaoManager = [[self alloc] init];
    });
    return sharedDaoManager;
}

-(id) init{
    if([super init]){
        self.initializedFromCache=NO;
        self.daoFileSystem=[[MLDaoFilesystem alloc]init];
        self.daoMemory=[[MLDaoMemory alloc]init];
    }
    return self;
}

-(void)saveThumbnail:(UIImage*)image withId:(NSString*)identification{
    [self.daoFileSystem saveThumbnail:image withId:identification andPath:[[self getCacheFilePath]stringByAppendingString:identification]];
}

-(BOOL)isImageCachedWithId:(NSString*) identification{
    return [self.daoFileSystem isImageCachedWithId:identification andPath:[[self getCacheFilePath]stringByAppendingString:identification]];
}

-(UIImage*) getThumbnailWithId:(NSString*) identification{
    return [self.daoFileSystem getThumbnailWithId:identification andPath:[[self getCacheFilePath]stringByAppendingString:identification]];
}

-(NSMutableArray*) getHistory{
   return [self.daoFileSystem getHistoryFromPath:[[self getCacheFilePath]stringByAppendingString:@"history.dat"]];
}

-(void)saveHistory:(NSMutableArray*) history {
    [self.daoFileSystem saveHistory:history inPath:[[self getCacheFilePath]stringByAppendingString:@"history.dat"]];
}

-(void) deleteHistory{
    [self saveHistory:[[NSMutableArray alloc]init]];
}

-(NSString*) getCacheFilePath{
    /*Library folder, where you store configuration files and writable databases that you also want to keep around, but you don't want the user to be able to mess with through iTunes*/
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}
@end
