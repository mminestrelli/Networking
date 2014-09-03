//
//  MLItemListViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLItemListViewController.h"
#import "ProductTableViewCell.h"
#import "MLSearchItem.h"
#import "MLItemDetailViewController.h"
#import "MLSearchService.h"
#import "MLThumbnailService.h"
#import "MLDaoImageManager.h"
#import "MLNoResultsViewController.h"
#define kProductCellHeight 72

@interface MLItemListViewController ()<MLSearchManagerDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) NSString* input;
@property (nonatomic,strong) ProductTableViewCell* lastVisibleCell;
@property (nonatomic,strong) MLSearchService* searchService;
@property (nonatomic,strong) MLThumbnailService* thumbnailService;
@property (nonatomic,strong) NSOperationQueue* thumbnailDownloadQueue;

@property (nonatomic,copy) NSString * myString;

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
    [self loadingHud];
    [self.searchService startFetchingItemsWithInput:self.input andOffset:0];
}

#pragma mark - SearchManagerDelegate
- (void)didReceiveItems:(NSArray *)items
{
    [self endHud];
    if (self.items == nil){
        self.items= [NSMutableArray arrayWithArray:items] ;
    }else{
        [self.items addObjectsFromArray:items];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //redraw UI in mainQueue
        [self.tableView reloadData];
    });
    
}

- (void)fetchingItemsFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

-(void)didNotReceiveItems{
    //should push a noResultsViewController
    NSLog(@"0 resultados");
    [self endHud];
    dispatch_async(dispatch_get_main_queue(), ^{
        MLNoResultsViewController * noResultsView = [[MLNoResultsViewController alloc]initWithNibName:nil bundle:nil];
        [self.view addSubview:noResultsView.view];
    });
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
    return cell;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
  
    MLSearchItem *item = self.items[indexPath.row];
    [(ProductTableViewCell*)cell fillCellWithItem:item];
}
-(void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Cancel
    //no deberia haber tantos ifs el manager deberia encargarse de darme una imagen no me importa de donde
    //debería tener

    [(ProductTableViewCell *)cell cancelService];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray *visibleRows = [self.tableView visibleCells];
    ProductTableViewCell *lastCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastCell];
    if(path.row == [self.items count]-1)
    {
        if(lastCell!= self.lastVisibleCell){
            self.lastVisibleCell=lastCell;
                        UIActivityIndicatorView * spinner= [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        [spinner startAnimating];
                        spinner.frame = CGRectMake(0, 0, 320, 44);
                        self.tableView.tableFooterView =spinner;
            [self.searchService fetchNextPage];
        }
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MLSearchItem *item = self.items[indexPath.row];
    MLItemDetailViewController * detailView= [[MLItemDetailViewController alloc] initWithNibName:nil bundle:nil andItem:item ];
    [self.navigationController pushViewController:detailView animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end