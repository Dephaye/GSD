#import "HeadPortraitSelectVC.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HeadPortraitView.h"
#import "HeadPortraitModel.h"


#define HEAD_PORTRAIT_IMAGE_SIZE 160.0f

@interface HeadPortraitSelectVC ()
@property (strong, nonatomic) HeadPortraitView *headPortraitImage;
@property (strong, nonatomic) HeadPortraitModel *headPortraitModel;

@end

@implementation HeadPortraitSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headPortraitImage = [[HeadPortraitView alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
    self.headPortraitImage.delegate = self;
    [self.view addSubview:self.headPortraitImage];
    
    self.headPortraitModel = [[HeadPortraitModel alloc] init];
    self.headPortraitImage.image = [self.headPortraitModel getHeadPortraitImage];
    // Do any additional setup after loading the view.
}

#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.headPortraitModel performSelector:@selector(saveImage:) withObject:image afterDelay:0.5];
    self.headPortraitImage.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}








- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
