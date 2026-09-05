
// ============================================
// FILE: TempMailApp.m
// ============================================
// APP MAIL ẢO - NHẬN CODE QUA EMAIL
// BUILD BẰNG CLANG - IPA TRỰC TIẾP
// COPYRIGHT: HAI LAM
// SERVER: mail.tm API (miễn phí)

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface TempMailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UILabel *nhanEmail;
@property (nonatomic, strong) UILabel *nhanTrangThai;
@property (nonatomic, strong) UIButton *nutTaoMail;
@property (nonatomic, strong) UIButton *nutLamMoi;
@property (nonatomic, strong) UIButton *nutCopy;
@property (nonatomic, strong) UITableView *bangTinNhan;
@property (nonatomic, strong) UITextView *khungNoiDung;
@property (nonatomic, strong) NSMutableArray *danhSachTinNhan;
@property (nonatomic, strong) NSString *emailHienTai;
@property (nonatomic, strong) NSString *matKhauHienTai;
@property (nonatomic, strong) NSString *tokenHienTai;
@property (nonatomic, strong) NSTimer *timerLamMoi;

@end

@implementation TempMailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.12 alpha:1.0];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:1.0].CGColor,
                        (id)[UIColor colorWithRed:0.1 green:0.05 blue:0.2 alpha:1.0].CGColor,
                        (id)[UIColor colorWithRed:0.2 green:0.05 blue:0.1 alpha:1.0].CGColor];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    CGFloat chieuRong = self.view.bounds.size.width;
    CGFloat chieuCao = self.view.bounds.size.height;
    
    // Tiêu đề
    UILabel *tieuDe = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, chieuRong - 40, 35)];
    tieuDe.text = @"© HAI LAM - MAIL ẢO";
    tieuDe.textAlignment = NSTextAlignmentCenter;
    tieuDe.font = [UIFont boldSystemFontOfSize:24];
    tieuDe.textColor = [UIColor whiteColor];
    [self.view addSubview:tieuDe];
    
    [NSTimer scheduledTimerWithTimeInterval:0.08 repeats:YES block:^(NSTimer *timer) {
        static int mauIndex = 0;
        mauIndex = (mauIndex + 1) % 7;
        NSArray *mauRainbow = @[[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor],
                                [UIColor greenColor], [UIColor cyanColor], [UIColor blueColor], [UIColor purpleColor]];
        tieuDe.textColor = mauRainbow[mauIndex];
    }];
    
    // Nhãn email
    self.nhanEmail = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, chieuRong - 40, 35)];
    self.nhanEmail.text = @"Chưa có email";
    self.nhanEmail.textAlignment = NSTextAlignmentCenter;
    self.nhanEmail.font = [UIFont boldSystemFontOfSize:16];
    self.nhanEmail.textColor = [UIColor yellowColor];
    self.nhanEmail.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.8];
    self.nhanEmail.layer.cornerRadius = 8;
    self.nhanEmail.clipsToBounds = YES;
    [self.view addSubview:self.nhanEmail];
    
    // Nhãn trạng thái
    self.nhanTrangThai = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, chieuRong - 40, 25)];
    self.nhanTrangThai.text = @"Trạng thái: Chưa tạo mail";
    self.nhanTrangThai.textAlignment = NSTextAlignmentCenter;
    self.nhanTrangThai.font = [UIFont systemFontOfSize:13];
    self.nhanTrangThai.textColor = [UIColor lightGrayColor];
    [self.view addSubview:self.nhanTrangThai];
    
    // Hàng nút
    CGFloat nutRong = (chieuRong - 60) / 3;
    
    self.nutTaoMail = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nutTaoMail.frame = CGRectMake(20, 175, nutRong, 45);
    [self.nutTaoMail setTitle:@"TẠO MAIL" forState:UIControlStateNormal];
    [self.nutTaoMail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nutTaoMail.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.8 alpha:1.0];
    self.nutTaoMail.layer.cornerRadius = 10;
    self.nutTaoMail.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.nutTaoMail addTarget:self action:@selector(taoMailMoi) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nutTaoMail];
    
    self.nutLamMoi = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nutLamMoi.frame = CGRectMake(30 + nutRong, 175, nutRong, 45);
    [self.nutLamMoi setTitle:@"LÀM MỚI" forState:UIControlStateNormal];
    [self.nutLamMoi setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nutLamMoi.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:1.0];
    self.nutLamMoi.layer.cornerRadius = 10;
    self.nutLamMoi.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.nutLamMoi addTarget:self action:@selector(lamMoiTinNhan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nutLamMoi];
    
    self.nutCopy = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nutCopy.frame = CGRectMake(40 + nutRong * 2, 175, nutRong, 45);
    [self.nutCopy setTitle:@"COPY" forState:UIControlStateNormal];
    [self.nutCopy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nutCopy.backgroundColor = [UIColor colorWithRed:0.6 green:0.4 blue:0.1 alpha:1.0];
    self.nutCopy.layer.cornerRadius = 10;
    self.nutCopy.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.nutCopy addTarget:self action:@selector(copyEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nutCopy];
    
    // Bảng tin nhắn
    self.bangTinNhan = [[UITableView alloc] initWithFrame:CGRectMake(20, 235, chieuRong - 40, 180) style:UITableViewStylePlain];
    self.bangTinNhan.backgroundColor = [UIColor colorWithWhite:0.12 alpha:0.9];
    self.bangTinNhan.layer.cornerRadius = 10;
    self.bangTinNhan.delegate = self;
    self.bangTinNhan.dataSource = self;
    self.bangTinNhan.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:self.bangTinNhan];
    
    // Nhãn nội dung
    UILabel *nhanNoiDung = [[UILabel alloc] initWithFrame:CGRectMake(20, 425, 200, 25)];
    nhanNoiDung.text = @"Nội dung tin nhắn:";
    nhanNoiDung.textColor = [UIColor whiteColor];
    nhanNoiDung.font = [UIFont boldSystemFontOfSize:14];
    [self.view addSubview:nhanNoiDung];
    
    // Khung nội dung
    self.khungNoiDung = [[UITextView alloc] initWithFrame:CGRectMake(20, 455, chieuRong - 40, chieuCao - 475)];
    self.khungNoiDung.backgroundColor = [UIColor blackColor];
    self.khungNoiDung.textColor = [UIColor greenColor];
    self.khungNoiDung.font = [UIFont fontWithName:@"Menlo" size:13];
    self.khungNoiDung.editable = NO;
    self.khungNoiDung.layer.cornerRadius = 10;
    self.khungNoiDung.text = @"Nội dung tin nhắn sẽ hiển thị ở đây...\n\nBấm TẠO MAIL để bắt đầu.";
    [self.view addSubview:self.khungNoiDung];
    
    self.danhSachTinNhan = [NSMutableArray array];
    self.emailHienTai = @"";
    self.matKhauHienTai = @"";
    self.tokenHienTai = @"";
}

- (void)taoMailMoi {
    self.nhanTrangThai.text = @"Trạng thái: Đang tạo mail...";
    self.nhanTrangThai.textColor = [UIColor orangeColor];
    self.nutTaoMail.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Gọi API tạo tài khoản
        NSString *urlStr = @"https://api.mail.tm/accounts";
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSString *tenNgauNhien = [NSString stringWithFormat:@"hailam%d", arc4random_uniform(999999)];
        NSDictionary *body = @{
            @"address": [NSString stringWithFormat:@"%@@mailto.plus", tenNgauNhien],
            @"password": @"HaiLam@123"
        };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
        [request setHTTPBody:jsonData];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.nhanTrangThai.text = @"Trạng thái: Lỗi kết nối";
                    self.nhanTrangThai.textColor = [UIColor redColor];
                    self.nutTaoMail.enabled = YES;
                });
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode == 201 || httpResponse.statusCode == 200) {
                    NSDictionary *ketQua = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    self.emailHienTai = ketQua[@"address"] ?: @"";
                    self.matKhauHienTai = @"HaiLam@123";
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.nhanEmail.text = self.emailHienTai;
                        self.nhanTrangThai.text = @"Trạng thái: Đã tạo mail";
                        self.nhanTrangThai.textColor = [UIColor greenColor];
                        self.nutTaoMail.enabled = YES;
                    });
                    
                    // Lấy token
                    [self dangNhapLayToken];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.nhanTrangThai.text = @"Trạng thái: Tạo mail thất bại";
                        self.nhanTrangThai.textColor = [UIColor redColor];
                        self.nutTaoMail.enabled = YES;
                    });
                }
            }
            dispatch_semaphore_signal(semaphore);
        }];
        [task resume];
        
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    });
}

- (void)dangNhapLayToken {
    NSString *urlStr = @"https://api.mail.tm/token";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *body = @{
        @"address": self.emailHienTai,
        @"password": self.matKhauHienTai
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    [request setHTTPBody:jsonData];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                NSDictionary *ketQua = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.tokenHienTai = ketQua[@"token"] ?: @"";
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self lamMoiTinNhan];
                    [self batDauTimer];
                });
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
}

- (void)lamMoiTinNhan {
    if (self.tokenHienTai.length == 0) {
        return;
    }
    
    NSString *urlStr = @"https://api.mail.tm/messages";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.tokenHienTai] forHTTPHeaderField:@"Authorization"];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                NSDictionary *ketQua = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *tinNhan = ketQua[@"hydra:member"] ?: @[];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.danhSachTinNhan removeAllObjects];
                    [self.danhSachTinNhan addObjectsFromArray:tinNhan];
                    [self.bangTinNhan reloadData];
                    
                    if (tinNhan.count > 0) {
                        self.nhanTrangThai.text = [NSString stringWithFormat:@"Có %lu tin nhắn", (unsigned long)tinNhan.count];
                        self.nhanTrangThai.textColor = [UIColor greenColor];
                    } else {
                        self.nhanTrangThai.text = @"Chưa có tin nhắn";
                        self.nhanTrangThai.textColor = [UIColor lightGrayColor];
                    }
                });
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
}

- (void)batDauTimer {
    if (self.timerLamMoi) {
        [self.timerLamMoi invalidate];
    }
    
    self.timerLamMoi = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer *timer) {
        [self lamMoiTinNhan];
    }];
}

- (void)copyEmail {
    if (self.emailHienTai.length > 0) {
        UIPasteboard *bangNhom = [UIPasteboard generalPasteboard];
        bangNhom.string = self.emailHienTai;
        
        self.nhanTrangThai.text = @"Đã copy email";
        self.nhanTrangThai.textColor = [UIColor cyanColor];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.danhSachTinNhan.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    }
    
    NSDictionary *tinNhan = self.danhSachTinNhan[indexPath.row];
    cell.textLabel.text = tinNhan[@"subject"] ?: @"Không có tiêu đề";
    cell.detailTextLabel.text = tinNhan[@"from"][@"address"] ?: @"";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *tinNhan = self.danhSachTinNhan[indexPath.row];
    NSString *idTinNhan = tinNhan[@"id"] ?: @"";
    
    if (idTinNhan.length > 0 && self.tokenHienTai.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *urlStr = [NSString stringWithFormat:@"https://api.mail.tm/messages/%@", idTinNhan];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"GET"];
            [request setValue:[NSString stringWithFormat:@"Bearer %@", self.tokenHienTai] forHTTPHeaderField:@"Authorization"];
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    if (httpResponse.statusCode == 200) {
                        NSDictionary *ketQua = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        
                        NSString *noiDung = ketQua[@"text"] ?: @"";
                        NSString *chuDe = ketQua[@"subject"] ?: @"";
                        NSString *nguoiGui = ketQua[@"from"][@"address"] ?: @"";
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.khungNoiDung.text = [NSString stringWithFormat:@"Từ: %@\nTiêu đề: %@\n\n%@", nguoiGui, chuDe, noiDung];
                        });
                    }
                }
                dispatch_semaphore_signal(semaphore);
            }];
            [task resume];
            
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
        });
    }
}

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor blackColor];
    
    TempMailViewController *rootVC = [[TempMailViewController alloc] init];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
