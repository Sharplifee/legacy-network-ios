import SwiftUI
import Charts

// MARK: - Palette
enum LN {
    static let blue      = Color(red: 0.192, green: 0.443, blue: 0.800)
    static let blueField = Color(red: 0.306, green: 0.525, blue: 0.839)
    static let dark      = Color(red: 0.098, green: 0.110, blue: 0.133)
    static let dark2     = Color(red: 0.126, green: 0.141, blue: 0.172)
    static let bg        = Color(red: 0.957, green: 0.965, blue: 0.973)
    static let ink       = Color(red: 0.106, green: 0.118, blue: 0.137)
    static let mut       = Color(red: 0.541, green: 0.580, blue: 0.651)
    static let yellow    = Color(red: 0.957, green: 0.718, blue: 0.251)
    static let red       = Color(red: 0.898, green: 0.204, blue: 0.239)
    static let green     = Color(red: 0.13, green: 0.65, blue: 0.58)
    static let line      = Color(red: 0.918, green: 0.929, blue: 0.949)
    static let accent    = Color(red: 0.29, green: 0.56, blue: 0.89)
}

// MARK: - Models
struct LNSubPoint: Identifiable { let id=UUID(); let month:String; let total:Double; let subscribed:Double; let unsub:Double }
struct LNRow: Identifiable { let id=UUID(); let title:String; let sub:String; var trailing:String=""; var icon:String="circle" }
struct LNNav: Identifiable { let id=UUID(); let label:String; let icon:String; let key:String }
struct LNTrain: Identifiable { let id=UUID(); let title:String; let rank:Int; let lessons:Int; let desc:String }
struct LNPack: Identifiable { let id=UUID(); let name:String; let price:String; let category:String }

// MARK: - Real data (captured live, Synergy 180555)
enum LNData {
    static let name="Connor Sharp", synergy="180555", tier="Pro", city="Orem, UT"
    static let billingContact="CONNOR SHARP", billingLine="1774 High Country Dr, Orem, UT"

    // Slow, steady growth beginning February 2026 (flat through late 2025, then a gentle climb)
    static let subs:[LNSubPoint] = {
        // Real-world style: flat through late 2025, growth kicks in Feb 2026, then
        // a choppy up-and-down climb (churn causes dips) netting upward, peaking to-date in Sep.
        let m=["OCT","NOV","DEC","JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP"]
        let t=[0.0,1,1,2,6,11,9,16,14,24,31,43]   // total subscribers (jagged, net up, peak Sep)
        let s=[0.0,1,0,1,6,9,5,12,7,14,11,18]     // new subscribed per month (grows with wobble)
        let u=[0.0,0,0,0,1,2,6,3,7,4,5,5]         // unsubscribed per month (real churn)
        return (0..<12).map{ LNSubPoint(month:m[$0],total:t[$0],subscribed:s[$0],unsub:u[$0]) }
    }()

    static let events:[LNRow]=[
        .init(title:"ELITE HEALTH CHALLENGE CHECK-IN", sub:"Tue 9/3 · 8:00pm MT · Online", icon:"calendar"),
        .init(title:"SPANISH BUSINESS PRESENTATION", sub:"Wed 9/4 · 7:00pm MT · Online", icon:"calendar"),
        .init(title:"SPECIAL DINNER AND BUSINESS MEETING", sub:"Wed 9/11 · 6:30pm MT · In person", icon:"calendar"),
        .init(title:"BUSINESS TRAINING", sub:"Tue 9/17 · 8:00pm MT · Online", icon:"calendar"),
        .init(title:"LA OPORTUNIDAD DE LEGACY NETWORK", sub:"Jue 9/19 · 7:00pm MT · Online", icon:"calendar"),
        .init(title:"CAPACITACIÓN ESPECIAL: PRESIDENTIAL", sub:"Jue 9/19 · 8:10pm MT · Online", icon:"calendar"),
    ]
    static let training:[LNTrain]=[
        .init(title:"Welcome & Overview", rank:1, lessons:8, desc:"Welcome to Legacy Network! The first step is to learn."),
        .init(title:"Session 1: Business Foundation", rank:8, lessons:8, desc:"The components that support your business setup."),
        .init(title:"Session 2: My Health & Income Path", rank:23, lessons:6, desc:"Focus on your personal health and income goals."),
        .init(title:"Session 3: Inviting & Follow-Up", rank:54, lessons:7, desc:"Skills to interact with partners and follow up."),
        .init(title:"Session 4: Presenting", rank:70, lessons:5, desc:"Present the opportunity with confidence."),
    ]
    static let campaigns:[LNRow]=[
        .init(title:"EHC (Elite Health Challenge)", sub:"Nurture sequence · active", icon:"envelope.fill"),
        .init(title:"New Subscriber Welcome", sub:"Onboarding series · active", icon:"envelope.fill"),
        .init(title:"Monthly Newsletter", sub:"Broadcast to all subscribers", icon:"envelope.fill"),
    ]
    static let goals:[LNRow]=[
        .init(title:"Reach Presidential Executive", sub:"Rank · due Dec 2026", icon:"target"),
        .init(title:"Grow team to 50 active", sub:"Team · due Jun 2026", icon:"target"),
        .init(title:"Complete all training sessions", sub:"Personal · due Mar 2026", icon:"target"),
    ]
    static let categories=["Business Info","Product Info","Testimonials","Product Funnels (Automated)","Business Funnels (Automated)"]
    static let packages:[LNPack]=[
        .init(name:"Heart Health 140", price:"$189", category:"Product Info"),
        .init(name:"Immune 200", price:"$270", category:"Product Info"),
        .init(name:"Immune 115", price:"$145", category:"Product Info"),
        .init(name:"Core Nutrition 200", price:"$269", category:"Product Info"),
        .init(name:"Core Nutrition 150", price:"$194", category:"Product Info"),
        .init(name:"Energy 120", price:"$159", category:"Product Info"),
    ]
    static let customersTotal=50, ordersTotal=441, teamTotal=20

    static let nav:[LNNav]=[
        .init(label:"Dashboard", icon:"house.fill", key:"dashboard"),
        .init(label:"Email", icon:"envelope.fill", key:"email"),
        .init(label:"Events", icon:"calendar", key:"events"),
        .init(label:"Business Building", icon:"briefcase.fill", key:"business"),
        .init(label:"Training", icon:"lightbulb.fill", key:"training"),
        .init(label:"Store", icon:"cart.fill", key:"store"),
        .init(label:"Storage", icon:"folder.fill", key:"storage"),
        .init(label:"Achievements", icon:"trophy.fill", key:"achievements"),
        .init(label:"Settings", icon:"gearshape.fill", key:"settings"),
        .init(label:"Notifications", icon:"bell.fill", key:"notifications"),
        .init(label:"Log Out", icon:"rectangle.portrait.and.arrow.right", key:"logout"),
    ]
}

// MARK: - Design system (refined)
enum UI {
    static let bg       = Color(red:0.960, green:0.969, blue:0.980)   // #F5F7FA
    static let surface  = Color.white
    static let primary  = Color(red:0.192, green:0.443, blue:0.800)   // #3171CC
    static let deep     = Color(red:0.118, green:0.306, blue:0.612)   // #1E4E9C
    static let teal     = Color(red:0.090, green:0.745, blue:0.690)   // #17BEB0
    static let ink      = Color(red:0.078, green:0.094, blue:0.122)   // #14181F
    static let ink2     = Color(red:0.357, green:0.392, blue:0.447)   // #5B6472
    static let muted    = Color(red:0.580, green:0.612, blue:0.671)   // #949CAB
    static let hair     = Color(red:0.925, green:0.937, blue:0.953)   // #ECEFF3
    static let amber    = Color(red:0.957, green:0.718, blue:0.251)
    static let red      = Color(red:0.898, green:0.278, blue:0.290)
    static let green    = Color(red:0.106, green:0.639, blue:0.518)
}

extension View {
    func card(_ pad: CGFloat = 18, radius: CGFloat = 22) -> some View {
        self.padding(pad)
            .background(UI.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(UI.hair, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

// tinted icon chip
struct IconChip: View {
    let sf: String; var tint: Color = UI.primary; var size: CGFloat = 44
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size*0.3, style: .continuous).fill(tint.opacity(0.12))
            Image(systemName: sf).font(.system(size: size*0.42, weight: .semibold)).foregroundStyle(tint)
        }.frame(width: size, height: size)
    }
}

struct SectionHeader: View {
    let title: String; var action: String? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.system(size: 19, weight: .bold)).foregroundStyle(UI.ink)
            Spacer()
            if let a = action { Text(a).font(.system(size: 14, weight: .semibold)).foregroundStyle(UI.primary) }
        }
    }
}

// standard row
struct RowItem: View {
    let title: String; var sub: String = ""; var sf: String = "circle.fill"
    var tint: Color = UI.primary; var trailing: String = ""; var chevron: Bool = true
    var body: some View {
        HStack(spacing: 14) {
            IconChip(sf: sf, tint: tint, size: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(UI.ink).lineLimit(1)
                if !sub.isEmpty { Text(sub).font(.system(size: 13)).foregroundStyle(UI.muted).lineLimit(1) }
            }
            Spacer(minLength: 8)
            if !trailing.isEmpty { Text(trailing).font(.system(size: 14, weight: .bold)).foregroundStyle(UI.ink) }
            if chevron { Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(UI.muted.opacity(0.6)) }
        }
        .padding(.vertical, 12).padding(.horizontal, 16)
    }
}
func rowsCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    VStack(spacing: 0) { content() }
        .background(UI.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(UI.hair, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
}

// MARK: - Root
struct LNRoot: View {
    enum Stage { case splash, login, app }
    @State private var stage: Stage = .splash
    var body: some View {
        ZStack {
            switch stage {
            case .splash: LNSplash()
            case .login:  LNLogin { withAnimation(.easeInOut(duration: 0.35)) { stage = .app } }
            case .app:    LNTabs { withAnimation(.easeInOut(duration: 0.35)) { stage = .login } }
            }
        }
        .onAppear {
            if stage == .splash {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.4) { withAnimation(.easeInOut(duration: 0.4)) { stage = .login } }
            }
        }
    }
}

struct LNSplash: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [UI.primary, UI.deep], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 22) {
                Image("LegacyGlobe").resizable().renderingMode(.template).scaledToFit()
                    .frame(width: 118, height: 118).foregroundStyle(.white)
                Text("Legacy").font(.system(size: 30, weight: .bold)).foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Login (faithful gate, lightly polished)
struct LNLogin: View {
    var onLogin: () -> Void
    @State private var dist = true; @State private var email = ""; @State private var pass = ""
    var body: some View {
        ZStack {
            LinearGradient(colors: [UI.primary, UI.deep], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Image("LegacyGlobe").resizable().renderingMode(.template).scaledToFit()
                            .frame(width: 84, height: 84).foregroundStyle(.white)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LEGACY").font(.system(size: 40, weight: .heavy)).foregroundStyle(.white)
                            Text("network").font(.system(size: 17, weight: .light)).tracking(9).foregroundStyle(.white.opacity(0.95))
                        }
                    }.padding(.top, 44).padding(.bottom, 46)

                    HStack(spacing: 0) {
                        seg("Distributor", dist) { dist = true }
                        seg("Customer", !dist) { dist = false }
                    }
                    .padding(4).background(Color.white.opacity(0.15)).clipShape(Capsule()).padding(.bottom, 26)

                    field("Email", $email, "Email", "envelope.fill", false)
                    field("Password", $pass, "Password", "eye.slash.fill", true)

                    VStack(spacing: 15) {
                        lk("Forgot Password?")
                        lk("Never received Welcome Email?")
                        lk("Never received Verification Email?")
                        lk("Existing Synergy Team Member wanting to use the Legacy Network WebApp?")
                    }.padding(.top, 22)

                    Button(action: onLogin) {
                        Text("Log In").font(.system(size: 18, weight: .bold)).foregroundStyle(UI.primary)
                            .frame(maxWidth: .infinity).frame(height: 58)
                            .background(Color.white).clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.15), radius: 14, y: 6)
                    }.padding(.top, 34)
                }.padding(.horizontal, 26).padding(.bottom, 40)
            }
        }
    }
    private func seg(_ t: String, _ a: Bool, _ tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            Text(t).font(.system(size: 16, weight: .semibold)).foregroundStyle(a ? UI.primary : .white)
                .frame(maxWidth: .infinity).frame(height: 46)
                .background(a ? Color.white : Color.clear).clipShape(Capsule())
        }
    }
    private func field(_ l: String, _ t: Binding<String>, _ ph: String, _ ic: String, _ sec: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l).font(.system(size: 15, weight: .medium)).foregroundStyle(.white.opacity(0.95))
            HStack {
                Group {
                    if sec { SecureField("", text: t, prompt: Text(ph).foregroundColor(.white.opacity(0.7))) }
                    else { TextField("", text: t, prompt: Text(ph).foregroundColor(.white.opacity(0.7))).textInputAutocapitalization(.never).keyboardType(.emailAddress) }
                }.foregroundStyle(.white).padding(.leading, 18)
                Spacer()
                Image(systemName: ic).foregroundStyle(.white.opacity(0.9)).font(.system(size: 20)).padding(.trailing, 18)
            }.frame(height: 58).background(Color.white.opacity(0.16)).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }.padding(.bottom, 14)
    }
    private func lk(_ t: String) -> some View {
        Text(t).font(.system(size: 15, weight: .medium)).foregroundStyle(.white.opacity(0.95)).multilineTextAlignment(.center).frame(maxWidth: .infinity)
    }
}

// MARK: - Avatar
struct Avatar: View {
    var size: CGFloat = 40
    var body: some View {
        Group {
            if let ui = UIImage(named: "Avatar") { Image(uiImage: ui).resizable().scaledToFill() }
            else { ZStack { UI.primary; Text("CS").foregroundStyle(.white).font(.system(size: size*0.4, weight: .bold)) } }
        }
        .frame(width: size, height: size).clipShape(Circle())
        .overlay(Circle().stroke(UI.hair, lineWidth: 1))
    }
}

// MARK: - Tabs
struct LNTabs: View {
    var onLogout: () -> Void
    @State private var tab = 0
    init(onLogout: @escaping () -> Void) {
        self.onLogout = onLogout
        let a = UITabBarAppearance(); a.configureWithOpaqueBackground()
        a.backgroundColor = UIColor.white
        a.shadowColor = UIColor(white: 0, alpha: 0.06)
        UITabBar.appearance().standardAppearance = a
        UITabBar.appearance().scrollEdgeAppearance = a
    }
    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { LNHome() }.tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            NavigationStack { LNGrow() }.tabItem { Label("Grow", systemImage: "chart.line.uptrend.xyaxis") }.tag(1)
            NavigationStack { LNLearn() }.tabItem { Label("Learn", systemImage: "graduationcap.fill") }.tag(2)
            NavigationStack { LNStore() }.tabItem { Label("Store", systemImage: "bag.fill") }.tag(3)
            NavigationStack { LNMore(onLogout: onLogout) }.tabItem { Label("More", systemImage: "square.grid.2x2.fill") }.tag(4)
        }
        .tint(UI.primary)
    }
}

// scaffold for a screen with a large title + avatar
struct Screen<C: View>: View {
    let title: String; var showAvatar = true; @ViewBuilder var content: C
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) { content }
                .padding(.horizontal, 18).padding(.top, 6).padding(.bottom, 30)
        }
        .background(UI.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if showAvatar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { LNAccount() } label: { Avatar(size: 34) }
                }
            }
        }
    }
}

// MARK: - Home (Dashboard)
struct LNHome: View {
    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        return h < 12 ? "Good morning" : (h < 18 ? "Good afternoon" : "Good evening")
    }
    var body: some View {
        Screen(title: "Dashboard") {
            // hero
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(greeting),").font(.system(size: 15, weight: .medium)).foregroundStyle(.white.opacity(0.85))
                        Text(LNData.name).font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
                    }
                    Spacer()
                    Text(LNData.tier).font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6).background(Color.white.opacity(0.22)).clipShape(Capsule())
                }
                HStack(spacing: 10) {
                    heroStat("\(Int(LNData.subs.last?.total ?? 0))", "Subscribers")
                    Divider().frame(height: 34).overlay(Color.white.opacity(0.25))
                    heroStat("\(LNData.teamTotal)", "Team")
                    Divider().frame(height: 34).overlay(Color.white.opacity(0.25))
                    heroStat("\(LNData.customersTotal)+", "Customers")
                }
            }
            .padding(20)
            .background(LinearGradient(colors: [UI.primary, UI.deep], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: UI.primary.opacity(0.28), radius: 18, y: 10)

            // total subscribers chart
            VStack(alignment: .leading, spacing: 10) {
                HStack { Text("Total subscribers").font(.system(size: 16, weight: .bold)).foregroundStyle(UI.ink); Spacer()
                    pill("6 Months") }
                Text("\(Int(LNData.subs.last?.total ?? 0))").font(.system(size: 30, weight: .heavy)).foregroundStyle(UI.ink)
                Chart(LNData.subs) {
                    AreaMark(x: .value("m", $0.month), y: .value("t", $0.total)).interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(colors: [UI.primary.opacity(0.25), UI.primary.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                    LineMark(x: .value("m", $0.month), y: .value("t", $0.total)).interpolationMethod(.catmullRom)
                        .foregroundStyle(UI.primary).lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                }
                .chartYScale(domain: 0...50)
                .chartXAxis { AxisMarks(values: .automatic) { AxisValueLabel().font(.system(size: 10)).foregroundStyle(UI.muted) } }
                .chartYAxis { AxisMarks(position: .leading) { AxisGridLine().foregroundStyle(UI.hair); AxisValueLabel().font(.system(size: 10)).foregroundStyle(UI.muted) } }
                .frame(height: 180)
            }.card()

            // new subscribers chart
            VStack(alignment: .leading, spacing: 10) {
                HStack { Text("New Subscribers").font(.system(size: 16, weight: .bold)).foregroundStyle(UI.ink); Spacer(); pill("6 Months") }
                HStack(spacing: 20) { legend(UI.primary, "Subscribed"); legend(UI.red, "Unsubscribe") }
                Chart {
                    ForEach(LNData.subs) {
                        LineMark(x: .value("m", $0.month), y: .value("s", $0.subscribed), series: .value("k","s")).foregroundStyle(UI.primary).interpolationMethod(.catmullRom).lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        LineMark(x: .value("m", $0.month), y: .value("u", $0.unsub), series: .value("k","u")).foregroundStyle(UI.red).interpolationMethod(.catmullRom).lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    }
                }
                .chartXAxis { AxisMarks(values: .automatic) { AxisValueLabel().font(.system(size: 10)).foregroundStyle(UI.muted) } }
                .chartYAxis { AxisMarks(position: .leading) { AxisGridLine().foregroundStyle(UI.hair); AxisValueLabel().font(.system(size: 10)).foregroundStyle(UI.muted) } }
                .frame(height: 170)
            }.card()

            // next event
            SectionHeader(title: "Next up")
            if let e = LNData.events.first {
                rowsCard { RowItem(title: e.title, sub: e.sub, sf: "calendar", tint: UI.teal, chevron: false) }
            }
        }
    }
    private func heroStat(_ v: String, _ l: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(v).font(.system(size: 22, weight: .heavy)).foregroundStyle(.white)
            Text(l).font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.8))
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    private func pill(_ t: String) -> some View {
        HStack(spacing: 5) { Text(t); Image(systemName: "chevron.down").font(.system(size: 10, weight: .bold)) }
            .font(.system(size: 13, weight: .semibold)).foregroundStyle(UI.ink2)
            .padding(.horizontal, 12).padding(.vertical, 7).background(UI.bg).clipShape(Capsule())
    }
    private func legend(_ c: Color, _ t: String) -> some View {
        HStack(spacing: 7) { Circle().fill(c).frame(width: 9, height: 9); Text(t).font(.system(size: 13)).foregroundStyle(UI.ink2) }
    }
}

// MARK: - Grow (Business Building)
struct LNGrow: View {
    var body: some View {
        Screen(title: "Grow") {
            // KPI tiles
            HStack(spacing: 12) {
                kpi("\(LNData.teamTotal)", "Team", "person.2.fill", UI.primary)
                kpi("\(LNData.customersTotal)+", "Customers", "person.crop.circle.fill", UI.teal)
                kpi("\(LNData.ordersTotal)", "Orders", "bag.fill", UI.amber)
            }
            SectionHeader(title: "Goals")
            rowsCard {
                ForEach(Array(LNData.goals.enumerated()), id: \.offset) { i, g in
                    RowItem(title: g.title, sub: g.sub, sf: "target", tint: UI.primary, chevron: false)
                    if i < LNData.goals.count-1 { Divider().overlay(UI.hair).padding(.leading, 72) }
                }
            }
            SectionHeader(title: "Tools")
            rowsCard {
                navRow("Invites", "paperplane.fill", UI.primary) { LNList("Invites", [.init(title:"Pending invites", sub:"0 outstanding", icon:"paperplane"), .init(title:"Send new invite", sub:"Distributor or customer", icon:"plus.circle")]) }
                Divider().overlay(UI.hair).padding(.leading, 72)
                navRow("Business Partners", "person.2.fill", UI.teal) { LNList("Business Partners", [.init(title:"\(LNData.teamTotal) partners", sub:"Your organization", icon:"person.2")]) }
                Divider().overlay(UI.hair).padding(.leading, 72)
                navRow("Members Tree", "point.3.connected.trianglepath.dotted", UI.primary) { LNList("Members Tree", [.init(title:LNData.name, sub:"Director · root", icon:"person.crop.circle"), .init(title:"Direct downline", sub:"View your genealogy", icon:"arrow.down")]) }
                Divider().overlay(UI.hair).padding(.leading, 72)
                navRow("Reports", "chart.bar.fill", UI.amber) { LNList("Reports", [.init(title:"Volume report", sub:"6-month view", icon:"chart.bar"), .init(title:"Enrollment report", sub:"New members", icon:"chart.line.uptrend.xyaxis")]) }
                Divider().overlay(UI.hair).padding(.leading, 72)
                navRow("Customers", "person.crop.circle.fill", UI.teal) { LNList("Customers", [.init(title:"\(LNData.customersTotal)+ customers", sub:"Retail + preferred", icon:"person.crop.circle")]) }
                Divider().overlay(UI.hair).padding(.leading, 72)
                navRow("Benefits", "gift.fill", UI.red) { LNList("Benefits", [.init(title:"Rank benefits", sub:"Director tier", icon:"gift")]) }
            }
        }
    }
    private func kpi(_ v: String, _ l: String, _ sf: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            IconChip(sf: sf, tint: tint, size: 38)
            Text(v).font(.system(size: 22, weight: .heavy)).foregroundStyle(UI.ink)
            Text(l).font(.system(size: 12, weight: .medium)).foregroundStyle(UI.muted)
        }.frame(maxWidth: .infinity, alignment: .leading).card(14, radius: 20)
    }
}

// MARK: - Learn (Training)
struct LNLearn: View {
    @State private var seg = 0
    var body: some View {
        Screen(title: "Learn") {
            Picker("", selection: $seg) { Text("Sessions").tag(0); Text("Leadership").tag(1); Text("Tutorials").tag(2) }.pickerStyle(.segmented)
            if seg == 0 {
                rowsCard {
                    ForEach(Array(LNData.training.enumerated()), id: \.offset) { i, s in
                        NavigationLink { LNTrainDetail(s: s) } label: {
                            RowItem(title: s.title, sub: "Rank \(s.rank) · \(s.lessons) lessons", sf: "play.circle.fill", tint: UI.primary)
                        }
                        if i < LNData.training.count-1 { Divider().overlay(UI.hair).padding(.leading, 72) }
                    }
                }
            } else if seg == 1 {
                rowsCard { RowItem(title: "Leadership Live", sub: "Weekly broadcast", sf: "dot.radiowaves.left.and.right", tint: UI.teal, chevron: false) }
            } else {
                rowsCard {
                    RowItem(title: "Getting Started Tutorial", sub: "Video · 6 min", sf: "questionmark.circle.fill", tint: UI.amber, chevron: false)
                    Divider().overlay(UI.hair).padding(.leading, 72)
                    RowItem(title: "Using the WebApp", sub: "Video · 9 min", sf: "questionmark.circle.fill", tint: UI.amber, chevron: false)
                }
            }
        }
    }
}
struct LNTrainDetail: View {
    let s: LNTrain
    var body: some View {
        Screen(title: s.title, showAvatar: false) {
            Text(s.desc).font(.system(size: 15)).foregroundStyle(UI.ink2)
            SectionHeader(title: "\(s.lessons) lessons")
            rowsCard {
                ForEach(1...s.lessons, id: \.self) { n in
                    RowItem(title: "Lesson \(n)", sub: "Tap to view", sf: "\(n).circle.fill", tint: UI.primary)
                    if n < s.lessons { Divider().overlay(UI.hair).padding(.leading, 72) }
                }
            }
        }
    }
}

// MARK: - Store
struct LNStore: View {
    @State private var seg = 0
    var body: some View {
        Screen(title: "Store") {
            Picker("", selection: $seg) { Text("Products").tag(0); Text("Categories").tag(1); Text("Autoship").tag(2); Text("Orders").tag(3) }.pickerStyle(.segmented)
            switch seg {
            case 0:
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(LNData.packages) { p in
                        VStack(alignment: .leading, spacing: 10) {
                            IconChip(sf: "shippingbox.fill", tint: UI.teal, size: 40)
                            Text(p.name).font(.system(size: 14.5, weight: .bold)).foregroundStyle(UI.ink).lineLimit(2)
                            Text(p.category).font(.system(size: 12)).foregroundStyle(UI.muted).lineLimit(1)
                            Text(p.price).font(.system(size: 18, weight: .heavy)).foregroundStyle(UI.primary)
                        }.frame(maxWidth: .infinity, alignment: .leading).card(14, radius: 20)
                    }
                }
            case 1:
                rowsCard {
                    ForEach(Array(LNData.categories.enumerated()), id: \.offset) { i, c in
                        RowItem(title: c, sub: "Browse products", sf: "square.grid.2x2.fill", tint: UI.primary)
                        if i < LNData.categories.count-1 { Divider().overlay(UI.hair).padding(.leading, 72) }
                    }
                }
            case 2:
                rowsCard { RowItem(title: "Active autoship", sub: "Monthly · next ship in 12 days", sf: "repeat", tint: UI.green, trailing: "On", chevron: false) }
            default:
                rowsCard { RowItem(title: "\(LNData.ordersTotal) total orders", sub: "Order history", sf: "bag.fill", tint: UI.amber) }
            }
        }
    }
}

// MARK: - More (grid)
struct LNMore: View {
    var onLogout: () -> Void
    let items: [(String,String,Color,String)] = [
        ("Email","envelope.fill", UI.primary, "email"),
        ("Events","calendar", UI.teal, "events"),
        ("Storage","folder.fill", UI.amber, "storage"),
        ("Achievements","trophy.fill", UI.red, "achievements"),
        ("Settings","gearshape.fill", UI.ink2, "settings"),
        ("Notifications","bell.fill", UI.primary, "notifications"),
    ]
    var body: some View {
        Screen(title: "More") {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, it in
                    NavigationLink { destination(it.3) } label: {
                        VStack(alignment: .leading, spacing: 14) {
                            IconChip(sf: it.1, tint: it.2, size: 46)
                            Text(it.0).font(.system(size: 15, weight: .bold)).foregroundStyle(UI.ink)
                        }.frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading).card(16, radius: 22)
                    }
                }
            }
            Button(action: onLogout) {
                HStack { Image(systemName: "rectangle.portrait.and.arrow.right"); Text("Log Out").fontWeight(.semibold) }
                    .foregroundStyle(UI.red).frame(maxWidth: .infinity).frame(height: 52)
                    .background(UI.surface).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(UI.hair, lineWidth: 1))
            }.padding(.top, 4)
        }
    }
    @ViewBuilder private func destination(_ key: String) -> some View {
        switch key {
        case "email": LNEmail()
        case "events": LNList("Events", LNData.events)
        case "storage": LNList("Storage", [.init(title:"Marketing Assets", sub:"Folder · images & PDFs", icon:"folder.fill"), .init(title:"Product Images", sub:"Folder", icon:"folder.fill"), .init(title:"Presentations", sub:"Folder", icon:"folder.fill"), .init(title:"legacy-overview.pdf", sub:"1.2 MB", icon:"doc.fill")])
        case "achievements": LNAchievements()
        case "settings": LNSettings()
        default: LNNotifications()
        }
    }
}

// MARK: - Email
struct LNEmail: View {
    @State private var seg = 0
    var body: some View {
        Screen(title: "Email", showAvatar: false) {
            Picker("", selection: $seg) { Text("Campaigns").tag(0); Text("SMS").tag(1); Text("Sequences").tag(2) }.pickerStyle(.segmented)
            switch seg {
            case 0: listCard(LNData.campaigns, "envelope.fill", UI.primary)
            case 1: listCard([.init(title:"EHC SMS Blast", sub:"Sent · 3 recipients", icon:""), .init(title:"Event Reminder SMS", sub:"Scheduled", icon:"")], "message.fill", UI.teal)
            default: listCard([.init(title:"Welcome Sequence", sub:"5 emails · active", icon:""), .init(title:"Re-engagement", sub:"3 emails · paused", icon:"")], "arrow.triangle.branch", UI.amber)
            }
        }
    }
    private func listCard(_ rows: [LNRow], _ sf: String, _ tint: Color) -> some View {
        rowsCard {
            ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                RowItem(title: r.title, sub: r.sub, sf: sf, tint: tint, chevron: false)
                if i < rows.count-1 { Divider().overlay(UI.hair).padding(.leading, 72) }
            }
        }
    }
}

// MARK: - Achievements
struct LNAchievements: View {
    @State private var seg = 0
    var body: some View {
        Screen(title: "Achievements", showAvatar: false) {
            Picker("", selection: $seg) { Text("Awards").tag(0); Text("Levels").tag(1) }.pickerStyle(.segmented)
            if seg == 0 {
                rowsCard {
                    RowItem(title: "First Enrollment", sub: "Unlocked", sf: "rosette", tint: UI.amber, trailing: "✓", chevron: false)
                    Divider().overlay(UI.hair).padding(.leading, 72)
                    RowItem(title: "Director Rank", sub: "Unlocked", sf: "rosette", tint: UI.amber, trailing: "✓", chevron: false)
                    Divider().overlay(UI.hair).padding(.leading, 72)
                    RowItem(title: "Team of 50", sub: "In progress", sf: "rosette", tint: UI.muted, chevron: false)
                }
            } else {
                rowsCard {
                    ForEach(1...6, id: \.self) { n in
                        RowItem(title: "Level \(n)", sub: n<=3 ? "Achieved" : "Locked", sf: "star.fill", tint: n<=3 ? UI.amber : UI.muted, trailing: n<=3 ? "✓" : "", chevron: false)
                        if n < 6 { Divider().overlay(UI.hair).padding(.leading, 72) }
                    }
                }
            }
        }
    }
}

// MARK: - Settings
struct LNSettings: View {
    let rows: [(String,String,Color,AnyView)] = [
        ("Account","person.crop.circle.fill", UI.primary, AnyView(LNAccount())),
        ("Notification Settings","bell.badge.fill", UI.teal, AnyView(LNMini("Notification Settings","bell.badge.fill"))),
        ("Manage Subscription","creditcard.fill", UI.primary, AnyView(LNList("Manage Subscription", [.init(title:"Legacy Pro", sub:"Active · $49.00/mo", trailing:"Active", icon:"checkmark.seal.fill")]))),
        ("Payment Information","dollarsign.circle.fill", UI.green, AnyView(LNList("Payment Information", [.init(title:LNData.billingContact, sub:LNData.billingLine, icon:"creditcard")]))),
        ("Payment History","clock.fill", UI.amber, AnyView(LNList("Payment History", [.init(title:"\(LNData.ordersTotal) transactions", sub:"View full history", icon:"clock")]))),
        ("Change Password","lock.fill", UI.ink2, AnyView(LNMini("Change Password","lock.fill"))),
        ("Personal URL","link", UI.primary, AnyView(LNMini("Personal URL","link"))),
    ]
    var body: some View {
        Screen(title: "Settings", showAvatar: false) {
            HStack(spacing: 14) {
                Avatar(size: 58)
                VStack(alignment: .leading, spacing: 3) {
                    Text(LNData.name).font(.system(size: 18, weight: .bold)).foregroundStyle(UI.ink)
                    Text("Synergy ID \(LNData.synergy) · \(LNData.tier)").font(.system(size: 13)).foregroundStyle(UI.muted)
                    Text(LNData.city).font(.system(size: 13)).foregroundStyle(UI.muted)
                }
                Spacer()
            }.card()
            rowsCard {
                ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                    NavigationLink { r.3 } label: { RowItem(title: r.0, sf: r.1, tint: r.2) }
                    if i < rows.count-1 { Divider().overlay(UI.hair).padding(.leading, 72) }
                }
            }
            Text("Legacy Network · Connor Sharp").font(.system(size: 12)).foregroundStyle(UI.muted).frame(maxWidth: .infinity).padding(.top, 6)
        }
    }
}
struct LNAccount: View {
    var body: some View {
        Screen(title: "Account", showAvatar: false) {
            HStack { Spacer(); Avatar(size: 96); Spacer() }.padding(.vertical, 8)
            rowsCard {
                info("Name", LNData.name, "person.fill"); div()
                info("Synergy ID", LNData.synergy, "number"); div()
                info("Tier", LNData.tier, "star.fill"); div()
                info("Location", LNData.city, "mappin.and.ellipse"); div()
                info("Billing", LNData.billingLine, "creditcard")
            }
        }
    }
    private func div() -> some View { Divider().overlay(UI.hair).padding(.leading, 72) }
    private func info(_ l: String, _ v: String, _ sf: String) -> some View {
        RowItem(title: l, sub: v, sf: sf, tint: UI.primary, chevron: false)
    }
}

// MARK: - Notifications
struct LNNotifications: View {
    var body: some View {
        Screen(title: "Notifications", showAvatar: false) {
            VStack(spacing: 14) {
                IconChip(sf: "bell.slash.fill", tint: UI.muted, size: 60)
                Text("No new notifications").font(.system(size: 16, weight: .semibold)).foregroundStyle(UI.ink)
                Text("You're all caught up.").font(.system(size: 14)).foregroundStyle(UI.muted)
            }.frame(maxWidth: .infinity).padding(.top, 60)
        }
    }
}

// MARK: - Generic list + mini
struct LNList: View {
    let title: String; let rows: [LNRow]
    init(_ t: String, _ r: [LNRow]) { title = t; rows = r }
    var body: some View {
        Screen(title: title, showAvatar: false) {
            rowsCard {
                ForEach(Array(rows.enumerated()), id: \.offset) { i, r in
                    RowItem(title: r.title, sub: r.sub, sf: r.icon.isEmpty ? "circle.fill" : r.icon, tint: UI.primary, trailing: r.trailing, chevron: false)
                    if i < rows.count-1 { Divider().overlay(UI.hair).padding(.leading, 72) }
                }
            }
        }
    }
}
struct LNMini: View {
    let title: String; let sf: String
    init(_ t: String, _ s: String) { title = t; sf = s }
    var body: some View {
        Screen(title: title, showAvatar: false) {
            VStack(spacing: 14) {
                IconChip(sf: sf, tint: UI.primary, size: 64)
                Text(title).font(.system(size: 18, weight: .bold)).foregroundStyle(UI.ink)
                Text("This section mirrors the live \(title) area.").font(.system(size: 14)).foregroundStyle(UI.muted).multilineTextAlignment(.center)
            }.frame(maxWidth: .infinity).padding(.top, 50)
        }
    }
}

// helper for nav rows inside rowsCard
@ViewBuilder func navRow<D: View>(_ title: String, _ sf: String, _ tint: Color, @ViewBuilder _ dest: @escaping () -> D) -> some View {
    NavigationLink { dest() } label: { RowItem(title: title, sf: sf, tint: tint) }
}
