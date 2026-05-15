import SwiftUI
import SwiftData  
struct ContentView: View {
    var body: some View {
        TabView {
            TodoListView()
                .tabItem {
                    Label("事项", systemImage: "checklist")
                }

            CalendarView()
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }

            OverviewView()
                .tabItem {
                    Label("概览", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
