#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

// 1. Hook hàm kiểm tra chuỗi (có thể app dùng hàm này để so sánh key)
static BOOL (*orig_isEqualToString)(NSString *self, SEL _cmd, NSString *aString) = nullptr;
static BOOL hook_isEqualToString(NSString *self, SEL _cmd, NSString *aString) {
    // Nếu app đang so sánh chuỗi liên quan đến Key, ép nó trả về ĐÚNG
    if ([self containsString:@"Key"] || [self containsString:@"AimHub"] || [aString containsString:@"Key"]) {
        NSLog(@"[Bypass] Ép isEqualToString trả về YES cho: %@", aString);
        return YES;
    }
    return orig_isEqualToString(self, _cmd, aString);
}

// 2. Hook hàm show lỗi (UIAlertController) để chặn không cho hiện bảng "Key không tồn tại"
static void (*orig_presentViewController)(id self, SEL _cmd, UIViewController *vc, BOOL animated, id completion) = nullptr;
static void hook_presentViewController(id self, SEL _cmd, UIViewController *vc, BOOL animated, id completion) {
    if ([vc isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alert = (UIAlertController *)vc;
        if ([alert.title containsString:@"Key"] || [alert.message containsString:@"tồn tại"]) {
            NSLog(@"[Bypass] Đã chặn bảng báo lỗi Key!");
            return; // Không hiển thị bảng lỗi
        }
    }
    orig_presentViewController(self, _cmd, vc, animated, completion);
}

__attribute__((constructor))
static void init_tweak() {
    NSLog(@"[Bypass] Đã load!");
    
    // Hook hàm so sánh chuỗi
    Class nsStringClass = objc_getClass("NSString");
    if (nsStringClass) {
        MSHookMessageEx(nsStringClass, @selector(isEqualToString:), (IMP)hook_isEqualToString, (IMP*)&orig_isEqualToString);
    }
    
    // Hook hàm hiển thị thông báo
    Class vcClass = objc_getClass("UIViewController");
    if (vcClass) {
        MSHookMessageEx(vcClass, @selector(presentViewController:animated:completion:), (IMP)hook_presentViewController, (IMP*)&orig_presentViewController);
    }
}
