import SwiftUI

// MARK: - Primary pill button

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(Theme.Color.textOnPrimary)
                } else {
                    Text(title)
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.Color.textOnPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Theme.Color.primary.opacity(isEnabled ? 1 : 0.5))
            .clipShape(Capsule())
        }
        .disabled(!isEnabled || isLoading)
        .animation(Theme.Motion.quick, value: isLoading)
    }
}

// MARK: - Card container

struct Card<Content: View>: View {
    var padding: CGFloat = Theme.Spacing.lg
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .themeShadow(Theme.Shadow.card)
    }
}

// MARK: - Circular chevron button (settings rows)

struct CircleChevron: View {
    var systemName: String = "chevron.right"
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.Color.textOnPrimary)
            .frame(width: 28, height: 28)
            .background(Theme.Color.primary)
            .clipShape(Circle())
    }
}

// MARK: - Segmented pill toggle (Distributor / Customer, Distributor / Admin)

struct SegmentedPill: View {
    let options: [String]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                let isActive = selection == index
                Button {
                    withAnimation(Theme.Motion.spring) { selection = index }
                } label: {
                    Text(options[index])
                        .font(Theme.Font.subhead)
                        .foregroundStyle(isActive ? Theme.Color.primary : Theme.Color.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if isActive {
                                    Capsule().fill(Color.white)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.white.opacity(0.18)))
    }
}

// MARK: - State containers

struct LoadingView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView().controlSize(.large)
            Text("Loading…")
                .font(Theme.Font.footnote)
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 34))
                .foregroundStyle(Theme.Color.warning)
            Text(message)
                .font(Theme.Font.callout)
                .foregroundStyle(Theme.Color.textSecondary)
                .multilineTextAlignment(.center)
            if let retry {
                Button("Try Again", action: retry)
                    .font(Theme.Font.subhead)
                    .foregroundStyle(Theme.Color.primary)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let title: String
    var subtitle: String?
    var systemImage: String = "tray"

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 34))
                .foregroundStyle(Theme.Color.textSecondary)
            Text(title)
                .font(Theme.Font.headline)
                .foregroundStyle(Theme.Color.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(Theme.Font.footnote)
                    .foregroundStyle(Theme.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Async content wrapper

/// Renders loading/error/empty/loaded states from a `Loadable` value.
struct LoadableContent<Value, Content: View>: View {
    let state: Loadable<Value>
    var retry: (() -> Void)?
    var isEmpty: (Value) -> Bool = { _ in false }
    var emptyTitle: String = "Nothing here yet"
    @ViewBuilder var content: (Value) -> Content

    var body: some View {
        switch state {
        case .idle, .loading:
            LoadingView()
        case .failed(let error):
            ErrorStateView(message: error.userMessage, retry: retry)
        case .loaded(let value):
            if isEmpty(value) {
                EmptyStateView(title: emptyTitle)
            } else {
                content(value)
            }
        }
    }
}
