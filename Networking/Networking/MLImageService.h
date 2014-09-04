//
//  MLThumbnailService.h
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLThumbnailResponseDelegate.h"

@interface MLImageService : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (weak, nonatomic) id<MLThumbnailResponseDelegate> delegate;
- (void)downloadImageWithURL:(NSURL *)url usingQueue:(NSOperationQueue*)queue withCompletionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
-(MLImageService*)downloadImageWithURL:(NSURL *)url andIdentification:(NSString*) identification;
-(void)cancel;

-(MLImageService*)downloadImageWithURL:(NSURL *)url image:(UIImage*) image andIdentification:(NSString*) identification;
@end