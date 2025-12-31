# macOS 26.2 YYText 兼容性修复说明

## 问题描述

在 macOS 26.2 系统上，YYText 框架出现多个头文件找不到的错误：

```
'YYTextInput.h' file not found
'YYTextUtilities.h' file not found
```

## 问题原因

macOS 26.2 改变了 Xcode 的头文件搜索路径行为：

1. **更严格的路径解析**：新版本的 Xcode 对头文件搜索路径的解析更加严格
2. **USE_HEADERMAP 行为变化**：即使设置了 `USE_HEADERMAP = NO`，某些情况下仍然无法正确解析子目录中的头文件
3. **相对路径处理**：YYText 使用相对路径 `#import "YYTextInput.h"` 导入子目录中的文件，但在新系统上无法正确解析

## 解决方案

### 自动修复（已实现）

在 `Podfile` 的 `post_install` hook 中添加了自动修复脚本，每次运行 `pod install` 时会自动：

1. **修复所有导入路径**：将相对路径改为包含子目录的路径
   - `#import "YYTextInput.h"` → `#import "Component/YYTextInput.h"`
   - `#import "YYTextUtilities.h"` → `#import "Utility/YYTextUtilities.h"`

2. **修复的文件列表**：
   - `Component/YYTextLine.m`
   - `Component/YYTextMagnifier.m`
   - `Component/YYTextSelectionView.m`
   - `Component/YYTextLayout.m`
   - `Component/YYTextLayout.h`
   - `Component/YYTextSelectionView.h`
   - `Component/YYTextKeyboardManager.m`
   - `Component/YYTextEffectWindow.m`
   - `Component/YYTextInput.m`
   - `String/YYTextParser.m`
   - `YYTextView.m`
   - `YYLabel.m`
   - `YYText.h`

### 手动修复（如果需要）

如果自动修复未生效，可以手动修复：

```bash
# 1. 进入 YYText 目录
cd Pods/YYText/YYText

# 2. 修复所有文件中的导入路径
# 使用 sed 批量替换（注意备份）
find . -name "*.m" -o -name "*.h" | xargs sed -i '' 's/#import "YYTextInput\.h"/#import "Component\/YYTextInput.h"/g'
find . -name "*.m" -o -name "*.h" | xargs sed -i '' 's/#import "YYTextUtilities\.h"/#import "Utility\/YYTextUtilities.h"/g'
```

## 验证修复

运行以下命令验证修复是否成功：

```bash
# 检查修复后的文件
grep -r '#import "Component/YYTextInput.h"' Pods/YYText/YYText/
grep -r '#import "Utility/YYTextUtilities.h"' Pods/YYText/YYText/

# 应该看到多个文件包含修复后的导入路径
```

## 注意事项

1. **每次 pod install 后自动修复**：修复脚本会在每次运行 `pod install` 时自动执行
2. **不影响其他项目**：修复只针对当前项目的 Pods 目录
3. **可以安全运行 pod update**：修复脚本会检查文件是否已修复，避免重复修改

## 相关配置

在 `Podfile` 中已添加以下配置以改善兼容性：

```ruby
config.build_settings['USE_HEADERMAP'] = 'NO'
config.build_settings['ALWAYS_SEARCH_USER_PATHS'] = 'YES'
config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
```

## 其他可能的问题

### OpenSSL-Universal 编译错误

如果遇到 OpenSSL-Universal 的编译错误，可能是由于：

1. **架构不匹配**：确保项目支持 Apple Silicon 和 Intel 架构
2. **脚本执行权限**：检查构建脚本的执行权限

解决方案：

```bash
# 清理 Pods 并重新安装
rm -rf Pods Podfile.lock
pod install

# 如果问题持续，检查 OpenSSL-Universal 的版本
pod update OpenSSL-Universal
```

## 总结

macOS 26.2 的更新导致 YYText 框架的头文件搜索路径解析更加严格。通过在 `Podfile` 中添加自动修复脚本，可以确保每次 `pod install` 后自动修复所有导入路径问题，无需手动干预。

