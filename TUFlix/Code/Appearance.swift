import UIKit

/// Defines the global appearance for the application.
struct Appearance {
    /// Sets the global appearance for the application.
    /// Call this method early in the applicaiton's setup, i.e. in `applicationDidFinishLaunching:`
    static func setup() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = Asset.primaryColor.color
        UINavigationBar.appearance().tintColor = Asset.primaryTextColor.color
        UISearchBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.primaryTextColor.color]
        UISegmentedControl.appearance().tintColor = Asset.primaryTextColor.color
    }
}
