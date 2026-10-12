# Receipt OCR & Expense Tracker (Cross-Platform Android & Web)

Ứng dụng đa nền tảng Flutter (Android & Web) hỗ trợ chụp ảnh hoặc chọn ảnh hóa đơn từ thư viện, nhận diện ký tự quang học (OCR) trên thiết bị Android bằng Google ML Kit, tự động trích xuất thông tin gợi ý (Tên cửa hàng, Ngày, Tổng tiền) qua biểu thức chính quy (Dart Regex & Heuristic), cho phép người dùng kiểm tra và chỉnh sửa trước khi lưu trữ bền vững vào cơ sở dữ liệu SQLite cục bộ (hỗ trợ IndexedDB trên Web), đồng thời theo dõi lịch sử và trực quan hóa chi tiêu bằng biểu đồ cột tự vẽ với `CustomPainter`.

---

## 🌐 Trải nghiệm Trực tuyến (Live Demo Web)

- **Firebase Hosting (Khuyến nghị):** [https://receipt-ocr-tracker.web.app](https://receipt-ocr-tracker.web.app)
  *(Không cần mật khẩu, tốc độ CDN toàn cầu, dữ liệu SQLite lưu trực tiếp vào trình duyệt qua IndexedDB và giữ nguyên sau khi F5/reload trang).*
- **Netlify Mirror:** [https://delightful-rabanadas-6fa037.netlify.app](https://delightful-rabanadas-6fa037.netlify.app) *(Mật khẩu nếu yêu cầu: `My-Drop-Site`)*

---

## 1. Luồng nghiệp vụ của ứng dụng

```text
[Chụp ảnh / Tải ảnh lên]
           │
           ▼
[Image Picker (Camera/Gallery/Upload)]
           │
           ├───────────────────────────────┐
           │ (Android Native)              │ (Web Browser)
           ▼                               ▼
[Google ML Kit OCR (Offline)]    [Fallback & Nhập liệu thủ công]
           │                               │
           ▼                               │
   [Văn bản OCR thô]                       │
           │                               │
           ▼                               │
[Dart Regex & Heuristic Parser]            │
 ┌───────────┼───────────┐                 │
 ▼           ▼           ▼                 │
Merchant   Date       Total                │
 └───────────┬───────────┘                 │
             └──────────────┬──────────────┘
                            ▼
             [Màn hình Review & Nhập liệu]
                            │
                            ▼
                  [Xác nhận lưu dữ liệu]
                            │
                            ▼
        [SQLite: sqflite native / sqflite_ffi_web (IndexedDB)]
        ┌───────────────────┴───────────────────┐
        ▼                                       ▼
  [Lịch sử hóa đơn]                         [Dashboard]
                                          ┌─────┴─────┐
                                          ▼           ▼
                                     Tổng chi tiêu   Biểu đồ CustomPainter
```

---

## 2. Kiến trúc tương thích chéo nền tảng (Cross-Platform Architecture)

Nhằm đảm bảo **100% mã nguồn Android bản địa không bị ảnh hưởng**, ứng dụng triển khai mô hình **Conditional Imports** và **Interface Abstraction**:

1. **Hiển thị hình ảnh (`AppImageView`):**
   - *Android:* Sử dụng `app_image_view_io.dart` hiển thị trực tiếp từ file bộ nhớ trong bằng `Image.file(File(path))`.
   - *Web:* Sử dụng `app_image_view_web.dart` hiển thị qua `Image.network(path)`.
2. **Lưu trữ ảnh hóa đơn (`ReceiptImageService`):**
   - *Android:* `receipt_image_service_io.dart` sao chép file ảnh vào thư mục ứng dụng qua `path_provider`.
   - *Web:* `receipt_image_service_web.dart` đọc `XFile.readAsBytes()` và chuyển đổi thành **Data URL (Base64)** `data:image/jpeg;base64,...` lưu vào SQLite. Nhờ đó ảnh không bị mất sau khi tải lại trang web (F5), khắc phục hoàn toàn điểm yếu của `blob:` URL tạm thời.
3. **Cơ sở dữ liệu SQLite bền vững trên Web (`AppDatabase`):**
   - Ứng dụng tích hợp `sqflite_common_ffi_web` kết hợp `sqlite3.wasm` và Web Worker `sqflite_sw.js`.
   - Lưu trữ dữ liệu hóa đơn 100% chuẩn SQLite quan hệ backed bởi IndexedDB của trình duyệt mà không cần sử dụng JSON thô qua SharedPreferences.
4. **Nhận diện ký tự OCR thích ứng (`TextRecognitionService`):**
   - *Android:* Kích hoạt mô hình học máy trên thiết bị `google_mlkit_text_recognition`.
   - *Web:* Nhận diện nền tảng Web (`kIsWeb`) và thông báo minh bạch cho người dùng, tự động chuyển ảnh sang màn hình Review để người dùng nhập thông tin nhanh chóng.
5. **Giao diện đáp ứng (Responsive UI):**
   - Màn hình chính và các biểu mẫu được bọc bởi `ConstrainedBox(maxWidth: 768)` căn giữa, mang lại trải nghiệm tối ưu cả trên điện thoại di động, máy tính bảng và màn hình máy tính lớn.

---

## 3. Yêu cầu môi trường
- **Flutter SDK:** Phiên bản `>= 3.41.0` (Dart SDK `>= 3.11.0`)
- **Java Development Kit (JDK):** JDK 17 (Microsoft OpenJDK 17 hoặc OpenJDK 17+)
- **Android SDK:** Compile SDK 35/36, `minSdk` 21, Build-tools 35.0.0
- **Trình duyệt Web:** Chrome, Edge, Firefox, Safari phiên bản hiện đại hỗ trợ WebAssembly & IndexedDB.

---

## 4. Cách mở và khởi chạy dự án

### Mở đúng thư mục dự án
```bash
cd e:\Dai_Hoc\Nam4_Ky1\cross_platform_application_development\MiniProject3\receipt_ocr_expense_tracker
```

### Cài đặt thư viện dependencies
```bash
flutter pub get
```

### Khởi chạy trên trình duyệt Web (Local Dev)
```bash
flutter run -d chrome
```

### Khởi chạy trên thiết bị Android / Emulator
```bash
flutter run -d android
```

---

## 5. Kiểm tra mã nguồn và Test

### Phân tích mã nguồn (Lint & Analyze)
```bash
flutter analyze
```
*Kết quả thực tế:* `No issues found!` — Không có lỗi, không có cảnh báo.

### Chạy toàn bộ Unit Tests & Widget Tests
```bash
flutter test
```
*Kết quả thực tế:* `All 24 tests passed!` bao gồm:
- `test/currency_formatter_test.dart`: Định dạng số nguyên VND (`0 đ`, `15.000 đ`, `250.000 đ`, `1.250.000 đ`), phân tích chuỗi về `int`.
- `test/date_parser_test.dart`: Kiểm tra ngày theo lịch Gregorian, ngăn chặn DateTime tự cuộn (từ chối 31/02, 29/02 năm không nhuận, tháng 13).
- `test/receipt_model_test.dart`: Kiểm tra model, map SQLite, serialization, cấm số tiền âm.
- `test/receipt_parser_service_test.dart`: Kiểm tra 5 trường hợp OCR (đầy đủ, có Subtotal/Grand total, thiếu trường, chuỗi nhiễu rỗng, định dạng tiền dấu chấm/phẩy).
- `test/chart_data_test.dart`: Kiểm tra thuật toán gom nhóm chi tiêu 7 ngày và 6 tháng cho biểu đồ (xử lý danh sách rỗng, toàn số 0).
- `test/widget_test.dart`: Kiểm tra khởi động MaterialApp, chuyển đổi NavigationBar và xác thực form Review.

---

## 6. Build và Triển khai (Build & Deploy)

### Đóng gói APK Release cho Android
```bash
flutter build apk --release
```
- **File APK:** `build\app\outputs\flutter-apk\app-release.apk`
- **Kích thước file:** `82.7 MB` (~78.8 MiB)

### Đóng gói bản Web Release
```bash
flutter build web --release
```
- **Thư mục đầu ra:** `build/web/` (chứa `index.html`, `main.dart.js`, `sqlite3.wasm`, `sqflite_sw.js`).

### Triển khai lên Firebase Hosting
```bash
npx firebase-tools deploy --only hosting:receipt-ocr-tracker
```
URL hoạt động: **https://receipt-ocr-tracker.web.app**

---

## 7. Cấu trúc thư mục chi tiết

```text
lib/
├── main.dart                     # Khởi tạo WidgetsBinding, cấu hình databaseFactoryFfiWeb trên Web và chạy app
├── app.dart                      # Cấu hình MaterialApp và Theme Material 3
├── core/
│   ├── constants/
│   │   └── app_constants.dart    # Tên database, version, bảng, tên các cột SQLite
│   ├── theme/
│   │   └── app_theme.dart        # Bảng màu chủ đạo (Deep Emerald & Warm Amber), typography
│   ├── utils/
│   │   ├── currency_formatter.dart # Tiện ích định dạng tiền VND và chuyển đổi an toàn
│   │   └── date_parser.dart      # Phân tích ngày hợp lệ theo chuẩn dd/MM/yyyy
│   └── widgets/
│       ├── app_image_view.dart        # Conditional export widget ảnh
│       ├── app_image_view_io.dart     # Hiển thị ảnh Image.file trên Android/Desktop
│       └── app_image_view_web.dart    # Hiển thị ảnh Image.network trên Web
├── models/
│   └── receipt.dart              # Model hóa đơn, ràng buộc tiền integer >= 0, copyWith, toMap/fromMap
├── data/
│   ├── local/
│   │   └── app_database.dart     # SQLite helper, mở database tự động trên Android lẫn IndexedDB Web
│   └── repositories/
│       └── receipt_repository.dart # API dữ liệu hóa đơn, tính tổng chi tiêu tháng, đếm hóa đơn
├── services/
│   ├── receipt_image_service.dart     # Conditional export dịch vụ ảnh
│   ├── receipt_image_service_io.dart  # Lưu trữ file ảnh vào storage Android
│   ├── receipt_image_service_web.dart # Mã hóa ảnh Base64 Data URL bền vững trên Web
│   ├── text_recognition_service.dart     # Conditional export dịch vụ OCR
│   ├── text_recognition_service_io.dart  # Nhận diện OCR Google ML Kit trên thiết bị
│   ├── text_recognition_service_web.dart # Fallback OCR thân thiện trên Web
│   └── receipt_parser_service.dart   # Heuristic bóc tách Merchant, Date, TotalAmount
├── features/
│   ├── dashboard/
│   │   ├── screens/
│   │   │   └── dashboard_screen.dart # Tổng quan chi tiêu tháng, nút truy cập nhanh, hóa đơn gần đây
│   │   └── widgets/
│   │       ├── expense_summary_card.dart  # Thẻ số liệu chi tiêu tháng hiện tại
│   │       └── monthly_expense_chart.dart # Biểu đồ cột tự vẽ bằng CustomPainter (7 ngày / 6 tháng)
│   ├── scan/
│   │   ├── screens/
│   │   │   └── scan_receipt_screen.dart   # Điều phối chọn ảnh, hiển thị loading, xử lý OCR thích ứng
│   │   └── widgets/
│   │       └── ocr_result_preview.dart    # Xem trước ảnh và văn bản OCR nhận diện được
│   ├── review/
│   │   └── screens/
│   │       └── review_receipt_screen.dart # Form kiểm tra gợi ý, chỉnh sửa và xác nhận lưu
│   └── history/
│       ├── screens/
│       │   ├── receipt_history_screen.dart # Danh sách hóa đơn mới nhất trước, tìm kiếm
│       │   └── receipt_detail_screen.dart  # Xem chi tiết, chỉnh sửa và xóa có dialog xác nhận
│       └── widgets/
│           └── receipt_list_tile.dart      # Widget thẻ hóa đơn tái sử dụng
└── navigation/
    └── app_navigation.dart        # NavigationBar 3 tab có giới hạn chiều rộng maxWidth: 768
```

---

## 8. Hướng dẫn cài đặt file APK lên điện thoại Android

1. Sao chép file `build\app\outputs\flutter-apk\app-release.apk` vào điện thoại.
2. Mở ứng dụng **Quản lý tệp (File Manager)** trên điện thoại và chọn file `app-release.apk`.
3. Cho phép cài đặt từ nguồn không xác định nếu có thông báo.
4. Nhấn **Cài đặt (Install)** và mở ứng dụng.
