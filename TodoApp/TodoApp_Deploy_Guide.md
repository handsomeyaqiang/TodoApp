# iOS App 本地运行 & 真机测试指南

## 前置条件

| 要求 | 说明 |
|------|------|
| Mac 电脑 | macOS 13 Ventura 或更高版本 |
| Xcode | 版本 15.0 或更高（支持 SwiftData / Swift Charts / iOS 17） |
| Apple ID | 免费 Apple ID 即可用于真机测试（无需付费开发者账号） |
| iPhone/iPad | iOS 17.0 或更高版本（如需真机测试） |
| USB 数据线 | 将设备连接到 Mac（也支持无线） |

---

## 第一步：安装 Xcode

1. 打开 Mac App Store
2. 搜索 **Xcode**，点击安装（约 12GB）
3. 安装完成后，首次打开 Xcode 会自动安装模拟器组件，等待完成

验证安装：
```bash
xcode-select --version
# 应输出：xcode-select version 2395 (或更高)
```

---

## 第二步：创建 Xcode 项目

1. 打开 Xcode → 点击 **Create New Project...**
2. 选择平台 **iOS** → 模板选择 **App** → 点击 **Next**
3. 填写项目信息：

   | 字段 | 填写内容 |
   |------|---------|
   | Product Name | `TodoApp` |
   | Team | 选择你的 Apple ID（见第三步） |
   | Organization Identifier | `com.yourname`（随意填写，如 `com.demo`） |
   | Bundle Identifier | 自动生成（如 `com.yourname.TodoApp`） |
   | Interface | **SwiftUI** |
   | Language | **Swift** |
   | Storage | **None**（我们手动使用 SwiftData） |

4. 点击 **Next** → 选择保存位置（建议保存到桌面或文稿） → 点击 **Create**

---

## 第三步：配置 Apple ID（签名）

### 添加 Apple ID 到 Xcode

1. 打开 Xcode → 菜单栏 **Xcode → Settings...**（或 `⌘,`）
2. 点击 **Accounts** 标签页
3. 点击左下角 **+** → 选择 **Apple ID**
4. 输入你的 Apple ID 和密码登录

### 设置项目签名

1. 在 Xcode 左侧文件导航器，点击最顶层的蓝色 **TodoApp** 项目图标
2. 在中间编辑区，选择 **TARGETS** 下的 **TodoApp**
3. 点击 **Signing & Capabilities** 标签页
4. 勾选 **Automatically manage signing**
5. **Team** 下拉菜单选择你的 Apple ID（格式：`Your Name (Personal Team)`）

> ⚠️ 如果看到红色错误提示"Bundle identifier is not unique"，修改 Bundle Identifier 为更唯一的值，如 `com.yourname.todoapp.2025`

---

## 第四步：导入源代码

### 完整目录结构

将本项目 `TodoApp/TodoApp/` 目录下所有文件和文件夹复制到 Xcode 项目对应目录。目录结构如下：

```
TodoApp/TodoApp/
├── TodoAppApp.swift
├── ContentView.swift
├── Models/
│   ├── TodoItem.swift
│   └── Tag.swift
├── ViewModels/
│   ├── TodoListViewModel.swift
│   ├── TodoDetailViewModel.swift
│   └── TagViewModel.swift
├── Services/                        ← 新增目录
│   └── NotificationService.swift    ← 本地通知服务
├── Views/
│   ├── TodoList/
│   │   ├── TodoListView.swift
│   │   ├── TodoRowView.swift
│   │   └── FilterBarView.swift
│   ├── TodoDetail/
│   │   ├── TodoDetailView.swift
│   │   └── TodoEditView.swift
│   ├── Tags/
│   │   ├── TagListView.swift
│   │   ├── TagPickerView.swift
│   │   └── TagChipView.swift
│   ├── Calendar/                    ← 新增目录
│   │   ├── CalendarView.swift       ← 日历主页面
│   │   └── CalendarGridView.swift   ← 月历网格组件
│   └── Overview/                    ← 新增目录
│       └── OverviewView.swift       ← 概览仪表板
├── Utilities/
│   ├── Color+Extensions.swift
│   └── DateFormatter+Extensions.swift
└── Preview Content/
    └── PreviewData.swift
```

### 导入步骤（方法一：Finder 复制，推荐）

1. 在 Finder 中找到 Xcode 项目位置，打开 `TodoApp/TodoApp/` 文件夹
2. 将所有文件和文件夹**复制覆盖**进去（删除 Xcode 自动生成的 `ContentView.swift`）
3. 回到 Xcode，右键点击左侧 **TodoApp 文件夹** → **Add Files to "TodoApp"...**
4. 选中所有文件夹和文件（特别确保包含 `Services/`、`Views/Calendar/`、`Views/Overview/`）
5. 勾选 **Copy items if needed** → 勾选 **Create groups** → 点击 **Add**

### 导入步骤（方法二：Xcode 内逐文件创建）

1. 在 Xcode 左侧右键 → **New Group**，按上方结构创建所有文件夹（包括 `Services`、`Calendar`、`Overview`）
2. 右键每个文件夹 → **New File...** → 选择 **Swift File** → 粘贴对应代码

---

## 第五步：在模拟器中运行

### 选择模拟器

在 Xcode 顶部工具栏，点击设备选择器：
- 推荐选择：**iPhone 15 Pro**（iOS 17+）
- 或任何 iOS 17+ 的模拟器型号

### 运行 App

- 点击顶部工具栏的 ▶ **Run** 按钮
- 或使用快捷键 `⌘ + R`

首次编译约需 30-60 秒，之后增量编译会很快。

### 模拟器操作提示

| 手势 | 模拟器快捷键 |
|------|------------|
| 点击 | 鼠标左键单击 |
| 长按 | 鼠标长按 |
| 上下滚动 | 鼠标滚轮 |
| 左右滑动 | 按住 Option + 鼠标拖拽 |
| 返回主屏幕 | `⌘ + Shift + H` |

### 在模拟器中测试推送通知

模拟器支持本地通知，但需要以下步骤触发：

1. App 启动后，系统会弹出通知授权弹窗 → 点击**允许**
2. 新建一个事项，开启提醒，将提醒时间设为 1-2 分钟后
3. 按 `⌘ + Shift + H` 回到主屏幕（App 进入后台）
4. 等待到提醒时间，通知横幅出现在屏幕顶部

---

## 第六步：在真机（iPhone）上运行

### 6.1 连接设备

**有线连接（推荐）：**
1. 用 USB 数据线连接 iPhone 到 Mac
2. iPhone 上弹出"信任此电脑？" → 点击**信任**
3. 在 Xcode 顶部设备选择器中选择你的 iPhone

**无线连接：**
1. iPhone 和 Mac 连接同一 Wi-Fi
2. 先用数据线连接一次，Xcode 菜单 **Window → Devices and Simulators**
3. 勾选 **Connect via network**，之后可断开数据线

### 6.2 信任开发者证书（首次必须）

第一次在真机运行后，iPhone 会提示"未受信任的开发者"：

1. 打开 iPhone **设置** → **通用**
2. 滚动到底部 → **VPN与设备管理**
3. 在"开发者 App"部分，点击你的 Apple ID 邮箱
4. 点击 **信任 "你的 Apple ID"**
5. 在弹出的确认框点击**信任**

### 6.3 运行到真机

1. Xcode 顶部选择你的 iPhone 作为目标设备
2. 点击 ▶ 运行（或 `⌘ + R`）
3. App 安装完成后自动启动

### 6.4 授权通知权限（真机）

首次启动时 App 会弹出通知授权弹窗：
- 点击**允许**以接收待办事项提醒
- 若误点了"不允许"，可在 **设置 → TodoApp → 通知** 中手动开启

> 📝 注意：免费开发者账号安装的 App 有效期为 **7 天**，到期后需要重新连接 Xcode 运行一次以刷新证书。

---

## 第七步：功能验证清单

运行成功后，依次验证以下功能：

**基础功能**
- [ ] 新建事项，填写标题、优先级、截止日期
- [ ] 列表显示事项，优先级图标颜色正确
- [ ] 左滑删除事项；右滑切换完成状态
- [ ] 编辑事项，修改内容后保存
- [ ] 标签管理：新建、改色、重命名、删除标签
- [ ] 标签过滤：顶部过滤条筛选事项

**提醒通知**
- [ ] 新建事项，开启提醒，设置 2 分钟后
- [ ] 按 Home 键回到后台
- [ ] 2 分钟后收到推送通知，标题为事项名称
- [ ] 编辑事项修改提醒时间，通知正确更新（旧通知取消，新通知调度）
- [ ] 关闭提醒 Toggle 保存，通知取消（可在 Xcode → Debug → Simulate Push 验证）

**日历视图**
- [ ] Tab 2 打开日历，当前月份正确显示
- [ ] 有截止日期事项的日期格显示彩色圆点
- [ ] 点击日期，下方列出当日事项
- [ ] 左右箭头切换月份，"今天"按钮回到当月
- [ ] 日历页 + 按钮，新建事项预填了当前选中日期

**概览仪表板**
- [ ] Tab 3 统计卡片数字与实际数据吻合
- [ ] 优先级分布进度条正确反映比例
- [ ] 近 7 天趋势柱状图显示完成数据
- [ ] 即将到期事项列表正确（未来 3 天内）

---

## 第八步：常见问题排查

### 问题 1：编译报错"No such module 'SwiftData'"

**原因**：Deployment Target 低于 iOS 17  
**解决**：
1. 选中 Targets → TodoApp → General
2. 将 **Minimum Deployments** 改为 **iOS 17.0**

### 问题 2：编译报错"No such module 'Charts'"

**原因**：Swift Charts 要求 iOS 16+，但应已包含在 iOS 17+ SDK 中  
**解决**：确认 Minimum Deployments 为 iOS 17.0，重新编译

### 问题 3："Signing certificate ... is not valid"

**解决**：
1. Xcode → Signing & Capabilities
2. 点击 **Automatically manage signing** 旁的刷新
3. 或删除 `~/Library/MobileDevice/Provisioning Profiles/` 目录后重试

### 问题 4：模拟器白屏或崩溃

**解决**：
1. 模拟器菜单 **Device → Erase All Content and Settings...**
2. 重新运行 App

### 问题 5："Bundle Identifier" 已被占用

**解决**：修改 Bundle Identifier 加上随机后缀，如 `com.yourname.TodoApp.v2`

### 问题 6：真机显示"无法安装，需要升级"

**原因**：手机系统版本低于 App 的 Minimum Deployment Target  
**解决**：将 Minimum Deployments 降低到与手机系统版本匹配，或升级手机系统

### 问题 7：设置了提醒但收不到通知

排查步骤：
1. 确认已允许通知权限：**设置 → TodoApp → 通知 → 允许通知**（打开）
2. 确认提醒时间设置在**未来**（编辑页有黄色警告提示如果时间已过）
3. 确认 App 已进入后台（回到主屏幕），前台状态下通知默认不显示横幅
4. 模拟器中可在 `Features → Simulate Push Notification` 触发测试

---

## 第九步：打包 IPA 文件（可选）

如需将 App 分发给其他人测试（需要付费开发者账号 $99/年）：

1. 连接设备或选择 **Any iOS Device**
2. 菜单 **Product → Archive**（需选择真机目标，不能是模拟器）
3. 打包完成后，Organizer 窗口自动打开
4. 选中最新的 Archive → 点击 **Distribute App**
5. 选择分发方式：
   - **TestFlight**：通过 App Store Connect 内测
   - **Ad Hoc**：直接安装到已注册的设备
   - **App Store Connect**：正式上架 App Store

---

## 快捷键速查

| 操作 | 快捷键 |
|------|--------|
| 运行 | `⌘ + R` |
| 停止运行 | `⌘ + .` |
| 编译 | `⌘ + B` |
| 清除编译缓存 | `⌘ + Shift + K` |
| 打开文件 | `⌘ + Shift + O` |
| 格式化代码 | `⌘ + A` 全选，再 `Ctrl + I` |
| 显示/隐藏 Canvas 预览 | `⌘ + Option + Return` |
| 刷新 Canvas 预览 | `⌘ + Option + P` |

---

## 项目文件结构说明

```
TodoApp/
├── TodoApp.xcodeproj/               ← Xcode 项目文件（双击此文件打开）
└── TodoApp/
    ├── TodoAppApp.swift              ← App 入口，SwiftData 容器初始化，请求通知权限
    ├── ContentView.swift             ← TabView 根视图（三个 Tab）
    ├── Models/
    │   ├── TodoItem.swift            ← 待办事项数据模型（含提醒字段）
    │   └── Tag.swift                 ← 标签数据模型
    ├── ViewModels/
    │   ├── TodoListViewModel.swift   ← 列表过滤/搜索/排序逻辑
    │   ├── TodoDetailViewModel.swift ← 编辑状态管理与通知调度
    │   └── TagViewModel.swift        ← 标签管理逻辑
    ├── Services/
    │   └── NotificationService.swift ← 本地通知封装（权限、调度、取消）
    ├── Views/
    │   ├── TodoList/
    │   │   ├── TodoListView.swift    ← 主列表页
    │   │   ├── TodoRowView.swift     ← 列表行组件（含铃铛图标）
    │   │   └── FilterBarView.swift  ← 标签过滤条
    │   ├── TodoDetail/
    │   │   ├── TodoDetailView.swift  ← 详情页（完整时间戳+提醒信息）
    │   │   └── TodoEditView.swift    ← 新建/编辑页（含提醒设置）
    │   ├── Tags/
    │   │   ├── TagListView.swift     ← 标签管理页
    │   │   ├── TagPickerView.swift   ← 标签选择器
    │   │   └── TagChipView.swift     ← 标签胶囊组件
    │   ├── Calendar/
    │   │   ├── CalendarView.swift    ← 日历主页面（月视图 + 日事项列表）
    │   │   └── CalendarGridView.swift ← 月历网格（日期格 + 圆点标记）
    │   └── Overview/
    │       └── OverviewView.swift    ← 概览仪表板（统计+图表+即将到期）
    ├── Utilities/
    │   ├── Color+Extensions.swift   ← 颜色工具
    │   └── DateFormatter+Extensions.swift ← 日期工具
    └── Preview Content/
        └── PreviewData.swift        ← SwiftUI 预览数据
```
