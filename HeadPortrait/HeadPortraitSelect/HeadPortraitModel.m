#import "HeadPortraitModel.h"
#import "QiniuSDK.h"
#import "AFNetworking.h"

#define HEAD_PORTRAIT_IMAGE_SIZE 160.0f
#define DEFAULT_HEAD_PORTRAIT_IMAGE @"explore.jpg"
#define QINIU_DOMAIN_TOKEN_URL @"http://115.231.183.102:9090/api/quick_start/simple_image_example_token.php"
#define QINIU_KEY @"headPortraitImageQINIU.png"
#define QINIU_NSURSERDEFAULTS_HEAD_PORTRAIT_IMAGE_URL_KEY @"HeadPortraitImageURLQINIU"

@interface HeadPortraitModel()
@property (nonatomic, strong) UIImage *headPortraitImage;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *domain;
@end

@implementation HeadPortraitModel
- (UIImage *)getHeadPortraitImage {
    UIImage *image;
    NSString *headPortraitImageURL = [self getHeadPortraitImageURL];
    if (headPortraitImageURL == nil) {
        // 从服务器未获取到了头像图片的url。
        // 使用此盘中存储等头像图片。
        image = [UIImage imageWithContentsOfFile:[self getHeadPortraitImageFilePath]];
    } else {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:headPortraitImageURL]]];
    }
    
    if (nil == image) {
        image = [UIImage imageNamed:DEFAULT_HEAD_PORTRAIT_IMAGE];
    }
    return image;
}

// 包括图片持久化到本地和上传至服务器。
- (void)saveImage:(UIImage *)image {
    UIImage *smallImage = [self scaleFromImage:image toSize:CGSizeMake(HEAD_PORTRAIT_IMAGE_SIZE, HEAD_PORTRAIT_IMAGE_SIZE)];
    
    if (![self storeHeadPortraitImageIntoFileSystem:smallImage]) {
        // 是否需要通知用户磁盘空间不足等信息。
    }
    
    if (![self uploadHeadPortraitImageToServer:smallImage]) {
        // 是否需要通知用户网络状况不好等信息导致图片上传至服务器失败。
    }
}

- (BOOL)storeHeadPortraitImageIntoFileSystem:(UIImage *)image {
    BOOL isExist = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imageFilePath = [self getHeadPortraitImageFilePath];
    isExist = [fileManager fileExistsAtPath:imageFilePath];
    if(isExist) {
        [fileManager removeItemAtPath:imageFilePath error:nil];
    }
    BOOL result = [UIImagePNGRepresentation(image) writeToFile:imageFilePath atomically:YES];
    
    return result;
}

- (BOOL)uploadHeadPortraitImageToServer:(UIImage *)image {
    BOOL __block result = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:QINIU_DOMAIN_TOKEN_URL
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.domain = responseObject[@"domain"];
              self.token = responseObject[@"uptoken"];
              result = [self uploadImageFileToQINIU:[self getHeadPortraitImageFilePath]];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", error);
              result = NO;
          }
     ];
    
    return result;
}

- (BOOL)uploadImageFileToQINIU:(NSString *)filePath {
    // http://developer.qiniu.com/code/v7/sdk/objc.html#upload
    // 一般情况下，开发者可以忽略put方法中的option参数，即在调用时保持option的值为nil即可。
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putFile:filePath
                   key:nil
                 token:self.token
              complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  NSString *headPortraitImageURLQINIU = [NSString stringWithFormat:@"%@/%@", self.domain, resp[@"key"]];
                  [self persistHeadPortraitImageURLIntoNSUserDefaults:headPortraitImageURLQINIU];
                  NSLog(@"%@/%@", self.domain, resp[@"key"]);
                  if (![self updateHeadPortraitImageURLToServer:headPortraitImageURLQINIU]) {
                      // 更新头像图片的URL到Server失败。
                  }
              }
                option:nil
    ];
    return YES;
}

- (void)persistHeadPortraitImageURLIntoNSUserDefaults:(NSString *)url {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:url forKey:QINIU_NSURSERDEFAULTS_HEAD_PORTRAIT_IMAGE_URL_KEY];
    [userDefaults synchronize];
}

- (NSString *)getHeadPortraitImageURLFromNSUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:QINIU_NSURSERDEFAULTS_HEAD_PORTRAIT_IMAGE_URL_KEY];
}

- (BOOL)updateHeadPortraitImageURLToServer:(NSString *)url {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 将QINIU返回的图片URL传给服务器
    
    
    
    
    return YES;
}

- (NSString *)getHeadPortraitImageURL {
    NSString *url;
    // 加入从server取得图片持久化到本地的代码。异常处理，获取失败的时候是否需要提示用户。
    // 直接存入磁盘路径下。
    if (url != nil) {
        [self persistHeadPortraitImageURLIntoNSUserDefaults:url];
    }
    
    url = [self getHeadPortraitImageURLFromNSUserDefaults];
    return url;
}

// 获取头像图片在文件系统中的位置。
- (NSString *)getHeadPortraitImageFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"headPortraitImageDISK.png"];
    return imageFilePath;
}

// 改变图像的尺寸，方便持久化到本地及上传服务器。
- (UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
