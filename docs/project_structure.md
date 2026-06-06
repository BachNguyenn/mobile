# Bản đồ cấu trúc dự án

Tài liệu này mô tả vai trò của từng phần chính trong dự án Zen Japanese Mobile.
Mục tiêu là giúp người mới vào codebase hiểu ranh giới trách nhiệm trước khi sửa
feature, refactor, hoặc debug lỗi runtime.

## Tổng quan luồng chạy

```text
main()
  -> ProviderScope(appRepositoryOverrides)
  -> MyApp
  -> AuthWrapper
  -> LoginScreen | MainNavigation
```

`main.dart` chỉ nên giữ vai trò entrypoint: khởi tạo app, đọc setting nền tảng,
chọn theme, và quyết định route đầu tiên. Logic nghiệp vụ học tập, database,
review, garden, analytics không nên đặt trực tiếp ở đây.

## Thư mục gốc

- `android/`: cấu hình Android, launcher icon, native splash, Gradle project.
- `ios/`: cấu hình iOS runner và tài nguyên nền tảng.
- `assets/`: dữ liệu học tập, ảnh, font, và tài nguyên đóng gói cùng app.
- `docs/`: tài liệu kiến trúc, quy ước phát triển, ghi chú bảo trì.
- `lib/`: toàn bộ source Dart/Flutter của ứng dụng.
- `test/`: unit/widget tests theo feature hoặc shared widget.
- `script_python/`: script và dữ liệu hỗ trợ tạo/xử lý tài nguyên kanji; giữ tách khỏi runtime app.

## `lib/app`

Phần `app` là lớp điều phối cấp ứng dụng, đứng giữa entrypoint và các feature.

- `bootstrap/`: các provider/widget khởi tạo app như seed database, màn loading startup.
- `composition/`: composition root, nơi nối provider contract với implementation cụ thể.
- `theme/`: mapper hoặc adapter theme ở cấp app, không chứa UI feature.

Quy ước: chỉ đặt logic khởi tạo hoặc wiring dependency ở đây. Không thêm business
rule của từng feature vào `app`.

## `lib/core`

`core` chứa năng lực dùng chung, không thuộc riêng một feature nào.

- `providers/`: provider hạ tầng như database singleton.
- `services/`: service nền tảng như notification, audio, handwriting, logging.
- `theme/`: màu, typography, spacing, Material/Cupertino theme.
- `srs/`: thuật toán spaced repetition dùng lại bởi review/learning.
- `models/`, `content/`: model hoặc provider nội dung dùng chung.

Quy ước: `core` không phụ thuộc ngược vào `features/*/presentation`.

## `lib/data`

`data` cấp cao hiện chứa datasource dùng chung như Drift database và seeder.
Các repository cụ thể nên nằm trong từng feature để giữ ownership rõ ràng.

- `datasources/app_database.dart`: schema và database access chính.
- `datasources/app_database.g.dart`: code generated từ Drift, không sửa thủ công.
- `datasources/database_seeder.dart`: nạp dữ liệu học tập ban đầu.

## `lib/features`

Mỗi feature nên đi theo cùng một cấu trúc nhẹ của Clean Architecture:

```text
features/<feature>/
  domain/        entity, repository contract, domain service
  application/   provider, controller, orchestration use case
  data/          repository implementation, datasource adapter
  presentation/  screen, widget, painter, navigation UI
```

Ranh giới nên giữ:

- `presentation` chỉ render UI, nhận input, và watch provider.
- `application` điều phối action, invalidate provider, gọi repository/domain service.
- `domain` định nghĩa mô hình và luật nghiệp vụ không phụ thuộc Flutter UI.
- `data` nói chuyện với Drift, Firebase, SharedPreferences, assets, hoặc API ngoài.

## Feature chính

- `auth`: đăng nhập, đăng ký, auth state, repository Firebase/Google Sign-In.
- `home`: dashboard học tập, kế hoạch ngày, insight tiến độ.
- `learning`: lộ trình học, lesson, quiz, placement test.
- `review`: SRS review, đánh giá câu trả lời, handwriting review.
- `kanji`: thư viện kanji, chi tiết, lọc JLPT.
- `vocabulary`: thư viện từ vựng, chi tiết, tìm kiếm.
- `grammar`: thư viện ngữ pháp, review grammar point.
- `sentence`: luyện câu và repository sentence practice.
- `analytics`: thống kê heatmap, tiến độ JLPT, study insight.
- `garden`: reward loop zen garden, resource, shop item, garden state.
- `settings`: theme mode, font scale, reminder settings, persistence.
- `dictionary`: tra cứu và điều hướng nội dung học.

## `lib/presentation` và `lib/shared`

- `presentation/`: shell hoặc widget cross-feature có quyền biết nhiều feature,
  ví dụ bottom navigation, route constants, global search.
- `shared/`: component UI tái sử dụng, không biết nghiệp vụ feature cụ thể.

Quy ước: nếu widget chỉ đẹp và reusable, đặt ở `shared`. Nếu widget cần hiểu
nhiều feature để điều hướng hoặc tổng hợp dữ liệu, đặt ở `presentation`.

## Quy ước comment trong code

Comment nên giải thích lý do hoặc ranh giới trách nhiệm, không lặp lại code.

Nên comment:

- Bootstrap/deferred service có ảnh hưởng startup.
- Composition root và provider override.
- Logic seed/migration để tránh mất dữ liệu người dùng.
- Thuật toán hoặc rule nghiệp vụ khó đoán.
- Workaround do giới hạn nền tảng Android/iOS/Firebase.

Không nên comment:

- Setter/getter hiển nhiên.
- Widget tree đơn giản.
- Dòng code đã tự mô tả rõ ràng bằng tên hàm/biến.

## Quy ước dọn dự án

Có thể xóa an toàn khi cần làm sạch local workspace:

- `build/`
- `.dart_tool/`
- `.sandbox_appdata/`
- `.idea/`
- `*.iml`
- `.flutter`
- `.flutter_tool_state`
- `.flutter-plugins-dependencies`

Không xóa nếu chưa kiểm tra ownership:

- `assets/`
- `script_python/`
- `lib/data/datasources/app_database.g.dart`
- `pubspec.lock`
- `android/` hoặc `ios/` resource generated đang được app dùng
