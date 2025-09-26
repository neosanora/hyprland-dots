#!/usr/bin/env bash
# --------------------------------------------------------------
# Auto Download & Install Fonts (force sudo -> /usr/share/fonts)
# Robust: fallback to GitHub releases API when direct URL fails
# --------------------------------------------------------------

VERBOSE="${VERBOSE:-0}"

log()  { printf "%s\n" "$*"; }
info() { log "ℹ️  $*"; }
warn() { log "⚠️  $*"; }
err()  { log "❌ $*" >&2; }
debug(){ (( VERBOSE )) && log "[DEBUG] $*"; }

SYSTEM_FONTS_DIR="/usr/share/fonts"

# require sudo
if ! command -v sudo >/dev/null 2>&1; then
    err "'sudo' tidak ditemukan. Skrip ini membutuhkan sudo."
    exit 1
fi

info "Meminta autentikasi sudo (jika belum aktif)..."
if ! sudo -v; then
    err "Gagal autentikasi sudo. Pastikan user punya akses sudo."
    exit 1
fi

# ensure target dir exists and has sane perms
sudo mkdir -p "$SYSTEM_FONTS_DIR"
sudo chmod 0755 "$SYSTEM_FONTS_DIR" || true
debug "Target font dir: $SYSTEM_FONTS_DIR"

# Require unzip and downloader
if ! command -v unzip >/dev/null 2>&1; then
    err "'unzip' diperlukan. Pasang 'unzip' lalu jalankan ulang."
    exit 1
fi

DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
else
    err "Butuh 'curl' atau 'wget' untuk mendownload font."
    exit 1
fi
debug "Downloader: $DOWNLOADER"

# Basic URL check (returns 0 if reachable)
check_url() {
    local url="$1"
    if [[ "$DOWNLOADER" == "curl" ]]; then
        curl -fsI --max-time 10 "$url" >/dev/null 2>&1
    else
        wget --spider --timeout=10 "$url" >/dev/null 2>&1
    fi
}

# Try to get asset download URL from GitHub latest release:
# repo => "owner/repo"
# pattern => grep pattern to match asset name or URL
github_latest_asset_url() {
    local repo="$1"
    local pattern="$2"
    local api="https://api.github.com/repos/${repo}/releases/latest"
    debug "Mencari asset dari GitHub API: $api (pattern: $pattern)"
    if [[ "$DOWNLOADER" == "curl" ]]; then
        local body
        body="$(curl -fsSL --max-time 10 "$api" 2>/dev/null || true)"
    else
        local body
        body="$(wget -q -O - "$api" 2>/dev/null || true)"
    fi
    if [[ -z "$body" ]]; then
        debug "GitHub API kosong atau gagal."
        return 1
    fi
    # extract browser_download_url lines and match pattern
    local url
    url="$(printf "%s" "$body" \
        | grep -oE '"browser_download_url":[[:space:]]*"[^"]+"' \
        | sed -E 's/.*"browser_download_url":[[:space:]]*"([^"]+)".*/\1/' \
        | grep -i -E "$pattern" \
        | head -n1 || true)"
    if [[ -n "$url" ]]; then
        printf "%s" "$url"
        return 0
    fi
    return 1
}

# Download to temp file; tries direct URL first,
# on failure optionally try GitHub releases fallback (if repo provided).
download_font_with_fallback() {
    local name="$1"
    local url="$2"
    local gh_repo="${3:-}"   # optional "owner/repo" to search releases when direct URL fails
    local gh_pattern="${4:-$name}" # pattern used to find file in release assets
    local tmp
    tmp="$(mktemp --suffix=".zip")"
    trap '[[ -f "$tmp" ]] && rm -f "$tmp"' RETURN

    info "Mencoba unduh (direct) : $name"
    if [[ "$DOWNLOADER" == "curl" ]]; then
        if curl -fSL "$url" -o "$tmp" --max-time 60 2>/dev/null; then
            debug "Direct download sukses: $url"
            printf "%s" "$tmp"
            return 0
        else
            debug "Direct download gagal untuk $url"
        fi
    else
        if wget -q -O "$tmp" "$url"; then
            debug "Direct download sukses: $url"
            printf "%s" "$tmp"
            return 0
        else
            debug "Direct download gagal untuk $url"
        fi
    fi

    # direct failed -> try GitHub releases API fallback if repo provided
    if [[ -n "$gh_repo" ]]; then
        info "Coba cari asset di GitHub releases untuk ${gh_repo}..."
        local asset_url
        if asset_url="$(github_latest_asset_url "$gh_repo" "$gh_pattern")"; then
            debug "Found GitHub asset URL: $asset_url"
            # overwrite tmp with actual download
            if [[ "$DOWNLOADER" == "curl" ]]; then
                if curl -fSL "$asset_url" -o "$tmp" --max-time 60 2>/dev/null; then
                    printf "%s" "$tmp"
                    return 0
                fi
            else
                if wget -q -O "$tmp" "$asset_url"; then
                    printf "%s" "$tmp"
                    return 0
                fi
            fi
            debug "Gagal unduh asset dari GitHub URL."
        else
            debug "Tidak menemukan asset yang cocok di GitHub releases."
        fi
    fi

    # nothing worked
    rm -f "$tmp"
    return 1
}

# download & install (uses sudo to write)
download_and_install_font() {
    local name="$1"
    local url="$2"
    local dst="$SYSTEM_FONTS_DIR/$name"
    local gh_repo="${3:-}"    # optional owner/repo
    local gh_pattern="${4:-$name}"

    if sudo test -e "$dst"; then
        debug "Font '$name' sudah ada di $dst — melewatkan."
        return 0
    fi

    info "Memeriksa URL untuk $name..."
    # Try simple check first (may fail on assets requiring redirect)
    if ! check_url "$url" && [[ -z "$gh_repo" ]]; then
        warn "URL tidak valid/terjangkau untuk $name: $url — melewatkan."
        return 0
    fi

    local tmp_zip
    if ! tmp_zip="$(download_font_with_fallback "$name" "$url" "$gh_repo" "$gh_pattern")"; then
        warn "⚠️  Download gagal atau file kosong untuk $name"
        return 0
    fi

    info "Mengekstrak $name ke $dst (menggunakan sudo)..."
    sudo mkdir -p "$dst"
    if ! sudo unzip -oq "$tmp_zip" -d "$dst"; then
        warn "Ekstraksi gagal untuk $name"
        rm -f "$tmp_zip"
        return 0
    fi

    # cleanup temp (trap RETURN already set)
    rm -f "$tmp_zip"
    debug "Font $name diinstal ke $dst"
    return 0
}

install_local_font() {
    local name="$1"
    local src_dir="$2"
    local src_path="$src_dir/$name"
    local dst="$SYSTEM_FONTS_DIR/$name"

    if sudo test -e "$dst"; then
        debug "Font lokal '$name' sudah ada di $dst — melewatkan."
        return 0
    fi

    if [[ ! -e "$src_path" ]]; then
        warn "Sumber lokal tidak ditemukan: $src_path — melewatkan $name"
        return 0
    fi

    info "Mengcopy font lokal: $name -> $SYSTEM_FONTS_DIR (menggunakan sudo)"
    if [[ -d "$src_path" ]]; then
        sudo cp -a "$src_path" "$SYSTEM_FONTS_DIR/"
    else
        sudo mkdir -p "$dst"
        sudo cp -a "$src_path" "$dst/"
    fi
    debug "Copy selesai untuk $name"
    return 0
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
debug "SCRIPT_DIR: $SCRIPT_DIR"

# Remote fonts: provide optional GitHub repo fallback where known
# Format: name|url|github_repo|pattern
REMOTE_LIST=(
"FiraCode|https://github.com/tonsky/FiraCode/releases/latest/download/Fira_Code_v6.2.zip|tonsky/FiraCode|Fira_Code"
"Fira_Sans|https://github.com/mozilla/Fira/releases/latest/download/Fira_Sans.zip|mozilla/Fira|Fira_Sans"
)

# Local fonts (folder/file names inside $SCRIPT_DIR/fonts)
LOCAL_FONTS=(
            "Material-Icons" 
            "Niconne"
            "Satisfy"
            "Potta_One"
            "fontIcon"
            )

# Execute remote installs
for entry in "${REMOTE_LIST[@]}"; do
    IFS='|' read -r name url gh_repo gh_pattern <<< "$entry"
    download_and_install_font "$name" "$url" "$gh_repo" "$gh_pattern"
done

# Execute local copies
for name in "${LOCAL_FONTS[@]}"; do
    install_local_font "$name" "$SCRIPT_DIR/fonts"
done

info "Memperbarui cache font system (fc-cache)..."
if command -v fc-cache >/dev/null 2>&1; then
    sudo fc-cache -f "$SYSTEM_FONTS_DIR" >/dev/null 2>&1 || warn "fc-cache gagal dijalankan dengan sudo."
else
    warn "'fc-cache' tidak ditemukan; jalankan 'fc-cache -f /usr/share/fonts' jika perlu."
fi

info "✅ Instalasi font selesai ke $SYSTEM_FONTS_DIR"