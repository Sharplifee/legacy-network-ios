import SwiftUI

struct NetworkTreeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Network", load: {
            try await appState.data.networkTree()
        }) { root in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    NetworkNodeRow(node: root, depth: 0)
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        }
    }
}

/// Recursive expand/collapse row. Children present in the payload expand
/// inline; nodes flagged `hasChildren` without loaded children can be fetched
/// lazily (hook left for `Endpoint.networkNode`).
struct NetworkNodeRow: View {
    let node: NetworkNode
    let depth: Int
    @State private var expanded = false

    private var canExpand: Bool {
        (node.children?.isEmpty == false) || (node.hasChildren ?? false)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Theme.Spacing.sm) {
                if canExpand {
                    Button {
                        withAnimation(Theme.Motion.quick) { expanded.toggle() }
                    } label: {
                        Image(systemName: expanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.Color.textSecondary)
                            .frame(width: 20)
                    }
                } else {
                    Spacer().frame(width: 20)
                }

                Avatar(url: node.avatarURL, name: node.name)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(node.name).font(Theme.Font.body)
                    if let rank = node.rank {
                        Text(rank).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                    }
                }
                Spacer()
                if let total = node.totalCount {
                    Text("\(total)")
                        .font(Theme.Font.subhead)
                        .foregroundStyle(Theme.Color.primary)
                }
            }
            .padding(.vertical, Theme.Spacing.sm)
            .padding(.leading, CGFloat(depth) * Theme.Spacing.lg)

            if expanded, let children = node.children {
                ForEach(children) { child in
                    NetworkNodeRow(node: child, depth: depth + 1)
                }
            }
        }
    }
}
