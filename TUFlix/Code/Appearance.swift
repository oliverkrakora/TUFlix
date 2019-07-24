import UIKit

/// Defines the global appearance for the application.
struct Appearance {
    
    static private(set)var toggleToolbarLabelColor: UIColor!
    /// Sets the global appearance for the application.
    /// Call this method early in the applicaiton's setup, i.e. in `applicationDidFinishLaunching:`
    static func setup() {
//        setupBrandingAppeareance()
        setupWhiteAppeareanceWithPrimaryTint()
    }
    
    private static func setupBrandingAppeareance() {
        // NavigationBar
        UINavigationBar.appearance().barTintColor = Asset.primaryColor.color
        UINavigationBar.appearance().tintColor = Asset.primaryTextColor.color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.primaryTextColor.color]
        UINavigationBar.appearance().isTranslucent = false
        
        // SegmentedControl
        UISegmentedControl.appearance().tintColor = Asset.primaryTextColor.color
        
        //SearchBar
        UISearchBar.appearance().tintColor = .white
        
        //TabBar
        UITabBar.appearance().tintColor = Asset.primaryTextColor.color
        UITabBar.appearance().barTintColor = Asset.primaryColor.color
        UITabBar.appearance().isTranslucent = false
        
        //Toolbar
        UIToolbar.appearance().tintColor = Asset.primaryColor.color
        UIToolbar.appearance().barTintColor = Asset.primaryTextColor.color
        UIToolbar.appearance().isTranslucent = false
        toggleToolbarLabelColor = .white
    }
    
    private static func setupWhiteAppeareanceWithPrimaryTint() {
        // NavigationBar
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = Asset.primaryColor.color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.primaryColor.color]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .default
        
        // SegmentedControl
        UISegmentedControl.appearance().tintColor = Asset.primaryColor.color
        
        //SearchBar
        UISearchBar.appearance().tintColor = Asset.primaryColor.color
        UISearchBar.appearance().barStyle = .default
        
        //TabBar
        UITabBar.appearance().tintColor = Asset.primaryColor.color
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().isTranslucent = false
        
        //Toolbar
        UIToolbar.appearance().tintColor = Asset.primaryColor.color
        UIToolbar.appearance().barTintColor = .white
        UIToolbar.appearance().isTranslucent = false
        UIToolbar.appearance().barStyle = .default
        toggleToolbarLabelColor = .black
    }
}
