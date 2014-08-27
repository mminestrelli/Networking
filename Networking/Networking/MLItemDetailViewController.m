//
//  MLItemDetailViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLItemDetailViewController.h"
#import "MLImageCollectionViewCell.h"

@interface MLItemDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
- (IBAction)buyButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlGallery;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPhotoGallery;

//mock
@property (nonatomic) int currentIndex;
@property (nonatomic, strong) NSArray *dataArray;


@end

@implementation MLItemDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andItem:(MLSearchItem*)item
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadImages];
    [self setupCollectionView];
    self.pageControlGallery.hidden = YES;
    self.pageControlGallery.numberOfPages=[self.dataArray count];
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
    return [self.dataArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MLImageCollectionViewCell *cell = (MLImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    self.pageControlGallery.currentPage = indexPath.row;
    self.pageControlGallery.hidden = NO;
    NSString *imageName = [self.dataArray objectAtIndex:indexPath.row];
    [cell setImageName:imageName];
    [cell updateCell];
    
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewPhotoGallery.frame.size;
}

#pragma mark -
#pragma mark Data methods
-(void)loadImages {
    
    NSString *sourcePath = @"/Users/mminestrelli/Desktop/images";
    self.dataArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:NULL];
    
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


@end
