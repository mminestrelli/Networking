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
@property (nonatomic,strong) UIActivityIndicatorView* spinner;



@end

@implementation MLItemDetailViewController

-(instancetype) init{
    if([super init]){
        self.vipService= [[MLVipService alloc]init];
        self.imageService=[[MLThumbnailService alloc]init];
    }
    return self;
}
- (instancetype)initWithItem:(MLSearchItem*)item
{
    self = [self init];
    if (self) {
        // Custom initialization
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
    //self.imageService.delegate=self;
    self.pageControlGallery.hidden = YES;
    [self showLoadingHud];
    [self.vipService startFetchingItemsWithInput:self.searchItem.identifier];
    
    
}

-(void) viewWillDisappear:(BOOL)animated{
#warning vip service & image service must be implemented so that it supports cancelling
    //[self.vipService cancel];
    //[self.imageService cancel];
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
        
        self.spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.spinner.center = CGPointMake(self.collectionViewPhotoGallery.frame.size.width/2,self.collectionViewPhotoGallery.frame.size.height/2);
        [self.collectionViewPhotoGallery addSubview:self.spinner];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.spinner startAnimating];
        });
        
        [self.imageService downloadImageWithURL:url usingQueue:self.thumbnailDownloadQueue withCompletionBlock:
            ^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                // change the image in the cell
                // Update UI on the main thread.
                    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                        
                        [_images addObject:image];
                        self.imagesFromService= _images;
                        if ([self.spinner isAnimating]) {
                            [self.spinner stopAnimating];
                        }
                        [self.collectionViewPhotoGallery reloadData];
                        
                    }];
                }
            }];
        
    }
    
}

#pragma mark - search manager delegates
- (void)didReceiveItem:(MLSearchItem*)item{
    [self removeLoadingHud];
    [self loadImagesWithItem:item];
}

-(void)didNotReceiveItem{
    
}
-(void)fetchingItemsFailedWithError:(NSError *)error{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}


@end
