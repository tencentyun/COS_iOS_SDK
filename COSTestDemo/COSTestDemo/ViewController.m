#import "ViewController.h"
#import "COSClient.h"
#import "COSTask.h"
#import "FileBrowserController.h"
#import "COSClient.h"
#import "COSTask.h"

#import "QCloudUtils.h"

#define  SIGN @"S3AJa4ClTW3lVnhfOp8DTHdPAjxhPTEwMDA2NTk1Jms9QUtJREdaOTlaUFNWdHA3NTZzallDNjM1TER3UGZVTGJoVUhIJmU9MTQ3NDk2NDcwMSZ0PTE0NzQ5NjM3MDImcj0xNzc1NTEyMDg1JmY9JmI9MjI"

#define  kScreenWidth   ([UIScreen mainScreen].bounds.size.width)
#define  kScreenHeight  ([UIScreen mainScreen].bounds.size.height)
#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface ViewController ()<SelectFileProtocol,UIImagePickerControllerDelegate>
{
    UILabel *contentLable;
    UITextView *imgUrl;
    UILabel *imgFileID;
    UIImageView *imageV;

    
    NSString *appId;
    NSString *bucket;
    NSString *dir;
    NSString *fileName;
    NSString *imgSavepath;
    int64_t currentTaskid;

    COSClient *myClient;
}

@property (nonatomic,copy) NSString *sign;
@property (nonatomic,copy) NSString *oneSign;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    appId = @"1251668577";
    bucket = @"huadongshanghai";
    dir =  @"dir2";
    fileName = @"admin12312345";
    //页面布局
    [self setUI];
    [self getSign];
    
    myClient = [[COSClient alloc] initWithAppId:appId withRegion:@"sh"];
    //设置htpps请求
    [myClient openHTTPSrequset:YES];
}

-(void)uploadFileWithPath:(NSString *)path
{
    
     // 上传文件总共五步之    第一步： 注册产品信息

    
    //    COSObjectPutTask *task = [[COSObjectPutTask alloc] initWithPath:path
    //                                                               sign:_sign
    //                                                             bucket:bucket
    //                                                           fileName:@"ok"
    //                                                    customAttribute:@"customAttribute"
    //                                                    uploadDirectory:@"dir"
    //                                                         insertOnly:YES];
    
    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];
    
    task.filePath = path;
    task.fileName = fileName;
    task.bucket = bucket;
    task.attrs = @"customAttribute";
    task.directory = dir;
    task.sign = _sign;
    
    __weak UITextView *temp = imgUrl;
    //call back
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        UITextView *strong = temp;
        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
        if (rsp.retCode == 0) {
            strong.text = rsp.sourceURL;
        }else{
            NSLog(@"%@",rsp.descMsg);
        }
            
    };
    //put object
    [myClient putObject:task];
}


-(void)updateFileWithBtn
{
    //需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/%@",dir,fileName];
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSObjectUpdateCommand *cm = [[COSObjectUpdateCommand alloc] initWithFile:fileName
                                                                       bucket:bucket
                                                                    directory:dir
                                                                         sign:self.oneSign ];
     __weak UITextView *temp = imgUrl;
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSTaskRsp *rsp = (COSTaskRsp *)resp;
         UITextView *strong = temp;
        if (rsp.retCode == 0) {
            strong.text = [NSString stringWithFormat:@"文件相关属性更新成功，%@",rsp.descMsg];;
        }else{
            strong.text = rsp.descMsg;
        }
    };
    
    [myClient updateObject:cm];
}

-(void)deleteObject
{
    if (dir.length==0 &&fileName.length == 0 ) {
        
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"erro" message:@"fileName / dir 错误" delegate:nil
                                          cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
        return ;
    }
    NSString *path = nil;
    
    if (dir && dir.length>0) {
        //删除需要向业务后台申请一次性签名
        path = [NSString stringWithFormat:@"/%@/%@",dir,fileName];
    }else{
        //删除需要向业务后台申请一次性签名
        path = [NSString stringWithFormat:@"/%@",fileName];
    }
    
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSObjectDeleteCommand *cm = [[COSObjectDeleteCommand alloc] initWithFile:fileName
                                                                       bucket:bucket
                                                                    directory:dir
                                                                         sign:self.oneSign ];
    NSLog(@"---删除任务的-taskId---%lld",cm.taskId);
    __weak UITextView *temp = imgUrl;
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
         UITextView *strong = temp;
        COSTaskRsp *rsp = (COSTaskRsp *)resp;
        if (rsp.retCode == 0) {
            strong.text = rsp.descMsg;
        }else
        {
            strong.text = rsp.descMsg;
        }
    };
    [myClient deleteObject:cm];

}

-(void)queryUploadedFile
{
    if (dir.length==0 &&fileName.length == 0 ) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"erro" message:@"fileName / dir 错误" delegate:nil
                                          cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
        return ;
    }
    //删除需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/%@",dir,fileName];
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSObjectMetaCommand *cm = [[COSObjectMetaCommand alloc] initWithFile:fileName
                                                                   bucket:bucket
                                                                directory:dir
                                                                     sign:_sign ];
    NSLog(@"--文件查询任务的--taskId---%lld",cm.taskId);
    __weak UITextView *temp = imgUrl;

    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        UITextView *strong = temp;

        COSObjectMetaTaskRsp *rsp = (COSObjectMetaTaskRsp *)resp;
        if (rsp.retCode == 0) {

            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                strong.text = rsp.descMsg;
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            strong.text = jsonString;
        }else{
            strong.text = rsp.descMsg;
            
        }
    };
    [myClient getObjectMetaData:cm];
}

-(void)creatDir
{
    COSCreateDirCommand *cm = [[COSCreateDirCommand alloc] initWithDir:dir
                                                                bucket:bucket
                                                                  sign:_sign
                                                             attribute:@"attr" ];
//    cm.directory = dir;
//    cm.bucket = bucket;
//    cm.sign = _sign;
//    cm.attrs = @"dirTest";
    
    __weak UITextView *temp = imgUrl;

    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        UITextView *strong = temp;
        COSCreatDirTaskRsp *rsp = (COSCreatDirTaskRsp *)resp;
        if (rsp.retCode == 0) {
            strong.text = [NSString stringWithFormat:@"创建目录%@ :%@",dir,rsp.descMsg];
        }else{
            strong.text = [NSString stringWithFormat:@"创建目录%@ :%@",dir,rsp.descMsg];;
        }
    };
    [myClient createDir:cm];
}

-(void)getDirMetaData
{
    COSDirmMetaCommand *cm = [[COSDirmMetaCommand alloc] initWithDir:dir
                                                              bucket:bucket
                                                                sign:_sign];
       __weak UITextView *temp = imgUrl;
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        UITextView *strong = temp;

        COSDirMetaTaskRsp *rsp = (COSDirMetaTaskRsp *)resp;
        if (rsp.retCode == 0) {

            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                NSLog(@"Got an error: %@", error);
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            strong.text = jsonString;
        }else{
            strong.text = rsp.descMsg;
        }
    };
    [myClient getDirMetaData:cm];
}

-(void)updateDirBtn
{
    NSString *title = NSLocalizedString(@"更新目录属性", nil);
    NSString *message = NSLocalizedString(@"目录属性", nil);
    NSString *sureButtonTitle = NSLocalizedString(@"OK", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"cancel", nil);
    
    __block  UITextField *textFieldOne;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"attr";
        textFieldOne = textField;
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (textFieldOne.text.length>0) {
            [self updateDir:textFieldOne.text];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)updateDir:(NSString *)att
{
    //删除需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/",dir];
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSUpdateDirCommand *cm = [[COSUpdateDirCommand alloc] initWithDir:dir
                                                                bucket:bucket
                                                                  sign:self.oneSign
                                                             attribute:att];
    //cm.attrs = @"dirTest";
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSUpdateDirTaskRsp *rsp = (COSUpdateDirTaskRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = rsp.descMsg;
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [myClient updateDir:cm];
}

-(void)deleteDir
{
    //删除需要向业务后台申请一次性签名
    NSString *path = [NSString stringWithFormat:@"/%@/",dir];
    NSLog(@"path == %@",path);
    //删除需要向业务后台申请一次性签名
    self.oneSign = [self getOneTimeSignatureWithFileId:path];
    COSDeleteDirCommand *cm = [[COSDeleteDirCommand alloc] initWithDir:dir
                                                                bucket:bucket
                                                                  sign: self.oneSign];
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSdeleteDirTaskRsp *rsp = (COSdeleteDirTaskRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = rsp.descMsg;
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [myClient removeDir:cm];
}

-(void)getDirList
{
    COSListDirCommand *cm = [[COSListDirCommand alloc] initWithDir:dir
                                                            bucket:bucket
                                                            prefix:@""
                                                              sign:_sign
                                                            number:100
                                                       pageContext:@""];
    
    
//    cm.directory = dir;
//    cm.bucket = bucket;
//    cm.sign = _sign;
//    cm.num = 100;
//    cm.pageContext = @"";
//    cm.prefix = @"xx";
    
    
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSDirListTaskRsp *rsp = (COSDirListTaskRsp *)resp;
        if (rsp.retCode == 0) {
            NSLog(@"query sucess！=%@",rsp.data);
            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.infos
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                NSLog(@"Got an error: %@", error);
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            imgUrl.text = jsonString;
        }else{
            imgUrl.text = rsp.descMsg;
            
        }
    };
    [myClient listDir:cm];
}

-(void)downloadFile
{
    if (imgUrl.text.length==0) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"错误" message:@"urlisnull" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
        return;
    }
    
    COSObjectGetTask *cm = [[COSObjectGetTask alloc] initWithUrl:imgUrl.text];
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        
        COSGetObjectTaskRsp *rsp = (COSGetObjectTaskRsp *)resp;
        imgUrl.text = [NSString stringWithFormat:@"下载retCode = %d retMsg= %@",rsp.retCode,rsp.descMsg];
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"文件大小" message:[NSString stringWithFormat:@"%lu B",(unsigned long)rsp.object.length] delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [a show];
    };
    
    myClient.downloadProgressHandler = ^(int64_t receiveLength,int64_t contentLength){
        
        imgUrl.text = [NSString stringWithFormat:@"receiveLength =%ld,contentLength%ld",(long)receiveLength,(long)contentLength];;
    };
    [myClient getObject:cm];
}

#pragma mark- UI init
-(void)setUI
{
    currentTaskid = 0;
    int btnWidth = 100;
    int btnHeight = 100;
    int btnX = (kScreenWidth-btnWidth)/2;
    int btnY = 70;
    
    imageV = [[UIImageView alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
    [self.view addSubview:imageV];
    imageV.contentMode = UIViewContentModeScaleToFill;
    imageV.backgroundColor = [UIColor whiteColor];
    [self drawBorderWithButton:imageV];

    
    NSArray *titles =  @[@"选择文件",@"文件更新",@"文件删除",@"文件查询"];

    btnHeight = 30;
    btnX = (kScreenWidth-btnWidth)/2;

    
    
    btnY = 220;
    btnWidth = (kScreenWidth-((titles.count+1) * 10))/titles.count;

    
    for (int tag = 0; tag<titles.count; tag++) {
        UIButton *upload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        upload.frame = CGRectMake(10+(tag * btnWidth)+(10 * tag), btnY, btnWidth, btnHeight);
        [self.view addSubview:upload];
        upload.tag = tag;
        [upload addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [upload setTitle:titles[tag] forState:UIControlStateNormal];
        upload.backgroundColor = UIColorFromRGB(0x1da5fe);
        [upload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    NSArray *titlesS =  @[@"创建目录",@"删除目录",@"目录查询",@"更新目录",@"目录列表",@"下载文件"];
    
    btnWidth = (kScreenWidth-((titlesS.count+1) * 10))/titlesS.count;
    for (int tag = 0; tag<titlesS.count; tag++) {
        UIButton *upload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        upload.frame = CGRectMake(10+(tag * btnWidth)+(10 * tag), btnY+btnHeight +10, btnWidth, btnHeight);
        [self.view addSubview:upload];
        upload.tag = tag + titles.count;
        [upload addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [upload setTitle:titlesS[tag] forState:UIControlStateNormal];
        upload.backgroundColor = UIColorFromRGB(0x1da5fe);
        upload.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [upload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    NSArray *titlesT =  @[@"分片上传",@"取消上传",@"继续分片上传",@"bucket查询",@"暂停",@"bucket权限"];
    
    btnWidth = (kScreenWidth-((titlesT.count+1) * 10))/titlesT.count;
    for (int tag = 0; tag<titlesT.count; tag++) {
        UIButton *upload = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        upload.frame = CGRectMake(10+(tag * btnWidth)+(10 * tag), btnY+btnHeight*2+20, btnWidth, btnHeight);
        [self.view addSubview:upload];
        upload.tag = tag + titles.count+titlesS.count;
        [upload addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [upload setTitle:titlesT[tag] forState:UIControlStateNormal];
        upload.backgroundColor = UIColorFromRGB(0x1da5fe);
        upload.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [upload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    imgUrl = [[UITextView alloc]init];
    imgUrl.frame = CGRectMake(10, 380, self.view.bounds.size.width -20, 220);
    imgUrl.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:imgUrl];
}

-(void)uploadFileMultipartWithPath:(NSString *)path
{
    //    fileName = [NSString stringWithFormat:@"a%lld",fileName];
    //    COSObjectMultipartPutTask *task = [[COSObjectMultipartPutTask alloc] init];
    COSObjectPutTask *task = [[COSObjectPutTask alloc] init];
    
    NSLog(@"-send---taskId---%lld",task.taskId);
    task.multipartUpload = YES;
    currentTaskid = task.taskId;
    
    task.filePath = path;
    task.fileName = fileName;
    task.bucket = bucket;
    task.attrs = @"customAttribute";
    task.directory = dir;
    task.sign = _sign;
    //call back
    __weak UITextView *temp = imgUrl;
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
        UITextView *strong = temp;
        if (rsp.retCode == 0) {
            strong.text = rsp.sourceURL;
            NSLog(@"context  = %@",context);
        }else{
            strong.text = rsp.descMsg;
        }
    };
    myClient.progressHandler = ^(int64_t bytesWritten,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite){
        UITextView *strong = temp;
        strong.text = [NSString stringWithFormat:@"进度展示：bytesWritten %ld.totalBytesWritten %ld.totalBytesExpectedToWrite %ld",(long)bytesWritten,(long)totalBytesWritten,(long)totalBytesExpectedToWrite];
    };
    [myClient putObject:task];
}

-(void)tryResumeSend:(NSString *)path
{
    
    if (currentTaskid == 0) {
        imgUrl.text = @"没有在上传中任务";
        return;
    }
    
    //    COSObjectMultipartResumePutTask *task = [[COSObjectMultipartResumePutTask alloc] init];
    //    NSLog(@"-send---taskId---%lld",task.taskId);
    //    currentTaskid = task.taskId;
    //
    //    task.filePath = path;
    //    task.fileName = fileName;
    //    task.bucket = bucket;
    //    task.attrs = @"customAttribute";
    //    task.directory = dir;
    //    task.insertOnly = YES;
    //    task.sign = _sign;
    //
    //    COSClient *client= [[COSClient alloc] initWithAppId:appId withRegion:[Congfig instance].region];
    //    //call back
    //    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
    //        COSObjectUploadTaskRsp *rsp = (COSObjectUploadTaskRsp *)resp;
    //        if (rsp.retCode == 0) {
    //            imgUrl.text = rsp.sourceURL;
    //            NSLog(@"context  = %@",context);
    //        }else{
    //             imgUrl.text = rsp.descMsg;
    //        }
    //    };
    //
    //    myClient.progressHandler = ^(NSInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite){
    //        imgUrl.text = [NSString stringWithFormat:@"进度展示：bytesWritten %ld.totalBytesWritten %ld.totalBytesExpectedToWrite %ld",(long)bytesWritten,(long)totalBytesWritten,(long)totalBytesExpectedToWrite];
    //    };
    
    [myClient resume:currentTaskid];
}

-(void)resumeUploadMultipart
{
    [self tryResumeSend:imgSavepath];
    //  [self btnTryAction:nil];
}


//分片上传取消
-(void)tryCancelSend
{
    if (currentTaskid == 0) {
        imgUrl.text = @"没有在上传中任务";
        return;
    }
    [myClient cancel:currentTaskid];
}



-(void)pauseBtn
{
    if (currentTaskid == 0) {
        imgUrl.text = @"没有在上传中任务";
        return;
    }
    [myClient pause:currentTaskid];
    
}

- (void)getBucketBtn
{
    COSBucketMetaCommand *cm = [[COSBucketMetaCommand alloc] initWithBucket:bucket
                                                                       sign: self.sign];
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSBucketMetaRsp *rsp = (COSBucketMetaRsp *)resp;
        if (rsp.retCode == 0) {
            NSString *jsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rsp.data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (! jsonData) {
                imgUrl.text = rsp.descMsg;
            } else {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            imgUrl.text = jsonString;
            
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [myClient headBucket:cm];
}
- (void)getBucketAclBtn
{
    COSBucketAclCommand *cm = [[COSBucketAclCommand alloc] initWithBucket:bucket
                                                                     sign: self.sign];
    myClient.completionHandler = ^(COSTaskRsp *resp, NSDictionary *context){
        COSBucketAclRsp *rsp = (COSBucketAclRsp *)resp;
        if (rsp.retCode == 0) {
            imgUrl.text = rsp.authority;
            
        }else{
            imgUrl.text = rsp.descMsg;
        }
    };
    [myClient getBucketAcl:cm];
}


-(void)completeSelectFiles:(NSArray *)fileList uploadDir:(NSString *)dirPath
{
    if ([fileList count]<=0 || !dirPath) {
        return;
    }
    [self uploadFileWithPath:fileList.firstObject];
}

#pragma mark - view init

-(void)btnAction:(UIButton *)btn
{
    switch (btn.tag) {
        case 0:
            [self selectFile];
            break;
        case 1:
            [self updateFileWithBtn];
            break;
        case 2:
            [self deleteObject];
            break;
        case 3:
            [self queryUploadedFile];
            break;
        case 4:
            [self creatDir];
            break;
        case 5:
            [self deleteDir];
            break;
        case 6:
            [self getDirMetaData];
            break;
        case 7:
            [self updateDirBtn];
            break;
        case 8:
            [self getDirList];
            break;
        case 9:
            [self downloadFile];
            break;
        case 10:
            NSLog(@"10");
            [self gotoImagePickerController];
            break;
        case 11:
            NSLog(@"11");
            [self tryCancelSend];
            break;
        case 12:
            NSLog(@"12");
            [self resumeUploadMultipart];
            break;
        case 13:
            NSLog(@"13");
            [self getBucketBtn];
            break;
        case 14:
            NSLog(@"14");
            [self pauseBtn];
            break;
        case 15:
            NSLog(@"15");
            [self getBucketAclBtn];
            break;
            

            
        default:
            break;
    }
}

#pragma mark -- select Photo

- (void)gotoImagePickerController
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate =  self;
    
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *url  = [info objectForKey:UIImagePickerControllerReferenceURL];
    NSString *photoPath = [self photoSavePathForURL:url];
    
    UIImage *orginalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(orginalImage, 1.f);
    [imageData writeToFile:photoPath atomically:YES];
    
    imageV.image = orginalImage;
    imgSavepath = photoPath;
    
    [self uploadFileMultipartWithPath:imgSavepath];
}

- (NSString *)photoSavePathForURL:(NSURL *)url
{
    NSString *photoSavePath = nil;
    NSString *urlString = [url absoluteString];
    NSString *uuid = nil;
    if (urlString) {
        uuid = [QCloudUtils findUUID:urlString];
    } else {
        uuid = [QCloudUtils uuid];
    }
    
    NSString *resourceCacheDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UploadPhoto/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:resourceCacheDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourceCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    photoSavePath = [resourceCacheDir stringByAppendingPathComponent:uuid];
    
    return photoSavePath;

}


-(void)selectFile
{
    FileBrowserController * fileBrowser = [[FileBrowserController alloc]init];
    fileBrowser.delegate = self;
    fileBrowser.uploadDirPath = @"/";
    fileBrowser.supportMultifiles = NO;
    [self.navigationController pushViewController:fileBrowser animated:YES];
}

- (void)drawBorderWithButton:(UIView *)view {
    
    CALayer * downButtonLayer = [view layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
}
#pragma mark － network
-(void)getSignFinis:(NSString *)string
{
    if (string) {
        self.sign = string;
        NSLog(@"demo self.sign = %@",self.sign);
        imgUrl.text =self.sign;
    }else{
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"警告" message:@"签名为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
    }
}

-(void)getOneSignFinish:(NSString *)string
{
    self.oneSign = string;
}

-(void)getSign
{
    //网络请求工具类
    self.client = [[HttpClient alloc] init];
    self.client.vc = self;
    //向自己的业务服务器请求 上传所需要的签名
    [self getUploadSign];
}

- (NSString *)getOneTimeSignatureWithFileId:(NSString *)fileId
{
    NSString *pams = [NSString stringWithFormat:@"http://203.195.194.28/cosv4/getsignv4.php?bucket=%@&service=cos&expired=0&path=",bucket];// 需要单次签名的接口如，删除，复制等，请求的网络的接口需要用户自定义
    NSString *tem = [NSString stringWithFormat:@"%@%@",pams,fileId];
    NSURL *url =  [NSURL URLWithString:[tem stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *httpResponse = nil;
    NSError *connectionError = nil;
    NSData *signData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&connectionError];
    NSDictionary *responseDic = nil;
    if (signData) {
        responseDic = [NSJSONSerialization JSONObjectWithData:signData options:kNilOptions error:nil];
    }
    NSString *result = nil;
    if (responseDic) {
        result = [responseDic  objectForKey:@"sign"];
    }
    return result;
}

-(void)getUploadSign
{
    NSString *url = [NSString stringWithFormat:@"http://203.195.194.28/cosv4/getsignv4.php?bucket=%@&service=video",bucket];
    [self.client getSignWithUrl:url callBack:@selector(getSignFinis:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
