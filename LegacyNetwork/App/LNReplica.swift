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

    static let subs:[LNSubPoint] = {
        let m=["OCT","NOV","DEC","JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP"]
        let t=[1.0,1,1,1,2,5,3,2,2,1,3,1], s=[0.0,0,1,0,1,3,1,1,1,0,2,0], u=[0.0,0,0,0,0,1,0,0,0,0,1,0]
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

// MARK: - Root
struct LNRoot: View {
    enum Stage { case splash, login, shell }
    @State private var stage:Stage = .splash
    var body: some View {
        ZStack {
            switch stage {
            case .splash: LNSplash()
            case .login:  LNLogin{ withAnimation{ stage = .shell } }
            case .shell:  LNShell{ withAnimation{ stage = .login } }
            }
        }
        .onAppear{ if stage == .splash {
            DispatchQueue.main.asyncAfter(deadline:.now()+1.4){ withAnimation(.easeInOut(duration:0.4)){ stage = .login } } } }
    }
}

struct LNSplash: View {
    var body: some View {
        ZStack { LN.blue.ignoresSafeArea()
            VStack(spacing:22){
                Image("LegacyGlobe").resizable().renderingMode(.template).scaledToFit()
                    .frame(width:120,height:120).foregroundStyle(.white)
                Text("Legacy").font(.system(size:30,weight:.bold)).foregroundStyle(.white)
            } } }
}

struct LNLogin: View {
    var onLogin:()->Void
    @State private var dist=true; @State private var email=""; @State private var pass=""
    var body: some View {
        ZStack { LN.blue.ignoresSafeArea()
            ScrollView { VStack(spacing:0){
                HStack(spacing:16){
                    Image("LegacyGlobe").resizable().renderingMode(.template).scaledToFit()
                        .frame(width:88,height:88).foregroundStyle(.white)
                    VStack(alignment:.leading,spacing:4){
                        Text("LEGACY").font(.system(size:42,weight:.heavy)).foregroundStyle(.white)
                        Text("network").font(.system(size:18,weight:.light)).tracking(9).foregroundStyle(.white)
                    }
                }.padding(.top,40).padding(.bottom,50)
                HStack(spacing:0){ seg("Distributor",dist){dist=true}; seg("Customer",!dist){dist=false} }
                    .background(Color.white).clipShape(Capsule())
                    .overlay(Capsule().stroke(.white,lineWidth:2)).padding(.bottom,28)
                field("Email",$email,"Email","envelope.fill",false)
                field("Password",$pass,"Password","eye.slash.fill",true)
                VStack(spacing:16){
                    lk("Forgot Password?"); lk("Never received Welcome Email?")
                    lk("Never received Verification Email?")
                    lk("Existing Synergy Team Member wanting to use the Legacy Network WebApp?")
                }.padding(.top,20)
                Button(action:onLogin){ Text("Log In").font(.system(size:19,weight:.semibold))
                    .foregroundStyle(Color(red:0.25,green:0.34,blue:0.49))
                    .frame(maxWidth:.infinity).frame(height:62)
                    .background(Color(red:0.79,green:0.84,blue:0.94)).clipShape(Capsule()) }.padding(.top,36)
            }.padding(.horizontal,28).padding(.bottom,40) } }
    }
    private func seg(_ t:String,_ a:Bool,_ tap:@escaping()->Void)->some View {
        Button(action:tap){ Text(t).font(.system(size:17,weight:.semibold))
            .foregroundStyle(a ? LN.blue : .white).frame(maxWidth:.infinity).frame(height:52)
            .background(a ? Color.white : LN.blue).clipShape(Capsule()) } }
    private func field(_ l:String,_ t:Binding<String>,_ ph:String,_ ic:String,_ sec:Bool)->some View {
        VStack(alignment:.leading,spacing:8){ Text(l).font(.system(size:17)).foregroundStyle(.white)
            HStack{ Group{ if sec { SecureField("",text:t,prompt:Text(ph).foregroundColor(Color(white:0.95))) }
                else { TextField("",text:t,prompt:Text(ph).foregroundColor(Color(white:0.95))).textInputAutocapitalization(.never).keyboardType(.emailAddress) } }
                .foregroundStyle(.white).padding(.leading,18)
                Spacer(); Image(systemName:ic).foregroundStyle(.white).font(.system(size:22)).padding(.trailing,18) }
            .frame(height:62).background(LN.blueField).clipShape(RoundedRectangle(cornerRadius:12)) }.padding(.bottom,12) }
    private func lk(_ t:String)->some View { Text(t).font(.system(size:16,weight:.medium)).foregroundStyle(.white).multilineTextAlignment(.center).frame(maxWidth:.infinity) }
}

// MARK: - Shell
struct LNShell: View {
    var onLogout:()->Void
    @State private var active="dashboard"; @State private var drawer=false
    var body: some View {
        ZStack(alignment:.leading){
            LN.bg.ignoresSafeArea()
            VStack(spacing:0){
                HStack{
                    Button{ withAnimation(.easeOut(duration:0.25)){ drawer=true } } label:{
                        VStack(spacing:5){ ForEach(0..<3){ _ in Capsule().fill(LN.accent).frame(width:26,height:3) } }
                            .frame(width:52,height:46).background(LN.dark2).clipShape(RoundedRectangle(cornerRadius:12)) }
                    Spacer(); LNAvatar(size:56)
                }.padding(.horizontal,18).padding(.vertical,8).background(LN.dark)
                NavigationStack { LNPage(key:active).toolbar(.hidden, for:.navigationBar).background(LN.bg) }
            }
            if drawer {
                Color.black.opacity(0.5).ignoresSafeArea().onTapGesture{ withAnimation{ drawer=false } }
                LNDrawer(active:active){ key in withAnimation{ drawer=false }
                    if key=="logout" { onLogout() } else { active=key } }
                    .frame(width:320).transition(.move(edge:.leading))
            }
        }
    }
}

struct LNAvatar: View {
    var size:CGFloat
    var body: some View {
        Group { if let ui=UIImage(named:"Avatar"){ Image(uiImage:ui).resizable().scaledToFill() }
            else { ZStack{ LN.blue; Text("CS").foregroundStyle(.white).font(.system(size:size*0.4,weight:.bold)) } } }
        .frame(width:size,height:size).clipShape(Circle()).overlay(Circle().stroke(Color(white:0.2),lineWidth:2))
    }
}

struct LNDrawer: View {
    let active:String; var onSelect:(String)->Void
    var body: some View {
        ZStack(alignment:.topLeading){ LN.dark.ignoresSafeArea()
            VStack(alignment:.leading,spacing:0){
                HStack{ Spacer(); LNAvatar(size:64) }.padding(.horizontal,20).padding(.top,8)
                Text("BETA").font(.system(size:14,weight:.heavy)).foregroundStyle(.white)
                    .padding(.horizontal,14).padding(.vertical,5).background(LN.red)
                    .clipShape(RoundedRectangle(cornerRadius:8)).padding(.leading,20).padding(.vertical,8)
                ScrollView{ VStack(spacing:0){ ForEach(LNData.nav){ item in
                    Button{ onSelect(item.key) } label:{
                        HStack(spacing:20){ Image(systemName:item.icon).frame(width:26).font(.system(size:20))
                            Text(item.label).font(.system(size:19)); Spacer() }
                        .foregroundStyle(item.key==active ? LN.accent : Color(red:0.68,green:0.71,blue:0.76))
                        .padding(.horizontal,22).padding(.vertical,18)
                        .background(item.key==active ? LN.dark2 : Color.clear) }
                    Divider().overlay(LN.dark2) } } }
            } }
    }
}

// MARK: - Page router
struct LNPage: View {
    let key:String
    var body: some View {
        switch key {
        case "dashboard": LNDashboard()
        case "email": LNEmail()
        case "events": LNSimpleList(title:"Events", rows:LNData.events)
        case "business": LNBusiness()
        case "training": LNTrainingScreen()
        case "store": LNStore()
        case "storage": LNStorage()
        case "achievements": LNAchievements()
        case "settings": LNSettings()
        case "notifications": LNNotifications()
        default: LNPlaceholder(title:"Section", icon:"square.grid.2x2")
        }
    }
}

// MARK: - Reusable
struct LNScreen<C:View>: View {
    let title:String; @ViewBuilder var content:C
    var body: some View {
        ScrollView { VStack(alignment:.leading,spacing:16){
            Text(title).font(.system(size:26,weight:.bold)).foregroundStyle(LN.ink)
            content }.padding(16) }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct LNCardList: View {
    let rows:[LNRow]
    var body: some View {
        VStack(spacing:0){ ForEach(rows){ r in
            HStack(spacing:14){
                ZStack{ RoundedRectangle(cornerRadius:10).fill(LN.blue.opacity(0.12)).frame(width:40,height:40)
                    Image(systemName:r.icon).foregroundStyle(LN.blue) }
                VStack(alignment:.leading,spacing:3){
                    Text(r.title).font(.system(size:15,weight:.semibold)).foregroundStyle(LN.ink)
                    Text(r.sub).font(.system(size:13)).foregroundStyle(LN.mut) }
                Spacer()
                if !r.trailing.isEmpty { Text(r.trailing).font(.system(size:14,weight:.semibold)).foregroundStyle(LN.green) }
            }.padding(16)
            if r.id != rows.last?.id { Divider().overlay(LN.line) } } }
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius:14))
        .overlay(RoundedRectangle(cornerRadius:14).stroke(LN.line))
    }
}
struct LNSimpleList: View { let title:String; let rows:[LNRow]
    var body: some View { LNScreen(title:title){ LNCardList(rows:rows) } } }

struct LNMenuRow: View { let label:String; let icon:String
    var body: some View {
        HStack(spacing:14){
            ZStack{ RoundedRectangle(cornerRadius:10).fill(LN.blue.opacity(0.12)).frame(width:38,height:38)
                Image(systemName:icon).foregroundStyle(LN.blue).font(.system(size:16)) }
            Text(label).font(.system(size:15,weight:.medium)).foregroundStyle(LN.ink)
            Spacer(); Image(systemName:"chevron.right").foregroundStyle(LN.mut).font(.system(size:13))
        }.padding(15)
    }
}

// MARK: - Dashboard
struct LNDashboard: View {
    var body: some View {
        LNScreen(title:"Dashboard"){
            chartCard("Total subscribers"){
                Chart(LNData.subs){ LineMark(x:.value("m",$0.month),y:.value("t",$0.total)).interpolationMethod(.catmullRom).foregroundStyle(LN.yellow).lineStyle(StrokeStyle(lineWidth:3))
                    AreaMark(x:.value("m",$0.month),y:.value("t",$0.total)).interpolationMethod(.catmullRom).foregroundStyle(LN.yellow.opacity(0.15)) }
                .chartYScale(domain:0...140).frame(height:250)
            }
            chartCard("New Subscribers"){
                HStack(spacing:24){ leg(LN.blue,"Subscribed"); leg(LN.red,"Unsubscribe") }.frame(maxWidth:.infinity)
                Chart{ ForEach(LNData.subs){
                    LineMark(x:.value("m",$0.month),y:.value("s",$0.subscribed),series:.value("k","s")).foregroundStyle(LN.blue).interpolationMethod(.catmullRom)
                    LineMark(x:.value("m",$0.month),y:.value("u",$0.unsub),series:.value("k","u")).foregroundStyle(LN.red).interpolationMethod(.catmullRom) } }
                .chartYScale(domain:0...140).frame(height:210)
            }
        }
    }
    private func chartCard<C:View>(_ t:String,@ViewBuilder _ c:()->C)->some View {
        VStack(alignment:.leading,spacing:12){
            HStack{ Text(t).font(.system(size:22,weight:.bold)).foregroundStyle(LN.ink); Spacer()
                HStack(spacing:6){ Text("6 Months"); Image(systemName:"chevron.down").font(.system(size:12)) }.font(.system(size:16)).foregroundStyle(LN.ink) }
            c() }
        .padding(18).background(Color.white).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(LN.line))
    }
    private func leg(_ c:Color,_ t:String)->some View { HStack(spacing:8){ RoundedRectangle(cornerRadius:2).fill(c).frame(width:26,height:12); Text(t).foregroundStyle(LN.ink) }.font(.system(size:15)) }
}

// MARK: - Email
struct LNEmail: View {
    @State private var tab=0
    var body: some View {
        LNScreen(title:"Email"){
            Picker("",selection:$tab){ Text("Campaigns").tag(0); Text("SMS").tag(1); Text("Sequences").tag(2) }.pickerStyle(.segmented)
            switch tab {
            case 0: LNCardList(rows:LNData.campaigns)
            case 1: LNCardList(rows:[.init(title:"EHC SMS Blast", sub:"Sent · 3 recipients", icon:"message.fill"), .init(title:"Event Reminder SMS", sub:"Scheduled", icon:"message.fill")])
            default: LNCardList(rows:[.init(title:"Welcome Sequence", sub:"5 emails · active", icon:"arrow.triangle.branch"), .init(title:"Re-engagement", sub:"3 emails · paused", icon:"arrow.triangle.branch")])
            }
            NavigationLink{ LNPlaceholder(title:"New Email", icon:"square.and.pencil") } label:{ LNMenuRow(label:"Compose new email", icon:"square.and.pencil").background(Color.white).clipShape(RoundedRectangle(cornerRadius:12)).overlay(RoundedRectangle(cornerRadius:12).stroke(LN.line)) }
        }
    }
}

// MARK: - Business Building
struct LNBusiness: View {
    let items:[(String,String,AnyView)] = [
        ("Invites","paperplane.fill", AnyView(LNSimpleList(title:"Invites", rows:[.init(title:"Pending invites", sub:"0 outstanding", icon:"paperplane"), .init(title:"Send new invite", sub:"Distributor or customer", icon:"plus.circle")]))),
        ("Business Partners","person.2.fill", AnyView(LNSimpleList(title:"Business Partners", rows:[.init(title:"\(LNData.teamTotal) partners", sub:"Your organization", icon:"person.2")]))),
        ("Members Tree","point.topleft.down.curvedto.point.bottomright.up", AnyView(LNSimpleList(title:"Members Tree", rows:[.init(title:"Connor Sharp", sub:"Director · root", icon:"person.crop.circle"), .init(title:"Direct downline", sub:"View your genealogy", icon:"arrow.down")]))),
        ("Goals","target", AnyView(LNSimpleList(title:"Goals", rows:LNData.goals))),
        ("Benefits","gift.fill", AnyView(LNSimpleList(title:"Benefits", rows:[.init(title:"Rank benefits", sub:"Director tier", icon:"gift")]))),
        ("Reports","chart.bar.fill", AnyView(LNSimpleList(title:"Reports", rows:[.init(title:"Volume report", sub:"6-month view", icon:"chart.bar"), .init(title:"Enrollment report", sub:"New members", icon:"chart.line.uptrend.xyaxis")]))),
        ("Customers","person.crop.circle.fill", AnyView(LNSimpleList(title:"Customers", rows:[.init(title:"\(LNData.customersTotal)+ customers", sub:"Retail + preferred", icon:"person.crop.circle")]))),
        ("Activate Members","checkmark.seal.fill", AnyView(LNPlaceholder(title:"Activate Members", icon:"checkmark.seal"))),
    ]
    var body: some View {
        LNScreen(title:"Business Building"){
            VStack(spacing:0){ ForEach(Array(items.enumerated()),id:\.offset){ _,it in
                NavigationLink{ it.2 } label:{ LNMenuRow(label:it.0, icon:it.1) }
                Divider().overlay(LN.line) } }
            .background(Color.white).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(LN.line))
        }
    }
}

// MARK: - Training
struct LNTrainingScreen: View {
    @State private var tab=0
    var body: some View {
        LNScreen(title:"Training"){
            Picker("",selection:$tab){ Text("Entrepreneurship").tag(0); Text("Leadership").tag(1); Text("Tutorials").tag(2) }.pickerStyle(.segmented)
            if tab==0 {
                VStack(spacing:0){ ForEach(LNData.training){ s in
                    NavigationLink{ LNTrainDetail(s:s) } label:{
                        HStack(spacing:14){
                            ZStack{ RoundedRectangle(cornerRadius:10).fill(LN.blue.opacity(0.12)).frame(width:40,height:40); Image(systemName:"play.circle.fill").foregroundStyle(LN.blue) }
                            VStack(alignment:.leading,spacing:3){ Text(s.title).font(.system(size:15,weight:.semibold)).foregroundStyle(LN.ink)
                                Text("Rank \(s.rank) · \(s.lessons) lessons").font(.system(size:13)).foregroundStyle(LN.mut) }
                            Spacer(); Image(systemName:"chevron.right").foregroundStyle(LN.mut).font(.system(size:13)) }.padding(16) }
                    if s.id != LNData.training.last?.id { Divider().overlay(LN.line) } } }
                .background(Color.white).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(LN.line))
            } else if tab==1 {
                LNCardList(rows:[.init(title:"Leadership Live", sub:"Weekly broadcast", icon:"dot.radiowaves.left.and.right")])
            } else {
                LNCardList(rows:[.init(title:"Getting Started Tutorial", sub:"Video · 6 min", icon:"questionmark.circle"), .init(title:"Using the WebApp", sub:"Video · 9 min", icon:"questionmark.circle")])
            }
        }
    }
}
struct LNTrainDetail: View { let s:LNTrain
    var body: some View {
        LNScreen(title:s.title){
            Text(s.desc).font(.system(size:15)).foregroundStyle(LN.mut)
            LNCardList(rows:(1...s.lessons).map{ .init(title:"Lesson \($0)", sub:"Tap to view", icon:"\($0).circle.fill") })
        }
    }
}

// MARK: - Store
struct LNStore: View {
    @State private var tab=0
    var body: some View {
        LNScreen(title:"Store"){
            Picker("",selection:$tab){ Text("Products").tag(0); Text("Categories").tag(1); Text("Autoship").tag(2); Text("Orders").tag(3) }.pickerStyle(.segmented)
            switch tab {
            case 0:
                VStack(spacing:0){ ForEach(LNData.packages){ p in
                    HStack(spacing:14){
                        ZStack{ RoundedRectangle(cornerRadius:10).fill(LN.green.opacity(0.14)).frame(width:44,height:44); Image(systemName:"shippingbox.fill").foregroundStyle(LN.green) }
                        VStack(alignment:.leading,spacing:3){ Text(p.name).font(.system(size:15,weight:.semibold)).foregroundStyle(LN.ink); Text(p.category).font(.system(size:13)).foregroundStyle(LN.mut) }
                        Spacer(); Text(p.price).font(.system(size:16,weight:.bold)).foregroundStyle(LN.ink) }.padding(16)
                    if p.id != LNData.packages.last?.id { Divider().overlay(LN.line) } } }
                .background(Color.white).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(LN.line))
            case 1:
                LNCardList(rows:LNData.categories.map{ .init(title:$0, sub:"Browse products", icon:"square.grid.2x2.fill") })
            case 2:
                LNCardList(rows:[.init(title:"Active autoship", sub:"Monthly · next ship in 12 days", icon:"repeat", trailing:"On", icon2Unused:())].map{$0} )
            default:
                LNCardList(rows:[.init(title:"\(LNData.ordersTotal) total orders", sub:"Order history", icon:"bag.fill")])
            }
        }
    }
}
extension LNRow { init(title:String,sub:String,icon:String,trailing:String,icon2Unused:Void){ self.init(title:title,sub:sub,trailing:trailing,icon:icon) } }

// MARK: - Storage
struct LNStorage: View {
    var body: some View {
        LNScreen(title:"Storage"){
            LNCardList(rows:[
                .init(title:"Marketing Assets", sub:"Folder · images & PDFs", icon:"folder.fill"),
                .init(title:"Product Images", sub:"Folder", icon:"folder.fill"),
                .init(title:"Presentations", sub:"Folder", icon:"folder.fill"),
                .init(title:"legacy-overview.pdf", sub:"1.2 MB", icon:"doc.fill"),
            ])
        }
    }
}

// MARK: - Achievements
struct LNAchievements: View {
    @State private var tab=0
    var body: some View {
        LNScreen(title:"Achievements"){
            Picker("",selection:$tab){ Text("Awards").tag(0); Text("Levels").tag(1) }.pickerStyle(.segmented)
            if tab==0 {
                LNCardList(rows:[
                    .init(title:"First Enrollment", sub:"Unlocked", icon:"rosette", trailing:"✓", icon2Unused:()),
                    .init(title:"Director Rank", sub:"Unlocked", icon:"rosette", trailing:"✓", icon2Unused:()),
                    .init(title:"Team of 50", sub:"In progress", icon:"rosette"),
                ])
            } else {
                LNCardList(rows:(1...6).map{ .init(title:"Level \($0)", sub:$0<=3 ? "Achieved" : "Locked", icon:"star.fill", trailing:$0<=3 ? "✓":"", icon2Unused:()) })
            }
        }
    }
}

// MARK: - Settings
struct LNSettings: View {
    let rows:[(String,String,AnyView)] = [
        ("Account", "person.crop.circle.fill", AnyView(LNAccount())),
        ("Notification Settings","bell.badge.fill", AnyView(LNPlaceholder(title:"Notification Settings", icon:"bell.badge"))),
        ("Manage Subscription","creditcard.fill", AnyView(LNSimpleList(title:"Manage Subscription", rows:[.init(title:"Legacy Pro", sub:"Active · $49.00/mo", icon:"checkmark.seal.fill", trailing:"Active", icon2Unused:())]))),
        ("Payment Information","dollarsign.circle.fill", AnyView(LNSimpleList(title:"Payment Information", rows:[.init(title:LNData.billingContact, sub:LNData.billingLine, icon:"creditcard")]))),
        ("Payment History","clock.fill", AnyView(LNSimpleList(title:"Payment History", rows:[.init(title:"\(LNData.ordersTotal) transactions", sub:"View full history", icon:"clock")]))),
        ("Change Password","lock.fill", AnyView(LNPlaceholder(title:"Change Password", icon:"lock"))),
        ("Personal URL","link", AnyView(LNPlaceholder(title:"Personal URL", icon:"link"))),
    ]
    var body: some View {
        LNScreen(title:"Settings"){
            HStack(spacing:14){
                LNAvatar(size:56)
                VStack(alignment:.leading,spacing:3){
                    Text(LNData.name).font(.system(size:17,weight:.bold)).foregroundStyle(LN.ink)
                    Text("Synergy ID \(LNData.synergy) · \(LNData.tier)").font(.system(size:13)).foregroundStyle(LN.mut)
                    Text(LNData.city).font(.system(size:13)).foregroundStyle(LN.mut)
                }
                Spacer()
            }
                .padding(16).background(Color.white).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(LN.line))
            VStack(spacing:0){ ForEach(Array(rows.enumerated()),id:\.offset){ _,r in
                NavigationLink{ r.2 } label:{ LNMenuRow(label:r.0, icon:r.1) }
                Divider().overlay(LN.line) } }
            .background(Color.white).clipShape(RoundedRectangle(cornerRadius:14)).overlay(RoundedRectangle(cornerRadius:14).stroke(LN.line))
        }
    }
}
struct LNAccount: View {
    var body: some View {
        LNScreen(title:"Account"){
            HStack{ Spacer(); LNAvatar(size:88); Spacer() }.padding(.vertical,10)
            LNCardList(rows:[
                .init(title:"Name", sub:LNData.name, icon:"person.fill"),
                .init(title:"Synergy ID", sub:LNData.synergy, icon:"number"),
                .init(title:"Tier", sub:LNData.tier, icon:"star.fill"),
                .init(title:"Location", sub:LNData.city, icon:"mappin.and.ellipse"),
                .init(title:"Billing", sub:LNData.billingLine, icon:"creditcard"),
            ])
        }
    }
}

// MARK: - Notifications
struct LNNotifications: View {
    var body: some View {
        LNScreen(title:"Notifications"){
            VStack(spacing:14){
                Image(systemName:"bell.slash").font(.system(size:40)).foregroundStyle(LN.mut).padding(.top,50)
                Text("No new notifications").font(.system(size:16,weight:.medium)).foregroundStyle(LN.ink)
                Text("You're all caught up.").font(.system(size:14)).foregroundStyle(LN.mut)
            }.frame(maxWidth:.infinity)
        }
    }
}

// MARK: - Placeholder
struct LNPlaceholder: View { let title:String; let icon:String
    var body: some View {
        LNScreen(title:title){
            VStack(spacing:16){
                ZStack{ RoundedRectangle(cornerRadius:16).fill(LN.blue.opacity(0.12)).frame(width:64,height:64); Image(systemName:icon).font(.system(size:30)).foregroundStyle(LN.blue) }.padding(.top,50)
                Text(title).font(.system(size:19,weight:.semibold)).foregroundStyle(LN.ink)
                Text("This section mirrors the live \(title) area.").font(.system(size:14)).foregroundStyle(LN.mut).multilineTextAlignment(.center)
            }.frame(maxWidth:.infinity)
        }
    }
}

