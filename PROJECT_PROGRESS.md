# BÁO CÁO TIẾN ĐỘ DỰ ÁN (PROJECT PROGRESS)

> **Thời điểm cập nhật:** 12/10/2026 21:26 (Giờ hệ thống)  
> **Trạng thái:** Hoàn tất 100% mục tiêu kép: **Phiên bản Android Native (APK Release)** và **Phiên bản Flutter Web (Triển khai trực tuyến lên Internet)**.

---

## 1. Thông tin chung về dự án
- **Tên dự án:** `receipt_ocr_expense_tracker`
- **Thư mục gốc:** `e:\Dai_Hoc\Nam4_Ky1\cross_platform_application_development\MiniProject3\receipt_ocr_expense_tracker`
- **Môi trường phát triển:**
  - Flutter SDK: `3.41.0` (Dart `3.11.0`)
  - Java JDK: Microsoft OpenJDK 17 (`C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot`)
  - Android SDK: Compile SDK 35/36, `minSdk` 21, Build-tools 35.0.0
- **Trực tuyến (Live URLs):**
  - **Firebase Hosting (Chính thức):** [https://receipt-ocr-tracker.web.app](https://receipt-ocr-tracker.web.app)
  - **Netlify Mirror:** [https://delightful-rabanadas-6fa037.netlify.app](https://delightful-rabanadas-6fa037.netlify.app) *(Password nếu yêu cầu: `My-Drop-Site`)*

---

## 2. Bảng theo dõi tiến độ các giai đoạn

| Giai đoạn | Nội dung công việc | Trạng thái | Ghi chú & Kết quả kiểm chứng |
|:---|:---|:---|:---|
| **A** | Khởi tạo dự án & Cấu trúc thư mục | **Hoàn thành 100%** | Chuẩn hóa cây thư mục sạch sẽ |
| **B** | Cấu hình Dependencies & Android Native | **Hoàn thành 100%** | JDK 17, ProGuard rules, `minSdk = 21` |
| **C** | Models & Utilities (Currency, Date) | **Hoàn thành 100%** | 12/12 unit tests passed |
| **D** | SQLite Database & Repository | **Hoàn thành 100%** | CRUD parameterized, tự động cấu hình theo nền tảng |
| **E** | Dịch vụ Chọn ảnh & OCR Offline | **Hoàn thành 100%** | Image picker + Google ML Kit offline trên Android |
| **F** | Regex & Heuristic Parser | **Hoàn thành 100%** | 5/5 test cases passed |
| **G** | Màn hình Quét hóa đơn (Scan) | **Hoàn thành 100%** | Tự động thích ứng Android (ML Kit) và Web (Fallback) |
| **H** | Màn hình Kiểm tra & Lưu (Review) | **Hoàn thành 100%** | Form xác thực, date picker, responsive max-width 768 |
| **I** | Lịch sử, Chi tiết, Chỉnh sửa, Xóa | **Hoàn thành 100%** | Tìm kiếm theo tên, dialog xác nhận |
| **J** | Dashboard & Biểu đồ CustomPainter | **Hoàn thành 100%** | Biểu đồ cột tự vẽ (7 ngày / 6 tháng), 4/4 test passed |
| **K** | Navigation & Material 3 Theme | **Hoàn thành 100%** | 3 tab chuyển đổi, responsive layout |
| **L** | Kiểm thử & Phân tích mã nguồn | **Hoàn thành 100%** | `flutter analyze`: 0 lỗi; `flutter test`: 24/24 passed |
| **M** | Build APK Release Android | **Hoàn thành 100%** | File `app-release.apk` (82.7 MB) đã kiểm chứng |
| **N** | Tương thích chéo nền tảng (Web Adaptation) | **Hoàn thành 100%** | Conditional imports cho Image, OCR, Storage |
| **O** | Lưu trữ SQLite Web (IndexedDB) | **Hoàn thành 100%** | `sqflite_common_ffi_web` + `sqlite3.wasm` + `sqflite_sw.js` |
| **P** | Build Web Release & Deploy | **Hoàn thành 100%** | Triển khai thành công lên Firebase Hosting & Netlify |
| **Q** | Cập nhật tài liệu README & Hướng dẫn | **Hoàn thành 100%** | Tài liệu chi tiết song ngữ giải thích kiến trúc |

---

## 3. Kết quả các lệnh kiểm tra thực tế

1. **`flutter analyze`:**
   ```text
   Analyzing receipt_ocr_expense_tracker...                        
   No issues found! (ran in 3.4s)
   ```
2. **`flutter test`:**
   ```text
   00:01 +24: All tests passed! (24/24 passed)
   ```
3. **`flutter build apk --release` (Android Native):**
   ```text
   Running Gradle task 'assembleRelease'...                           89.2s
   √ Built build\app\outputs\flutter-apk\app-release.apk (82.7MB)
   ```
4. **`flutter build web --release` (Web Release):**
   ```text
   Compiling lib\main.dart for the Web...                             28.7s
   √ Built build\web
   ```
   *Tài nguyên trong `build/web/`:*
   - `index.html`
   - `main.dart.js` (2.7 MB)
   - `sqlite3.wasm` (733 KB)
   - `sqflite_sw.js` (264 KB)
   - `_redirects` (Hỗ trợ Single Page Application)
5. **Triển khai Web Trực tuyến (Firebase Hosting):**
   ```text
   +  Deploy complete!
   Hosting URL: https://receipt-ocr-tracker.web.app
   ```
   *Kiểm tra HTTP status:* Trả về 200 OK, tải đầy đủ ứng dụng Flutter Web.

---

## 4. Các giải pháp kỹ thuật đã áp dụng

1. **Cách ly thư viện `dart:io` khỏi Web:**
   Sử dụng kiến trúc *Conditional Import/Export*:
   - `app_image_view.dart` -> `app_image_view_io.dart` (Android: `Image.file`) / `app_image_view_web.dart` (Web: `Image.network`).
   - `receipt_image_service.dart` -> `receipt_image_service_io.dart` (Android: copy file storage) / `receipt_image_service_web.dart` (Web: chuyển `XFile` thành Data URL Base64 bền vững trong SQLite).
2. **Lưu trữ SQLite thật sự trên Web:**
   Thay vì dùng SharedPreferences (vốn chỉ phù hợp dữ liệu cấu hình nhỏ), dự án dùng `sqflite_common_ffi_web` kết hợp `sqlite3.wasm` và Web Worker, dữ liệu được ghi vào IndexedDB của trình duyệt, không bao giờ mất sau khi F5.
3. **Thích ứng OCR (Graceful Fallback):**
   Google ML Kit chỉ chạy native trên Android/iOS. Trên Web, `TextRecognitionServiceWeb` trả về thông báo rõ ràng cho người dùng và tự động đưa ảnh sang màn hình Review để người dùng nhập thông tin nhanh chóng mà không gây crash ứng dụng.
4. **Giao diện đáp ứng (Responsive UI):**
   Bọc `AppNavigation` và `ReviewReceiptScreen` bằng `ConstrainedBox(maxWidth: 768)` giúp hiển thị thanh lịch trên cả màn hình Desktop lớn.
