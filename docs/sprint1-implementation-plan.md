# Sprint 1：地基搭建 — 实施计划

> 目标：从"时令水果日历 App"过渡到"全国水果信息平台"的第一阶段。
> 产出：可独立发布的 v0.2.0 版本，支持用户注册登录、API 连通、水果数据扩展。

---

## 目录

1. [后端：Supabase 初始化](#1-后端supabase-初始化)
2. [后端：数据迁移（PostgreSQL 建表）](#2-后端数据迁移)
3. [后端：文件上传 API](#3-后端文件上传-api)
4. [后端：基础 API 网关与部署](#4-后端基础-api-网关与部署)
5. [Flutter：项目结构重构](#5-flutter项目结构重构)
6. [Flutter：集成 Supabase SDK 与认证系统](#6-flutter集成-supabase-sdk-与认证系统)
7. [Flutter：登录/注册页面](#7-flutter登录注册页面)
8. [Flutter：用户状态管理](#8-flutter用户状态管理)
9. [Flutter：网络层封装](#9-flutter网络层封装)
10. [Flutter：现有数据模型兼容改造](#10-flutter现有数据模型兼容改造)
11. [数据：水果 JSON 扩展（挑选技巧/品种）](#11-数据水果-json-扩展)
12. [验证与检查清单](#12-验证与检查清单)

---

## 1. 后端：Supabase 初始化

### 1.1 创建 Supabase 项目

1. 登录 [supabase.com](https://supabase.com) → **New project**
2. 填写：
   - **Name**: `shiling-fruit`
   - **Database Password**: 生成并记录（未来用 `psql` 连时用）
   - **Region**: 选择 **Singapore**（或最近的可用 Region）
   - **Pricing Plan**: Free（够初期用）
3. 等待数据库初始化完成后，进入 Dashboard

### 1.2 记录项目凭证

记录以下值到 `lib/core/config/env.dart`（**不要提交到 git**）：

```dart
// lib/core/config/env.dart
class Env {
  static const supabaseUrl = 'https://xxxxx.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOi...';
}
```

### 1.3 启用需要的 Supabase 功能

- **Authentication** → **Providers** → 启用 **Phone**（短信验证码登录）
  - 开发阶段可先用 **Email + Password** 模式（方便调试）
- **Storage** → 创建 bucket `posts`（公开读，认证写）
- **Storage** → 创建 bucket `avatars`（公开读，认证写）
- **SQL Editor** → 执行下方建表脚本

---

## 2. 后端：数据迁移

### 2.1 建表 SQL

在 Supabase **SQL Editor** 中执行以下脚本：

```sql
-- =============================================
-- 1. 水果扩展表（在线端副本，离线仍用 JSON）
-- =============================================
CREATE TABLE IF NOT EXISTS fruits (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  english_name  TEXT DEFAULT '',
  emoji         TEXT DEFAULT '',
  image         TEXT DEFAULT '',
  color_hex     TEXT DEFAULT '#CCCCCC',
  brix_min      REAL DEFAULT 0,
  brix_max      REAL DEFAULT 0,
  calorie       INT DEFAULT 0,
  tcm_nature    TEXT DEFAULT '平',

  -- 新增：挑选技巧
  picking_tips       TEXT DEFAULT '',
  storage_tips       TEXT DEFAULT '',
  best_eat_method    TEXT DEFAULT '',
  variety_json       TEXT DEFAULT '[]',
  grade_std          TEXT DEFAULT '',

  alias_json         TEXT DEFAULT '[]',
  vitamins_json      TEXT DEFAULT '{}',
  minerals_json      TEXT DEFAULT '{}',
  benefits_json      TEXT DEFAULT '[]',
  contraindications_json TEXT DEFAULT '[]',
  origins_json       TEXT DEFAULT '[]',
  peak_season        TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================
-- 2. 用户扩展表
-- =============================================
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname    TEXT DEFAULT '',
  avatar_url  TEXT DEFAULT '',
  bio         TEXT DEFAULT '',
  city_id     TEXT DEFAULT '',
  level       INT DEFAULT 1,
  score       INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- 自动创建 profile 的触发器
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'nickname',
    '用户' || substr(NEW.id::text, 1, 6)));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- 3. 帖子表
-- =============================================
CREATE TABLE IF NOT EXISTS posts (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type         TEXT NOT NULL DEFAULT 'share'
               CHECK (type IN ('share','guide','experience','question')),
  title        TEXT NOT NULL DEFAULT '',
  content      TEXT DEFAULT '',
  fruit_id     TEXT REFERENCES fruits(id) ON DELETE SET NULL,
  city_id      TEXT DEFAULT '',
  latitude     REAL,
  longitude    REAL,
  tags         TEXT[] DEFAULT '{}',
  status       TEXT NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending','approved','rejected')),
  like_count   INT DEFAULT 0,
  comment_count INT DEFAULT 0,
  bookmark_count INT DEFAULT 0,
  view_count   INT DEFAULT 0,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_fruit_id ON posts(fruit_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);

-- =============================================
-- 4. 帖子图片表
-- =============================================
CREATE TABLE IF NOT EXISTS post_images (
  id          BIGSERIAL PRIMARY KEY,
  post_id     BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  thumbnail   TEXT DEFAULT '',
  width       INT DEFAULT 0,
  height      INT DEFAULT 0,
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_post_images_post_id ON post_images(post_id);

-- =============================================
-- 5. 评论表（支持楼中楼）
-- =============================================
CREATE TABLE IF NOT EXISTS comments (
  id          BIGSERIAL PRIMARY KEY,
  post_id     BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id   BIGINT REFERENCES comments(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  like_count  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON comments(parent_id);

-- =============================================
-- 6. 点赞表
-- =============================================
CREATE TABLE IF NOT EXISTS likes (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL CHECK (target_type IN ('post','comment')),
  target_id   BIGINT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, target_type, target_id)
);

CREATE INDEX IF NOT EXISTS idx_likes_target ON likes(target_type, target_id);

-- =============================================
-- 7. 收藏表
-- =============================================
CREATE TABLE IF NOT EXISTS bookmarks (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  post_id     BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, post_id)
);

-- =============================================
-- 8. 关注表
-- =============================================
CREATE TABLE IF NOT EXISTS follows (
  id            BIGSERIAL PRIMARY KEY,
  follower_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(follower_id, following_id),
  CHECK(follower_id <> following_id)
);

-- =============================================
-- 9. 审核日志
-- =============================================
CREATE TABLE IF NOT EXISTS moderation_logs (
  id           BIGSERIAL PRIMARY KEY,
  post_id      BIGINT REFERENCES posts(id) ON DELETE CASCADE,
  moderator_id UUID REFERENCES profiles(id),
  action       TEXT NOT NULL CHECK (action IN ('approve','reject','flag','unflag')),
  reason       TEXT DEFAULT '',
  created_at   TIMESTAMPTZ DEFAULT now()
);
```

### 2.2 设置 Row Level Security (RLS)

```sql
-- 开启 RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_images ENABLE ROW LEVEL SECURITY;

-- Profiles：自己可读写，其他只能读
CREATE POLICY "profiles_select_public" ON profiles
  FOR SELECT USING (true);
CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Posts：已审核的公开可读，自己的草稿自己可见
CREATE POLICY "posts_select_approved" ON posts
  FOR SELECT USING (status = 'approved' OR user_id = auth.uid());
CREATE POLICY "posts_insert_own" ON posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "posts_update_own" ON posts
  FOR UPDATE USING (auth.uid() = user_id);

-- Comments：公开可读，登录可写
CREATE POLICY "comments_select" ON comments FOR SELECT USING (true);
CREATE POLICY "comments_insert" ON comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Likes：公开可读，登录可写可删
CREATE POLICY "likes_select" ON likes FOR SELECT USING (true);
CREATE POLICY "likes_insert_own" ON likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "likes_delete_own" ON likes
  FOR DELETE USING (auth.uid() = user_id);

-- Storage：存储桶 RLS
CREATE POLICY "storage_posts_select" ON storage.objects
  FOR SELECT USING (bucket_id = 'posts');
CREATE POLICY "storage_posts_insert" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'posts' AND auth.role() = 'authenticated');
CREATE POLICY "storage_avatars_select" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "storage_avatars_insert" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
```

---

## 3. 后端：文件上传 API

Supabase Storage 自带 REST API，Flutter SDK 可直接调用。

```dart
// Flutter 端调用示例
final supabase = Supabase.instance.client;
final file = File(imagePath);
final fileName = '${uuid.v4()}.webp';
await supabase.storage.from('posts').upload(fileName, file);
final publicUrl = supabase.storage.from('posts').getPublicUrl(fileName);
```

**存储桶限制配置**（在 Dashboard → Storage 中设置）：

| Bucket | 最大文件 | 允许类型 | 访问策略 |
|--------|---------|---------|---------|
| `posts` | 10MB | image/jpeg, png, webp | 公开读，认证用户写 |
| `avatars` | 5MB | image/jpeg, png, webp | 公开读，本人写 |

---

## 4. 后端：基础 API 网关与部署

Sprint 1 直接使用 Supabase **Auto-generated REST API**，无需自建网关：

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/rest/v1/profiles` | 获取用户列表 |
| GET | `/rest/v1/profiles?id=eq.{uid}` | 获取单个用户 |
| PATCH | `/rest/v1/profiles?id=eq.{uid}` | 更新用户资料 |
| GET | `/rest/v1/posts` | 帖子列表 |
| POST | `/rest/v1/posts` | 创建帖子 |
| GET | `/rest/v1/comments` | 评论列表 |
| POST | `/rest/v1/comments` | 创建评论 |
| POST | `/rest/v1/likes` | 点赞 |
| DELETE | `/rest/v1/likes?user_id=eq.{uid}&...` | 取消点赞 |

---

## 5. Flutter：项目结构重构

### 5.1 新目录结构

```
lib/
├── main.dart                        // 入口（改造）
├── app.dart                         // App 根组件（改造）
│
├── core/                            // 新增：基础设施层
│   ├── api/
│   │   ├── api_client.dart          // API 客户端
│   │   └── api_exception.dart       // 统一错误处理
│   ├── auth/
│   │   ├── auth_state.dart          // 认证状态模型
│   │   └── auth_provider.dart       // 认证状态 provider
│   ├── cache/
│   │   └── cache_manager.dart       // 离线缓存管理器
│   ├── config/
│   │   └── env.dart                 // 环境配置
│   └── constants/
│       └── app_constants.dart
│
├── data/                            // 保留 + 扩展
│   ├── database.dart                // Drift（保留）
│   ├── seed_loader.dart             // 离线种子（保留）
│   ├── models/                      // 新增：数据模型
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   └── fruit_ext_model.dart
│   └── repositories/                // 新增：数据仓库
│       ├── auth_repository.dart
│       ├── post_repository.dart
│       ├── profile_repository.dart
│       └── fruit_repository.dart
│
├── features/                        // 新增：按功能模块组织
│   ├── auth/                        // 登录注册
│   │   ├── pages/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   └── widgets/
│   │       └── auth_text_field.dart
│   │
│   ├── home/                        // 时令首页（迁移）
│   │   ├── pages/home_page.dart
│   │   ├── widgets/
│   │   └── providers/home_providers.dart
│   │
│   ├── encyclopedia/                // 水果百科（Sprint 2）
│   ├── community/                   // 社区（Sprint 2）
│   │
│   └── profile/                     // 个人中心
│       ├── pages/
│       │   ├── profile_page.dart
│       │   └── settings_page.dart
│       └── providers/
│
├── shared/                          // 共享组件
│   ├── widgets/
│   │   ├── network_image.dart
│   │   ├── loading_overlay.dart
│   │   └── error_view.dart
│   └── theme/                       // 主题（迁移）
│       ├── app_theme.dart
│       ├── season.dart
│       └── spacing.dart
│
├── services/                        // 保留
│   ├── data_updater.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   └── solar_term.dart
│
└── utils/
    └── date_utils.dart              // 保留
```

### 5.2 重构步骤

```
Step 1: 创建 core/ 目录和基础文件
Step 2: 创建 features/ 目录，迁移 home/ 到 features/home/
Step 3: 创建 shared/ 目录，迁移 theme/ 和 shared widgets
Step 4: 保留 data/ 和 services/ 不动
Step 5: 逐步引入新功能模块
```

---

## 6. Flutter：集成 Supabase SDK 与认证系统

### 6.1 添加依赖

```yaml
# pubspec.yaml — 新增依赖
dependencies:
  supabase_flutter: ^2.5.0
  image_picker: ^1.0.7
  cached_network_image: ^3.3.1
  uuid: ^4.3.3
  flutter_secure_storage: ^9.0.0
```

### 6.2 初始化 Supabase

```dart
// lib/main.dart — 入口改造
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化 Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // 2. 初始化离线数据库（原有逻辑保留）
  final db = AppDatabase();
  final updater = DataUpdater();
  await updater.ensureLocalCopy();
  await SeedLoader(db, updater).ensureLoaded();

  // 3. 原有城市初始化逻辑...
  // ...
}
```

### 6.3 Auth Provider

```dart
// lib/core/auth/auth_provider.dart
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.unauthenticated()) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = session != null
          ? AuthState.authenticated(userId: session.user.id)
          : const AuthState.unauthenticated();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email, password: password,
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      await Supabase.instance.client.auth.signUp(
        email: email, password: password,
      );
      state = const AuthState.emailVerificationSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

---

## 7. Flutter：登录/注册页面

### 7.1 App 路由改造

```dart
// lib/app.dart
class ShilingFruitApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: '时令水果',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: authState.when(
        unauthenticated: () => const LoginPage(),
        authenticated: (userId) => const MainShell(),
        loading: () => const SplashScreen(),
        initial: () => const SplashScreen(),
        emailVerificationSent: () => const EmailVerificationSentPage(),
        error: (msg) => LoginPage(errorMessage: msg),
      ),
    );
  }
}
```

### 7.2 登录页 UI 骨架

```dart
// lib/features/auth/pages/login_page.dart
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.errorMessage});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text('🍇', style: TextStyle(fontSize: 72)),
              Text('时令水果', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: '邮箱', prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码', prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _onLogin,
                child: const Text('登录'),
              ),
              OutlinedButton(
                onPressed: _onRegister,
                child: const Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Flutter：用户状态管理

### 8.1 Profile Provider

```dart
// lib/features/profile/providers/profile_providers.dart
final myProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.maybeWhen(
    authenticated: (uid) => uid,
    orElse: () => null,
  );
  if (userId == null) return null;

  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', userId)
      .single();

  return ProfileModel.fromJson(response);
});
```

### 8.2 认证感知 Provider

```dart
// lib/core/auth/auth_provider.dart
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).maybeWhen(
        authenticated: (uid) => uid,
        orElse: () => null,
      );
});
```

---

## 9. Flutter：网络层封装

```dart
// lib/core/api/api_client.dart
class ApiClient {
  ApiClient(this._supabase);
  final SupabaseClient _supabase;

  Future<T?> fetchOne<T>(String table,
      {String? select, Map<String, dynamic>? filters}) async {
    var query = _supabase.from(table).select(select ?? '*');
    filters?.forEach((k, v) => query = query.eq(k, v));
    final result = await query.single();
    return result as T;
  }

  Future<List<T>> fetchList<T>(String table,
      {int? limit, int? offset, String? order}) async {
    var query = _supabase.from(table).select('*');
    if (limit != null) query = query.limit(limit);
    if (order != null) {
      final parts = order.split(' ');
      query = query.order(parts[0], ascending: parts.length > 1 && parts[1] == 'asc');
    }
    return (await query).cast<T>();
  }

  Future<T> insert<T>(String table, Map<String, dynamic> data) async {
    final r = await _supabase.from(table).insert(data).select().single();
    return r as T;
  }

  Future<void> update(String table, Map<String, dynamic> data,
      Map<String, dynamic> filters) async {
    var query = _supabase.from(table).update(data);
    filters.forEach((k, v) => query = query.eq(k, v));
    await query;
  }

  Future<void> delete(String table, Map<String, dynamic> filters) async {
    var query = _supabase.from(table).delete();
    filters.forEach((k, v) => query = query.eq(k, v));
    await query;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(Supabase.instance.client);
});
```

---

## 10. Flutter：现有数据模型兼容改造

### 10.1 离线/在线双轨策略

```dart
// lib/data/repositories/fruit_repository.dart
class FruitRepository {
  FruitRepository(this._db, this._api);
  final AppDatabase _db;
  final ApiClient _api;

  /// 获取水果详情：优先本地，在线补充
  Future<FruitDetail> getFruitDetail(String fruitId) async {
    // Step 1: 从本地数据库获取基础数据
    final localFruit = await _db.findFruit(fruitId);
    if (localFruit == null) throw Exception('水果不存在');

    // Step 2: 从在线获取扩展信息（挑选技巧等）
    FruitExtModel? ext;
    try {
      final result = await _api.fetchOne<Map<String, dynamic>>(
        'fruits', filters: {'id': fruitId},
      );
      if (result != null) ext = FruitExtModel.fromJson(result);
    } catch (_) {
      // 离线时静默降级
    }

    return FruitDetail(basic: localFruit, ext: ext);
  }
}
```

### 10.2 现有 Provider 保留不受影响

原有 `_recsProvider`、`fruitProvider`、`favoritesProvider` 等全部保留，只新增在线数据仓库。老功能完全不受影响。

---

## 11. 数据：水果 JSON 扩展

### 11.1 新增字段示例

```json
{
  "id": "lychee",
  "name": "荔枝",
  "picking_tips": "## 看颜色\n- 桂味：浅红色带绿\n- 妃子笑：青红相间\n\n## 摸手感\n- 新鲜：果皮紧绷有弹性\n- 不新鲜：果皮发软\n\n## 闻气味\n- 清香 = 新鲜\n- 酒味 = 已变质",
  "storage_tips": "1. 剪掉枝叶保留小蒂\n2. 喷水用报纸包裹\n3. 保鲜袋冷藏(4°C)可存5-7天",
  "best_eat_method": "- 直接鲜食（最佳）\n- 冷藏1小时后更清甜\n- 可制荔枝酒",
  "variety_json": [
    {"name": "桂味", "desc": "果核小，肉质爽脆，带桂花香", "season": "6月中-7月上"},
    {"name": "妃子笑", "desc": "果大核小，酸甜适中", "season": "5月底-6月"},
    {"name": "糯米糍", "desc": "肉厚软糯，极甜", "season": "6月下-7月上"}
  ],
  "grade_std": "一级果：果径≥30mm，着色≥90%"
}
```

### 11.2 数据版本升级

```bash
dart scripts/validate_data.dart
# 更新 version.json 版本号
git add data/ assets/data/
git commit -m "feat(data): 水果数据扩展，增加挑选技巧/品种字段"
git tag v2-data
```

---

## 12. 验证与检查清单

### 12.1 Sprint 1 完成检查清单

| # | 任务 | 状态 | 验证方式 |
|---|------|------|----------|
| S1.1 | Supabase 项目创建 | ☐ | Dashboard 可访问 |
| S1.2 | 所有数据库表创建 | ☐ | SQL 执行无错误 |
| S1.3 | RLS 策略设置 | ☐ | 权限访问验证通过 |
| S1.4 | Storage buckets 创建 | ☐ | 文件上传/读取正常 |
| S1.5 | Flutter 依赖更新 | ☐ | `flutter pub get` 通过 |
| S1.6 | 项目结构重构 | ☐ | 新目录就绪，旧功能正常 |
| S1.7 | Supabase 初始化 | ☐ | App 启动无网络错误 |
| S1.8 | 登录页 UI | ☐ | 邮箱/密码输入可交互 |
| S1.9 | 注册功能 | ☐ | Auth 表有记录 |
| S1.10 | 认证状态切换 | ☐ | 登录跳转首页，登出回登录页 |
| S1.11 | Profile 自动创建 | ☐ | 注册后 profiles 表有记录 |
| S1.12 | API 客户端 | ☐ | CRUD 请求正常 |
| S1.13 | 离线/在线双轨 | ☐ | 离线可浏览，在线可刷新 |
| S1.14 | 水果扩展 JSON | ☐ | 新字段可被解析 |
| S1.15 | 编译通过 | ☐ | `flutter build apk --debug` 成功 |

### 12.2 验证命令

```bash
flutter analyze
flutter test
flutter build apk --debug
dart scripts/validate_data.dart
```

### 12.3 Commit 规划

```
feat(core): 新增 core/ 基础设施层（API 客户端、异常、环境配置）
feat(auth): 集成 Supabase Auth，实现登录/注册及页面 UI
refactor: 项目结构按 feature 分层重组
feat(data): 扩展水果 JSON，增加挑选技巧/品种字段
chore: 更新依赖和 pubspec.yaml
```

---

## 附录：常见问题

**Q：Sprint 1 完成后用户能看到什么？**
- 现有功能全部保留（时令推荐、月历、收藏）
- 登录/注册页面可访问
- 注册后自动创建 Profile
- 发帖入口已预留但隐藏（Sprint 2 启用）
- 数据扩展字段就绪，UI 暂未使用

**Q：如何本地调试？**
```bash
flutter run
# Supabase Dashboard 实时查看数据
```

**Q：需要后端开发人员吗？**
Sprint 1 可以由 Flutter 开发者独立完成（Supabase 减少 80% 后端工作），
但需要有基础 SQL 知识。

**Q：数据库迁移如何管理？**
所有 SQL 脚本放在 `docs/db/migrations/`：`001_init.sql` → `002_xxx.sql`。
后续可用 Supabase CLI 管理。

**Q：生产环境安全？**
- Free Plan 每天 50,000 请求限制
- RLS 确保用户只能操作自己数据
- 文件上传限制 10MB
- 建议在 Dashboard 开启 Rate Limiting
