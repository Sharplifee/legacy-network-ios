# Legacy Network — Web Replica

A clean-room front-end replica of the **current live** Legacy Network web
experience, rebuilt from public assets, captured structure, and the live design
tokens. No proprietary source, scraped database, or member PII is used.

## Scope

This repo rebuilds the Legacy Network product as **one web replica** in two parts:

1. **Marketing site** — replica of `legacynetwork.com` (this folder, `index.html`
   + `styles.css`). Fully public content: real section flow, real brand copy, the
   live gold / navy / cream palette, and Poppins + Cabin Condensed type. **Done.**
2. **Member area** — shell + screens matching the live `app.legacynetwork.com`
   Vue SPA (`beta-1.6.8`) design system (blue `#3171CC` / teal `#21BCAA`, Open
   Sans, 10px radius). Built on mock data, ready to swap in real member data from
   an owner-supplied HAR capture. **Next.**

## Run locally

```bash
cd web
python3 -m http.server 4310
# open http://localhost:4310/index.html
```

## Design tokens (marketing)

| Token | Value |
|-------|-------|
| Gold | `#D4AF37` |
| Navy | `#001031` |
| Cream | `#f4f1ea` |
| Display font | Cabin Condensed |
| Body font | Poppins |

`Member Login` links point at the live app (`app.legacynetwork.com/login`); no
authentication is implemented here.

## Provenance / method

Reconstructed by **clean-room (black-box) reverse engineering + re-platforming**:
the *what* (structure, copy, visual language) is rebuilt from public pages and
the live CSS bundle; none of the original implementation is copied. Real member
data enters only via an owner-provided HAR, and only into a private target.
