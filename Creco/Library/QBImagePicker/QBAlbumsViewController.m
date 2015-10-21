//
//  QBAlbumsViewController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/06.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAlbumsViewController.h"

// Views
#import "QBAlbumCell.h"

// ViewControllers
#import "QBImagePickerController.h"
#import "QBAssetsViewController.h"
#import "GoogleViewController.h"
#import "CalendarManager.h"

@interface QBImagePickerController (Private)

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSBundle *assetBundle;

@end

@interface QBAlbumsViewController () <NSURLSessionDataDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, copy) NSArray *assetsGroups;

// google
@property (nonatomic, strong) NSMutableArray *imageURLs;

@end

@implementation QBAlbumsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpToolbarItems];
    
    [self updateAssetsGroupsWithCompletion:^{
        [self.tableView reloadData];
    }];
    
    // Register observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(assetsLibraryChanged:)
                                                 name:ALAssetsLibraryChangedNotification
                                               object:nil];
    
    _imageURLs = [NSMutableArray array];
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"カメラのアクセスが許可されていないです。\n端末の設定画面よりプライバシー設定の変更をお願い致します。"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
    self.navigationItem.title = @"アルバム";
    self.navigationItem.prompt = self.imagePickerController.prompt;
    [self.navigationController.navigationBar setTintColor:[ShareMethods colorFromHexRGB:@"2045a1"]];
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
    
    [self updateControlState];
    [self updateSelectionInfo];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

- (void)dealloc
{
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALAssetsLibraryChangedNotification
                                                  object:nil];
}

#pragma mark - Handling Assets Library Changes

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAssetsGroupsWithCompletion:^{
            [self.tableView reloadData];
        }];
    });
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerControllerDidCancel:)]) {
        [self.imagePickerController.delegate qb_imagePickerControllerDidCancel:self.imagePickerController];
    }
}

- (IBAction)done:(id)sender
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didSelectAssets:)]) {
        [self fetchAssetsFromSelectedAssetURLsWithCompletion:^(NSArray *assets) {
            [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController didSelectAssets:assets];
        }];
    }
}


#pragma mark - Toolbar

- (void)setUpToolbarItems
{
    // Space
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // Info label
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
}

- (void)updateSelectionInfo
{
    NSMutableOrderedSet *selectedAssetURLs = self.imagePickerController.selectedAssetURLs;
    
    if (selectedAssetURLs.count > 0) {
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSString *format;
        if (selectedAssetURLs.count > 1) {
            format = NSLocalizedStringFromTableInBundle(@"items_selected", @"QBImagePicker", bundle, nil);
        } else {
            format = NSLocalizedStringFromTableInBundle(@"item_selected", @"QBImagePicker", bundle, nil);
        }
        
        NSString *title = [NSString stringWithFormat:format, selectedAssetURLs.count];
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
    } else {
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
    }
}


#pragma mark - Fetching Assets

- (void)updateAssetsGroupsWithCompletion:(void (^)(void))completion
{
    [self fetchAssetsGroupsWithTypes:self.imagePickerController.groupTypes completion:^(NSArray *assetsGroups) {
        // Map assets group to dictionary
        NSMutableDictionary *mappedAssetsGroups = [NSMutableDictionary dictionaryWithCapacity:assetsGroups.count];
        for (ALAssetsGroup *assetsGroup in assetsGroups) {
            NSMutableArray *array = mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]];
            if (!array) {
                array = [NSMutableArray array];
            }
            
            // カスタマイズ
            NSString *name = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
            if ([@"カメラロール" isEqualToString:name] || [@"Instagram" isEqualToString:name] || [@"最後に追加した項目" isEqualToString:name] || [@"Camera Roll" isEqualToString:name]) {
                [array addObject:assetsGroup];
            }
        
            mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]] = array;
        }
        
        // Pick the groups to be shown
        NSMutableArray *sortedAssetsGroups = [NSMutableArray arrayWithCapacity:self.imagePickerController.groupTypes.count];
        
        for (NSValue *groupType in self.imagePickerController.groupTypes) {
            NSArray *array = mappedAssetsGroups[groupType];
            
            if (array) {
                [sortedAssetsGroups addObjectsFromArray:array];
            }
        }
        
        self.assetsGroups = sortedAssetsGroups;
        
        if (completion) {
            completion();
        }
    }];
}

- (void)fetchAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    ALAssetsLibrary *assetsLibrary = self.imagePickerController.assetsLibrary;
    ALAssetsFilter *assetsFilter;
    
    switch (self.imagePickerController.filterType) {
        case QBImagePickerControllerFilterTypeNone:
            assetsFilter = [ALAssetsFilter allAssets];
            break;
            
        case QBImagePickerControllerFilterTypePhotos:
            assetsFilter = [ALAssetsFilter allPhotos];
            break;
            
        case QBImagePickerControllerFilterTypeVideos:
            assetsFilter = [ALAssetsFilter allVideos];
            break;
    }
    
    for (NSNumber *type in types) {
        [assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                     usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                         if (assetsGroup) {
                                             // Apply assets filter
                                             [assetsGroup setAssetsFilter:assetsFilter];
                                             
                                             // Add assets group
                                             [assetsGroups addObject:assetsGroup];
                                         } else {
                                             numberOfFinishedTypes++;
                                         }
                                         
                                         // Check if the loading finished
                                         if (numberOfFinishedTypes == types.count) {
                                             if (completion) {
                                                 completion(assetsGroups);
                                             }
                                         }
                                     } failureBlock:^(NSError *error) {
                                         NSLog(@"Error: %@", [error localizedDescription]);
                                     }];
    }
}

- (void)fetchAssetsFromSelectedAssetURLsWithCompletion:(void (^)(NSArray *assets))completion
{
    // Load assets from URLs
    // The asset will be ignored if it is not found
    ALAssetsLibrary *assetsLibrary = self.imagePickerController.assetsLibrary;
    NSMutableOrderedSet *selectedAssetURLs = self.imagePickerController.selectedAssetURLs;
    
    __block NSMutableArray *assets = [NSMutableArray array];
    
    void (^checkNumberOfAssets)(void) = ^{
        if (assets.count == selectedAssetURLs.count) {
            if (completion) {
                completion([assets copy]);
            }
        }
    };
    
    for (NSURL *assetURL in selectedAssetURLs) {
        [assetsLibrary assetForURL:assetURL
                       resultBlock:^(ALAsset *asset) {
                           if (asset) {
                               // Add asset
                               [assets addObject:asset];
                               
                               // Check if the loading finished
                               checkNumberOfAssets();
                           } else {
                               [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                   [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                           // Add asset
                                           [assets addObject:result];
                                           
                                           // Check if the loading finished
                                           checkNumberOfAssets();
                                           
                                           *stop = YES;
                                       }
                                   }];
                               } failureBlock:^(NSError *error) {
                                   NSLog(@"Error: %@", [error localizedDescription]);
                               }];
                           }
                       } failureBlock:^(NSError *error) {
                           NSLog(@"Error: %@", [error localizedDescription]);
                       }];
    }
}


#pragma mark - Checking for Selection Limit

- (BOOL)isMinimumSelectionLimitFulfilled
{
    return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssetURLs.count);
}

- (BOOL)isMaximumSelectionLimitReached
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssetURLs.count);
    }
    
    return NO;
}

- (void)updateControlState
{
    [_cancelButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[ShareMethods colorFromHexRGB:[[NSUserDefaults standardUserDefaults] valueForKey:kAppTopicColor]]} forState:UIControlStateNormal];
    self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.tableView.indexPathForSelectedRow.row == self.assetsGroups.count) {
        GoogleViewController *googleViewController = segue.destinationViewController;
        googleViewController.imagePickerController = self.imagePickerController;
        googleViewController.imageURLs = _imageURLs;
    } else {
        QBAssetsViewController *assetsViewController = segue.destinationViewController;
        assetsViewController.imagePickerController = self.imagePickerController;
        assetsViewController.assetsGroup = self.assetsGroups[self.tableView.indexPathForSelectedRow.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
    
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusAuthorized) {
        if (self.assetsGroups.count != 0 && indexPath.row == self.assetsGroups.count) {
            // Album title
            cell.titleLabel.text = @"Google検索";
            // Number of photos
            cell.countLabel.hidden = YES;
            
            // google
            NSString *keyword = [CalendarManager sharedManager].keyword;
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSString *urlBaseString = @"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&hl=ja&q=%@";
            NSString *urlString = [NSString stringWithFormat:urlBaseString, keyword];
            NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil  ];
            
            NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
                    if (httpResp.statusCode == 200) {
                        NSLog(@"success!");
                        NSError *jsonError;
                        
                        NSDictionary *rawJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                        
                        [_imageURLs removeAllObjects];
                        if (!jsonError) {
                            NSDictionary *responseData = rawJSON[@"responseData"];
                            if ([responseData isKindOfClass:[NSDictionary class]]) {
                                NSArray *results = responseData[@"results"];
                                for (NSDictionary *result in results) {
                                    NSString *imageURL = result[@"url"];
                                    [_imageURLs addObject:imageURL];
                                }
                                if (_imageURLs != nil && _imageURLs.count != 0) {
                                    cell.imageView1.hidden = NO;
                                    NSURL *url1 = [NSURL URLWithString:[_imageURLs objectAtIndex:0]];
                                    [cell.imageView1 sd_setImageWithURL:url1 placeholderImage:[UIImage imageNamed:@"box_noimage"] options:SDWebImageDelayPlaceholder];
                                } else {
                                    cell.imageView1.hidden = NO;
                                    cell.imageView1.image = [UIImage imageNamed:@"box_noimage"];
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                });
                            }
                        }
                    }
                }
            }];
            [jsonData resume];
            
            return cell;
        } else {
            // Thumbnail
            ALAssetsGroup *assetsGroup = self.assetsGroups[indexPath.row];
            
            NSUInteger numberOfAssets = MIN(3, [assetsGroup numberOfAssets]);
            
            if (numberOfAssets > 0) {
                NSRange range = NSMakeRange([assetsGroup numberOfAssets] - numberOfAssets, numberOfAssets);
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
                
                cell.imageView3.hidden = YES;
                cell.imageView2.hidden = YES;
                
                [assetsGroup enumerateAssetsAtIndexes:indexes options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (!result || cell.tag != indexPath.row) return;
                    
                    UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                    
                    if (index == NSMaxRange(range) - 1) {
                        cell.imageView1.hidden = NO;
                        cell.imageView1.image = thumbnail;
                    } else if (index == NSMaxRange(range) - 2) {
                        cell.imageView2.hidden = NO;
                        cell.imageView2.image = thumbnail;
                    } else {
                        cell.imageView3.hidden = NO;
                        cell.imageView3.image = thumbnail;
                    }
                }];
            } else {
                cell.imageView3.hidden = NO;
                cell.imageView2.hidden = NO;
                
                // Set placeholder image
                UIImage *placeholderImage = [self placeholderImageWithSize:cell.imageView1.frame.size];
                cell.imageView1.image = placeholderImage;
                cell.imageView2.image = placeholderImage;
                cell.imageView3.image = placeholderImage;
            }
            
            // Album title
            cell.titleLabel.text = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
            
            // Number of photos
            cell.countLabel.text = [NSString stringWithFormat:@"%lu", (long)assetsGroup.numberOfAssets];
            
            return cell;
        }
    } else {
        // Album title
        cell.titleLabel.text = @"Google検索";
        // Number of photos
        cell.countLabel.hidden = YES;
        
        // google
        NSString *keyword = [CalendarManager sharedManager].keyword;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *urlBaseString = @"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&hl=ja&q=%@";
        NSString *urlString = [NSString stringWithFormat:urlBaseString, keyword];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil  ];
        
        NSURLSessionDataTask *jsonData = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
                if (httpResp.statusCode == 200) {
                    NSLog(@"success!");
                    NSError *jsonError;
                    
                    NSDictionary *rawJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    [_imageURLs removeAllObjects];
                    if (!jsonError) {
                        NSDictionary *responseData = rawJSON[@"responseData"];
                        if ([responseData isKindOfClass:[NSDictionary class]]) {
                            NSArray *results = responseData[@"results"];
                            for (NSDictionary *result in results) {
                                NSString *imageURL = result[@"url"];
                                [_imageURLs addObject:imageURL];
                            }
                            if (_imageURLs != nil && _imageURLs.count != 0) {
                                cell.imageView1.hidden = NO;
                                NSURL *url1 = [NSURL URLWithString:[_imageURLs objectAtIndex:0]];
                                [cell.imageView1 sd_setImageWithURL:url1 placeholderImage:[UIImage imageNamed:@"box_noimage"] options:SDWebImageDelayPlaceholder];
                            } else {
                                cell.imageView1.hidden = NO;
                                cell.imageView1.image = [UIImage imageNamed:@"box_noimage"];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            });
                        }
                    }
                }
            }
        }];
        [jsonData resume];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.assetsGroups.count) {
        [self performSegueWithIdentifier:@"google" sender:self];
    } else {
        [self performSegueWithIdentifier:@"photo" sender:self];
    }
}

- (UIImage *)placeholderImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1.0];
    UIColor *iconColor = [UIColor colorWithRed:(179.0 / 255.0) green:(179.0 / 255.0) blue:(182.0 / 255.0) alpha:1.0];
    
    // Background
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Icon (back)
    CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                     size.height * (20.0 / 68.0),
                                     size.width * (32.0 / 68.0),
                                     size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, backIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
    
    // Icon (front)
    CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                      size.height * (24.0 / 68.0),
                                      size.width * (32.0 / 68.0),
                                      size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, frontIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
