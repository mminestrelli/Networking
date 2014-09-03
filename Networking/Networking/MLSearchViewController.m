//
//  MLSearchViewController.m
//  Networking
//
//  Created by Mauricio Minestrelli on 8/25/14.
//  Copyright (c) 2014 mercadolibre. All rights reserved.
//

#import "MLSearchViewController.h"
#import "MLItemListViewController.h"
#import "MLHistoryTableViewCell.h"
#import "MLDaoHistoryManager.h"
#import "MLKeyboardToolbar.h"

#define kHistoryCellHeight 36;

@interface MLSearchViewController ()
//Search history
@property (nonatomic,strong)NSMutableArray* history;
@end

@implementation MLSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.history=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableViewHistory.delegate = self;
    self.tableViewHistory.dataSource = self;
    self.tableViewHistory.scrollEnabled=YES;
    self.searchBar.delegate=self;
    
    // Particular de la search
    UIImage* logoImage = [UIImage imageNamed:@"mercadolibre.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    [self.searchBar setPlaceholder:@"Buscar en Mercadolibre"];
    
    if ([[MLDaoHistoryManager sharedManager] getHistory]!=nil) {
        self.history=[[MLDaoHistoryManager sharedManager] getHistory];
    }
    
    MLKeyboardToolbar *toolBar = [[MLKeyboardToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                                 0.0f,
                                                                                 self.view.window.frame.size.width,
                                                                                 35.0f)];
    toolBar.okButton.action=@selector(doneEditing);
    self.searchBar.inputAccessoryView = toolBar;
    
    [self.tableViewHistory registerNib:[UINib nibWithNibName:@"MLHistoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchHistoryCellIdentifier"];
    
    
    [self setTitle:@"Buscar"];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableViewHistory reloadData];
    /*Alternativa de appending no para un reloadeo total*/
    //    NSArray* indexPaths=[NSArray arrayWithObject:indexPath];
    //    [self.tableViewHistory beginUpdates];
    //    [self.tableViewHistory insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    //    [self.tableViewHistory endUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     static NSString * tableIdentifier = @"MLHistoryTableViewCell";
     MLHistoryTableViewCell * historyCell = (MLHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
     
     if (historyCell == nil) {
     NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MLHistoryTableViewCell" owner:self options:nil];
     historyCell = [nib objectAtIndex:0];
     }
     */
    
    MLHistoryTableViewCell * historyCell = [tableView dequeueReusableCellWithIdentifier:@"SearchHistoryCellIdentifier"];
    
    
    MLHistoryItem * item=[self.history objectAtIndex:indexPath.row];
    historyCell.labelHistoryItem.text=item.searchedItem;
    
    //FEO
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if([item.searchDate isToday]){
        [formatter setDateFormat:@"hh:mm"];
    }
    else{
        [formatter setDateFormat:@"dd/MM/yyyy"];
    }
    
    NSString *stringFromDate = [formatter stringFromDate:item.searchDate];
    historyCell.labelDate.text=stringFromDate;
    historyCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return historyCell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MLHistoryItem* item=[self.history objectAtIndex:indexPath.row];
    [self.history removeObject:item];
    [self.history addObject:[[MLHistoryItem alloc]initWithItem:item.searchedItem andDate:[NSDate date]]];
    
    [[MLDaoHistoryManager sharedManager] saveHistory:self.history];
    [self searchWithInput:item.searchedItem];
    [self.tableViewHistory deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
#warning y si cambio el tamaño de la celda?
    //return [self.cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    return kHistoryCellHeight;
}

-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kHistoryCellHeight;
}
#pragma mark keyboard
/*Dismisses searchbar keyboard*/
-(void)dismissKeyboard{
    [self.searchBar resignFirstResponder];
}
#pragma mark searchbar
/*Search bar button clicked pushes item list view controller, adds input from search to history*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self dismissKeyboard];
    
    [self.history addObject:[[MLHistoryItem alloc]initWithItem:self.searchBar.text andDate:[NSDate date]]];
    MLDaoHistoryManager * daoHistoryManager=[MLDaoHistoryManager sharedManager];
    [daoHistoryManager saveHistory:self.history];
    
    [self searchWithInput:self.searchBar.text];
    self.searchBar.text=@"";
}

-(void)searchWithInput:(NSString*)input{
    [self dismissKeyboard];
    MLItemListViewController * controller=[[MLItemListViewController alloc]initWithInput:input];
    [self.navigationController pushViewController:controller animated:YES];
}
-(void) doneEditing{
    [self.searchBar resignFirstResponder];
}

@end