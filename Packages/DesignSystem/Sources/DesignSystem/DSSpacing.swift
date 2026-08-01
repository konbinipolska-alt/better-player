import CoreGraphics

/// Spacing scale on a 4pt base. Use tokens instead of raw numbers in layouts.
public enum DSSpacing {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    public static let xxxl: CGFloat = 48
}

/// Corner radii.
public enum DSRadius {
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let card: CGFloat = 20
    /// Fully rounded (pill / capsule).
    public static let pill: CGFloat = 999
}

/// Hairline / border widths.
public enum DSStroke {
    public static let hairline: CGFloat = 0.5
    public static let regular: CGFloat = 1
}
