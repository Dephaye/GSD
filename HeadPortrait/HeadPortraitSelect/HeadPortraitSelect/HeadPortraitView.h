#import <UIKit/UIKit.h>

@interface HeadPortraitView : UIImageView
@property (nonatomic, weak) id<UIImagePickerControllerDelegate, UINavigationControllerDelegate> delegate;

@end
