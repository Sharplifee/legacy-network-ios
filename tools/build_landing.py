"""Turn the rendered legacynetwork.com homepage into a self-hosted static page.

- Strips the site builder's scripts (the page is captured fully rendered).
- Downloads every image, stylesheet and font into assets/ and rewrites URLs.
- Re-creates the two video players with video.js (self-hosted), playing the
  same MP4s, with the "Enable sound" buttons wired up.
- Keeps the Legacy IQ chat widget by loading its own script.
- Sends both "Member Login" buttons to /login (the replica's login screen).
"""
import hashlib, os, re, sys, urllib.parse
import requests
from bs4 import BeautifulSoup

SRC, OUT = sys.argv[1], sys.argv[2]
ASSETS = os.path.join(OUT, "assets")
os.makedirs(ASSETS, exist_ok=True)
BASE = "https://legacynetwork.com/"
UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")
S = requests.Session(); S.headers["User-Agent"] = UA
cache = {}

VIDEOS = {  # player id -> source MP4 (order taken from the page's own data)
    "video-ac3JwrTRvp": "https://assets.cdn.filesafe.space/1T6HV1FE6ut5jqpssuhn/media/6a9b2e843dd2068ce696dcdb.mp4",
    "video-QiRjqIOodn": "https://assets.cdn.filesafe.space/1T6HV1FE6ut5jqpssuhn/media/6a9ebeaaa2de8f8e8fbadb21.mp4",
}
EXT = {"image/webp": ".webp", "image/png": ".png", "image/jpeg": ".jpg", "image/svg+xml": ".svg",
       "image/gif": ".gif", "image/x-icon": ".ico", "image/vnd.microsoft.icon": ".ico",
       "font/woff2": ".woff2", "font/woff": ".woff", "font/ttf": ".ttf", "text/css": ".css",
       "application/javascript": ".js", "text/javascript": ".js"}


def fetch(url):
    """Download url once into assets/, return its public path."""
    url = url.replace("&amp;", "&")
    if url in cache:
        return cache[url]
    r = S.get(url, timeout=60)
    r.raise_for_status()
    ctype = r.headers.get("content-type", "").split(";")[0].strip()
    ext = EXT.get(ctype) or os.path.splitext(urllib.parse.urlparse(url).path)[1][:6] or ".bin"
    name = hashlib.sha1(url.encode()).hexdigest()[:16] + ext
    body = r.content
    if ext == ".css":
        body = rewrite_css(r.text, url).encode()
    with open(os.path.join(ASSETS, name), "wb") as f:
        f.write(body)
    cache[url] = "/landing/assets/" + name
    return cache[url]


def rewrite_css(css, base):
    def rep(m):
        raw = m.group(2).strip()
        if raw.startswith(("data:", "#")) or not raw:
            return m.group(0)
        absu = urllib.parse.urljoin(base, raw)
        try:
            return f"url({fetch(absu)})"
        except Exception as e:
            print("  css asset failed", absu[:120], e)
            return m.group(0)
    css = re.sub(r"url\((['\"]?)([^'\")]+)\1\)", rep, css)
    def imp(m):
        return f'@import url({fetch(urllib.parse.urljoin(base, m.group(2)))});'
    return re.sub(r"@import\s+(['\"])([^'\"]+)\1\s*;", imp, css)


def fix_srcset(v):
    out = []
    for part in v.split(","):
        bits = part.strip().split()
        if not bits:
            continue
        bits[0] = fetch(urllib.parse.urljoin(BASE, bits[0]))
        out.append(" ".join(bits))
    return ", ".join(out)


html = open(SRC, encoding="utf-8").read()
soup = BeautifulSoup(html, "html.parser")

# 1. scripts and script preloads out (page is already rendered)
for t in soup.find_all(["script", "noscript"]):
    t.decompose()
for t in soup.find_all("link"):
    rel = " ".join(t.get("rel", []))
    if t.get("as") == "script" or "modulepreload" in rel or "preconnect" in rel or "dns-prefetch" in rel \
            or ("preload" in rel and t.get("as") == "style"):
        t.decompose()

# 2. Legacy IQ widget: drop the rendered copy, load its live script instead
w = soup.find(id="legacy-iq-widget")
if w:
    w.decompose()

# 3. stylesheets -> local files
for t in soup.find_all("link", rel=True):
    rel = " ".join(t["rel"])
    if "stylesheet" in rel and t.get("href"):
        t["href"] = fetch(urllib.parse.urljoin(BASE, t["href"]))
        t["media"] = "all"
        if t.has_attr("onload"):
            del t["onload"]
    elif "icon" in rel and t.get("href"):
        t["href"] = fetch(urllib.parse.urljoin(BASE, t["href"]))

# 4. inline <style> blocks and style="" attributes
for t in soup.find_all("style"):
    if t.string:
        t.string.replace_with(rewrite_css(t.string, BASE))
for t in soup.find_all(style=True):
    if "url(" in t["style"]:
        t["style"] = rewrite_css(t["style"], BASE)

# 5. images
for t in soup.find_all(["img", "source"]):
    for attr in ("src", "data-src"):
        v = t.get(attr)
        if v and not v.startswith(("data:", "blob:")):
            t[attr] = fetch(urllib.parse.urljoin(BASE, v))
    for attr in ("srcset", "data-srcset"):
        if t.get(attr):
            t[attr] = fix_srcset(t[attr])

# 6. video players -> fresh video.js players on the same MP4s
for pid, mp4 in VIDEOS.items():
    old = soup.find(id=f"{pid}-video-js")
    if not old:
        print("video container missing", pid); continue
    classes = [c for c in old.get("class", []) if c in (
        "video-js", "vjs-ghl", "vjs-big-play-centered", "vjs-fluid", f"{pid}-video-js-dimensions")]
    v = soup.new_tag("video", id=f"{pid}-video-js", attrs={
        "class": " ".join(classes), "playsinline": "", "muted": "", "autoplay": "", "preload": "auto",
        "controls": ""})
    v.append(soup.new_tag("source", src=mp4, type="video/mp4"))
    old.replace_with(v)

# 7. links: Member Login -> replica login; relative links -> real site
for a in soup.find_all("a", href=True):
    h = a["href"].strip()
    if "app.legacynetwork.com/login" in h:
        a["href"] = "/login"
        a["target"] = ""
    elif h.startswith("/") and not h.startswith("//"):
        a["href"] = urllib.parse.urljoin(BASE, h)

# 8. video.js + small glue + Legacy IQ widget
vjs_css = fetch("https://stcdn.leadconnectorhq.com/videojs/8.0.0/video-js.css")
vjs_js = fetch("https://stcdn.leadconnectorhq.com/videojs/8.0.0/video.min.js")
head = soup.head
if not any(l.get("href") == vjs_css for l in soup.find_all("link")):
    head.append(soup.new_tag("link", rel="stylesheet", href=vjs_css))
body = soup.body or soup
body.append(soup.new_tag("script", src=vjs_js))
glue = soup.new_tag("script")
glue.string = """
(function () {
  var ids = %s;
  ids.forEach(function (id) {
    var el = document.getElementById(id + '-video-js');
    if (!el || !window.videojs) return;
    var p = videojs(el, { fluid: true, autoplay: 'muted', muted: true, controls: true, preload: 'auto' });
    var wrap = el.closest('.video-container') || el.parentElement;
    var host = wrap; for (var i = 0; i < 4 && host && !host.querySelector('.enable-sound-button'); i++) host = host.parentElement;
    var btn = host && host.querySelector('.enable-sound-button');
    if (btn) btn.addEventListener('click', function () { p.muted(false); p.volume(1); p.play(); btn.style.display = 'none'; });
    p.ready(function () { var pr = p.play(); if (pr && pr.catch) pr.catch(function () {}); });
    p.on('volumechange', function () { if (btn && !p.muted()) btn.style.display = 'none'; });
  });
})();
""" % [k for k in VIDEOS]
body.append(glue)
body.append(soup.new_tag("script", src="https://legacy-iq-brain.vercel.app/widget.js", defer=""))

with open(os.path.join(OUT, "index.html"), "w", encoding="utf-8") as f:
    f.write(str(soup))
print("assets:", len(cache), "bytes:", sum(os.path.getsize(os.path.join(ASSETS, x)) for x in os.listdir(ASSETS)))
