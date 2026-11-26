import SwiftUI
import UIKit
import WebKit

// Legacy Network — the app is the web replica itself, bundled as replica.html and
// shown full-screen in WebKit. Nothing is redrawn natively, so every color, logo,
// font and pixel is exactly what the replica page renders.

@main
struct LegacyNetworkApp: App {
    init() {
        EventLog.configure(url: "https://lbvaosyfikkpvcwksiph.supabase.co", apiKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxidmFvc3lmaWtrcHZjd2tzaXBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwMDg0MDksImV4cCI6MjA5MDU4NDQwOX0.Gh9whjmUPz4rdKYr5yo8ZHS0nSNpkQUOwdIladX6mG4", project: "legacy-network")   // append-only event log (public.event_log)
    }
    var body: some Scene {
        WindowGroup { ReplicaScreen() }
    }
}

/// Colors painted behind the status bar and home indicator so they always match
/// whatever the page is showing at its top and bottom edges.
final class EdgeColors: ObservableObject {
    static let legacyBlue = Color(red: 0x31 / 255.0, green: 0x71 / 255.0, blue: 0xCC / 255.0)
    @Published var top: Color = EdgeColors.legacyBlue
    @Published var bottom: Color = EdgeColors.legacyBlue
}

struct ReplicaScreen: View {
    @StateObject private var edges = EdgeColors()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                edges.top
                edges.bottom
            }
            .ignoresSafeArea()
            ReplicaWebView(edges: edges)
        }
    }
}

struct ReplicaWebView: UIViewRepresentable {
    let edges: EdgeColors

    func makeCoordinator() -> Coordinator { Coordinator(edges: edges) }

    func makeUIView(context: Context) -> WKWebView {
        let content = WKUserContentController()
        content.add(context.coordinator, name: "ln")
        content.addUserScript(WKUserScript(source: Coordinator.bridgeJS,
                                           injectionTime: .atDocumentStart,
                                           forMainFrameOnly: true))
        let config = WKWebViewConfiguration()
        config.userContentController = content
        config.allowsInlineMediaPlayback = true

        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = .clear
        web.scrollView.backgroundColor = .clear
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.overrideUserInterfaceStyle = .light
        web.allowsBackForwardNavigationGestures = false
        web.navigationDelegate = context.coordinator
        web.uiDelegate = context.coordinator
        if #available(iOS 16.4, *) { web.isInspectable = true }
        context.coordinator.load(into: web, path: "/")
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        /// The page uses the real app.legacynetwork.com paths, so it is loaded under
        /// that origin. Everything it needs is inside the bundled file; nothing is fetched.
        static let origin = "https://app.legacynetwork.com"

        private let edges: EdgeColors
        private var html: String?
        private var allowNextLoad = false

        init(edges: EdgeColors) { self.edges = edges }

        func load(into web: WKWebView, path: String) {
            let job = EventLog.job("replica.load")
            if html == nil {
                guard let url = Bundle.main.url(forResource: "replica", withExtension: "html") else {
                    job.end(status: "fail", ["reason": "replica.html missing from bundle"])
                    return
                }
                do { html = try String(contentsOf: url, encoding: .utf8) }
                catch { job.fail(error); return }
            }
            guard let html else { return }
            allowNextLoad = true
            web.loadHTMLString(html, baseURL: URL(string: Coordinator.origin + path))
            job.end(["path": path, "bytes": html.utf8.count])
        }

        // MARK: navigation

        func webView(_ webView: WKWebView,
                     decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard action.targetFrame?.isMainFrame ?? false else { decisionHandler(.allow); return }
            if allowNextLoad {
                allowNextLoad = false
                decisionHandler(.allow)
                return
            }
            guard let url = action.request.url else { decisionHandler(.cancel); return }
            let scheme = url.scheme?.lowercased() ?? ""
            if ["about", "data", "blob", "javascript"].contains(scheme) { decisionHandler(.allow); return }

            decisionHandler(.cancel)
            if action.navigationType == .formSubmitted {
                EventLog.action("nav.form_blocked", ["url": url.absoluteString])
                return
            }
            if url.host?.lowercased() == "app.legacynetwork.com" {
                // A full page load inside the replica: serve the bundled page at that path instead.
                EventLog.action("nav.reload_replica", ["path": url.path])
                load(into: webView, path: url.path.isEmpty ? "/" : url.path)
                return
            }
            if ["http", "https", "mailto", "tel", "sms"].contains(scheme) {
                EventLog.action("nav.open_external", ["url": url.absoluteString])
                UIApplication.shared.open(url)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            EventLog.action("replica.ready", ["url": webView.url?.absoluteString ?? ""])
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            EventLog.error(error, name: "replica.nav_fail")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            EventLog.error(error, name: "replica.nav_fail_provisional")
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            EventLog.action("replica.process_terminated_reloading")
            load(into: webView, path: "/")
        }

        // MARK: popups and JS dialogs

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = action.request.url {
                EventLog.action("nav.open_external", ["url": url.absoluteString])
                UIApplication.shared.open(url)
            }
            return nil
        }

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            if !present(alert, from: webView) { completionHandler() }
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
            if !present(alert, from: webView) { completionHandler(false) }
        }

        private func present(_ alert: UIAlertController, from view: UIView) -> Bool {
            guard var top = view.window?.rootViewController else { return false }
            while let next = top.presentedViewController { top = next }
            top.present(alert, animated: true)
            return true
        }

        // MARK: bridge from the page

        func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: Any], let type = body["t"] as? String else { return }
            switch type {
            case "edges":
                let top = Coordinator.color(from: body["top"] as? String)
                let bottom = Coordinator.color(from: body["bottom"] as? String)
                DispatchQueue.main.async {
                    if let top { self.edges.top = top }
                    if let bottom { self.edges.bottom = bottom }
                }
            case "route":
                EventLog.action("screen.view", ["path": body["p"] as? String ?? "", "how": body["k"] as? String ?? ""])
            case "tap":
                EventLog.action("tap", ["label": body["x"] as? String ?? "", "id": body["id"] as? String ?? "",
                                        "view": body["v"] as? String ?? "", "path": body["p"] as? String ?? ""])
            case "error":
                EventLog.shared.log(.error, "replica.js_error", status: "fail",
                                    payload: ["source": body["s"] as? String ?? ""],
                                    errorMessage: body["m"] as? String ?? "")
            default:
                break
            }
        }

        /// Parses "rgb(r, g, b)" / "rgba(r, g, b, a)" from getComputedStyle.
        static func color(from css: String?) -> Color? {
            guard let css else { return nil }
            let nums = css.split(whereSeparator: { !"0123456789.".contains($0) }).compactMap { Double($0) }
            guard nums.count >= 3 else { return nil }
            return Color(red: nums[0] / 255.0, green: nums[1] / 255.0, blue: nums[2] / 255.0)
        }

        static let bridgeJS = #"""
        (function () {
          function post(m) { try { window.webkit.messageHandlers.ln.postMessage(m); } catch (e) {} }

          function parse(c) {
            var m = (c || '').match(/rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+)\s*)?\)/);
            if (!m) return null;
            return [+m[1], +m[2], +m[3], m[4] === undefined ? 1 : +m[4]];
          }
          // Color actually seen at (x, y): composite every translucent layer
          // (e.g. a modal scrim) over the first opaque background beneath it.
          function bgAt(x, y) {
            var stack = document.elementsFromPoint ? document.elementsFromPoint(x, y) : [];
            var layers = [], base = null;
            for (var i = 0; i < stack.length; i++) {
              var c = parse(getComputedStyle(stack[i]).backgroundColor);
              if (!c || c[3] === 0) continue;
              if (c[3] >= 0.99) { base = c; break; }
              layers.push(c);
            }
            if (!base) base = parse(getComputedStyle(document.documentElement).backgroundColor) || [49, 113, 204, 1];
            if (base[3] < 0.99) base = [255, 255, 255, 1];
            for (var j = layers.length - 1; j >= 0; j--) {
              var l = layers[j], a = l[3];
              base = [l[0] * a + base[0] * (1 - a), l[1] * a + base[1] * (1 - a), l[2] * a + base[2] * (1 - a), 1];
            }
            return 'rgb(' + Math.round(base[0]) + ', ' + Math.round(base[1]) + ', ' + Math.round(base[2]) + ')';
          }
          var lastTop = '', lastBottom = '';
          function sample() {
            if (!document.body) return;
            var x = Math.floor(window.innerWidth / 2);
            var top = bgAt(x, 0), bottom = bgAt(x, window.innerHeight - 1);
            if (top !== lastTop || bottom !== lastBottom) {
              lastTop = top; lastBottom = bottom;
              post({ t: 'edges', top: top, bottom: bottom });
            }
          }

          function route(kind) { post({ t: 'route', p: location.pathname + location.search, k: kind }); setTimeout(sample, 0); }
          var push = history.pushState, replace = history.replaceState;
          history.pushState = function () { var r = push.apply(this, arguments); route('push'); return r; };
          history.replaceState = function () { var r = replace.apply(this, arguments); route('replace'); return r; };
          window.addEventListener('popstate', function () { route('pop'); });

          document.addEventListener('click', function (e) {
            var t = e.target && e.target.closest ? e.target : null;
            if (!t) return;
            var el = t.closest('a,button,[data-view],[data-go],[role=switch],li,label') || t;
            var label = ((el.innerText || el.getAttribute('aria-label') || '') + '').trim().replace(/\s+/g, ' ').slice(0, 80);
            post({ t: 'tap', x: label, id: el.id || '',
                   v: el.getAttribute('data-view') || el.getAttribute('data-go') || '',
                   p: location.pathname });
            setTimeout(sample, 50); setTimeout(sample, 400);
          }, true);

          window.addEventListener('error', function (e) {
            post({ t: 'error', m: String(e.message || ''), s: (e.filename || '') + ':' + (e.lineno || 0) });
          });
          window.addEventListener('unhandledrejection', function (e) {
            post({ t: 'error', m: 'unhandled rejection: ' + String(e.reason), s: '' });
          });

          document.addEventListener('DOMContentLoaded', function () { route('load'); sample(); });
          setInterval(sample, 300);
        })();
        """#
    }
}
