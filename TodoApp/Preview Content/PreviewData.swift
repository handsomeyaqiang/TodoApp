import SwiftData
import SwiftUI

@MainActor
struct PreviewData {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: TodoItem.self, Tag.self, configurations: config)
        let ctx = c.mainContext

        let work = Tag(name: "工作", colorHex: "#007AFF")
        let personal = Tag(name: "个人", colorHex: "#34C759")
        let urgent = Tag(name: "紧急", colorHex: "#FF3B30")
        ctx.insert(work); ctx.insert(personal); ctx.insert(urgent)

        let t1 = TodoItem(title: "完成 Q2 报告", notes: "需要包含数据分析部分", priority: .high, dueDate: Date())
        t1.tags = [work, urgent]
        ctx.insert(t1)

        let t2 = TodoItem(title: "买菜", notes: "苹果、牛奶、鸡蛋", priority: .medium)
        t2.tags = [personal]
        ctx.insert(t2)

        let t3 = TodoItem(title: "读书 30 分钟", priority: .low)
        t3.tags = [personal]
        ctx.insert(t3)

        let t4 = TodoItem(title: "代码 Review", notes: "审查 PR #42", priority: .high, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()))
        t4.tags = [work]
        ctx.insert(t4)

        let t5 = TodoItem(title: "已完成的任务示例", priority: .low)
        t5.isCompleted = true
        ctx.insert(t5)

        return c
    }()
}
