//
//  FileBrowserController.h
//  TXYUploadSDK
//
//  Created by kodywu on 30/4/15.
//  Copyright (c) 2015 Qzone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectFileProtocol;


@interface FileBrowserController : UIViewController{
@private

NSString *_path;

NSArray *_files;
}

@property (nonatomic,strong) NSString *path;

@property (nonatomic, weak) id<SelectFileProtocol> delegate;
@property (nonatomic,strong) NSString *uploadDirPath;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UILabel *lable;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *collectedFiles;
@property (nonatomic,assign) BOOL supportMultifiles;
@end


@protocol SelectFileProtocol<NSObject>
@required
- (void) completeSelectFiles:(NSArray*)fileList uploadDir:(NSString*)dirPath;

@end