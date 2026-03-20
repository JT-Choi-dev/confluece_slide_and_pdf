# Project History — Confluence PDF Exporter

## 1. User Request — Confluence PDF Quality Improvement
- Confluence Cloud's built-in PDF exporter produces poor output; code blocks lack line numbers.
- Requested a tool using MCP to connect to Confluence and convert pages to HTML/PDF.
- Domain: `https://pinkwink.atlassian.net/`, Output: HTML + PDF

## 2. Claude — Approach Design & Planning
- Chose **REST API + Python script** over Confluence MCP Server or WebFetch.
- Created conda environment `confluence` (Python 3.11).
- Packages: `requests`, `beautifulsoup4`, `playwright`, `python-dotenv`.

## 3. Claude — Core Script Implementation
- Wrote `confluence_export.py`: REST API v2/v1 auto-switch, page ID extraction from URL, code block line numbers, base64 image embedding, macro conversion, PDF generation via Playwright Chromium.

## 4. Claude — Image Download Path Fix
- Fixed image download URL requiring `/wiki` prefix for Confluence Cloud.

## 5. User Request — Cover Page + TOC Page
- Requested a title page (PinkLAB logo + title) and a table of contents page.

## 6. Claude — Cover & TOC Implementation
- Cover page: PinkLAB logo + centered title with page-break.
- TOC page: hierarchical numbering (1.1, 1.1.1...) with anchor links.

## 7. User Request — Layout Improvement + Last Page + Documentation
- Move PinkLAB logo to bottom 1/4 of cover page.
- Add YouTube channel promotion (`@pinklab_studio`) on the last page.
- Create `history.html`, `architecture.html`, `README.md`.

## 8. Claude — Final Implementation
- Cover: title+meta at top 3/4, logo at bottom 1/4.
- Last page: PinkLAB logo, YouTube subscribe button, channel URL.
- All 3 documents created.

## 9. User Request — Presentation Mode
- Convert Confluence pages into slide-style presentations. H1/H2 as title slides, H3+ as content slides.

## 10. Claude — Presentation Mode Implementation
- 16:9 slide layout with topbar (section + title + logo) and footer (author + page number).
- Keyboard navigation: Space/Arrow/PageUp/Down/Home/End + mouse wheel.
- Slide PDF: 1280×720px page size.
- Video attachment auto-download & `<video>` tag playback support.

## 11. User Request — Usage Cleanup + Documentation Update
- Switch token management from `.env` to `confluence_token.txt`.
- Consolidate output to 3 files: Document PDF + Presentation HTML + Presentation PDF.

## 12. Claude — Final Cleanup
- Removed `python-dotenv` dependency, direct `confluence_token.txt` parsing.
- 3 output files (removed Document HTML).
- Rewrote `README.md`, updated `history.html` and `architecture.html`.

## 13. User Request — Presentation Image Scaling + Cover Cleanup
- Small images in presentations displayed at original small size — requested scaling up to fit slides.
- Remove "Exported from Confluence", URL, and date meta info from the cover slide.

## 14. Claude — Presentation Image Scaling & Cover Cleanup
- **Image scaling**: Removed inline `width`/`height` attributes from images in `build_presentation_html()`. Added CSS `min-height: 200px` so small images scale up to fill available slide space.
- **Cover cleanup**: Removed `cover-meta` section (Exported from Confluence, URL, date) from the cover slide — now shows only title + divider + logo.

## 15. User Request — Document PDF Cover Meta Removal
- Remove "Exported from Confluence", URL, and date info from the document PDF cover page as well.

## 16. Claude — Document PDF Cover Meta Removal
- Removed `cover-meta` div from `build_cover_page()`. Cleaned up unused `from datetime import date` import and `today` variable.

## 17. User Request — UNKNOWN_ATTACHMENT Image Fix
- Reported broken images on a specific page where Confluence stored filenames as `UNKNOWN_ATTACHMENT`.

## 18. Claude — UNKNOWN_ATTACHMENT Fallback
- Root cause: Confluence paste bug stores `ri:filename="UNKNOWN_ATTACHMENT"` while `ac:alt` contains the real filename.
- Added fallback in `process_images()`: when `ri:filename` is `UNKNOWN_ATTACHMENT`, extract the real filename from `ac:alt`.

## 19. User Request — Presentation TOC Navigation (2026-03-07)
- Requested a keyboard-triggered TOC popup for quick slide navigation in presentations.
- TOC should list H1, H2, H3 headings with hierarchy and allow jumping to any slide.

## 20. Claude — TOC Navigation Implementation
- **TOC overlay**: Floating panel triggered by `T` key, showing all heading slides (H1/H2/H3) with hierarchical indentation.
- **Keyboard navigation**: Arrow keys to move selection, Enter to jump, T/Escape to close.
- **Visual design**: Semi-transparent backdrop, animated panel, current slide highlighted, page numbers shown.
- **CSS**: Added `.toc-overlay`, `.toc-panel`, `.toc-item` styles with level-based indentation. Hidden in print.
- **Data attributes**: Each slide with a heading gets `data-toc-level` and `data-toc-title` for JS-based TOC building.

## 21. User Request — Presentation Panel Slide Filling (2026-03-09)
- H3 content slides with panel macros (Info/Note/Warning/etc.) show panels as small boxes, leaving most of the slide empty.
- Requested panels to expand and fill the slide area when content is sparse.

## 22. Claude — Panel Auto-Expand in Presentations
- **Panel flex expansion**: Added `flex: 1; width: 100%` to `.confluence-panel` and `.confluence-custom-panel` so they grow to fill the `content-inner` container.
- **Content-inner flex**: Made `.content-inner` use `flex: 1; width: 100%` to fill the full `content-body` area.
- **Typography scaling**: Increased panel font size from 14px to 18px, padding from 12px/16px to 20px/28px, and border-left from 4px to 5px for better slide readability.
- **Custom panel body**: Added `flex: 1; justify-content: center` to `.confluence-custom-panel-body` so titled panels also fill the slide.

## 23. User Request — Web GUI (2026-03-10)
- Requested a browser-based GUI instead of CLI-only usage.
- Features: page URL input, custom logo upload, output directory selection, custom filenames for 3 output files.
- Default logo: PinkLAB, default filenames: auto-generated from page title.

## 24. Claude — Web GUI Implementation (Flask)
- **Server**: Chose Flask for simplicity, lightweight footprint, and easy conda installation.
- **`app.py`**: Flask server with REST API endpoints for export, status polling, logo upload/reset, and defaults.
- **`templates/index.html`**: Single-page web UI with light design, real-time progress log, file result display.
- **Architecture**:
  - `POST /api/export` — Starts export in background thread, returns job ID.
  - `GET /api/status/<id>` — Returns progress log and completion status (polling).
  - `POST /api/logo/upload` — Saves uploaded logo to `uploads/` directory.
  - `POST /api/logo/reset` — Resets to default PinkLAB logo.
  - `GET /api/defaults` — Returns default output directory path.
- **Custom logo**: Temporarily monkey-patches `ce.load_logo_base64()` during export to use uploaded logo.
- **Custom filenames**: User can override all 3 output filenames; extensions auto-appended if missing.
- **Static files**: `static/` directory with symlinked PinkLAB logo for preview.
- Updated `.gitignore` (added `uploads/`), `README.md`, `history.md`, `architecture.md`.

## 25. User Request — Output File Links + Per-File Toggle (2026-03-10)
- Provide direct links to open the 3 generated files in the browser after export.
- Add checkboxes in Output Settings to enable/disable generation of each file (default: all selected).

## 26. Claude — File Open Links & Generation Toggle
- **Open links**: Added "Open" button per result file. `GET /api/files/<path>` route serves files for in-browser viewing in a new tab.
- **Checkbox toggle**: Added checkbox per output file (Document PDF, Presentation HTML, Presentation PDF). Unchecked items disable the filename input and skip generation on the server.
- **Skip logic**: `enable_doc_pdf`, `enable_present_html`, `enable_present_pdf` flags sent to API. When only Presentation PDF is selected, a temp HTML is generated and deleted after PDF creation.
- **Validation**: Returns "At least one output must be enabled" error when all three are unchecked.
- Updated `history.md`, `architecture.md`, `README.md`.

## 27. User Request — Documentation Cleanup + macOS Launcher (2026-03-10)
- Keep `history.html` in Korean.
- Create a macOS shortcut to activate conda, start app.py, and open the browser in one click.

## 28. Claude — Korean History HTML & macOS Launcher
- **history.html**: Rewrote entirely in Korean including #23~#28.
- **`start.command`**: macOS double-click launcher — initializes conda, activates `confluence` environment, starts Flask server, and opens `http://localhost:5001` in the default browser after a 2-second delay.
- Updated `history.md`, `README.md`.

## 29. User Request — Presentation Code Block & H3 Heading Improvements (2026-03-13)
- Code blocks in presentations use dark theme — requested a lighter theme for better readability.
- Code block line spacing should be 1.2× (line numbers keep original spacing).
- Font size should be larger (~12px).
- H3 headings with no content should visually appear the same as H2 (title-only heading slide).

## 30. Claude — Light Code Theme & Title-Only H3 Heading Slides
- **Code block light theme**: Changed presentation code block from dark (#2d2d2d) to light (#F8F9FA) background, header from #404040 to #EDF2F7, line number background from #363636 to #EDF2F7, text color from #e0e0e0 to #2D3748. Added subtle border (#E2E8F0).
- **Code line spacing**: Set `.code-line-text` line-height to 1.2 (was 1.5). Line number line-height kept at 1.5 for consistent alignment.
- **H3 title-only slides**: When an H3 heading has no following content, it is now rendered as a `slide-heading` (same visual as H1/H2 title slides) instead of a `slide-content` with empty body. TOC level preserved as `h3`.
- Updated `history.md`.
