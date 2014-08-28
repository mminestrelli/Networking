//
//  MLImageCollectionViewCell.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/27/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLImageCollectionViewCell.h"
@interface MLImageCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPhoto;

@end
@implementation MLImageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"MLImageCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}


-(void) setImage:(UIImage*) image{
    [self.imageViewPhoto setImage:image];
    [self.imageViewPhoto setContentMode:UIViewContentModeScaleAspectFit];
}

@end
