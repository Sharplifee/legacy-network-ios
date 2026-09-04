import SwiftUI
import Charts

// MARK: - Palette (Legacy Network real tokens)
enum LN {
    static let blue      = Color(red: 0.192, green: 0.443, blue: 0.800) // #3171CC
    static let blueField = Color(red: 0.306, green: 0.525, blue: 0.839) // #4E86D6
    static let dark      = Color(red: 0.098, green: 0.110, blue: 0.133) // #191C22
    static let dark2     = Color(red: 0.126, green: 0.141, blue: 0.172) // #20242C
    static let bg        = Color(red: 0.957, green: 0.965, blue: 0.973) // #F4F6F8
    static let ink       = Color(red: 0.106, green: 0.118, blue: 0.137) // #1B1E23
    static let mut       = Color(red: 0.541, green: 0.580, blue: 0.651) // #8A94A6
    static let yellow    = Color(red: 0.957, green: 0.718, blue: 0.251) // #F4B740
    static let red       = Color(red: 0.898, green: 0.204, blue: 0.239)
    static let line      = Color(red: 0.918, green: 0.929, blue: 0.949)
}

// MARK: - Data (real, captured live from api.legacynetwork.com as Dianne Leavitt / Synergy 180555)
struct LNSubPoint: Identifiable { let id = UUID(); let month: String; let total: Double; let subscribed: Double; let unsub: Double }
struct LNEvent: Identifiable { let id = UUID(); let name: String; let when: String; let venue: String }
struct LNTraining: Identifiable { let id = UUID(); let title: String; let rank: Int; let lessons: Int; let desc: String }
struct LNCampaign: Identifiable { let id = UUID(); let name: String; let desc: String }
struct LNGoal: Identifiable { let id = UUID(); let title: String; let category: String; let due: String }
struct LNNav: Identifiable { let id = UUID(); let label: String; let icon: String; let key: String }

enum LNData {
    static let name = "Dianne Leavitt"
    static let synergy = "180555"
    static let tier = "Pro"
    static let city = "Orem, UT"

    static let subs: [LNSubPoint] = {
        let m = ["OCT","NOV","DEC","JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP"]
        let t: [Double] = [1,1,1,1,2,5,3,2,2,1,3,1]
        let s: [Double] = [0,0,1,0,1,3,1,1,1,0,2,0]
        let u: [Double] = [0,0,0,0,0,1,0,0,0,0,1,0]
        return (0..<12).map { LNSubPoint(month: m[$0], total: t[$0], subscribed: s[$0], unsub: u[$0]) }
    }()

    static let events: [LNEvent] = [
        .init(name: "ELITE HEALTH CHALLENGE CHECK-IN", when: "Tue 9/3 · 8:00pm MT", venue: "Online"),
        .init(name: "SPANISH BUSINESS PRESENTATION", when: "Wed 9/4 · 7:00pm MT", venue: "Online"),
        .init(name: "SPECIAL DINNER AND BUSINESS MEETING", when: "Wed 9/11 · 6:30pm MT", venue: "In person"),
        .init(name: "BUSINESS TRAINING", when: "Tue 9/17 · 8:00pm MT", venue: "Online"),
        .init(name: "LA OPORTUNIDAD DE LEGACY NETWORK", when: "Jue 9/19 · 7:00pm MT", venue: "Online"),
        .init(name: "CAPACITACIÓN ESPECIAL: PRESIDENTIAL", when: "Jue 9/19 · 8:10pm MT", venue: "Online"),
    ]

    static let training: [LNTraining] = [
        .init(title: "Welcome & Overview", rank: 1, lessons: 8, desc: "Welcome to Legacy Network! The first step in your new business is to learn."),
        .init(title: "Session 1: Business Foundation", rank: 8, lessons: 8, desc: "The components that support your business setup."),
        .init(title: "Session 2: My Health & Income Path", rank: 23, lessons: 6, desc: "Focus on your personal health and income goals."),
        .init(title: "Session 3: Inviting & Follow-Up", rank: 54, lessons: 7, desc: "Skills to interact with potential partners and follow up."),
        .init(title: "Session 4: Presenting", rank: 70, lessons: 5, desc: "How to present the opportunity with confidence."),
    ]

    static let campaigns: [LNCampaign] = [
        .init(name: "EHC (Elite Health Challenge)", desc: "Elite Health Challenge nurture sequence"),
        .init(name: "New Subscriber Welcome", desc: "Onboarding series for new subscribers"),
        .init(name: "Monthly Newsletter", desc: "General broadcast to all subscribers"),
    ]

    static let goals: [LNGoal] = [
        .init(title: "Reach Presidential Executive", category: "Rank", due: "Dec 2026"),
        .init(title: "Grow team to 50 active", category: "Team", due: "Jun 2026"),
        .init(title: "Complete all training sessions", category: "Personal", due: "Mar 2026"),
    ]

    static let nav: [LNNav] = [
        .init(label: "Dashboard", icon: "house.fill", key: "dashboard"),
        .init(label: "Email", icon: "envelope.fill", key: "email"),
        .init(label: "Events", icon: "calendar", key: "events"),
        .init(label: "Business Building", icon: "briefcase.fill", key: "business"),
        .init(label: "Training", icon: "lightbulb.fill", key: "training"),
        .init(label: "Store", icon: "cart.fill", key: "store"),
        .init(label: "Storage", icon: "folder.fill", key: "storage"),
        .init(label: "Achievements", icon: "trophy.fill", key: "achievements"),
        .init(label: "Settings", icon: "gearshape.fill", key: "settings"),
        .init(label: "Notifications", icon: "bell.fill", key: "notifications"),
        .init(label: "Log Out", icon: "rectangle.portrait.and.arrow.right", key: "logout"),
    ]
}

// MARK: - Root coordinator (splash -> login -> shell)
struct LNRoot: View {
    enum Stage { case splash, login, shell }
    @State private var stage: Stage = .splash
    var body: some View {
        ZStack {
            switch stage {
            case .splash: LNSplash().transition(.opacity)
            case .login:  LNLogin(onLogin: { withAnimation { stage = .shell } }).transition(.opacity)
            case .shell:  LNShell(onLogout: { withAnimation { stage = .login } }).transition(.opacity)
            }
        }
        .onAppear {
            if stage == .splash {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.easeInOut(duration: 0.4)) { stage = .login }
                }
            }
        }
    }
}

// MARK: - Splash
struct LNSplash: View {
    var body: some View {
        ZStack {
            LN.blue.ignoresSafeArea()
            VStack(spacing: 22) {
                Image("LegacyGlobe").resizable().renderingMode(.template)
                    .scaledToFit().frame(width: 120, height: 120).foregroundStyle(.white)
                Text("Legacy").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Login gate
struct LNLogin: View {
    var onLogin: () -> Void
    @State private var isDistributor = true
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        ZStack {
            LN.blue.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Image("LegacyGlobe").resizable().renderingMode(.template)
                            .scaledToFit().frame(width: 88, height: 88).foregroundStyle(.white)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LEGACY").font(.system(size: 42, weight: .heavy)).foregroundStyle(.white)
                            Text("network").font(.system(size: 18, weight: .light)).tracking(9).foregroundStyle(.white)
                        }
                    }
                    .padding(.top, 40).padding(.bottom, 50)

                    HStack(spacing: 0) {
                        segButton("Distributor", active: isDistributor) { isDistributor = true }
                        segButton("Customer", active: !isDistributor) { isDistributor = false }
                    }
                    .background(Color.white).clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                    .padding(.bottom, 28)

                    field("Email", text: $email, placeholder: "Email", icon: "envelope.fill", secure: false)
                    field("Password", text: $password, placeholder: "Password", icon: "eye.slash.fill", secure: true)

                    VStack(spacing: 16) {
                        link("Forgot Password?")
                        link("Never received Welcome Email?")
                        link("Never received Verification Email?")
                        link("Existing Synergy Team Member wanting to use the Legacy Network WebApp?")
                    }.padding(.top, 20)

                    Button(action: onLogin) {
                        Text("Log In").font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(Color(red: 0.25, green: 0.34, blue: 0.49))
                            .frame(maxWidth: .infinity).frame(height: 62)
                            .background(Color(red: 0.79, green: 0.84, blue: 0.94)).clipShape(Capsule())
                    }.padding(.top, 36)
                }
                .padding(.horizontal, 28).padding(.bottom, 40)
            }
        }
    }
    private func segButton(_ t: String, active: Bool, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Text(t).font(.system(size: 17, weight: .semibold))
                .foregroundStyle(active ? LN.blue : .white)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(active ? Color.white : LN.blue).clipShape(Capsule())
        }
    }
    private func field(_ label: String, text: Binding<String>, placeholder: String, icon: String, secure: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 17)).foregroundStyle(.white)
            HStack {
                Group {
                    if secure { SecureField("", text: text, prompt: Text(placeholder).foregroundColor(Color(white: 0.95))) }
                    else { TextField("", text: text, prompt: Text(placeholder).foregroundColor(Color(white: 0.95))).textInputAutocapitalization(.never).keyboardType(.emailAddress) }
                }
                .foregroundStyle(.white).italic().padding(.leading, 18)
                Spacer()
                Image(systemName: icon).foregroundStyle(.white).font(.system(size: 22)).padding(.trailing, 18)
            }
            .frame(height: 62).background(LN.blueField).clipShape(RoundedRectangle(cornerRadius: 12))
        }.padding(.bottom, 12)
    }
    private func link(_ t: String) -> some View {
        Text(t).font(.system(size: 16, weight: .medium)).foregroundStyle(.white)
            .multilineTextAlignment(.center).frame(maxWidth: .infinity)
    }
}

// MARK: - App shell with drawer
struct LNShell: View {
    var onLogout: () -> Void
    @State private var active = "dashboard"
    @State private var title = "Dashboard"
    @State private var drawerOpen = false
    var body: some View {
        ZStack(alignment: .leading) {
            LN.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                // top bar
                HStack {
                    Button { withAnimation(.easeOut(duration: 0.25)) { drawerOpen = true } } label: {
                        VStack(spacing: 5) { ForEach(0..<3) { _ in Capsule().fill(Color(red:0.29,green:0.56,blue:0.89)).frame(width: 26, height: 3) } }
                            .frame(width: 52, height: 46).background(LN.dark2).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Spacer()
                    avatar(56)
                }
                .padding(.horizontal, 18).padding(.vertical, 8)
                .background(LN.dark)

                // content
                ScrollView { LNPage(key: active).padding(16) }
            }

            if drawerOpen {
                Color.black.opacity(0.5).ignoresSafeArea()
                    .onTapGesture { withAnimation { drawerOpen = false } }
                LNDrawer(active: active) { key, label in
                    withAnimation { drawerOpen = false }
                    if key == "logout" { onLogout() } else { active = key; title = label }
                }
                .frame(width: 320).transition(.move(edge: .leading))
            }
        }
    }
}

func avatar(_ size: CGFloat) -> some View {
    Group {
        if let ui = UIImage(named: "Avatar") {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            ZStack { LN.blue; Text("DL").foregroundStyle(.white).font(.system(size: size*0.4, weight: .bold)) }
        }
    }
    .frame(width: size, height: size).clipShape(Circle())
    .overlay(Circle().stroke(Color(white: 0.2), lineWidth: 2))
}

// MARK: - Drawer
struct LNDrawer: View {
    let active: String
    var onSelect: (String, String) -> Void
    var body: some View {
        ZStack(alignment: .topLeading) {
            LN.dark.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack { Spacer(); avatar(64) }.padding(.horizontal, 20).padding(.top, 8)
                Text("BETA").font(.system(size: 14, weight: .heavy)).foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 5)
                    .background(LN.red).clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.leading, 20).padding(.vertical, 8)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(LNData.nav) { item in
                            Button { onSelect(item.key, item.label) } label: {
                                HStack(spacing: 20) {
                                    Image(systemName: item.icon).frame(width: 26).font(.system(size: 20))
                                    Text(item.label).font(.system(size: 19))
                                    Spacer()
                                }
                                .foregroundStyle(item.key == active ? Color(red:0.29,green:0.56,blue:0.89) : Color(red:0.68,green:0.71,blue:0.76))
                                .padding(.horizontal, 22).padding(.vertical, 19)
                                .background(item.key == active ? LN.dark2 : Color.clear)
                            }
                            Divider().overlay(LN.dark2)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Pages
struct LNPage: View {
    let key: String
    var body: some View {
        switch key {
        case "dashboard": LNDashboard()
        case "events": LNList(title: "Events", rows: LNData.events.map { ($0.name, "\($0.when) · \($0.venue)") }, icon: "calendar")
        case "training": LNList(title: "Training", rows: LNData.training.map { ($0.title, "Rank \($0.rank) · \($0.lessons) lessons") }, icon: "lightbulb.fill")
        case "email": LNList(title: "Email Campaigns", rows: LNData.campaigns.map { ($0.name, $0.desc) }, icon: "envelope.fill")
        case "business": LNList(title: "Business Building", rows: LNData.goals.map { ($0.title, "\($0.category) · due \($0.due)") }, icon: "briefcase.fill")
        default: LNPlaceholder(title: label(key), icon: icon(key))
        }
    }
    private func label(_ k: String) -> String { LNData.nav.first { $0.key == k }?.label ?? "Section" }
    private func icon(_ k: String) -> String { LNData.nav.first { $0.key == k }?.icon ?? "square.grid.2x2" }
}

struct LNCard<Content: View>: View {
    let title: String; @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.system(size: 22, weight: .bold)).foregroundStyle(LN.ink)
                Spacer()
                HStack(spacing: 6) { Text("6 Months"); Image(systemName: "chevron.down").font(.system(size: 12)) }
                    .font(.system(size: 16)).foregroundStyle(LN.ink)
            }
            content
        }
        .padding(18).background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(LN.line))
    }
}

struct LNDashboard: View {
    var body: some View {
        VStack(spacing: 18) {
            LNCard(title: "Total subscribers") {
                Chart(LNData.subs) {
                    LineMark(x: .value("Month", $0.month), y: .value("Total", $0.total))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LN.yellow).lineStyle(StrokeStyle(lineWidth: 3))
                    AreaMark(x: .value("Month", $0.month), y: .value("Total", $0.total))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LN.yellow.opacity(0.15))
                }
                .chartYScale(domain: 0...140).frame(height: 260)
            }
            LNCard(title: "New Subscribers") {
                HStack(spacing: 24) {
                    legend(LN.blue, "Subscribed"); legend(LN.red, "Unsubscribe")
                }.frame(maxWidth: .infinity)
                Chart {
                    ForEach(LNData.subs) {
                        LineMark(x: .value("Month", $0.month), y: .value("Subscribed", $0.subscribed), series: .value("s","sub"))
                            .foregroundStyle(LN.blue).interpolationMethod(.catmullRom)
                        LineMark(x: .value("Month", $0.month), y: .value("Unsubscribe", $0.unsub), series: .value("s","uns"))
                            .foregroundStyle(LN.red).interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: 0...140).frame(height: 220)
            }
        }
    }
    private func legend(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 8) { RoundedRectangle(cornerRadius: 2).fill(c).frame(width: 26, height: 12); Text(t).foregroundStyle(LN.ink) }
            .font(.system(size: 15))
    }
}

struct LNList: View {
    let title: String; let rows: [(String, String)]; let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(size: 24, weight: .bold)).foregroundStyle(LN.ink)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, r in
                    HStack(spacing: 14) {
                        ZStack { RoundedRectangle(cornerRadius: 10).fill(LN.blue.opacity(0.12)).frame(width: 40, height: 40)
                            Image(systemName: icon).foregroundStyle(LN.blue) }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(r.0).font(.system(size: 15, weight: .semibold)).foregroundStyle(LN.ink)
                            Text(r.1).font(.system(size: 13)).foregroundStyle(LN.mut)
                        }
                        Spacer()
                    }
                    .padding(16)
                    Divider().overlay(LN.line)
                }
            }
            .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(LN.line))
        }
    }
}

struct LNPlaceholder: View {
    let title: String; let icon: String
    var body: some View {
        VStack(spacing: 16) {
            ZStack { RoundedRectangle(cornerRadius: 16).fill(LN.blue.opacity(0.12)).frame(width: 64, height: 64)
                Image(systemName: icon).font(.system(size: 30)).foregroundStyle(LN.blue) }
                .padding(.top, 60)
            Text(title).font(.system(size: 19, weight: .semibold)).foregroundStyle(LN.ink)
            Text("This section mirrors the live \(title) area.").font(.system(size: 14)).foregroundStyle(LN.mut)
        }.frame(maxWidth: .infinity)
    }
}
