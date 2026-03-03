import Foundation

public enum UIStateRole: String, CaseIterable, Sendable {
    case neutral
    case active
    case success
    case error
    case disabled
}

public struct TypographyScale: Equatable, Sendable {
    public let title: Double
    public let label: Double
    public let input: Double
    public let primaryAction: Double
    public let secondaryAction: Double

    public init(title: Double,
                label: Double,
                input: Double,
                primaryAction: Double,
                secondaryAction: Double) {
        self.title = title
        self.label = label
        self.input = input
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}

public struct SpacingScale: Equatable, Sendable {
    public let windowPadding: Double
    public let sectionGap: Double
    public let fieldGap: Double
    public let actionGap: Double

    public init(windowPadding: Double,
                sectionGap: Double,
                fieldGap: Double,
                actionGap: Double) {
        self.windowPadding = windowPadding
        self.sectionGap = sectionGap
        self.fieldGap = fieldGap
        self.actionGap = actionGap
    }
}

public struct FolderAffordanceStyle: Equatable, Sendable {
    public let iconVisible: Bool
    public let actionLabel: String

    public init(iconVisible: Bool, actionLabel: String) {
        self.iconVisible = iconVisible
        self.actionLabel = actionLabel
    }
}

public struct VisualStateStyle: Equatable, Sendable {
    public let role: UIStateRole
    public let nonColorCue: String

    public init(role: UIStateRole, nonColorCue: String) {
        self.role = role
        self.nonColorCue = nonColorCue
    }
}

public enum UIStyle {
    public static let typography = TypographyScale(
        title: 16,
        label: 13,
        input: 14,
        primaryAction: 13,
        secondaryAction: 12
    )

    public static let spacing = SpacingScale(
        windowPadding: 16,
        sectionGap: 12,
        fieldGap: 8,
        actionGap: 8
    )

    public static let folderAffordance = FolderAffordanceStyle(
        iconVisible: false,
        actionLabel: "Choisir le dossier..."
    )

    public static let states: [UIStateRole: VisualStateStyle] = [
        .neutral: VisualStateStyle(role: .neutral, nonColorCue: ""),
        .active: VisualStateStyle(role: .active, nonColorCue: "Disponible"),
        .success: VisualStateStyle(role: .success, nonColorCue: "Succes"),
        .error: VisualStateStyle(role: .error, nonColorCue: "Erreur"),
        .disabled: VisualStateStyle(role: .disabled, nonColorCue: "Indisponible")
    ]

    public static func stateStyle(for role: UIStateRole) -> VisualStateStyle {
        states[role] ?? VisualStateStyle(role: role, nonColorCue: "")
    }
}
