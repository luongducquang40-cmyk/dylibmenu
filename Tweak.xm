#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

// ==========================================
// PHẦN 1: GHI ĐÈ CÁC HÀM XÁC THỰC KEY
// ==========================================
static BOOL (*orig_checkKey)(id self, SEL _cmd, NSString* key) = nullptr;

static BOOL hook_checkKey(id self, SEL _cmd, NSString* key) {
    NSLog(@"[AimHub Bypass] Đã chặn hàm checkKey với key: %@", key);
    return YES; // Luôn trả về true (hợp lệ)
}

static BOOL (*orig_isKeyValid)(id self, SEL _cmd) = nullptr;
static BOOL hook_isKeyValid(id self, SEL _cmd) {
    return YES;
}

// ==========================================
// PHẦN 2: ẨN MÀN HÌNH LOGIN
// ==========================================
static void (*orig_viewDidAppear)(id self, SEL _cmd, BOOL animated) = nullptr;

static void hook_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    orig_viewDidAppear(self, _cmd, animated);
    
    NSString *className = NSStringFromClass([self class]);
    
    // Tự động đóng các màn hình Login/Auth nếu phát hiện
    if ([className containsString:@"Login"] || 
        [className containsString:@"Auth"] || 
        [className containsString:@"Key"]) {
        
        NSLog(@"[AimHub Bypass] Đã phát hiện màn hình login: %@. Đang ẩn...", className);
        UIViewController *vc = (UIViewController *)self;
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
}

// ==========================================
// PHẦN 3: KHỞI TẠO
// ==========================================
__attribute__((constructor))
static void init_tweak() {
    NSLog(@"[AimHub Bypass] Đã load tweak vào app!");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Hook các class giả định (thay tên nếu bạn tìm được tên thật)
        Class authClass = objc_getClass("AuthManager");
        if (authClass) {
            MSHookMessageEx(authClass, @selector(checkKey:), (IMP)hook_checkKey, (IMP*)&orig_checkKey);
            NSLog(@"[AimHub Bypass] Đã hook AuthManager::checkKey");
        }
        
        Class licenseClass = objc_getClass("LicenseManager");
        if (licenseClass) {
            MSHookMessageEx(licenseClass, @selector(isKeyValid), (IMP)hook_isKeyValid, (IMP*)&orig_isKeyValid);
            NSLog(@"[AimHub Bypass] Đã hook LicenseManager::isKeyValid");
        }
        
        Class vcClass = objc_getClass("UIViewController");
        if (vcClass) {
            MSHookMessageEx(vcClass, @selector(viewDidAppear:), (IMP)hook_viewDidAppear, (IMP*)&orig_viewDidAppear);
        }
    });
}
