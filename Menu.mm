#import "Menu.h"

static FFMenu *g_menu = nil;

@implementation FFMenu {
    UISwitch *_aimSwitch;
    UISwitch *_espSwitch;
    UISlider *_smoothSlider;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        g_menu = [[FFMenu alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return g_menu;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.windowLevel = UIWindowLevelAlert + 100;
    self.backgroundColor = [UIColor clearColor];
    self.rootViewController = [UIViewController new];

    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 260, 220)];
    panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    panel.layer.cornerRadius = 12;
    [self.rootViewController.view addSubview:panel];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panel addGestureRecognizer:pan];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 236, 24)];
    title.text = @"FF MENU OP";
    title.textColor = [UIColor greenColor];
    title.font = [UIFont boldSystemFontOfSize:16];
    [panel addSubview:title];

    UILabel *aimLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 50, 120, 28)];
    aimLbl.text = @"Aimbot";
    aimLbl.textColor = [UIColor whiteColor];
    [panel addSubview:aimLbl];
    _aimSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(180, 48, 51, 31)];
    [panel addSubview:_aimSwitch];

    UILabel *espLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 90, 120, 28)];
    espLbl.text = @"ESP Box";
    espLbl.textColor = [UIColor whiteColor];
    [panel addSubview:espLbl];
    _espSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(180, 88, 51, 31)];
    [panel addSubview:_espSwitch];

    UILabel *sLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 130, 236, 18)];
    sLbl.text = @"Smoothing: 0.30";
    sLbl.textColor = [UIColor whiteColor];
    sLbl.font = [UIFont systemFontOfSize:12];
    [panel addSubview:sLbl];
    _smoothSlider = [[UISlider alloc] initWithFrame:CGRectMake(12, 150, 236, 24)];
    _smoothSlider.minimumValue = 0.05;
    _smoothSlider.maximumValue = 1.0;
    _smoothSlider.value = 0.3;
    [panel addSubview:_smoothSlider];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(12, 180, 236, 30);
    [closeBtn setTitle:@"HIDE" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor redColor];
    closeBtn.layer.cornerRadius = 6;
    [closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:closeBtn];

    return self;
}

- (void)handlePan:(UIPanGestureRecognizer*)g {
    CGPoint t = [g translationInView:self];
    g.view.center = CGPointMake(g.view.center.x + t.x, g.view.center.y + t.y);
    [g setTranslation:CGPointZero inView:self];
}
- (void)hide { self.hidden = YES; }
- (void)show { self.hidden = NO; }
- (BOOL)isAimbotEnabled { return _aimSwitch.isOn; }
- (BOOL)isEspEnabled { return _espSwitch.isOn; }
- (float)getSmoothing { return _smoothSlider.value; }
@end
