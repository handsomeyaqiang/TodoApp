import SwiftUI
import SwiftData

@main
struct TodoAppApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: TodoItem.self, Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("SwiftData 初始化失败: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await NotificationService.shared.requestAuthorization()
                }
        }
        .modelContainer(container)
    }
}
