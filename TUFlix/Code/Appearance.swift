import UIKit

/// Defines the global appearance for the application.
struct Appearance {
    /// Sets the global appearance for the application.
    /// Call this method early in the applicaiton's setup, i.e. in `applicationDidFinishLaunching:`
    static func setup() {
        
        // NavigationBar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = Asset.primaryColor.color
        UINavigationBar.appearance().tintColor = Asset.primaryTextColor.color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.primaryTextColor.color]
        
        // SegmentedControl
        UISegmentedControl.appearance().tintColor = Asset.primaryTextColor.color
        
        //SearchBar
        UISearchBar.appearance().tintColor = .white
        
        //TabBar
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().barTintColor = Asset.primaryColor.color
        UITabBar.appearance().isTranslucent = false
        
        //Toolbar
        UIToolbar.appearance().tintColor = .white
        UIToolbar.appearance().barTintColor = Asset.primaryColor.color
        UIToolbar.appearance().isTranslucent = false
    }
}
