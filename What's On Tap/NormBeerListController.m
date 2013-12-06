//
//  NormBeerListController.m
//  What's On Tap
//
//  Created by Ryan Norman on 11/28/13.
//  Copyright (c) 2013 Ryan Norman. All rights reserved.
//

#import "NormBeerListController.h"
#import "NormBeer.h"
#import "NormAddBeerViewController.h"
#import "NormBeerViewController.h"
#import "NormBeerTableCell.h"
#import "NormBeersManager.h"
#import "NormWhatsOnTap.h"
#import <QuartzCore/QuartzCore.h>

@interface NormBeerListController () <NormBeersManagerDelegate, UITableViewDelegate>
@property NSMutableDictionary *serveTypes;
@property NSMutableArray *serveTypeKeys;
@property NSMutableDictionary *styles;
@property NSArray *styleKeys;
@property NormBeersManager *beersManager;

@end

@implementation NormBeerListController

- (void)startFetchingAvailableBeers
{
    [self.beersManager fetchAvailableBeersAtLocation];
}

- (void)didReceiveBeers:(NSArray *)beers
{
    self.serveTypes = [[NSMutableDictionary alloc] init];
    self.serveTypeKeys = [[NSMutableArray alloc] init];
    
    self.styles = [[NSMutableDictionary alloc] init];
    self.styleKeys = [[NSArray alloc] init];
    
    NSMutableArray * unOrderedStyleKeys = [[NSMutableArray alloc] init];
    
    for (NormBeer* beer in beers)
    {
        if ([self.serveTypes objectForKey:beer.serveType] == nil){
            [self.serveTypes setObject:[[NSMutableArray alloc] init] forKey:beer.serveType];
            [self.serveTypeKeys addObject: beer.serveType];
        }
        
        [[self.serveTypes objectForKey:beer.serveType] addObject:beer];
        
        if ([self.styles objectForKey:beer.style] == nil){
            [self.styles setObject:[[NSMutableArray alloc] init] forKey:beer.style];
            [unOrderedStyleKeys addObject:beer.style];
        }
        
        [[self.styles objectForKey:beer.style] addObject:beer];
    }
    
    self.styleKeys = [unOrderedStyleKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

//    [self.tableView reloadData];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)fetchingBeersFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

//- (IBAction)unwindToList:(UIStoryboardSegue *)segue
//{
//    NormAddBeerViewController *source = [segue sourceViewController];
//    NormBeer *beer = source.beer;
//    
//    if (beer != nil) {
//        [self.availableBeers addObject:beer];
//        [self.tableView reloadData];
//    }
//}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    self.beersManager = [[NormBeersManager alloc] init];
    self.beersManager.communicator = [[NormWhatsOnTap alloc] init];
    self.beersManager.communicator.delegate = self.beersManager;
    self.beersManager.delegate = self;
    
//    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
//    if ([[ver objectAtIndex:0] intValue] >= 7) {
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:245.0/255.0 green:201.0/255.0 blue:69.0/255.0 alpha:0.9];
//        self.navigationController.navigationBar.translucent = YES;
//    }else {
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:245.0/255.0 green:201.0/255.0 blue:69.0/255.0 alpha:0.9];
//    }
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
        self.navigationController.navigationBar.translucent = YES;
    }else {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:245.0/255.0 green:201.0/255.0 blue:69.0/255.0 alpha:0.9]}];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:245.0/255.0 green:201.0/255.0 blue:69.0/255.0 alpha:0.9]} forState:UIControlStateNormal];
    
    [[self.navigationController.navigationBar.subviews lastObject] setTintColor:[UIColor colorWithRed:245.0/255.0 green:201.0/255.0 blue:69.0/255.0 alpha:0.9]];
    
    [self startFetchingAvailableBeers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.styleKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.styles valueForKey:[self.styleKeys objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.styleKeys objectAtIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normTableCellIdentifier = @"NormBeerTableCell";
    
    NormBeerTableCell *cell = (NormBeerTableCell *)[tableView dequeueReusableCellWithIdentifier:normTableCellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BeerTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NormBeer *beer = [[self.styles objectForKey: [self.styleKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.nameLabel.text = beer.name;
    cell.costLabel.text = [NSString stringWithFormat:@"$%g", beer.price];
    cell.detailsLabel.text = [[NSArray arrayWithObjects:beer.servedIn, @" - ", [NSString stringWithFormat:@"%.02f%% ABV", beer.abv], nil] componentsJoinedByString:@" "];
    
//    if (beer.icons.count > 0) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NormBeer *beer = [[self.styles objectForKey: [self.styleKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    NormBeerViewController *nbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"BeerViewController"];
    nbvc.beer = beer;
    [self.navigationController pushViewController:nbvc animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
