# ANTIGRAVITY PROJECT SPECIFICATION

# Mini-Project 3: Receipt OCR & Expense Tracker

**Mục tiêu:** Xây dựng ứng dụng Flutter Android có thể chụp/chọn ảnh hóa
đơn, nhận diện chữ bằng Google ML Kit trên thiết bị, dùng Dart
Regex/heuristic gợi ý tên cửa hàng/ngày/tổng tiền, cho người dùng kiểm
tra và sửa trước khi lưu SQLite, xem lịch sử chi tiêu và biểu đồ tự vẽ
bằng `CustomPainter`. Cuối cùng kiểm thử, build APK release và hướng dẫn
triển khai lên thiết bị Android thật.

> **Cách dùng:** Mở đúng workspace dự án trong Antigravity, gửi toàn bộ
> tài liệu này cho AI và yêu cầu thực hiện tuần tự. AI phải tạo cấu trúc
> trước, xác nhận cấu trúc, sau đó bám sát cấu trúc trong toàn bộ quá
> trình.

------------------------------------------------------------------------

## 1. Vai trò và quy tắc bắt buộc

Bạn là kỹ sư Flutter/Dart cấp senior, chịu trách nhiệm triển khai dự án
trực tiếp trong workspace hiện tại. Không chỉ trả lời bằng code mẫu
trong chat: hãy tạo/sửa file, chạy lệnh, đọc kết quả và xử lý lỗi khi
môi trường cho phép.

### Quy tắc làm việc

1.  **Kiểm tra trước khi sửa:** xác định workspace, công nghệ, thư mục
    gốc và trạng thái Git nếu có.
2.  Nếu đã có dự án Flutter, hãy phát triển trên dự án đó. Không tạo dự
    án lồng nhau, không ghi đè cấu hình hoặc xóa file hiện hữu tùy tiện.
3.  Nếu workspace trống và không có dự án, tạo project
    `receipt_ocr_expense_tracker`.
4.  Chỉ chạy lệnh Flutter trong thư mục có `pubspec.yaml`.
5.  **Tạo cấu trúc trước khi viết tính năng.** Sau khi tạo cấu trúc,
    hiển thị cây thư mục thực tế và đối chiếu với mục 4.
6.  Bám sát cấu trúc đã thống nhất. Nếu thật sự cần đổi cấu trúc, cập
    nhật tài liệu/README và giải thích lý do trước khi tiếp tục.
7.  Dùng Dart null safety, code dễ đọc, tên biến/hàm có ý nghĩa và các
    package tương thích với Flutter SDK đang cài.
8.  Không cam kết OCR chính xác tuyệt đối. Mọi trường nhận diện chỉ là
    gợi ý và phải có màn hình Review để người dùng xác nhận.
9.  OCR xử lý cục bộ trên thiết bị được hỗ trợ. Không tải ảnh hóa đơn
    lên server.
10. Không thêm backend, tài khoản, Firebase, cloud sync hoặc dịch vụ trả
    phí khi chưa được yêu cầu.
11. Không dùng thư viện biểu đồ ngoài cho biểu đồ chính; phải dùng
    `CustomPainter`.
12. Không để lại TODO, nút không hoạt động, class chưa định nghĩa,
    import lỗi, code demo counter hoặc dữ liệu giả trong chức năng thật.
13. Không lưu tiền bằng `double` trong SQLite. Dùng số nguyên VND
    (`int`).
14. Không lưu đường dẫn ảnh cache tạm làm đường dẫn lâu dài. Nếu lưu
    ảnh, sao chép vào thư mục ứng dụng bền vững và xử lý xóa ảnh an
    toàn; nếu không cần giữ ảnh thì không lưu ảnh.
15. Không đưa mật khẩu, API key, private key, signing key hoặc dữ liệu
    nhạy cảm vào source code/Git.
16. Chạy `flutter pub get`, `flutter analyze`, `flutter test` và sửa lỗi
    do code mới gây ra.
17. Không tuyên bố một lệnh hoặc tính năng thành công nếu chưa có kết
    quả xác minh.
18. Nếu thiếu SDK, thiết bị hoặc quyền truy cập, nêu rõ trở ngại và
    hướng dẫn bước tiếp theo; không giả lập kết quả.
19. Trước thao tác có khả năng phát sinh chi phí, dừng và hỏi người
    dùng.
20. Làm theo các giai đoạn bên dưới; không nhảy thẳng sang code giao
    diện khi chưa hoàn thành cấu trúc.

------------------------------------------------------------------------

## 2. Phân tích yêu cầu

### Luồng nghiệp vụ

``` text
Chụp ảnh / Chọn ảnh hóa đơn
            |
            v
       Image Picker
            |
            v
 Google ML Kit Text Recognition
        (OCR cục bộ)
            |
            v
       Văn bản OCR thô
            |
            v
    Dart Regex + Parser
   /         |          \
Merchant    Date        Total
   \         |          /
            v
      Màn hình Review
      người dùng sửa
            |
       Xác nhận lưu
            |
            v
      Repository / SQLite
        /             \
       v               v
 Lịch sử hóa đơn    Dashboard
                    /       \
                   v         v
             Tổng chi tiêu  CustomPainter Chart
```

### Chức năng bắt buộc

-   Chụp ảnh hóa đơn bằng camera.
-   Chọn ảnh từ thư viện.
-   Hiển thị ảnh đã chọn/chụp.
-   OCR bằng Google ML Kit Text Recognition trên nền tảng native được hỗ
    trợ.
-   Trích xuất gợi ý tên cửa hàng, ngày và tổng tiền bằng Dart
    Regex/heuristic.
-   Hiển thị văn bản OCR để đối chiếu.
-   Màn hình Review cho phép sửa mọi trường nhận diện.
-   Chỉ lưu sau khi người dùng bấm xác nhận.
-   SQLite lưu dữ liệu bền vững qua lần khởi động lại ứng dụng.
-   Danh sách lịch sử sắp xếp ngày mới nhất trước.
-   Xem chi tiết, chỉnh sửa và xóa hóa đơn; xóa phải có xác nhận.
-   Dashboard tổng chi tiêu tháng hiện tại và số lượng hóa đơn.
-   Biểu đồ cột tự vẽ bằng `CustomPainter`, lấy dữ liệu thật từ SQLite.
-   Loading, thông báo lỗi, empty state, xử lý hủy chọn ảnh, OCR rỗng và
    lỗi database.
-   Build APK release để cài trên thiết bị Android thật.
-   README tiếng Việt giải thích cài đặt, chạy, kiểm thử và build.

### Ngoài phạm vi phiên bản đầu

-   Không cần đăng nhập, server, đồng bộ cloud hoặc thanh toán.
-   Không yêu cầu phát hành Google Play nếu đề bài chỉ cần cài APK.
-   Không yêu cầu xuất Excel/PDF.
-   Không được coi kết quả OCR là dữ liệu đúng tuyệt đối.

------------------------------------------------------------------------

## 3. Nền tảng mục tiêu và quyết định kỹ thuật

### Mục tiêu chính: Android

Đề bài yêu cầu ứng dụng chạy trên điện thoại thật, OCR bằng ML Kit và
SQLite local. Vì vậy, mục tiêu triển khai chính là **Android APK**.

`google_mlkit_text_recognition` và `sqflite` sử dụng thành phần native
và không bảo đảm có cùng chức năng trên Flutter Web. Không chọn Firebase
Hosting làm phương án triển khai chính cho bản native. Chỉ xem xét web
nếu người dùng yêu cầu thêm một phiên bản web riêng và các plugin cần
thiết có giải pháp tương thích.

### Công nghệ

-   Flutter + Dart.
-   Material 3.
-   `image_picker` để chụp/chọn ảnh.
-   `google_mlkit_text_recognition` để OCR.
-   `sqflite` + `path` để lưu SQLite.
-   `path_provider` chỉ khi cần giữ ảnh bền vững.
-   `intl` nếu cần định dạng ngày/tiền.
-   `CustomPainter` để vẽ biểu đồ.
-   Flutter test cho unit/widget tests.

Chọn phiên bản package tương thích với Flutter SDK và nền tảng hiện có.
Kiểm tra tài liệu/package thực tế trước khi thay đổi Android Gradle,
Java/Kotlin, `minSdk` hoặc compile SDK. Không nâng cấp hàng loạt khi
không cần thiết.

------------------------------------------------------------------------

## 4. Cấu trúc thư mục bắt buộc

Tên dự án mới nếu cần tạo: `receipt_ocr_expense_tracker`.

``` text
receipt_ocr_expense_tracker/
├── android/
├── ios/                                  # nếu project hỗ trợ/tạo ra
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── currency_formatter.dart
│   │       └── date_parser.dart
│   ├── models/
│   │   └── receipt.dart
│   ├── data/
│   │   ├── local/
│   │   │   └── app_database.dart
│   │   └── repositories/
│   │       └── receipt_repository.dart
│   ├── services/
│   │   ├── receipt_image_service.dart
│   │   ├── text_recognition_service.dart
│   │   └── receipt_parser_service.dart
│   ├── features/
│   │   ├── dashboard/
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── expense_summary_card.dart
│   │   │       └── monthly_expense_chart.dart
│   │   ├── scan/
│   │   │   ├── screens/
│   │   │   │   └── scan_receipt_screen.dart
│   │   │   └── widgets/
│   │   │       └── ocr_result_preview.dart
│   │   ├── review/
│   │   │   └── screens/
│   │   │       └── review_receipt_screen.dart
│   │   └── history/
│   │       ├── screens/
│   │       │   ├── receipt_history_screen.dart
│   │       │   └── receipt_detail_screen.dart
│   │       └── widgets/
│   │           └── receipt_list_tile.dart
│   └── navigation/
│       └── app_navigation.dart
├── test/
│   ├── currency_formatter_test.dart
│   ├── date_parser_test.dart
│   ├── receipt_parser_service_test.dart
│   ├── receipt_model_test.dart
│   ├── chart_data_test.dart
│   └── widget_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

### Trách nhiệm từng thành phần

  -----------------------------------------------------------------------
  Thành phần                          Trách nhiệm
  ----------------------------------- -----------------------------------
  `main.dart`                         Điểm khởi chạy, khởi tạo dependency
                                      cần thiết

  `app.dart`                          `MaterialApp`, theme và cấu hình
                                      ứng dụng

  `app_constants.dart`                Hằng số ứng dụng, tên bảng/database
                                      nếu phù hợp

  `app_theme.dart`                    Theme Material 3 và style thống
                                      nhất

  `currency_formatter.dart`           Định dạng tiền VND dùng chung

  `date_parser.dart`                  Phân tích, kiểm tra và định dạng
                                      ngày

  `receipt.dart`                      Model hóa đơn, map SQLite,
                                      copy/update

  `app_database.dart`                 Khởi tạo database, schema,
                                      migration và SQL CRUD

  `receipt_repository.dart`           API dữ liệu để UI không gọi SQL
                                      trực tiếp

  `receipt_image_service.dart`        Camera/gallery, kiểm tra kết quả
                                      picker

  `text_recognition_service.dart`     ML Kit OCR, xử lý lỗi và đóng
                                      recognizer

  `receipt_parser_service.dart`       Parser văn bản OCR thành gợi ý
                                      merchant/date/total

  `scan_receipt_screen.dart`          Điều phối chọn ảnh, OCR và điều
                                      hướng Review

  `ocr_result_preview.dart`           Hiển thị ảnh/text OCR để đối chiếu

  `review_receipt_screen.dart`        Form chỉnh sửa, xác thực và xác
                                      nhận lưu

  `receipt_history_screen.dart`       Danh sách lịch sử và trạng thái
                                      rỗng

  `receipt_detail_screen.dart`        Chi tiết, sửa, xóa

  `receipt_list_tile.dart`            Widget tái sử dụng cho item hóa đơn

  `dashboard_screen.dart`             Tổng quan chi tiêu từ dữ liệu thật

  `expense_summary_card.dart`         Thẻ tổng tiền/số hóa đơn có thể tái
                                      sử dụng

  `monthly_expense_chart.dart`        Biểu đồ `CustomPainter`

  `app_navigation.dart`               Navigation và refresh dữ liệu sau
                                      thao tác

  `test/`                             Unit test, widget test và test tổng
                                      hợp chart

  `README.md`                         Hướng dẫn thiết lập, chạy, kiểm thử
                                      và triển khai
  -----------------------------------------------------------------------

Không thêm tầng kiến trúc phức tạp không cần thiết. Nếu cần thêm file,
giải thích lý do và cập nhật cây thư mục.

------------------------------------------------------------------------

## 5. Giai đoạn A --- Kiểm tra workspace và tạo cấu trúc

### A1. Kiểm tra workspace

1.  In thư mục làm việc hiện tại.

2.  Liệt kê file/thư mục.

3.  Tìm `pubspec.yaml` trong workspace và các thư mục con có liên quan.

4.  Nếu có nhiều file `pubspec.yaml`, xác định đúng dự án bằng `lib/`,
    tên ứng dụng và file cấu hình.

5.  Nếu dự án đã tồn tại, giữ nguyên và phát triển trong đó.

6.  Nếu không có dự án Flutter và workspace trống, tạo project mới:

    ``` bash
    flutter create receipt_ocr_expense_tracker
    ```

7.  Không chạy `flutter create` bên trong một dự án đã có để tránh tạo
    project lồng nhau.

### A2. Kiểm tra công cụ

Tại thư mục chứa `pubspec.yaml`, chạy:

``` bash
flutter --version
flutter doctor
flutter devices
```

Ghi nhận lỗi môi trường. Visual Studio không bắt buộc chỉ để build
Android. Nếu thiếu Android SDK hoặc thiết bị, xử lý riêng và không giả
định đã kiểm thử native.

### A3. Tạo cấu trúc

Tạo thư mục/file theo mục 4. Nếu dự án có các file tương đương, có thể
giữ file hiện hữu và cập nhật cây cấu trúc để tránh di chuyển không cần
thiết.

**Điều kiện hoàn tất giai đoạn A:** - Đã xác định đúng thư mục gốc. - Có
`pubspec.yaml`. - Cây thư mục thực tế được hiển thị và đối chiếu. - Chưa
bắt đầu viết toàn bộ giao diện trước khi xác nhận cấu trúc.

------------------------------------------------------------------------

## 6. Giai đoạn B --- Cấu hình dependencies và nền tảng

### B1. Dependencies

Thêm các package cần dùng, ưu tiên lệnh `flutter pub add` để lấy phiên
bản tương thích:

``` bash
flutter pub add image_picker
flutter pub add google_mlkit_text_recognition
flutter pub add sqflite
flutter pub add path
```

Chỉ thêm khi thật sự sử dụng:

``` bash
flutter pub add path_provider
flutter pub add intl
```

Không chạy lặp lại các lệnh thêm package nếu package đã được khai báo.
Kiểm tra `pubspec.yaml` và chọn phiên bản tương thích với Flutter/Dart
SDK hiện có.

### B2. Cấu hình nền tảng

-   Kiểm tra yêu cầu Android của các package đã cài.
-   Chỉ thay đổi Gradle, Java/Kotlin, `minSdk` hoặc compile SDK khi
    log/tài liệu package chứng minh cần thiết.
-   Không nâng cấp toàn bộ project nếu không cần.
-   Nếu có iOS target, cấu hình quyền camera/photo theo hướng dẫn hiện
    hành của `image_picker`.
-   Không thêm quyền không sử dụng.
-   Không lưu secrets vào source.

### B3. Kiểm tra

``` bash
flutter pub get
```

Nếu thất bại, xử lý dependency conflict trước khi tiếp tục.

------------------------------------------------------------------------

## 7. Giai đoạn C --- Model và tiện ích

### C1. `lib/models/receipt.dart`

Định nghĩa model `Receipt` gồm:

-   `id`: `int?`, null khi chưa insert.
-   `merchant`: `String`.
-   `totalAmount`: `int`, lưu số nguyên VND.
-   `receiptDate`: ngày hóa đơn, lưu định dạng ISO-8601 nhất quán.
-   `rawOcrText`: `String?`, tùy chọn.
-   `imagePath`: `String?`, tùy chọn, chỉ khi lưu ảnh bền vững.
-   `createdAt`: thời điểm tạo.
-   `updatedAt`: thời điểm cập nhật, có thể nullable.

Yêu cầu: - Có constructor và kiểu dữ liệu rõ ràng. - Có `toMap()` và
`fromMap()`. - Có `copyWith()` nếu dùng trong luồng sửa dữ liệu. - Tên
cột thống nhất với schema SQLite. - Không dùng `double` để lưu tiền. -
Không cho lưu tổng âm. - Không lưu binary ảnh lớn trong SQLite. - Xử lý
null và dữ liệu map không hợp lệ an toàn.

### C2. `currency_formatter.dart`

Định dạng tiền theo yêu cầu Việt Nam:

-   `0` → `0 đ`
-   `15000` → `15.000 đ`
-   `250000` → `250.000 đ`
-   `1250000` → `1.250.000 đ`

Dùng formatter thống nhất trên dashboard, history, detail và chart. Viết
unit test.

### C3. `date_parser.dart`

-   Hiển thị ngày `dd/MM/yyyy`.
-   Hỗ trợ mẫu phổ biến như `dd/MM/yyyy`, `dd-MM-yyyy`, `yyyy-MM-dd`.
-   Kiểm tra ngày/tháng/năm thực sự hợp lệ; không để `DateTime` tự cuộn
    ngày không hợp lệ sang tháng khác mà không phát hiện.
-   Nếu không nhận diện được ngày, trả về `null` và để người dùng chọn;
    không tự bịa ngày hiện tại.
-   Viết unit test cho ngày hợp lệ, sai định dạng và ngày không tồn tại.

------------------------------------------------------------------------

## 8. Giai đoạn D --- SQLite và repository

### D1. `lib/data/local/app_database.dart`

Dùng `sqflite` và `path`. Bảng `receipts` tối thiểu:

``` sql
CREATE TABLE receipts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  merchant TEXT NOT NULL,
  total_amount INTEGER NOT NULL,
  receipt_date TEXT NOT NULL,
  raw_ocr_text TEXT,
  image_path TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT
);
```

Yêu cầu: - Có tên database và version rõ ràng. - Khởi tạo qua
`openDatabase`, `onCreate` và `onUpgrade` khi cần. - Migration phải an
toàn khi schema thay đổi. - Dùng tham số SQL (`whereArgs`) thay vì ghép
chuỗi dữ liệu người dùng vào SQL. - Hỗ trợ insert, query all, query by
ID, update và delete. - Sắp xếp theo ngày mới nhất trước. - Không mở
nhiều database instance không cần thiết. - Xử lý lỗi database rõ ràng.

### D2. `lib/data/repositories/receipt_repository.dart`

Cung cấp API: - `addReceipt` - `getReceipts` - `getReceiptById` -
`updateReceipt` - `deleteReceipt` - Phương thức truy xuất/tổng hợp dữ
liệu chi tiêu theo khoảng thời gian nếu cần.

UI chỉ gọi repository, không gọi SQL trực tiếp.

### D3. Quy tắc dữ liệu

-   Không lưu trước khi người dùng xác nhận.
-   Nếu lưu lỗi, giữ form và thông báo cho người dùng.
-   Xác nhận trước khi xóa.
-   Nếu có ảnh lưu riêng, chỉ xóa ảnh thuộc thư mục ứng dụng và xử lý
    lỗi file an toàn.
-   Không crash nếu record không tồn tại.

------------------------------------------------------------------------

## 9. Giai đoạn E --- Chụp/chọn ảnh và OCR

### E1. `receipt_image_service.dart`

-   Có API chọn ảnh từ camera hoặc gallery.
-   Trả về đường dẫn ảnh hợp lệ hoặc null khi người dùng hủy.
-   Xử lý permission/cancel/error phù hợp.
-   Kiểm tra ảnh tồn tại và đọc được.
-   Nếu lưu ảnh, sao chép vào thư mục ứng dụng bền vững.
-   Không coi đường dẫn cache của picker là đường dẫn lưu lâu dài.

### E2. `text_recognition_service.dart`

Dùng Google ML Kit Text Recognition: - Nhận đường dẫn ảnh hợp lệ. - Tạo
`InputImage` theo API phiên bản package đã cài. - Gọi text recognizer và
trả toàn bộ văn bản OCR. - Xử lý ảnh không đọc được, OCR lỗi và text
rỗng. - Quản lý vòng đời `TextRecognizer`, đóng tài nguyên khi xong. -
Tránh tạo recognizer liên tục mà không dispose/close. - OCR xử lý cục
bộ, không gửi ảnh lên server. - UI hiển thị loading và không cho người
dùng khởi chạy nhiều OCR chồng chéo.

Lưu ý: OCR có thể sai với ảnh mờ, chữ nhỏ, ảnh nghiêng hoặc ánh sáng
xấu. Không bỏ qua Review.

------------------------------------------------------------------------

## 10. Giai đoạn F --- Parser Dart Regex/heuristic

### `lib/services/receipt_parser_service.dart`

Input: văn bản OCR thô.

Output gợi ý: - `merchantCandidate` - `dateCandidate` -
`totalAmountCandidate` - `rawText` - trạng thái/độ chắc chắn hoặc ghi
chú trường cần xác nhận.

Có thể định nghĩa `ReceiptParseResult` trong cùng file nếu phù hợp.

### F1. Tổng tiền

-   Chuẩn hóa khoảng trắng và các ký tự OCR dễ nhầm.
-   Tìm dòng có từ khóa: `TOTAL`, `GRAND TOTAL`, `AMOUNT DUE`,
    `TỔNG CỘNG`, `THÀNH TIỀN`, `TỔNG TIỀN`, `CỘNG`.
-   Ưu tiên số tiền gần dòng tổng cuối cùng phù hợp, không mặc định chọn
    số lớn nhất.
-   Phân biệt subtotal, grand total, tiền khách đưa và tiền thối lại khi
    có đủ ngữ cảnh.
-   Hỗ trợ các dạng `250.000`, `250,000`, `250000` với quy tắc rõ ràng.
-   Không parse trực tiếp chuỗi có dấu phân cách địa phương bằng
    `double.parse`.
-   Nếu số mơ hồ, trả `null` thay vì đoán.
-   Không trả tổng âm.

### F2. Ngày

-   Dùng Regex cho `dd/MM/yyyy`, `dd-MM-yyyy`, `yyyy-MM-dd` và mẫu phù
    hợp khác.
-   Xác minh ngày hợp lệ.
-   Tránh nhầm ngày/tháng.
-   Nếu không tìm được, trả `null`, không dùng ngày hiện tại thay thế.

### F3. Tên cửa hàng

-   Heuristic có thể ưu tiên dòng đầu tiên không rỗng trước địa chỉ/số
    điện thoại.
-   Bỏ qua dòng chỉ có số hoặc dòng tiêu đề chung rõ ràng.
-   Nếu không chắc, trả chuỗi rỗng/null để người dùng nhập.

### F4. Test parser

Ít nhất 4 mẫu OCR: 1. Có merchant/date/total. 2. Có subtotal và grand
total. 3. Thiếu ngày hoặc thiếu tổng. 4. OCR rỗng/chuỗi nhiễu. 5. Có số
tiền dấu phân cách khác nhau.

Parser không phụ thuộc UI hoặc database.

------------------------------------------------------------------------

## 11. Giai đoạn G --- Màn hình Scan

### `scan_receipt_screen.dart`

Giao diện: - Tiêu đề `Quét hóa đơn`. - Nút `Chụp ảnh`. - Nút
`Chọn từ thư viện`. - Preview ảnh. - Nút bắt đầu OCR nếu cần tách
bước. - Loading indicator. - Thông báo rõ ràng khi hủy, ảnh lỗi hoặc OCR
không có text. - Khi OCR thành công, truyền ảnh/text/kết quả parser sang
Review. - Không ghi database trong bước Scan.

### `ocr_result_preview.dart`

-   Hiển thị ảnh và văn bản OCR có thể cuộn.
-   Không nhồi toàn bộ nghiệp vụ scan vào widget preview.
-   Tránh tràn layout trên màn hình nhỏ.

Các trạng thái phải phân biệt: - Chưa chọn ảnh. - Đang mở
camera/gallery. - Đang OCR. - OCR thành công. - OCR không có text. - Lỗi
OCR. - Người dùng hủy.

------------------------------------------------------------------------

## 12. Giai đoạn H --- Review/Edit và xác nhận lưu

### `review_receipt_screen.dart`

Hiển thị form: - Tên cửa hàng. - Tổng tiền. - Ngày hóa đơn. - Văn bản
OCR thô để đối chiếu. - Preview ảnh nếu có.

Yêu cầu: 1. Điền các gợi ý parser nhận diện được. 2. Trường không nhận
diện được phải để trống/đánh dấu cần nhập, không tự điền dữ liệu giả. 3.
Tổng tiền bắt buộc là số hợp lệ, không âm và không vượt giới hạn an toàn
của kiểu dữ liệu. 4. Ngày có date picker và validation. 5. Nút
`Lưu hóa đơn` chỉ hoạt động khi dữ liệu tối thiểu hợp lệ. 6. Khi lưu,
tạo `Receipt` và gọi `ReceiptRepository`. 7. Hiển thị loading khi lưu,
chặn nhấn lặp. 8. Lưu thành công thì thông báo và điều hướng về
History/Dashboard phù hợp. 9. Lưu lỗi thì giữ nội dung form để thử lại.
10. Không tự lưu ngay sau OCR. 11. Dùng `TextEditingController` đúng
vòng đời và dispose controller. 12. Hiển thị lỗi validation gần trường
tương ứng.

------------------------------------------------------------------------

## 13. Giai đoạn I --- History/Detail/Edit/Delete

### `receipt_history_screen.dart`

-   Lấy danh sách từ SQLite.
-   Sắp xếp ngày mới nhất trước.
-   Item hiển thị merchant, ngày, tổng tiền.
-   Empty state và nút chuyển sang Scan.
-   Refresh sau khi thêm, sửa hoặc xóa.
-   Tìm kiếm merchant nếu không làm ảnh hưởng luồng chính.
-   Xử lý lỗi database bằng thông báo dễ hiểu.

### `receipt_detail_screen.dart`

-   Hiển thị đầy đủ thông tin hóa đơn.
-   Cho phép sửa merchant, ngày, tổng tiền.
-   Cho phép xóa với dialog xác nhận.
-   Sau sửa/xóa, trả kết quả cho màn hình trước để reload.
-   Nếu bản ghi đã bị xóa hoặc không tìm thấy, thông báo và quay lại
    danh sách an toàn.

### `receipt_list_tile.dart`

Widget tái sử dụng cho item, dùng chung formatter tiền/ngày.

------------------------------------------------------------------------

## 14. Giai đoạn J --- Dashboard và CustomPainter

### `dashboard_screen.dart`

Hiển thị: - Tiêu đề `Expense Tracker`. - Tổng chi tiêu tháng hiện tại. -
Số hóa đơn. - Biểu đồ chi tiêu theo thời gian. - Nút `Quét hóa đơn`. -
Nút `Lịch sử`. - Empty state khi chưa có dữ liệu.

### `expense_summary_card.dart`

Thẻ tái sử dụng để hiển thị số liệu tổng quan. Nếu dùng InkWell, cần có
callback và phản hồi tap phù hợp.

### `monthly_expense_chart.dart`

Dùng `CustomPaint`/`CustomPainter`, không dùng package chart.

Yêu cầu: - Dữ liệu lấy từ hóa đơn SQLite. - Chọn và ghi rõ phạm vi: 7
ngày gần nhất hoặc 6 tháng gần nhất. - Tổng hợp dữ liệu theo khoảng thời
gian chính xác. - Trục và nhãn dễ đọc trên màn hình điện thoại. - Chiều
cao cột tỷ lệ với giá trị. - Xử lý list rỗng, giá trị toàn 0, một data
point và số lượng dữ liệu khác nhau. - Không vẽ ra ngoài canvas. -
`shouldRepaint` trả kết quả đúng khi dữ liệu/giá trị thay đổi. - Có phần
text tổng hợp để thông tin không chỉ thể hiện bằng hình ảnh. - Tách hàm
tổng hợp dữ liệu chart để unit test độc lập. - Không dùng dữ liệu giả
trong dashboard sau khi có dữ liệu SQLite.

------------------------------------------------------------------------

## 15. Giai đoạn K --- Navigation và theme

### `app_navigation.dart`

Có thể dùng `NavigationBar` Material 3 với 3 mục: 1. Tổng quan. 2. Quét
hóa đơn. 3. Lịch sử.

Đảm bảo luồng: - Dashboard → Scan → Review → lưu → History/Dashboard. -
History → Detail → Edit/Delete → refresh History. - Back button Android
hoạt động tự nhiên. - Không giữ màn hình cũ với dữ liệu lỗi thời. -
Không tạo nhiều database instance do chuyển tab.

### `app_theme.dart`

-   Material 3, giao diện sạch, dễ đọc.
-   Màu sắc nhất quán, độ tương phản đủ.
-   Card, button, spacing và typography nhất quán.
-   Responsive với màn hình điện thoại.
-   Tránh animation phức tạp không cần thiết.

------------------------------------------------------------------------

## 16. Giai đoạn L --- Kiểm thử và sửa lỗi

### Unit tests

-   Currency formatter: `0`, `15000`, `250000`, `1250000`.
-   Date parser: ngày hợp lệ, định dạng khác nhau, ngày không tồn tại,
    text không có ngày.
-   Receipt parser: đầy đủ trường, thiếu trường, subtotal/grand total,
    OCR rỗng, dấu phân cách tiền.
-   Receipt model: `toMap`/`fromMap`, null, kiểu tiền integer.
-   Chart data aggregation: rỗng, nhiều ngày/tháng, toàn số 0.

### Widget tests

-   App khởi động không exception.
-   Dashboard hiển thị.
-   Empty state hiển thị khi database chưa có hóa đơn.
-   Form Review validation.
-   Navigation chính có nhãn và thao tác đúng.
-   Không phụ thuộc camera/ML Kit thật trong widget test; mock hoặc tách
    service nếu cần.

### Lệnh kiểm tra

``` bash
flutter pub get
flutter analyze
flutter test
```

Nếu có thiết bị:

``` bash
flutter devices
flutter run
```

Không xóa test để làm cho test pass. Sửa nguyên nhân thật. Phân biệt lỗi
có sẵn từ dự án với lỗi do thay đổi mới, nhưng không bỏ qua lỗi liên
quan tính năng.

------------------------------------------------------------------------

## 17. Giai đoạn M --- Chạy trên thiết bị thật và build APK

### M1. Chuẩn bị Android

-   Bật Developer options và USB debugging nếu cài qua USB.
-   Kết nối điện thoại, xác nhận hộp thoại debugging.
-   Chạy `flutter devices`.
-   Nếu không nhận thiết bị, kiểm tra cáp, driver, quyền USB và Android
    SDK.

### M2. Chạy debug

``` bash
flutter run
```

Kiểm tra trên thiết bị: - Camera. - Gallery. - OCR. - Review/edit. - Lưu
SQLite. - Tắt/mở app và kiểm tra dữ liệu còn. - Lịch sử/chi
tiết/sửa/xóa. - Dashboard/chart cập nhật đúng.

Không tuyên bố các chức năng native đã được kiểm tra nếu chỉ chạy widget
tests.

### M3. Build APK release

Chỉ sau khi build/analyze/test đạt mức phù hợp:

``` bash
flutter build apk --release
```

File dự kiến:

`build/app/outputs/flutter-apk/app-release.apk`

Xác minh file tồn tại trước khi báo hoàn tất. Có thể cài vào thiết bị
kết nối bằng:

``` bash
flutter install
```

Nếu chia sẻ APK để cài thủ công, giải thích người nhận cần cho phép cài
ứng dụng từ nguồn phù hợp theo thiết lập Android; không yêu cầu tắt bảo
vệ thiết bị không cần thiết.

### M4. Nếu cần Google Play

``` bash
flutter build appbundle --release
```

File dự kiến:

`build/app/outputs/bundle/release/app-release.aab`

Trước khi phát hành: - Đặt application ID duy nhất. - Cập nhật
version/build number. - Thiết lập signing release an toàn. - Không
commit keystore/password lên Git. - Tuân theo yêu cầu Google Play hiện
hành. - Không tuyên bố đã phát hành lên Play Store nếu chưa hoàn thành
quy trình đó.

### M5. Deploy web không phải mục tiêu chính

Không dùng Firebase Hosting để thay thế APK. Các plugin OCR/SQLite
native có thể không hỗ trợ web. Chỉ làm bản web riêng khi người dùng yêu
cầu, đã xác minh khả năng tương thích và có phương án thay thế cho các
plugin không hỗ trợ.

------------------------------------------------------------------------

## 18. README bắt buộc

Tạo `README.md` tiếng Việt gồm: - Mô tả và luồng nghiệp vụ. - Yêu cầu
môi trường. - Cách mở đúng thư mục dự án. - Cài dependencies. - Chạy
Android. - Chạy unit/widget tests. - Build APK và đường dẫn file. - Cài
APK lên điện thoại. - Cấu trúc thư mục và trách nhiệm từng lớp. - Giới
hạn OCR và lý do phải Review. - SQLite lưu local, chưa có cloud sync. -
Kết quả lệnh kiểm tra thực tế. - Các bước xử lý lỗi phổ biến. - Các mục
chưa thể xác minh.

Không ghi kết quả giả vào README.

------------------------------------------------------------------------

## 19. Checklist nghiệm thu

-   [ ] Đã xác định đúng thư mục gốc Flutter.
-   [ ] Đã tạo và xác nhận cấu trúc trước khi triển khai.
-   [ ] Dependency tương thích với Flutter SDK.
-   [ ] Có model Receipt, tiền lưu integer.
-   [ ] Chụp ảnh hoạt động trên thiết bị hỗ trợ.
-   [ ] Chọn ảnh gallery hoạt động.
-   [ ] ML Kit OCR cục bộ có loading/error handling.
-   [ ] Parser gợi ý merchant/date/total và không bịa dữ liệu.
-   [ ] Có Review screen cho phép chỉnh sửa.
-   [ ] Chỉ lưu khi người dùng xác nhận.
-   [ ] SQLite CRUD và dữ liệu tồn tại sau khi khởi động lại.
-   [ ] History, detail, edit, delete hoạt động.
-   [ ] Dashboard tính tổng từ dữ liệu thật.
-   [ ] Chart dùng `CustomPainter`.
-   [ ] Chart xử lý empty/zero.
-   [ ] Unit tests và widget tests được tạo.
-   [ ] `flutter pub get` thành công.
-   [ ] `flutter analyze` không còn lỗi do code mới.
-   [ ] `flutter test` thành công.
-   [ ] Đã thử chức năng native trên thiết bị/emulator nếu môi trường
    cho phép.
-   [ ] APK release build thành công và file tồn tại.
-   [ ] README đầy đủ.
-   [ ] Báo cáo rõ phần đã hoàn thành và phần chưa xác minh.

Chỉ đánh dấu mục đã thực sự kiểm tra.

------------------------------------------------------------------------

## 20. Trình tự triển khai bắt buộc

Thực hiện theo đúng thứ tự:

1.  Kiểm tra workspace, Flutter SDK, xác định thư mục gốc.
2.  Tạo cấu trúc thư mục và báo cáo cây thực tế.
3.  Cấu hình dependencies/nền tảng.
4.  Viết model và utilities; test formatter/date.
5.  Viết database và repository.
6.  Viết image picker và OCR service.
7.  Viết parser và test OCR text mẫu.
8.  Viết Review form và luồng lưu.
9.  Viết History/Detail/Edit/Delete.
10. Viết Dashboard và CustomPainter chart.
11. Hoàn thiện navigation/theme.
12. Viết widget tests, chạy analyze/test và sửa lỗi.
13. Chạy thử trên Android thật hoặc emulator.
14. Build APK release và xác minh file.
15. Viết README và báo cáo cuối.

Nếu có lỗi ở một giai đoạn, xử lý trước khi chuyển giai đoạn tiếp theo.
Không tự ý bỏ chức năng bắt buộc để rút ngắn thời gian.

------------------------------------------------------------------------

## 21. Prompt khởi động dành cho Antigravity

Hãy bắt đầu triển khai dự án này trong workspace hiện tại theo tài liệu
này.

**Việc đầu tiên:** kiểm tra workspace và Flutter SDK, tìm đúng thư mục
chứa `pubspec.yaml`, xác định dự án hiện có hay cần tạo mới. Sau đó tạo
đúng cấu trúc ở mục 4 và báo cáo cây thư mục thực tế trước khi viết
code.

Tiếp tục tuần tự từ giai đoạn A đến M. Bám sát cấu trúc đã thống nhất,
tạo/sửa file trực tiếp khi có quyền, chạy lệnh và đọc log, sửa lỗi trước
khi đi tiếp. Không chạy Flutter ngoài thư mục gốc, không tạo project
lồng nhau, không tự ý thêm dịch vụ trả phí. Cuối cùng kiểm thử, build
APK release, xác minh file và hoàn thiện README.

Tôi là người mới học Flutter nên giải thích ngắn gọn từng giai đoạn và
hướng dẫn rõ khi cần tôi thao tác. Không chỉ đưa hướng dẫn chung nếu bạn
có thể thực hiện trực tiếp trong workspace. Không tuyên bố thành công
khi chưa có kết quả thực tế.
