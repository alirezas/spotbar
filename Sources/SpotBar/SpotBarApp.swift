import SwiftUI

@main
struct SpotBarApp: App {
    @StateObject private var menuBarController = MenuBarController()
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
