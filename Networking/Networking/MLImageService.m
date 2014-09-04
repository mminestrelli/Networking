//
//  MLThumbnailService.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLImageService.h"
#import "MLDaoImageManager.h"

@interface MLImageService()
@property (nonatomic,strong) NSURLConnection* connection;
@property (nonatomic,copy) NSString* identification;

// @property (nonatomic,strong) UIImage* currentImage;
@end

@implementation MLImageService

- (void)downloadImageWithURL:(NSURL *)url usingQueue:(NSOperationQueue*) queue withCompletionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(YES,image);
                                   });
                                   
                               } else{
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                        completionBlock(NO,nil);
                                   });

                               }
                           }];
}

-(MLImageService*)downloadImageWithURL:(NSURL *)url andIdentification:(NSString*) identification {

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.identification=identification;
    self.connection=[NSURLConnection connectionWithRequest:request delegate:self];
    return self;
}

-(MLImageService*)downloadImageWithURL:(NSURL *)url image:(UIImage*) image andIdentification:(NSString*) identification {

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.identification=identification;
    self.connection=[NSURLConnection connectionWithRequest:request delegate:self];
    return self;
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate loadImageWithData:data andIdentifier:self.identification];
        
    });
}


-(void)cancel{
    [self.connection cancel];
}

-(void) dealloc{
    [self.connection cancel];
}
@end
