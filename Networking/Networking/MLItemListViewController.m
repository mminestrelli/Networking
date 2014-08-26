//
//  MLItemListViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLItemListViewController.h"
#import "ProductTableViewCell.h"
#import "SearchItem.h"
#import "MLItemDetailViewController.h"
#import "MLSearchService.h"
#import "MLThumbnailService.h"
#define kProductCellHeight 72
#define kOffsetBlock 15
@interface MLItemListViewController ()<SearchManagerDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) NSString* input;
@property (nonatomic,strong) ProductTableViewCell* lastVisibleCell;
@property (nonatomic,strong) MLSearchService* searchService;
@property (nonatomic,strong) MLThumbnailService* thumbnailService;
@property (nonatomic,strong) NSOperationQueue* thumbnailDownloadQueue;

@end

@implementation MLItemListViewController

- (id)initWithInput:(NSString*)input
{
    self = [super init];
    if (self) {
        self.input=input;
        self.searchService = [[MLSearchService alloc]init];
        self.thumbnailService=[[MLThumbnailService
                                alloc]init];
        self.thumbnailDownloadQueue = [[NSOperationQueue alloc] init];
        self.thumbnailDownloadQueue.name = @"Download Queue";
        self.thumbnailDownloadQueue.maxConcurrentOperationCount=kOffsetBlock;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchService.delegate=self;
    //thumbnaildelegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setTitle:@"Resultados"];
    [self.searchService startFetchingItemsWithInput:self.input andOffset:0];
    //[self startFetchingItemsWithInput];
}

#pragma mark - Notification Observer
//- (void)startFetchingItemsWithInput
//{
//    [self loadingHud];
//    [self.manager fetchItemsWithInput:self.input];
//}

#pragma mark - SearchManagerDelegate
- (void)didReceiveItems:(NSArray *)items
{
    if (self.items == nil){
        self.items= [NSMutableArray arrayWithArray:items] ;
    }else{
        [self.items addObjectsFromArray:items];
    }
    //????
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        //[self finishingHUD];
    });
    
}

- (void)fetchingItemsFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

-(void)didNotReceiveItems{
    //should push a noResultsViewController
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kProductCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductTableViewCell * cell = (ProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    SearchItem *item = self.items[indexPath.row];
    [cell.labeltitle setText:item.title];
    NSString* soldQty=[NSString stringWithFormat:@"%d%@",item.sold_quantity,@" vendidos." ];
    [cell.labelPrice setText:[NSString stringWithFormat:@"%@",item.price ]];
    [cell.labelSubtitle setText:soldQty];
    NSURL *url = [NSURL URLWithString:item.thumbnail];
    
    // 
    if([item.thumbnail isEqualToString:@"" ]){
        cell.imageViewPreview.image = [UIImage imageNamed:@"noPicI.png"];
    }
    else{
        // download the image asynchronously
    [self.thumbnailService downloadImageWithURL:url usingQueue:self.thumbnailDownloadQueue withCompletionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                // Update UI on the main thread.
                [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                    cell.imageViewPreview.image = image;
                }];
                
                // cache the image for use later (when scrolling up)
            }
        }];
    
    }

    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray *visibleRows = [self.tableView visibleCells];
    ProductTableViewCell *lastCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastCell];
    if(path.row == [self.items count]-1)
    {
        if(lastCell!= self.lastVisibleCell){
            self.lastVisibleCell=lastCell;
//            UIActivityIndicatorView * spinner= [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//            [spinner startAnimating];
//            spinner.frame = CGRectMake(0, 0, 320, 44);
//            self.tableViewSearch.tableFooterView =spinner;
            [self.searchService fetchNextPage];
        }
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchItem *item = self.items[indexPath.row];
    MLItemDetailViewController * detailView= [[MLItemDetailViewController alloc] initWithNibName:nil bundle:nil andItem:item ];
    [self.navigationController pushViewController:detailView animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark progress hud animation
-(void)finishingHUD{
    HUD.mode = MBProgressHUDModeText;
	HUD.labelText = @"Listo!";
    [HUD hide:YES afterDelay:0.3];
    //[HUD hide:YES];
}
-(void) loadingHud{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Conectando";
	HUD.removeFromSuperViewOnHide = YES;
    
}

@end