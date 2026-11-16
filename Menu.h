#import <UIKit/UIKit.h>
@interface FFMenu : UIWindow
+ (instancetype)shared;
- (void)show;
- (BOOL)isAimbotEnabled;
- (BOOL)isEspEnabled;
- (float)getSmoothing;
@end
