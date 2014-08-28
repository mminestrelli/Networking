//
//  MLItemDetailViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLItemDetailViewController.h"
#import "MLImageCollectionViewCell.h"
#import "MLVipService.h"
#import "MLSearchItem.h"
#import "MLThumbnailService.h"

@interface MLItemDetailViewController ()<MLWebServiceDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
- (IBAction)buyButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlGallery;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPhotoGallery;

@property (nonatomic,strong) MLVipService * vipService;
@property (nonatomic,strong) MLThumbnailService * imageService;
//mock
@property (nonatomic) int currentIndex;
@property (nonatomic, strong) NSArray *imagesFromService;
@property (nonatomic,strong) MLSearchItem* searchItem;


@end

@implementation MLItemDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andItem:(MLSearchItem*)item
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.vipService= [[MLVipService alloc]init];
        self.imageService=[[MLThumbnailService alloc]init];
        self.searchItem=item;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self loadImages];
    [self setupCollectionView];
    self.vipService.delegate=self;
    self.pageControlGallery.hidden = YES;
    [self loadingHud];
    [self.vipService startFetchingItemsWithInput:self.searchItem.identifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)buyButtonPressed:(id)sender {
}

#pragma mark -
#pragma mark UICollectionView methods

-(void)setupCollectionView {
    [self.collectionViewPhotoGallery registerClass:[MLImageCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionViewPhotoGallery setPagingEnabled:YES];
    [self.collectionViewPhotoGallery setCollectionViewLayout:flowLayout];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesFromService count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MLImageCollectionViewCell *cell = (MLImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    self.pageControlGallery.currentPage = indexPath.row;
    self.pageControlGallery.numberOfPages=[self.imagesFromService count];
    self.pageControlGallery.hidden = NO;
    [cell setImage:[self.imagesFromService objectAtIndex:indexPath.row]];
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewPhotoGallery.frame.size;
}

#pragma mark -
#pragma mark Data methods

-(void)loadImagesWithItem:(MLSearchItem*)item {
    
    NSMutableArray * _images=[[NSMutableArray alloc]init];
    NSInteger counter=0;
    self.searchItem=item;
    self.labelTitle.text=item.title;
    self.labelPrice.text=[NSString stringWithFormat:@"%f",[item.price floatValue]];
    
    for (counter=0;counter<[self.searchItem.pictures count];counter++) {
        NSURL* url=[NSURL URLWithString:[self.searchItem.pictures objectAtIndex:counter]];
        [self.imageService downloadImageWithURL:url usingQueue:self.thumbnailDownloadQueue withCompletionBlock:
            ^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                // change the image in the cell
                // Update UI on the main thread.
                    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                        [_images addObject:image];
                        self.imagesFromService= _images;
                        [self.collectionViewPhotoGallery reloadData];
                    }];
                }
            }];
    }
    
}

#pragma mark -
#pragma mark Rotation handling methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:
(NSTimeInterval)duration {
    
    // Fade the collectionView out
    [self.collectionViewPhotoGallery setAlpha:0.0f];
    
    // Suppress the layout errors by invalidating the layout
    [self.collectionViewPhotoGallery.collectionViewLayout invalidateLayout];
    
    // Calculate the index of the item that the collectionView is currently displaying
    CGPoint currentOffset = [self.collectionViewPhotoGallery contentOffset];
    self.currentIndex = currentOffset.x / self.collectionViewPhotoGallery.frame.size.width;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Force realignment of cell being displayed
    CGSize currentSize = self.collectionViewPhotoGallery.bounds.size;
    float offset = self.currentIndex * currentSize.width;
    [self.collectionViewPhotoGallery setContentOffset:CGPointMake(offset, 0)];
    
    // Fade the collectionView back in
    [UIView animateWithDuration:0.125f animations:^{
        [self.collectionViewPhotoGallery setAlpha:1.0f];
    }];
    
}
#pragma mark - search manager delegates
- (void)didReceiveItem:(MLSearchItem*)item{
    [self endHud];
    [self loadImagesWithItem:item];
}

-(void)didNotReceiveItem{
    
}
-(void)fetchingItemsFailedWithError:(NSError *)error{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}


@end
