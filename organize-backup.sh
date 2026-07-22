#!/usr/bin/env bash
# organize-backup.sh — Categorize PhotoRec recovery dump by file type, then deduplicate
set -euo pipefail

SRC="/run/media/grave/Backup Drive/Backup-dump"
DST="$SRC/organized"
LOG="$SRC/organize-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG") 2>&1

echo "=== Organize backup dump ==="
echo "Started: $(date)"
echo "Source: $SRC"
echo "Target: $DST"
echo

# ── Step 0: Create directory structure ──────────────────────────

mkdir -p "$DST"/{images/{png,jpg,jpeg,webp,gif,ico,bmp,tiff,svg},archives/{gz,zst,zip,jar,tar,xz,7z,rar,bz2},documents/{txt,xml,csv,html,htm,docx,xlsx,pdf,json,md,rst,yaml,yml,toml,cfg,ini,log},code/{java,py,c,cpp,h,hpp,go,rs,js,ts,sh,bat,ps1},binaries/{dll,exe,sys,msi,scr,ocx},media/{mp3,mp4,flac,wav,ogg,wma,avi,mkv,webm,mov},data/{sqlite,db,torrent,crt,pem,pub,priv,key,p12,pfx},cbz,other}
echo "Directory structure created."
echo

# ── Step 1: Categorize files via hardlinks ───────────────────────

# All source directories (excluding broken recup_dir.521)
SRC_DIRS=()
for d in "$SRC"/recup_dir.*; do
    [[ "$(basename "$d")" == "recup_dir.521" ]] && continue
    SRC_DIRS+=("$d")
done
# Add carved-cbz dirs
for d in "$SRC"/carved-cbz.*; do
    [[ -d "$d" ]] && SRC_DIRS+=("$d")
done
# Add 2nd PhotoRec run
for d in "$SRC"/recover/recup_dir.*; do
    [[ -d "$d" ]] && SRC_DIRS+=("$d")
done

echo "Processing ${#SRC_DIRS[@]} source directories..."

TOTAL=0
CATEGORIZED=0
SKIPPED=0

declare -A CAT_COUNTS
declare -A EXT_COUNTS

for dir in "${SRC_DIRS[@]}"; do
    for file in "$dir"/*; do
        [[ -f "$file" ]] || continue
        ((TOTAL++))

        base=$(basename "$file")
        ext="${base##*.}"

        # Determine category from extension
        case "$ext" in
            png|jpg|jpeg|webp|gif|ico|bmp|tiff|svg)
                cat="images"; sub="$ext" ;;
            gz|zst|zip|jar|tar|xz|7z|rar|bz2)
                cat="archives"; sub="$ext" ;;
            txt|xml|csv|html|htm|docx|xlsx|pdf)
                cat="documents"; sub="$ext" ;;
            json|md|rst|yaml|yml|toml|cfg|ini|log)
                cat="documents"; sub="$ext" ;;
            java|py|c|cpp|h|hpp|go|rs|js|ts|sh|bat|ps1)
                cat="code"; sub="$ext" ;;
            dll|exe|sys|msi|scr|ocx)
                cat="binaries"; sub="$ext" ;;
            mp3|mp4|flac|wav|ogg|wma|avi|mkv|webm|mov)
                cat="media"; sub="$ext" ;;
            sqlite|db|torrent|crt|pem|pub|priv|key|p12|pfx)
                cat="data"; sub="$ext" ;;
            cbz)
                cat="cbz"; sub="$ext" ;;
            *)
                cat="other"; sub="$ext" ;;
        esac

        # Handle files where ext could be better guessed from the suffix
        # Some files are named like f442762048_kbdbhc_dll (original name embedded)
        # The last underscore segment is the extension with underscore instead of dot

        dst_path="$DST/$cat/$sub/$base"

        # Skip if already linked (same inode)
        if [[ -f "$dst_path" ]]; then
            src_ino=$(stat -c '%i' "$file" 2>/dev/null || echo "")
            dst_ino=$(stat -c '%i' "$dst_path" 2>/dev/null || echo "")
            if [[ -n "$src_ino" && "$src_ino" == "$dst_ino" ]]; then
                ((SKIPPED++))
                continue
            fi
            # Different file, same name — add suffix
            dst_path="${dst_path%.*}_$(stat -c '%i' "$file")_.${ext}"
        fi

        ln "$file" "$dst_path" 2>/dev/null && ((CATEGORIZED++)) || ((SKIPPED++))
        ((EXT_COUNTS["$ext"]++))

        # Progress every 5000 files
        if (( CATEGORIZED % 5000 == 0 )); then
            echo "  Progress: $CATEGORIZED / $TOTAL files categorized..."
        fi
    done
done

echo
echo "=== Categorization complete ==="
echo "Total files processed: $TOTAL"
echo "Categorized (hardlinked): $CATEGORIZED"
echo "Skipped: $SKIPPED"
echo

# ── Step 2: Rename files with original names ─────────────────────

echo "=== Extracting original filenames ==="

RENAMED=0

rename_with_original() {
    local dir="$1"
    local ext="$2"
    find "$dir" -maxdepth 1 -type f -name "*_*_${ext}" 2>/dev/null | while IFS= read -r file; do
        base=$(basename "$file")
        # Pattern: fNNNNNNNN_original_name_EXT where EXT matches underscore-delimited last segment
        # Try to reconstruct: remove the fNNNNN prefix and replace _EXT with .EXT
        no_prefix="${base#f[0-9]*_}"
        if [[ "$no_prefix" != "$base" && "$no_prefix" != *.${ext} ]]; then
            # Check if this is a known Windows/Java filename pattern
            # e.g., f442762048_kbdbhc_dll => kbdbhc.dll
            newname="$(echo "$no_prefix" | sed -E 's/_([a-z]{2,4})$/.\\1/')"
            if [[ "$newname" != "$no_prefix" ]]; then
                newpath="$dir/$newname"
                if [[ ! -e "$newpath" ]]; then
                    mv "$file" "$newpath" && ((RENAMED++)) 2>/dev/null || true
                fi
            fi
        fi
    done
}

for cat_dir in "$DST"/binaries/dll "$DST"/binaries/exe "$DST"/binaries/sys "$DST"/code/java "$DST"/code/py "$DST"/documents/xml "$DST"/documents/txt; do
    [[ -d "$cat_dir" ]] || continue
    ext=$(basename "$cat_dir")
    rename_with_original "$cat_dir" "$ext"
done

echo "Files renamed with original names: $RENAMED"
echo

# ── Step 3: Deduplication ────────────────────────────────────────

echo "=== Deduplication ==="
echo "Discovering duplicates by size+hash..."

DUPES_FOUND=0
SPACE_SAVED=0

# For each leaf directory, find duplicates
for leaf_dir in "$DST"/*/*/; do
    [[ -d "$leaf_dir" ]] || continue
    file_count=$(ls "$leaf_dir" 2>/dev/null | wc -l)
    (( file_count > 1 )) || continue

    # Group by file size, then hash within groups
    find "$leaf_dir" -maxdepth 1 -type f -printf '%s %p\0' 2>/dev/null | \
    sort -z -n | \
    awk -v RS='\0' -v ORS='\0' '
    {
        size=$1; $1=""; file=substr($0,2)
        if (size == prev_size) {
            group = group "\n" file
        } else {
            if (group && group ~ /\n/) print group
            group = file
            prev_size = size
        }
    }
    END { if (group && group ~ /\n/) print group }
    ' 2>/dev/null | while IFS= read -r -d '' group; do
        echo "$group" | while IFS= read -r file; do
            md5sum "$file" 2>/dev/null
        done | sort | awk '
        {
            hash=$1; $1=""; file=substr($0,2)
            if (hash == prev_hash && prev_hash != "") {
                # Duplicate found: replace with hardlink to first
                printf "%s\0%s\0", prev_file, file
            } else {
                prev_hash=hash; prev_file=file
            }
        }
        ' | while IFS= read -r -d '' original && IFS= read -r -d '' duplicate; do
            size=$(stat -c '%s' "$duplicate" 2>/dev/null || echo 0)
            rm -f "$duplicate" && ln "$original" "$duplicate" 2>/dev/null && {
                ((DUPES_FOUND++))
                ((SPACE_SAVED += size))
            } || true
        done
    done
done

echo "Duplicates found and hardlinked: $DUPES_FOUND"
echo "Estimated space saved: $((SPACE_SAVED / 1048576)) MB"
echo

# ── Step 4: Summary report ──────────────────────────────────────

echo "=== Summary ==="
echo
for cat in images archives documents code binaries media data cbz other; do
    cat_dir="$DST/$cat"
    [[ -d "$cat_dir" ]] || continue
    count=$(find "$cat_dir" -type f 2>/dev/null | wc -l)
    size=$(du -sh "$cat_dir" 2>/dev/null | cut -f1)
    printf "  %-12s %8d files  %8s\n" "$cat:" "$count" "$size"
done

echo
total_count=$(find "$DST" -type f 2>/dev/null | wc -l)
total_size=$(du -sh "$DST" 2>/dev/null | cut -f1)
echo "  TOTAL:       $total_count files  $total_size"

echo
echo "=== Done: $(date) ==="
