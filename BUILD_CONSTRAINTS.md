# 项目构建约束

> 本文件记录 shiling-fruit 在 CN 网络环境下的构建约束和配置。

---

## 1. ABI（原生二进制架构）约束

### 当前配置

**文件：** `android/app/build.gradle.kts`

```kotlin
ndk {
    abiFilters += listOf("x86_64")
}
```

### 原因

`sqlite3_flutter_libs` 插件构建时会下载各架构的原生 `.so` 库。CN 环境从 GitHub Releases 下载容易超时，限制只下载需要的架构。

### 切换指南

| 目标 | abiFilters 配置 | 适用场景 |
|------|----------------|---------|
| **x86_64** | `listOf("x86_64")` | 模拟器 / 虚拟机开发（当前） |
| **arm64-v8a** | `listOf("arm64-v8a")` | 主流真机 |
| **多架构** | `listOf("arm64-v8a", "x86_64")` | 真机 + 模拟器 |
| **全部架构** | 移除 `ndk {}` 块 | CI/CD 发版 |

> **发版前务必检查：** 将 abiFilters 改为 `arm64-v8a` 或移除，否则 APK 在真机无法安装。

### NDK 版本

`android/app/build.gradle.kts` 中指定：

```kotlin
android {
    ndkVersion = "28.2.13676358"
}
```

---

## 2. 网络配置

### 核心结论

**代理优先于镜像。** 实测：
- 阿里云 Maven 镜像 ✅ 工作正常（Gradle 依赖用）
- `flutter-io.cn` 镜像 ❌ 超时（不如直连快）
- 本地 HTTP 代理 `127.0.0.1:7897` ✅ 最快最稳定

### Gradle Maven 镜像

**文件：** `android/build.gradle.kts`

```kotlin
maven { url = uri("https://maven.aliyun.com/repository/public") }
maven { url = uri("https://maven.aliyun.com/repository/google") }
```

### 代理设置（构建前执行）

```bash
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
```

> **注意：** Dart/Flutter native assets 下载（sqlite3 等）**必须**设置**小写**的 `http_proxy` 和 `https_proxy` 变量。仅设大写无效。

---

## 3. 构建命令

```bash
# 1. 设置代理
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897

# 2. 构建
cd Z:/vibe_coding/shiling-fruit
flutter build apk --debug

# 3. 输出
# build/app/outputs/flutter-apk/app-debug.apk  (~160MB debug)
```

---

## 4. 常见问题

### 报 `libsqlite3.*.android.so` 下载失败？
→ 确认小写代理变量已设置。确认 abiFilters 只包含需要的架构。

### 报 Gradle 依赖下载超时？
→ 确认已配置阿里云 Maven 镜像。

### APK 无法安装到真机？
→ 发版前将 abiFilters 改为 `arm64-v8a` 或移除。

### `flutter analyze` 通过但构建失败？
→ 通常是 NDK 版本或网络问题，与代码无关。检查：
1. NDK 版本是否匹配（当前要求 28.2.13676358）
2. 代理是否正常
3. Gradle 缓存：`flutter clean` 重试