import UIKit

/// Defines the global appearance for the application.
struct Appearance {
    /// Sets the global appearance for the application.
    /// Call this method early in the applicaiton's setup, i.e. in `applicationDidFinishLaunching:`
    static func setup() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor(named: "primaryColor")!
        UINavigationBar.appearance().tintColor = UIColor(named: "primaryTextColor")!
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "primaryTextColor")!]
        UISegmentedControl.appearance().tintColor = UIColor(named: "primaryTextColor")!
    }
}
