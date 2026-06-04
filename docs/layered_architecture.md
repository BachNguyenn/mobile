# Bóc tách kiến trúc theo lớp

Dự án là ứng dụng Flutter học tiếng Nhật, dùng Riverpod cho state, Drift/SQLite cho dữ liệu local, Firebase Auth/Google Sign-In cho đăng nhập, và một số dịch vụ nền như thông báo, TTS, handwriting recognition.

Mục tiêu nên giữ theo hướng Clean Architecture nhẹ: chia theo feature trước, rồi trong mỗi feature tách `presentation`, `domain`, `data`. Các thành phần dùng chung đặt ở `core` hoặc `shared`.

## 1. Lớp entry/bootstrap

Vai trò:

- Khởi tạo Flutter binding, Firebase, font config.
- Bọc toàn app bằng `ProviderScope`.
- Khởi tạo dịch vụ nền sau frame đầu tiên.
- Quyết định app vào màn hình đăng nhập hay shell chính.

File hiện tại:

- `lib/main.dart`
- `lib/firebase_options.dart`

Luồng chính:

```text
main()
  -> ProviderScope
  -> MyApp
  -> AuthWrapper
  -> LoginScreen | MainNavigation
```

Gợi ý ranh giới:

- `main.dart` chỉ nên làm bootstrap và chọn app shell.
- Logic khởi tạo thông báo, Firebase, settings nên được gom vào provider/service riêng để test dễ hơn.

## 2. Lớp app shell và điều hướng

Vai trò:

- Điều hướng toàn cục.
- Bottom navigation / shell màn hình chính.
- Chuyển route giữa các feature.

File hiện tại:

- `lib/presentation/screens/main_navigation.dart`
- `lib/presentation/navigation/app_routes.dart`

Gợi ý ranh giới:

- Lớp này được phép biết nhiều feature để điều hướng.
- Không nên chứa nghiệp vụ học tập, tính SRS, hoặc truy vấn database.

## 3. Lớp presentation

Vai trò:

- Render UI: screen, widget, painter.
- Nhận input từ user.
- Watch/read Riverpod provider.
- Hiển thị loading, empty, error state.

Thư mục hiện tại:

- `lib/features/*/presentation/screens`
- `lib/features/*/presentation/widgets`
- `lib/presentation/widgets`
- `lib/shared/widgets`

Ví dụ:

- Home: `lib/features/home/presentation/screens/home_page.dart`
- Learning: `lib/features/learning/presentation/screens/*`
- Review: `lib/features/review/presentation/screens/review_screen.dart`
- Shared UI: `lib/shared/widgets/*`

Ranh giới nên giữ:

```text
Widget/Screen -> Provider/Controller -> Use case/domain service -> Repository contract
```

Không nên để UI gọi trực tiếp Drift, SharedPreferences, Firebase SDK, hoặc xử lý migration/database.

Điểm đã tách:

- Các provider/controller có orchestration chính đã được chuyển khỏi `presentation` sang `application/providers` hoặc `application/controllers`.
- `daily_study_plan_provider.dart` và `home_progress_provider.dart` nằm ở `lib/features/home/application/providers`, còn phần mở route theo kế hoạch học nằm ở `lib/features/home/presentation/navigation/daily_study_navigation.dart`.
- `learning_path_provider.dart` nằm ở `lib/features/learning/application/providers`.
- Một số screen đọc repository provider trực tiếp. Với màn nhỏ thì chấp nhận được, nhưng về lâu dài nên đẩy thao tác đó vào controller/use case.

## 4. Lớp application / state orchestration

Vai trò:

- Điều phối một user action thành nhiều bước.
- Kết hợp nhiều repository/domain service.
- Invalidate provider, emit study event, cập nhật state.
- Không chứa code UI.

Trong dự án hiện tại, các provider/controller chính đã được chuyển khỏi tầng `presentation` sang `application`.

Ví dụ hiện tại:

- `lib/features/home/application/providers/daily_study_plan_provider.dart`
- `lib/features/home/application/providers/home_progress_provider.dart`
- `lib/features/learning/application/controllers/lesson_controller.dart`
- `lib/features/review/application/providers/review_controller.dart`
- `lib/features/review/application/providers/study_event_provider.dart`
- `lib/features/grammar/application/providers/grammar_review_provider.dart`

Kiến trúc mục tiêu:

```text
lib/features/<feature>/
  application/
    providers/
    controllers/
    usecases/
  presentation/
    screens/
    widgets/
```

Gợi ý tiếp tục:

- Với provider chỉ là adapter rất mỏng cho UI, có thể giữ gần screen nếu thật sự cần, nhưng dự án hiện tại đang thống nhất đặt provider vào `application`.
- Các provider/controller có nghiệp vụ nhiều bước nên tiếp tục được gom thành use case/application service nhỏ hơn nếu file phình to.
- Các callback như `emitVocabularyStudyEventProvider` có thể tiến thêm một bước thành application service hoặc use case có tên nghiệp vụ rõ hơn.
- Các provider còn dính hạ tầng/UI cần tách tiếp: analytics đang đọc Drift/asset trực tiếp, daily study plan đang đọc Drift review log trực tiếp, settings đang giữ cả `ThemeMode` và `SharedPreferences`.

## 5. Lớp domain

Vai trò:

- Entity thuần.
- Repository contract.
- Business rule thuần Dart.
- Không phụ thuộc Flutter UI, Drift, Firebase, SharedPreferences, hoặc SDK platform.

Thư mục hiện tại:

- `lib/features/*/domain/entities`
- `lib/features/*/domain/repositories`
- `lib/features/*/domain/services`
- `lib/domain/entities`
- `lib/core/srs`
- `lib/core/models`

Ví dụ:

- `lib/features/vocabulary/domain/entities/vocabulary.dart`
- `lib/features/vocabulary/domain/repositories/vocabulary_repository.dart`
- `lib/features/kanji/domain/entities/kanji_card.dart`
- `lib/features/grammar/domain/entities/grammar_point.dart`
- `lib/features/home/domain/services/daily_study_coach.dart`
- `lib/core/srs/fsrs_engine.dart`

Điểm tốt:

- Kanji, vocabulary, grammar đã có repository interface ở domain và implementation ở data.
- `DailyStudyCoach` và `SrsService` là nghiệp vụ có test riêng, dễ giữ thuần.

Điểm cần làm sạch:

- Auth domain đã được bọc bằng `AuthUser` và `AuthFailure`; Firebase/Google Sign-In nằm ở data layer.
- `QuizQuestion` đã được tách khỏi Flutter Material.
- `lib/domain` toàn cục và `lib/features/*/domain` đang cùng tồn tại; nên chọn quy tắc rõ: entity thuộc feature thì để trong feature, entity dùng nhiều feature thì để `core/domain` hoặc `shared/domain`.

## 6. Lớp data

Vai trò:

- Implement repository contract.
- Giao tiếp Drift/SQLite, asset JSON, Firebase, Google Sign-In, SharedPreferences, SDK ngoài.
- Mapping giữa row/model bên ngoài và domain entity.

Thư mục hiện tại:

- `lib/data/datasources`
- `lib/features/*/data/repositories`
- `lib/features/review/data/study_session_service.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/learning/data/repositories/learning_path_repository.dart`
- `lib/features/garden/data/repositories/garden_repository.dart`

Ví dụ:

- `lib/data/datasources/app_database.dart`
- `lib/data/datasources/database_seeder.dart`
- `lib/features/vocabulary/data/repositories/vocabulary_repository_impl.dart`
- `lib/features/grammar/data/repositories/grammar_repository_impl.dart`
- `lib/features/kanji/data/repositories/kanji_repository_impl.dart`

Ranh giới nên giữ:

```text
Data implementation -> Data source / SDK
Data implementation -> Domain entity/contract
Domain không import ngược lại data.
```

Điểm đã xử lý/đang theo dõi:

- Database seeding đã được tách khỏi `lib/core/providers/database_provider.dart` sang `lib/app/bootstrap/database_initializer_provider.dart`, nên `databaseProvider` trong core chỉ còn chịu trách nhiệm tạo và đóng `AppDatabase`.
- `DatabaseSeeder` nằm ở `lib/data` nhưng import repository contract của nhiều feature. Có thể tách thành `core/bootstrap` hoặc `features/content/application`.

## 7. Lớp infrastructure / core

Vai trò:

- Dịch vụ dùng chung và cross-cutting concern.
- Theme/design token.
- Logger.
- Content provider dùng chung.
- Service wrapper cho notification, audio, handwriting.

Thư mục hiện tại:

- `lib/core/theme`
- `lib/core/services`
- `lib/core/content`
- `lib/core/providers`
- `lib/core/srs`
- `lib/core/models`

Gợi ý ranh giới:

- `core` có thể được mọi feature dùng.
- `core` không nên import từ `features`.
- `core/srs` đã được tách khỏi entity feature bằng `SrsItem` và `SrsReviewState`.
- Provider khởi tạo database/seeding nên tránh biết repository provider của feature.

## 8. Lớp shared UI

Vai trò:

- Widget nhỏ, tái sử dụng, không chứa nghiệp vụ feature.
- Component thiết kế chung: card, empty state, loading, badge, selector.

Thư mục hiện tại:

- `lib/shared/widgets`

Ví dụ:

- `AppCard`
- `AppEmptyState`
- `AppLoadingIndicator`
- `JlptLevelSelector`
- `PrimaryButton`

Gợi ý ranh giới:

- Shared widget chỉ nhận data qua constructor.
- Không watch provider feature bên trong shared widget.

## 9. Lớp platform và tài nguyên

Vai trò:

- Android/iOS native config.
- Asset JSON và ảnh.
- Firebase config.
- Generated Drift code.

Thư mục/file hiện tại:

- `android`
- `ios`
- `assets/data`
- `assets/images`
- `lib/data/datasources/app_database.g.dart`
- `firebase.json`

Gợi ý:

- Không chỉnh `app_database.g.dart` thủ công.
- Asset schema nên được test ở `test/features/content`.

## 10. Lớp test

Vai trò:

- Unit test domain service.
- Provider test cho state/application logic.
- Widget test cho màn hình quan trọng.
- Repository/data test với database test executor.

Thư mục hiện tại:

- `test/core/srs`
- `test/features/content`
- `test/features/grammar`
- `test/features/home`
- `test/features/learning`
- `test/features/sentence`
- `test/features/settings`

Điểm tốt:

- `SrsService`, `DailyStudyCoach`, `LessonQuestionGenerator`, settings provider và một số screen/provider đã có test.

Khoảng trống nên bổ sung:

- Repository test cho kanji/vocabulary/grammar search và review submit.
- Test application layer sau khi tách khỏi presentation provider.
- Test bootstrap/seeding để tránh lỗi dữ liệu rỗng hoặc seed lặp.

## 11. Bản đồ feature

```text
auth
  data: Firebase Auth, Google Sign-In implementation
  domain: AuthUser, AuthFailure, auth contract
  application: auth provider
  presentation: login/register screens

kanji
  data: KanjiRepositoryImpl
  domain: KanjiCard, KanjiRepository
  application: repository and library providers
  presentation: library/detail screens and widgets

vocabulary
  data: VocabularyRepositoryImpl
  domain: Vocabulary, VocabularyRepository
  application: repository and library providers
  presentation: library/detail screens and widgets

grammar
  data: GrammarRepositoryImpl
  domain: GrammarPoint, GrammarRepository
  application: repository, library, and review providers
  presentation: library/review screens and widgets

learning
  data: LearningPathRepository
  domain: category, goal, quiz question, question generator
  application: learning path provider, lesson controller
  presentation: path, lesson, placement, result screens

review
  data: StudySessionService
  domain: ReviewItem
  application: review controller, event stream
  presentation: review screen

sentence
  data: SentenceRepositoryImpl
  domain: Sentence, SentenceRepository
  application: sentence provider
  presentation: sentence practice screen

garden
  data: GardenRepository
  domain: currently uses shared ZenGarden entity
  application: garden provider, mission provider
  presentation: garden UI

analytics
  application: analytics provider
  presentation: analytics screen

dictionary
  presentation: aggregate search screen across kanji/vocabulary/grammar/sentence

home
  domain: DailyStudyCoach
  application: home progress, daily plan
  presentation: home screen and daily study navigation

settings
  application/data: settings provider currently also persists SharedPreferences
  presentation: settings screen
```

## 12. Luồng dữ liệu chuẩn

```text
Screen/Widget
  -> Riverpod provider/controller
  -> Use case/domain service
  -> Repository contract
  -> Repository implementation
  -> Drift/Firebase/Asset/SharedPreferences/SDK
  -> Domain entity/result
  -> UI state
```

Ví dụ vocabulary review:

```text
Vocabulary UI
  -> emitVocabularyStudyEventProvider
  -> SrsService.calculateNextVocabularyReview()
  -> VocabularyRepository.submitReview()
  -> DriftStudySessionService
  -> AppDatabase transaction/log/garden reward
  -> StudyEventController.addEvent()
  -> progress/garden/analytics providers refresh
```

## 13. Thứ tự refactor đề xuất

1. Tách application layer cho các provider nặng.
   - Tạo `lib/features/<feature>/application`.
   - Controller/provider chính đã được di chuyển khỏi tầng `presentation`.
   - Bước còn lại là chia nhỏ các provider lớn thành use case/application service khi cần.

2. Làm sạch dependency `core -> features`.
   - Database seeding đã được đưa ra `lib/app/bootstrap/database_initializer_provider.dart`.
   - `core/srs` đã không còn import entity của kanji/vocabulary.
   - Bước còn lại: rà thêm các provider khởi tạo cấp app nếu cần để tránh app bootstrap biết quá nhiều repository feature.

3. Làm domain thuần hơn.
   - Auth đã dùng `AuthUser` và `AuthFailure` thay vì lộ `User`/`UserCredential`.
   - `QuizQuestion` đã không còn import Flutter Material.
   - Bước còn lại: tách `AppSettings` khỏi `ThemeMode` nếu muốn settings domain/application hoàn toàn không phụ thuộc Flutter UI.

4. Chuẩn hóa vị trí entity dùng chung.
   - Chuyển entity toàn cục trong `lib/domain/entities` sang `lib/core/domain/entities` hoặc feature sở hữu rõ ràng.
   - Tránh để cả `lib/domain` và `lib/features/*/domain` phát triển song song mà không có quy tắc.

5. Dọn placeholder.
   - Các file placeholder rỗng đã được xóa vì không có import sử dụng.

6. Bổ sung test theo layer mới.
   - Domain service: unit test thuần.
   - Application controller/use case: provider/container test.
   - Data repository: test với database test executor.
   - Presentation: widget test cho các màn hình chính.

7. Tách tiếp application provider còn lẫn hạ tầng/UI.
   - Chuyển truy vấn analytics và weakest-area review log vào repository/read model ở data.
   - Tách settings persistence khỏi `SettingsController`.
   - Bọc `ThemeMode` bằng app enum hoặc mapper presentation nếu muốn application hoàn toàn thuần Flutter-free.

## 14. Cấu trúc mục tiêu

```text
lib/
  app/
    bootstrap/
    navigation/
    shell/
  core/
    domain/
    services/
    theme/
    logging/
    content/
  shared/
    widgets/
  features/
    vocabulary/
      presentation/
        screens/
        widgets/
      application/
        providers/
        controllers/
        usecases/
      domain/
        entities/
        repositories/
        services/
      data/
        repositories/
        datasources/
        mappers/
    kanji/
      ...
    grammar/
      ...
  data/
    local/
      app_database.dart
      app_database.g.dart
```

Nguyên tắc phụ thuộc mục tiêu:

```text
app -> features presentation/application
presentation -> application/domain/shared/core
application -> domain/core
data -> domain/core/infrastructure SDK
domain -> core domain primitives only
core -> no feature dependency
shared -> core theme only
```
