import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.09, blue: 0.11, alpha: 1)
            : UIColor(red: 1, green: 0.96, blue: 0.97, alpha: 1)
    })
    static let babyPink = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.29, green: 0.16, blue: 0.21, alpha: 1)
            : UIColor(red: 1, green: 0.86, blue: 0.90, alpha: 1)
    })
    static let accent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1, green: 0.66, blue: 0.76, alpha: 1)
            : UIColor(red: 0.61, green: 0.20, blue: 0.34, alpha: 1)
    })
}
