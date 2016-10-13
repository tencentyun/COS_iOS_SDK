//
//  FileBrowserController.m
//  TXYUploadSDK
//
//  Created by kodywu on 30/4/15.
//  Copyright (c) 2015 Qzone. All rights reserved.
//

#import "FileBrowserController.h"



@interface FileBrowserController ()<UITableViewDataSource, UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong) NSArray *files;
@end


@implementation FileBrowserController

static NSString * const kDefaultPath = @"/";
@synthesize path = _path;
@synthesize files = _files;

static NSString * const kDefaultBackString = @"返回上层";


- (id)init {
    if (self = [super init]) {
        
        self.hidesBottomBarWhenPushed = YES;
        _collectedFiles =[[NSMutableArray alloc]initWithCapacity:10];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect rc = self.view.bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(rc.origin.x, rc.origin.y, rc.size.width, rc.size.height-70) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    CGFloat y = _tableView.frame.origin.y+_tableView.frame.size.height;
    self.lable = [[UILabel alloc]initWithFrame:CGRectMake(0, y+5, rc.size.width, 15)];
    self.lable.text=@"已选择的文件";
    [self.view addSubview:self.lable];
    y = _lable.frame.origin.y+_lable.frame.size.height;
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0,y+5,rc.size.width,40) collectionViewLayout:flowLayout];
    
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:[UIColor grayColor]];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    [self.view addSubview:self.collectionView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.path)
        self.path =kDefaultPath;
    self.files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil];
    self.title = self.path;
    
}
- (void)viewDidAppear:(BOOL)animated
{
    
    //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44.0f, 0);
    //[[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor whiteColor]];
    [super viewDidAppear:animated];
    
    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStyleBordered target:self action:@selector(btnConfirm)];
    self.navigationItem.rightBarButtonItem = actionItem;
}

-(void)btnConfirm
{
    if(self.delegate != nil)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.delegate completeSelectFiles:_collectedFiles uploadDir:_uploadDirPath];
        //[self.navigationController popViewControllerAnimated:YES];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

- (NSString *)pathForFile:(NSString *)file {
    return [self.path stringByAppendingPathComponent:file];
}
- (BOOL)fileIsDirectory:(NSString *)file {
    BOOL isdir = NO;
    NSString *path = [self pathForFile:file];
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isdir];
    return isdir;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.files count] + 1;
}
-(void)updateData
{
    self.files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil];
    self.title = self.path;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    NSUInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }
    
    if(row == 0){
        cell.textLabel.text = kDefaultBackString;
        cell.textLabel.textColor = [UIColor blueColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        
        NSString *file = [self.files objectAtIndex:row-1];
        NSString *path = [self pathForFile:file];
        BOOL isdir = [self fileIsDirectory:file];
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isdir];
        cell.textLabel.text = file;
        cell.textLabel.textColor = isdir ? [UIColor blueColor] : [UIColor darkTextColor];
        cell.accessoryType = isdir ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    if(row == 0){
        NSString *currentPath = self.path;
        if (currentPath != nil && [currentPath isEqualToString:@"/"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        NSMutableArray *subStrings = [NSMutableArray arrayWithArray:[currentPath componentsSeparatedByString:@"/"]];
        NSUInteger count = [subStrings count];
        if( count > 1){
            currentPath = [currentPath stringByDeletingLastPathComponent];
            self.path = currentPath;
            [self updateData];
        }
        return;
        
        
    }
    NSString *file = [self.files objectAtIndex:row - 1];
    NSString *newPath = [self pathForFile:file];
    if ([self fileIsDirectory:file]) {
        self.path = newPath;
        [self updateData];
        
    } else {
        if (!_supportMultifiles) {
            [_collectedFiles removeAllObjects];
        }
        [_collectedFiles addObject:newPath];
        [_collectionView reloadData];
        
    }
}



//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_collectedFiles count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((110 * indexPath.row) / 255.0) green:((220 * indexPath.row)/255.0) blue:((330 * indexPath.row)/255.0) alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    label.textColor = [UIColor redColor];
    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(30, 30);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [_collectedFiles removeObjectAtIndex:indexPath.row];
    [_collectionView reloadData];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
