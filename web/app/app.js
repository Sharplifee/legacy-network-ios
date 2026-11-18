/* Legacy Network member-area replica — SPA logic (vanilla).
   Renders views from window.LN mock data. */
(function () {
  "use strict";
  var LN = window.LN;
  var cart = {}; // id -> qty

  var money = function (n) { return "$" + n.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }); };
  var money0 = function (n) { return "$" + n.toLocaleString("en-US", { maximumFractionDigits: 0 }); };
  var el = function (id) { return document.getElementById(id); };

  var NAV = [
    { id: "dashboard", label: "Dashboard", ic: "▦" },
    { id: "team", label: "Team", ic: "👥" },
    { id: "commissions", label: "Commissions", ic: "💰" },
    { id: "shop", label: "Shop", ic: "🛍" },
    { id: "orders", label: "Orders", ic: "📦" },
    { id: "achievements", label: "Achievements", ic: "🏅" },
    { id: "settings", label: "Settings", ic: "⚙" }
  ];
  var MOBILE_NAV = ["dashboard", "team", "shop", "commissions", "settings"];

  /* ---------------- Login ---------------- */
  el("loginForm").addEventListener("submit", function (e) {
    e.preventDefault();
    el("login").hidden = true;
    el("app").hidden = false;
    boot();
  });

  function boot() {
    buildNav();
    buildUser();
    // theme
    el("themeBtn").textContent = "☾";
    el("themeBtn").addEventListener("click", function () {
      var r = document.documentElement;
      var dark = r.getAttribute("data-theme") === "dark";
      r.setAttribute("data-theme", dark ? "light" : "dark");
      el("themeBtn").textContent = dark ? "☾" : "☀";
    });
    el("menuBtn").addEventListener("click", function () {
      document.querySelector(".side").classList.toggle("open");
    });
    el("cartBtn").addEventListener("click", openCart);
    el("closeCart").addEventListener("click", closeCart);
    el("scrim").addEventListener("click", closeCart);
    window.addEventListener("hashchange", route);
    route();
  }

  function buildNav() {
    var side = el("sideNav"); side.innerHTML = "";
    NAV.forEach(function (n) {
      var b = document.createElement("button");
      b.className = "side__link"; b.dataset.route = n.id;
      b.innerHTML = '<span class="ic">' + n.ic + '</span>' + n.label;
      b.onclick = function () { location.hash = n.id; document.querySelector(".side").classList.remove("open"); };
      side.appendChild(b);
    });
    var bn = el("bottomNav"); bn.innerHTML = "";
    MOBILE_NAV.forEach(function (id) {
      var n = NAV.find(function (x) { return x.id === id; });
      var b = document.createElement("button");
      b.dataset.route = n.id;
      b.innerHTML = '<span class="ic">' + n.ic + '</span>' + n.label;
      b.onclick = function () { location.hash = n.id; };
      bn.appendChild(b);
    });
  }

  function buildUser() {
    var u = LN.user;
    el("topAvatar").textContent = u.initials;
    el("sideUser").innerHTML =
      '<div class="av">' + u.initials + '</div>' +
      '<div><b>' + u.name + '</b><small>' + u.rank + ' · ' + u.memberId + '</small></div>';
  }

  /* ---------------- Router ---------------- */
  function route() {
    var id = (location.hash || "#dashboard").slice(1);
    if (!NAV.find(function (n) { return n.id === id; })) id = "dashboard";
    var n = NAV.find(function (x) { return x.id === id; });
    el("pageTitle").textContent = n.label;
    document.querySelectorAll("[data-route]").forEach(function (b) {
      b.classList.toggle("active", b.dataset.route === id);
    });
    el("view").innerHTML = VIEWS[id]();
    if (id === "shop") wireShop();
    window.scrollTo(0, 0);
  }

  /* ---------------- Views ---------------- */
  var VIEWS = {
    dashboard: function () {
      var d = LN.dashboard;
      var max = Math.max.apply(null, d.earningsByMonth.map(function (x) { return x.v; }));
      var bars = d.earningsByMonth.map(function (x) {
        return '<div class="bar" style="height:' + (x.v / max * 100) + '%"><span>' + x.m + '</span></div>';
      }).join("");
      var kpis = d.kpis.map(function (k) {
        return '<div class="stat"><div class="k"><span class="dot" style="background:' + k.color + '"></span>' + k.k +
          '</div><div class="v">' + k.v + '</div><div class="d ' + (k.up ? "up" : "down") + '">' + k.d + '</div></div>';
      }).join("");
      var comms = d.recentCommissions.map(function (c) {
        return '<div class="row"><div class="av on">$</div><div class="grow"><b>' + c.who + '</b><small>' + c.when +
          '</small></div><div class="amt up">+' + money(c.amt) + '</div></div>';
      }).join("");
      return (
        '<div class="hero"><small>Earnings this month</small>' +
          '<div class="big">' + money(d.earningsMonth) + '</div>' +
          '<span class="delta">▲ ' + d.earningsDelta + '% vs last month</span>' +
          '<div class="sub" style="margin-top:10px">Available balance ' + money(d.availableBalance) +
          ' · Lifetime ' + money0(d.lifetime) + '</div></div>' +
        '<div class="stats">' + kpis + '</div>' +
        '<div class="grid-2">' +
          '<div class="card"><h3>Earnings — last 6 months</h3><div class="bars">' + bars + '</div><div style="height:16px"></div></div>' +
          '<div class="card"><div class="section-h" style="margin-bottom:10px"><h3 style="margin:0">Recent commissions</h3>' +
            '<a href="#commissions" class="muted-link">View all</a></div><div class="rows">' + comms + '</div></div>' +
        '</div>' +
        rankCard()
      );
    },

    team: function () {
      var t = LN.team;
      var rows = t.members.map(function (m) {
        return '<div class="tnode lvl' + m.lvl + '">' +
          '<div class="av' + (m.on ? ' on' : '') + '" style="width:40px;height:40px;border-radius:50%;display:grid;place-items:center;font-weight:700;background:' +
            (m.on ? 'var(--green)' : 'var(--lightgray-active)') + ';color:' + (m.on ? '#fff' : 'var(--fg)') + '">' +
            m.name.split(" ").map(function (w) { return w[0]; }).join("") + '</div>' +
          '<div class="grow"><b>' + m.name + '</b><small>' + m.pv + ' PV · team of ' + m.team + '</small></div>' +
          '<span class="rank">' + m.rank + '</span></div>';
      }).join("");
      return (
        '<div class="stats">' +
          stat("Frontline", t.frontline, "var(--primary)") +
          stat("Total team", t.total, "var(--green)") +
          stat("Active", t.active, "var(--orange)") +
          stat("Inactive", t.total - t.active, "var(--gray)") +
        '</div>' +
        '<div class="card"><div class="section-h" style="margin-bottom:14px"><h3 style="margin:0">Your organization</h3>' +
          '<span class="pill pill--green">' + Math.round(t.active / t.total * 100) + '% active</span></div>' +
          '<div class="tree">' + rows + '</div></div>'
      );
    },

    commissions: function () {
      var c = LN.commissions;
      var total = c.breakdown.reduce(function (s, b) { return s + b.value; }, 0);
      var seg = c.breakdown.map(function (b) {
        return '<div style="flex:' + b.value + ';background:' + b.color + '" title="' + b.label + '"></div>';
      }).join("");
      var legend = c.breakdown.map(function (b) {
        return '<div class="row" style="padding:9px 0"><span class="dot" style="background:' + b.color + '"></span>' +
          '<div class="grow">' + b.label + '</div><div class="amt">' + money0(b.value) +
          '<small class="muted" style="font-weight:600;margin-left:6px">' + Math.round(b.value / total * 100) + '%</small></div></div>';
      }).join("");
      var hist = c.history.map(function (h) {
        return '<div class="row"><div class="grow"><b>' + h.type + '</b><small>' + h.when + '</small></div>' +
          '<span class="pill pill--green">' + h.status + '</span><div class="amt" style="min-width:90px;text-align:right">' + money(h.amt) + '</div></div>';
      }).join("");
      return (
        '<div class="stats">' +
          stat("Paid YTD", money0(c.paidYTD), "var(--green)") +
          stat("Pending", money(c.pending), "var(--orange)") +
          statText("Next payout", fmtDate(c.nextPayout), "var(--primary)") +
        '</div>' +
        '<div class="grid-2">' +
          '<div class="card"><h3>Earnings breakdown — YTD</h3>' +
            '<div style="display:flex;height:14px;border-radius:7px;overflow:hidden;margin-bottom:8px">' + seg + '</div>' +
            '<div class="rows">' + legend + '</div></div>' +
          '<div class="card"><h3>Payout history</h3><div class="rows">' + hist + '</div></div>' +
        '</div>'
      );
    },

    shop: function () {
      var items = LN.shop.products.map(function (p) {
        return '<div class="productitem"><div class="ph">' + p.emoji + '</div>' +
          '<div class="pb"><h4>' + p.name + '</h4>' +
          '<div class="price">' + money(p.price) + '</div>' +
          '<div class="cv">' + p.cv + ' CV' + (p.auto ? ' · Autoship eligible' : '') + '</div>' +
          '<div class="foot"><button class="btn btn--primary btn--sm addBtn" data-id="' + p.id + '">Add to cart</button></div>' +
          '</div></div>';
      }).join("");
      return (
        '<div class="section-h"><h2>Products</h2><span class="muted">' + LN.shop.products.length + ' items · prices include commission volume (CV)</span></div>' +
        '<div class="products">' + items + '</div>'
      );
    },

    orders: function () {
      var rows = LN.orders.map(function (o) {
        return '<div class="row"><div class="av">📦</div><div class="grow"><b>' + o.id + '</b><small>' + o.date + ' · ' + o.items + ' items</small></div>' +
          '<span class="pill pill--blue">' + o.status + '</span><div class="amt" style="min-width:80px;text-align:right">' + money(o.total) + '</div></div>';
      }).join("");
      return '<div class="card"><h3>Order history</h3><div class="rows">' + rows + '</div></div>';
    },

    achievements: function () {
      var got = LN.achievements.filter(function (a) { return a.got; }).length;
      var cards = LN.achievements.map(function (a) {
        return '<div class="badge' + (a.got ? '' : ' locked') + '"><div class="em">' + a.em + '</div>' +
          '<h4>' + a.name + '</h4><small>' + a.desc + '</small></div>';
      }).join("");
      return (
        '<div class="section-h"><h2>Milestones</h2><span class="pill pill--green">' + got + ' / ' + LN.achievements.length + ' earned</span></div>' +
        '<div class="badges">' + cards + '</div>'
      );
    },

    settings: function () {
      var u = LN.user;
      return (
        '<div class="card"><p class="settingsheader">Profile</p>' +
          setRow("Name", u.name) + setRow("Email", u.email) +
          setRow("Member ID", u.memberId) + setRow("Rank", u.rank) +
          setRow("Member since", fmtDate(u.joined)) + '</div>' +
        '<div class="card"><p class="settingsheader">Your personal link</p>' +
          '<div class="copybox"><code>' + u.personalUrl + '</code>' +
          '<button class="btn btn--green btn--sm" id="copyUrl">Copy</button></div></div>' +
        '<div class="card"><p class="settingsheader">Notifications</p>' +
          toggleRow("Commission alerts", "Get notified on every payout", true) +
          toggleRow("Team activity", "New enrollments and rank-ups", true) +
          toggleRow("Autoship reminders", "Before each monthly order", true) +
          toggleRow("Product announcements", "New launches and promos", false) + '</div>' +
        '<div class="card"><p class="settingsheader">Security</p>' +
          setRowAction("Password", "Last changed 42 days ago", "Change") +
          setRowAction("Two-factor auth", "Add an extra layer of security", "Enable") + '</div>' +
        '<button class="btn btn--ghost" id="signout">Sign out</button>'
      );
    }
  };

  /* ---------------- View helpers ---------------- */
  function stat(k, v, color) {
    return '<div class="stat"><div class="k"><span class="dot" style="background:' + color + '"></span>' + k + '</div><div class="v">' + v + '</div></div>';
  }
  function statText(k, v, color) {
    return '<div class="stat"><div class="k"><span class="dot" style="background:' + color + '"></span>' + k + '</div><div class="v" style="font-size:18px">' + v + '</div></div>';
  }
  function setRow(k, v) { return '<div class="setrow"><div class="grow"><b>' + k + '</b></div><div class="muted">' + v + '</div></div>'; }
  function setRowAction(k, sub, action) {
    return '<div class="setrow"><div class="grow"><b>' + k + '</b><small>' + sub + '</small></div><button class="btn btn--ghost btn--sm">' + action + '</button></div>';
  }
  function toggleRow(k, sub, on) {
    return '<div class="setrow"><div class="grow"><b>' + k + '</b><small>' + sub + '</small></div>' +
      '<button class="switch' + (on ? ' on' : '') + '" onclick="this.classList.toggle(\'on\')"></button></div>';
  }
  function rankCard() {
    var d = LN.dashboard, u = LN.user;
    return '<div class="card"><div class="section-h" style="margin-bottom:12px">' +
      '<h3 style="margin:0">Rank progress</h3><span class="pill pill--blue">' + u.rank + ' → ' + u.nextRank + '</span></div>' +
      '<div style="height:12px;background:var(--lightgray-active);border-radius:999px;overflow:hidden">' +
      '<div style="height:100%;width:' + (d.rankProgress * 100) + '%;background:linear-gradient(90deg,var(--primary),var(--green))"></div></div>' +
      '<div class="muted" style="margin-top:8px;font-size:13px">' + Math.round(d.rankProgress * 100) + '% of the way to ' + u.nextRank + '. Keep your team volume growing.</div></div>';
  }
  function fmtDate(iso) {
    var d = new Date(iso + (iso.length === 10 ? "T00:00:00" : ""));
    return d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
  }

  /* ---------------- Shop + cart ---------------- */
  function wireShop() {
    document.querySelectorAll(".addBtn").forEach(function (b) {
      b.onclick = function () { addToCart(b.dataset.id); b.textContent = "Added ✓"; setTimeout(function () { b.textContent = "Add to cart"; }, 1000); };
    });
    el("copyUrl") && (el("copyUrl").onclick = function () {});
    document.addEventListener("click", settingsDelegate);
  }
  function settingsDelegate(e) {
    if (e.target && e.target.id === "signout") { location.reload(); }
    if (e.target && e.target.id === "copyUrl") {
      try { navigator.clipboard.writeText(LN.user.personalUrl); } catch (x) {}
      e.target.textContent = "Copied ✓"; setTimeout(function () { e.target.textContent = "Copy"; }, 1200);
    }
  }

  function addToCart(id) { cart[id] = (cart[id] || 0) + 1; renderCart(); }
  function setQty(id, delta) {
    cart[id] = (cart[id] || 0) + delta;
    if (cart[id] <= 0) delete cart[id];
    renderCart();
  }
  window.__lnSetQty = setQty;

  function cartTotals() {
    var qty = 0, subtotal = 0, cv = 0;
    Object.keys(cart).forEach(function (id) {
      var p = LN.shop.products.find(function (x) { return x.id === id; });
      qty += cart[id]; subtotal += p.price * cart[id]; cv += p.cv * cart[id];
    });
    return { qty: qty, subtotal: subtotal, cv: cv };
  }
  function renderCart() {
    var t = cartTotals();
    el("cartCount").textContent = t.qty;
    el("cartCount").dataset.n = t.qty;
    var lines = Object.keys(cart).map(function (id) {
      var p = LN.shop.products.find(function (x) { return x.id === id; });
      return '<div class="cartItem"><div class="thumb">' + p.emoji + '</div>' +
        '<div class="grow"><b>' + p.name + '</b><small>' + money(p.price) + ' · ' + p.cv + ' CV</small></div>' +
        '<div class="qty"><button onclick="__lnSetQty(\'' + id + '\',-1)">−</button><span>' + cart[id] +
        '</span><button onclick="__lnSetQty(\'' + id + '\',1)">+</button></div></div>';
    }).join("") || '<p class="muted" style="text-align:center;padding:40px 0">Your cart is empty.</p>';
    el("cartLines").innerHTML = lines;
    el("cartSummary").innerHTML =
      '<div class="line"><span>Items</span><span>' + t.qty + '</span></div>' +
      '<div class="line"><span>Commission volume</span><span>' + t.cv + ' CV</span></div>' +
      '<div class="line total"><span>Subtotal</span><span>' + money(t.subtotal) + '</span></div>' +
      '<button class="btn btn--green btn--block" ' + (t.qty ? '' : 'disabled style="opacity:.5"') + '>Checkout</button>';
  }
  function openCart() { el("cart").hidden = false; el("scrim").hidden = false; renderCart(); }
  function closeCart() { el("cart").hidden = true; el("scrim").hidden = true; }

  renderCart();
})();
