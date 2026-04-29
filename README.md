# Confluence PDF Exporter

A Python tool that converts Confluence Cloud pages into **document PDFs** and **presentations (slides)**. Available as both a **web GUI** and a **CLI**.

It addresses the limitations of Confluence's built-in PDF exporter (e.g., missing line numbers in code blocks, poor styling) and allows pages to be used directly as presentation materials.

## Features

- **Web GUI** — Browser-based interface (Flask) with real-time progress
- **Document PDF** — Cover page + auto-generated TOC + body + back page
- **Presentation HTML** — Slide-based presentation (keyboard/mouse navigation)
- **Presentation PDF** — 16:9 slide PDF
- Custom logo support (default: PinkLAB logo)
- Configurable output directory and filenames
- Line numbers in code blocks
- Base64 inline image embedding (standalone)
- Automatic video attachment download & playback support
- Confluence macro conversion (panels, expand, status, emoticon, links, etc.)

## Prerequisites

- Confluence Cloud account + API Token
- **macOS**: [Conda](https://docs.conda.io/) (Miniconda or Anaconda)
- **Windows**: Python 3.10+ (no Conda required)

## Setup

### macOS — Conda

#### 1. Create Conda Environment

```bash
conda create -n confluence python=3.11 -y
conda activate confluence
```

#### 2. Install Packages

```bash
pip install requests beautifulsoup4 playwright flask
playwright install chromium
```

#### 3. Configure Authentication

Create a `confluence_token.txt` file in the project root:

```
CONFLUENCE_URL=https://your-domain.atlassian.net
CONFLUENCE_EMAIL=your-email@example.com
CONFLUENCE_API_TOKEN=your-api-token-here
```

> You can generate an API Token at [Atlassian API Token Management](https://id.atlassian.com/manage-profile/security/api-tokens).

---

### Windows — Python venv

> Conda 없이 Python 기본 가상환경(venv)으로 실행할 수 있습니다.

#### 1. Clone & Setup (최초 1회)

```bash
git clone https://github.com/JT-Choi-dev/confluece_slide_and_pdf
cd confluece_slide_and_pdf
```

`setup.bat`을 더블클릭하면 자동으로:
- `venv` 가상환경 생성
- 패키지 설치 (`requirements.txt`)
- Playwright Chromium 설치

#### 2. Configure Authentication

프로젝트 루트에 `confluence_token.txt` 파일 생성:

```
CONFLUENCE_URL=https://your-domain.atlassian.net
CONFLUENCE_EMAIL=your-email@example.com
CONFLUENCE_API_TOKEN=your-api-token-here
```

#### 3. Run

`start.bat`을 더블클릭하면 자동으로 venv를 활성화하고 브라우저에서 http://localhost:5001 을 열어줍니다.

---

## Usage

### Web GUI (Recommended)

**macOS** — double-click `Conf. Exporter.command` in Finder.

**Windows** — double-click `start.bat`.

Or manually:

```bash
# macOS
conda activate confluence
python app.py

# Windows
venv\Scripts\activate
python app.py
```

Open **http://localhost:5001** in your browser. The GUI provides:

- Confluence page URL input
- Logo selection (default PinkLAB logo, or upload a custom logo)
- Output directory configuration (default: `~/Downloads`)
- Per-file generation toggle (checkbox to enable/disable each output)
- Custom filenames for all 3 output files
- Real-time export progress log
- Direct "Open" links to view generated files in browser

### CLI

```bash
# macOS
conda activate confluence

# Windows
venv\Scripts\activate

# Basic usage
python confluence_export.py "https://your-domain.atlassian.net/wiki/spaces/SPACE/pages/PAGE_ID/Page+Title"

# Specify output directory
python confluence_export.py "PAGE_URL" --output-dir ./my_output
```

### Output

Three files are generated in the `output/` directory:

| File | Description |
|------|-------------|
| `Page_Title.pdf` | A4 document PDF (cover + TOC + body + back page) |
| `present_Page_Title.html` | Presentation HTML (can be presented directly in a browser) |
| `present_Page_Title.pdf` | Presentation PDF (16:9 slides) |

### Presentation Controls

Open the presentation HTML in a browser to use it as a slideshow:

| Action | Key |
|--------|-----|
| Next slide | `Space`, `→`, `↓`, `PageDown` |
| Previous slide | `←`, `↑`, `PageUp` |
| Go to first slide | `Home` |
| Go to last slide | `End` |
| Mouse wheel | Scroll up/down to navigate slides |
| Open TOC | `T` |

## Dependencies

| Package | Version | Role |
|---------|---------|------|
| `requests` | >= 2.28 | Confluence REST API calls |
| `beautifulsoup4` | >= 4.12 | HTML parsing and Confluence macro conversion |
| `playwright` | >= 1.40 | Headless Chromium PDF rendering |
| `flask` | >= 3.0 | Web GUI server |

## File Structure

```
confluece_slide_and_pdf/
├── Conf. Exporter.command    # macOS one-click launcher (Conda)
├── start.bat                 # Windows one-click launcher (venv)
├── setup.bat                 # Windows initial setup (venv, packages)
├── requirements.txt          # Python package list (venv용)
├── app.py                    # Flask web GUI server
├── confluence_export.py      # Core export engine + CLI entry point
├── templates/
│   └── index.html            # Web GUI template
├── static/
│   └── pinklab_logo_text.png # Logo (symlink)
├── pinklab_logo_text.png     # PinkLAB logo (cover/back pages)
├── confluence_token.txt      # Auth config (not in git)
├── .gitignore
├── README.md
├── history.md / history.html
├── architecture.md / architecture.html
├── uploads/                  # Temp uploaded logos (not in git)
└── output/                   # Generated files
```

## Supported Confluence Macros

| Macro | Conversion |
|-------|-----------|
| `code` | Styled code block with line numbers |
| `info` / `note` / `warning` / `tip` / `error` | Colored panels |
| `expand` | Expand/Collapse sections (shown expanded) |
| `status` | Colored status lozenges |
| `toc` | Removed (custom TOC page generated) |
| `ac:image` | Base64 inline embedded images |
| `ac:image` (video) | Video file download & `<video>` tag embedding |
| `ac:link` | Standard HTML `<a>` tags |
| `ac:emoticon` | Unicode emoji |
| Others | Graceful fallback (body content preserved) |

## Changelog

### Windows File Open Bug Fix (`app.py`)

**증상**: 변환 완료 후 파일 링크를 클릭하면 아래와 같은 URL로 이동하며 파일이 열리지 않음

```
http://localhost:5001/api/files/C%3A%5CUsers%5C이름%5CDownloads%5Cfile.pdf
```

**원인**: 기존 `/api/files/<path:filepath>` 방식은 macOS(`/Users/...`) 기준으로 설계되어, Windows 경로(`C:\Users\...`)의 드라이브 문자(`C:`)가 URL에 포함되면 경로가 올바르게 복원되지 않음

**수정 내용**: 파일 서빙 방식을 경로 기반 → **job_id + 파일명 기반**으로 변경

```
# 기존 (macOS 전용)
GET /api/files/C%3A%5CUsers%5C.../file.pdf

# 수정 후 (Windows/macOS 공통)
GET /api/files/{job_id}/{filename}
```

서버가 `job_id`로 출력 디렉토리를 조회한 뒤 파일명만으로 파일을 제공하므로, Windows 경로가 URL에 노출되지 않아 문제가 해결됨

> **적용 방법**: `git pull` 후 `start.bat` 재실행

---

## VIDEO
[![YOUTUBE](https://img.youtube.com/vi/VcSHt-2HNkY/0.jpg)](https://www.youtube.com/watch?v=VcSHt-2HNkY)
