# TodoApp

一款基于 SwiftUI + SwiftData 构建的 iOS 待办事项管理 App，支持增删改查、多标签管理、标签搜索过滤、本地推送提醒、日历视图与数据概览，数据完全本地存储。

---

## 功能概览

### 待办事项管理

| 功能 | 说明 |
|------|------|
| 新建事项 | 填写标题（必填）、备注、优先级、截止日期、提醒时间、标签 |
| 编辑事项 | 修改任意字段，保存后自动更新 `updatedAt` 时间戳 |
| 删除事项 | 列表左滑删除，同步取消已设置的提醒通知 |
| 完成/恢复 | 列表右滑或点击行首圆圈切换完成状态，完成条目显示删除线 |
| 优先级 | 三档：低 / 中 / 高，分别对应绿 / 橙 / 红色图标 |
| 截止日期 | 可选设置；逾期未完成的条目日期文字变红提示 |
| 提醒时间 | 可单独设置提醒时刻（精确到分钟），已设置提醒的事项行内显示铃铛图标 |

### 本地推送提醒

| 功能 | 说明 |
|------|------|
| 设置提醒 | 编辑页 Toggle 开启，选择具体日期和时间（精确到分钟） |
| 默认时间 | 若已设截止日期，默认提醒时间为截止日当天 09:00；否则为当前时间 + 1 小时 |
| 推送通知 | App 在后台或锁屏状态下到时推送，点击通知可跳回 App |
| 自动取消 | 关闭提醒 Toggle 或删除事项时，自动取消对应的待发通知 |
| 幂等调度 | 修改提醒时间保存后，自动撤销旧通知并调度新通知 |

### 标签系统

| 功能 | 说明 |
|------|------|
| 创建标签 | 输入名称 + 选择颜色（预设 8 色 + 自定义 ColorPicker） |
| 重命名标签 | 在标签管理页点击条目进入编辑 Sheet |
| 改变颜色 | 编辑 Sheet 内实时预览新颜色 |
| 删除标签 | 左滑删除；删除标签不会删除任何待办事项 |
| 名称唯一性 | 大小写不敏感，重复名称会提示错误 |
| 多对多关系 | 一个事项可挂多个标签，一个标签可关联多个事项 |

### 搜索与过滤

| 功能 | 说明 |
|------|------|
| 关键词搜索 | 实时匹配事项标题、备注内容、标签名称 |
| 标签过滤 | 顶部过滤条点选一个或多个标签，取**并集**过滤 |
| 清除过滤 | 过滤条末尾"清除"按钮一键重置 |
| 隐藏已完成 | 菜单中可切换是否显示已完成事项 |

### 排序

在事项列表右上角菜单中可按以下方式排序：

| 排序方式 | 规则 |
|------|------|
| 创建时间（默认） | 最新创建的在最上方 |
| 截止日期 | 最近截止的在最上方，无截止日期的排最后 |
| 优先级 | 高 → 中 → 低 |
| 标题 | 按字母/拼音升序 |

### 日历视图

| 功能 | 说明 |
|------|------|
| 月历网格 | 展示整月日历，含星期表头 |
| 事项圆点 | 有截止日期事项的日期格上显示优先级颜色圆点（最多 3 个） |
| 今天高亮 | 今日日期蓝色描边圆；选中日期蓝色填充圆 |
| 月份切换 | 顶部左右箭头翻月，"今天"按钮快速回到当月 |
| 日事项列表 | 点击日期后，下方列出该日所有到期事项，支持完成和删除操作 |
| 快速新建 | 右上角 + 按钮新建事项，自动预填当前选中日期为截止日期 |

### 概览仪表板

| 模块 | 说明 |
|------|------|
| 统计卡片 | 全部事项数、今日到期数、已完成数（含完成率）、逾期未完成数 |
| 优先级分布 | 高 / 中 / 低各优先级待完成事项的横向比例进度条 |
| 7 天完成趋势 | 用 Swift Charts 柱状图展示近 7 天每日完成事项数 |
| 即将到期 | 列出未来 3 天内到期的未完成事项，点击可进入详情 |

---

## 导航结构

```
TabView（底部 Tab 栏）
├── Tab 1：事项（checklist）
│   └── TodoListView（NavigationStack）
│       ├── FilterBarView（顶部标签过滤条）
│       ├── + → TodoEditView（新建 Sheet）
│       ├── 菜单 → 排序 / 显示已完成 / 管理标签
│       │         └── TagListView → AddTagSheet / EditTagSheet
│       └── 列表行 → TodoDetailView
│                       └── 编辑 → TodoEditView（编辑 Sheet）
│
├── Tab 2：日历（calendar）
│   └── CalendarView（NavigationStack）
│       ├── CalendarGridView（月历网格）
│       ├── 选中日事项列表 → TodoDetailView
│       └── + → TodoEditView（预填截止日期）
│
└── Tab 3：概览（chart.bar.fill）
    └── OverviewView（NavigationStack）
        └── 即将到期列表行 → TodoDetailView
```

---

## 技术栈

| 组件 | 版本 / 说明 |
|------|------------|
| Swift | 5.9+（使用 `@Observable`、`@Model`、`#Predicate`） |
| SwiftUI | iOS 17+ 原生 UI 框架 |
| SwiftData | iOS 17+ 苹果官方本地持久化框架 |
| Swift Charts | iOS 16+ 内置图表框架（柱状图趋势） |
| UserNotifications | iOS 10+ 本地推送通知框架 |
| 架构 | MVVM，ViewModel 使用 `@Observable`，View 使用 `@Query` |
| 第三方依赖 | 无 |
| 最低 iOS | 17.0 |

---

## 项目结构

```
TodoApp/
├── TodoAppApp.swift                     # @main 入口，ModelContainer 初始化，请求通知权限
├── ContentView.swift                    # TabView 根视图（三个 Tab）
│
├── Models/
│   ├── TodoItem.swift                   # 待办事项数据模型（含提醒字段）
│   └── Tag.swift                        # 标签数据模型
│
├── ViewModels/
│   ├── TodoListViewModel.swift          # 列表过滤、排序、搜索、删除逻辑
│   ├── TodoDetailViewModel.swift        # 编辑态临时状态、保存与通知调度逻辑
│   └── TagViewModel.swift              # 标签 CRUD 逻辑
│
├── Services/
│   └── NotificationService.swift       # UserNotifications 封装（权限、调度、取消）
│
├── Views/
│   ├── TodoList/
│   │   ├── TodoListView.swift           # 主列表页面
│   │   ├── TodoRowView.swift            # 单行 Cell 组件（含铃铛图标）
│   │   └── FilterBarView.swift          # 顶部标签过滤横向滚动条
│   ├── TodoDetail/
│   │   ├── TodoDetailView.swift         # 详情只读页面（完整时间戳+提醒展示）
│   │   └── TodoEditView.swift           # 新建 / 编辑表单 Sheet（含提醒设置）
│   ├── Tags/
│   │   ├── TagListView.swift            # 标签管理页面
│   │   ├── TagPickerView.swift          # 编辑表单内嵌标签多选器
│   │   └── TagChipView.swift            # 可复用标签胶囊组件
│   ├── Calendar/
│   │   ├── CalendarView.swift           # 日历主页面（月视图 + 日事项列表）
│   │   └── CalendarGridView.swift       # 月历网格组件（日期格子 + 圆点标记）
│   └── Overview/
│       └── OverviewView.swift           # 概览仪表板（统计卡片 + 图表 + 即将到期）
│
├── Utilities/
│   ├── Color+Extensions.swift           # Hex 字符串 ↔ Color 转换，预设色盘
│   └── DateFormatter+Extensions.swift   # 日期格式化与逾期判断
│
└── Preview Content/
    └── PreviewData.swift                # SwiftUI Canvas 预览用内存数据
```

---

## 数据模型

### TodoItem

```swift
@Model final class TodoItem {
    var id: UUID                    // 唯一标识
    var title: String               // 标题（必填，不可为空）
    var notes: String               // 备注（可为空字符串）
    var isCompleted: Bool           // 是否已完成
    var priorityRaw: Int            // 优先级原始值（0=低 1=中 2=高）
    var dueDate: Date?              // 截止日期（可选）
    var reminderDate: Date?         // 提醒时间（可选，精确到分钟）
    var notificationID: String?     // 对应的 UNNotificationRequest identifier
    var createdAt: Date             // 创建时间（自动设置）
    var updatedAt: Date             // 最后更新时间（保存时手动更新）
    var tags: [Tag]                 // 关联标签（多对多，deleteRule: .nullify）

    var priority: TodoItem.Priority // 优先级枚举（存取器代理 priorityRaw）
}
```

**Priority 枚举**

```swift
enum Priority: Int, Codable, CaseIterable {
    case low    = 0   // 低优先级，绿色，arrow.down.circle 图标
    case medium = 1   // 中优先级，橙色，minus.circle 图标
    case high   = 2   // 高优先级，红色，exclamationmark.circle 图标
}
```

| 属性 | 类型 | 说明 |
|------|------|------|
| `label` | `String` | "低" / "中" / "高" |
| `color` | `Color` | `.green` / `.orange` / `.red` |
| `systemImage` | `String` | SF Symbols 图标名 |

### Tag

```swift
@Model final class Tag {
    var id: UUID                    // 唯一标识
    var name: String                // 标签名（大小写不敏感唯一）
    var colorHex: String            // 颜色，格式 "#RRGGBB"
    var createdAt: Date             // 创建时间（自动设置）
    var todoItems: [TodoItem]       // 关联事项（多对多 inverse 侧，deleteRule: .nullify）

    var color: Color                // 计算属性，由 colorHex 转换
}
```

**关系说明**

```
TodoItem ←——多对多——→ Tag
  deleteRule: .nullify     deleteRule: .nullify
```

删除事项 → 标签不受影响；删除标签 → 事项不受影响，仅移除关联。

---

## 接口说明

### TodoListViewModel

列表页的状态管理与数据处理，通过 `@Observable` 驱动 UI 更新。

```swift
@MainActor @Observable final class TodoListViewModel
```

**状态属性**

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `searchText` | `String` | `""` | 搜索关键词，实时过滤 |
| `selectedTags` | `Set<PersistentIdentifier>` | `[]` | 当前激活的标签过滤集合 |
| `sortOrder` | `SortOrder` | `.byCreatedDate` | 当前排序方式 |
| `showCompleted` | `Bool` | `true` | 是否显示已完成事项 |

**方法**

```swift
// 对 @Query 返回的原始数组应用过滤、搜索、排序，返回处理后数组
func filteredItems(_ allItems: [TodoItem]) -> [TodoItem]

// 切换某标签的激活状态（已选则取消，未选则选中）
func toggleTag(_ tag: Tag)

// 判断某标签是否处于选中状态
func isTagSelected(_ tag: Tag) -> Bool

// 清空所有标签过滤
func clearTagFilter()

// 切换事项完成状态，同步更新 updatedAt
func toggleCompletion(_ item: TodoItem)

// 批量删除事项，同步取消关联通知
func deleteItems(_ items: [TodoItem], context: ModelContext)
```

---

### TodoDetailViewModel

新建/编辑事项表单的临时状态持有者，与 `TodoEditView` 绑定。

```swift
@MainActor @Observable final class TodoDetailViewModel
```

**状态属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `title` | `String` | 事项标题（绑定到 TextField） |
| `notes` | `String` | 备注（绑定到 TextEditor） |
| `priority` | `TodoItem.Priority` | 优先级（存取器代理 `priorityRaw`） |
| `dueDate` | `Date` | 截止日期（仅 `hasDueDate == true` 时有效） |
| `hasDueDate` | `Bool` | 是否启用截止日期（绑定到 Toggle） |
| `reminderDate` | `Date` | 提醒时间（仅 `hasReminder == true` 时有效） |
| `hasReminder` | `Bool` | 是否启用提醒（绑定到 Toggle） |
| `selectedTags` | `[Tag]` | 已选标签列表 |
| `isValid` | `Bool` | 标题非空则为 `true`，控制保存按钮可用性 |

**方法**

```swift
// 用已有 TodoItem 填充表单（用于编辑模式）
func populate(from item: TodoItem)

// 保存：existingItem 非 nil 则更新，nil 则新建并 insert 到 context
// 内部自动调用 NotificationService 调度或取消通知
func save(existingItem: TodoItem?, context: ModelContext)

// 计算默认提醒时间（截止日当天 09:00，或当前时间 + 1 小时）
func defaultReminderDate() -> Date
```

---

### TagViewModel

标签的创建、删除、重命名逻辑封装。

```swift
@MainActor @Observable final class TagViewModel
```

**状态属性**

| 属性 | 类型 | 说明 |
|------|------|------|
| `newTagName` | `String` | 待创建标签的名称输入 |
| `newTagColorHex` | `String` | 待创建标签的颜色（`#RRGGBB`） |
| `newTagColor` | `Color` | `newTagColorHex` 的 Color 存取器 |
| `errorMessage` | `String?` | 操作失败时的提示文本（如名称重复） |

**方法**

```swift
// 创建新标签；名称去空白、大小写不敏感重复检查，成功后重置输入状态
func createTag(context: ModelContext, allTags: [Tag])

// 删除指定标签（context.delete，关联事项不受影响）
func deleteTag(_ tag: Tag, context: ModelContext)

// 重命名标签；跳过自身，大小写不敏感重复检查
func renameTag(_ tag: Tag, to name: String, allTags: [Tag])
```

---

### NotificationService

UserNotifications 框架的单例封装，负责权限请求、通知调度与取消。

```swift
final class NotificationService: @unchecked Sendable
static let shared: NotificationService
```

**方法**

```swift
// 请求通知权限（alert + sound + badge），返回是否授权
// 若权限已决定（授权或拒绝）则直接返回当前状态
@discardableResult
func requestAuthorization() async -> Bool

// 为 TodoItem 调度本地通知（幂等：先取消旧通知再创建）
// reminderDate 必须在未来，否则返回 nil
// 返回新的 notificationID，调用方应写回 item.notificationID
@discardableResult
func scheduleNotification(for item: TodoItem) async -> String?

// 取消单个待发通知（通过 notificationID）
func cancelNotification(id: String)

// 批量取消待发通知（删除多个事项时调用）
func cancelNotifications(ids: [String])
```

**通知内容格式**

| 字段 | 内容 |
|------|------|
| `title` | 事项标题 |
| `body` | 备注前 60 字，若备注为空则显示 "待办事项提醒" |
| `sound` | `.default` |
| `trigger` | `UNCalendarNotificationTrigger`（精确到分钟，不重复） |
| `userInfo` | `["itemID": item.id.uuidString]` |

---

### Color 扩展（`Color+Extensions.swift`）

```swift
// 从 Hex 字符串构造 Color，支持 "#RGB" 和 "#RRGGBB" 两种格式，失败返回 nil
init?(hex: String)

// 将 Color 转为 "#RRGGBB" 格式字符串（通过 UIColor 桥接）
func toHex() -> String

// 预设的 8 种标签颜色（Apple HIG 标准色）
static let tagColors: [Color]
```

---

### Date 扩展（`DateFormatter+Extensions.swift`）

```swift
// 是否已逾期（self < .now）
var isOverdue: Bool

// 友好显示字符串：今天 / 明天 / 昨天 / 具体日期（中等长度格式）
var todoDisplayString: String

// 共享 DateFormatter 实例（dateStyle: .medium, timeStyle: .none）
static let todoDisplay: DateFormatter
```

---

### Calendar 扩展（`CalendarView.swift` 内）

```swift
// 获取指定日期所在月份的第一天（0 时 0 分 0 秒）
func startOfMonth(for date: Date) -> Date
```

---

## 数据持久化

- 使用 **SwiftData** 框架，数据存储在设备沙盒的 SQLite 数据库中
- `ModelContainer` 在 `TodoAppApp.swift` 的 `init()` 中初始化，通过 `.modelContainer()` 注入全局 SwiftUI 环境
- 所有写操作（insert / delete / 属性修改）在 `@MainActor` 上执行，由 SwiftData 自动持久化，无需手动调用 `save()`
- `notificationID` 字段与 `UNUserNotificationCenter` 的 pending requests 保持同步；App 被杀进程后通知由系统接管仍可正常触发

---

## 权限说明

| 权限 | 用途 | 申请时机 |
|------|------|---------|
| 通知权限（`UNAuthorizationOptions`） | 发送本地提醒推送 | App 首次启动时通过系统弹窗请求 |

本地通知无需远程推送证书，不需要在 Info.plist 中添加额外 Key，也不需要开启 Push Notifications capability。

---

## 本地运行 & 真机部署

详见 [TodoApp_Deploy_Guide.md](./TodoApp_Deploy_Guide.md)，包含：

- Xcode 安装与版本要求
- 项目创建与源码导入步骤（含新增 `Services/` 和 `Views/Calendar/`、`Views/Overview/` 目录）
- Apple ID 签名配置
- 模拟器运行（`⌘+R`）
- 真机安装与开发者证书信任
- 通知权限配置说明
- 常见问题排查
- IPA 打包与分发
