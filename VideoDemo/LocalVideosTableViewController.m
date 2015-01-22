//
//  LocalVideosTableViewController.m
//  VideoDemo
//
//  Created by VersionMismatch on 1/21/15.
//  Copyright (c) 2015 VersionMismatch. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

#import "LocalVideosTableViewController.h"

@interface LocalVideosTableViewController ()

@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) ALAssetsLibrary *library;
@end

@implementation LocalVideosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //The library shoul persist to access the asset's properties
    self.library = [[ALAssetsLibrary alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.assetsArray = [NSMutableArray array];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"storedVideos"] || ((NSArray*)[defaults objectForKey:@"storedVideos"]).count<1)
        NSLog(@"not");
    else
    {
        NSArray *assetsUrlArray = [defaults objectForKey:@"storedVideos"];
        __weak __typeof(self)weakSelf = self;
        
            for (NSString *assetUrlString in assetsUrlArray)
            {
                [self.library assetForURL:[NSURL URLWithString:assetUrlString] resultBlock:^(ALAsset *asset) {
                    [weakSelf.assetsArray addObject:asset];
                    
                    NSLog(@"success");
                    [weakSelf.tableView reloadData];

                } failureBlock:^(NSError *error) {
                    NSLog(@"fail");
                }];
            }
    }
    
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.assetsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AssetCell" forIndexPath:indexPath];
    
    ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row];
    
    [cell.imageView setImage:[UIImage imageWithCGImage:asset.thumbnail]];
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = [NSString stringWithFormat:@"Date: %@", [asset valueForProperty:ALAssetPropertyDate]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row];
    
    MPMoviePlayerViewController *movie = [[MPMoviePlayerViewController alloc] initWithContentURL:[asset valueForProperty:ALAssetPropertyAssetURL]];
    [self presentMoviePlayerViewControllerAnimated:movie];

}
@end
