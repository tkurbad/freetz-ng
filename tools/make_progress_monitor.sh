#! /usr/bin/env bash
# Freetz-NG Build Progress Monitor
# Monitor cross-compilation progress for Freetz-NG toolchain
# Run this script (with "-w") while "make" in a 2nd terminal
# by Ircama

# Determine script and project root directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Default settings
LIST_PACKAGES_ONLY=false
SHOW_LEGEND=true
SHOW_HEADER=true
SHOW_PACKAGES=true
SHOW_SUMMARY=true
SHOW_PROGRESS_BAR=true
OUTPUT_FORMAT="terminal"
ARCH_FILTER=""
WATCH_MODE=false
WATCH_INTERVAL=2

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --arch)
            ARCH_FILTER="$2"
            shift 2
            ;;
        --watch|-w)
            WATCH_MODE=true
            # If next argument is a number, use it as interval
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                WATCH_INTERVAL="$2"
                shift 2
            else
                shift
            fi
            ;;
        --markdown)
            OUTPUT_FORMAT="markdown"
            shift
            ;;
        --summary-only)
            SHOW_PACKAGES=false
            SHOW_LEGEND=false
            SHOW_PROGRESS_BAR=false
            shift
            ;;
        --no-legend|-L)
            SHOW_LEGEND=false
            shift
            ;;
        --no-header|-H)
            SHOW_HEADER=false
            shift
            ;;
        --no-summary|-S)
            SHOW_SUMMARY=false
            SHOW_PROGRESS_BAR=false
            shift
            ;;
        --compact|-C)
            SHOW_LEGEND=false
            SHOW_HEADER=false
            SHOW_PROGRESS_BAR=false
            shift
            ;;
        --list-archs)
            SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
            echo "Available architectures:"
            for arch_dir in $(find "$ROOT_DIR/source" -maxdepth 1 -type d -name "target-*" 2>/dev/null | sort); do
                arch=$(basename "$arch_dir")
                timestamp=$(find "$arch_dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
                if [ -n "$timestamp" ]; then
                    date_str=$(date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "")
                    echo "  $arch (last modified: $date_str)"
                else
                    echo "  $arch"
                fi
            done
            exit 0
            ;;
        --list-packages)
            LIST_PACKAGES_ONLY=true
            shift
            ;;
        --help|-h)
            echo "Freetz-NG Build Progress Monitor"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --arch <name>     Specify architecture to monitor (e.g., target-mips...)"
            echo "  --list-archs      List all available architectures and exit"
            echo "  --watch, -w [N]   Watch mode: refresh every N seconds (default: 2)"
            echo "  --markdown        Output in Markdown table format"
            echo "  --summary-only    Show only summary (no package list, no legend)"
            echo "  --no-legend, -L   Hide status legend"
            echo "  --no-header, -H   Hide column headers"
            echo "  --no-summary, -S  Hide summary section"
            echo "  --compact, -C     Equivalent to --no-legend --no-header"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Default: Auto-select most recently modified architecture"
            echo "         Full output with colored terminal display"
            echo ""
            echo "Examples:"
            echo "  $0 --watch                    # Watch mode with 2s refresh"
            echo "  $0 --watch 5                  # Watch mode with 5s refresh"
            echo "  $0 -w --compact               # Watch compact view"
            echo "  $0 -w -C                      # Same as above with short option"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Watch mode implementation - wrap the main script in a loop
if $WATCH_MODE; then
    # In watch mode, default to compact display for cleaner output
    if [ "$SHOW_LEGEND" = "true" ] && [ "$SHOW_HEADER" = "true" ]; then
        SHOW_LEGEND=false
        SHOW_HEADER=false
    fi
    
    while true; do
        # Run the script and capture output, then parse "Currently Compiling" line
        # Always enable summary internally to extract "Currently Compiling" info
        OUTPUT=$(WATCH_MODE=false bash "$BASH_SOURCE" \
            $([ -n "$ARCH_FILTER" ] && echo "--arch $ARCH_FILTER") \
            $(! $SHOW_LEGEND && echo "--no-legend") \
            $(! $SHOW_HEADER && echo "--no-header") \
            $(! $SHOW_PACKAGES && echo "--summary-only") 2>&1)
        
        # Extract "Currently Compiling" line if it exists
        CURRENT_BUILD=$(echo "$OUTPUT" | grep "Currently Compiling:" | head -1)
        
        # If user disabled summary, filter it out from output
        if ! $SHOW_SUMMARY; then
            OUTPUT=$(echo "$OUTPUT" | grep -v -E "Summary:|Completed:|In Progress:|Not Started:|Currently Compiling:|Overall Progress:")
        fi
        
        # Clear screen completely just before displaying
        tput clear 2>/dev/null || clear
        
        # Show watch mode header with timestamp (unless --no-header is set)
        if $SHOW_HEADER; then
            echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
            echo -e "${BOLD}   Freetz-NG Build Monitor - Watch Mode${NC}"
            echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
            echo -e "${DIM}Last updated: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
            echo ""
        fi
        
        if [ -n "$CURRENT_BUILD" ]; then
            # Show what's currently building
            echo -e "$CURRENT_BUILD"
        else
            echo -e "${YELLOW}⏸ No active compilation detected${NC}"
        fi
        echo ""
        
        # Display the rest of the output
        echo "$OUTPUT" | grep -v "Currently Compiling:"
        
        # Show refresh info at bottom
        echo ""
        echo -e "${DIM}Refreshing every ${WATCH_INTERVAL}s... (Press Ctrl+C to exit)${NC}"
        
        sleep "$WATCH_INTERVAL"
    done
    exit 0
fi

# Function to detect build architecture
get_build_arch() {
    # If architecture is specified, validate and use it
    if [ -n "$ARCH_FILTER" ]; then
        if [ -d "$ROOT_DIR/source/$ARCH_FILTER" ]; then
            echo "$ARCH_FILTER"
            return
        else
            echo "Error: Architecture '$ARCH_FILTER' not found" >&2
            echo "Use --list-archs to see available architectures" >&2
            exit 1
        fi
    fi
    
    # Auto-select: find architecture with most recent activity
    local newest_arch=""
    local newest_time=0
    
    for arch_dir in $(find "$ROOT_DIR/source" -maxdepth 1 -type d -name "target-*" 2>/dev/null); do
        local arch=$(basename "$arch_dir")
        local timestamp=$(find "$arch_dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
        
        if [ -n "$timestamp" ]; then
            # Use bc for floating point comparison if available, otherwise use integer comparison
            if command -v bc >/dev/null 2>&1; then
                if (( $(echo "$timestamp > $newest_time" | bc -l) )); then
                    newest_time=$timestamp
                    newest_arch=$arch
                fi
            else
                # Fallback to integer comparison
                timestamp_int=${timestamp%.*}
                newest_time_int=${newest_time%.*}
                if [ "$timestamp_int" -gt "$newest_time_int" ]; then
                    newest_time=$timestamp
                    newest_arch=$arch
                fi
            fi
        fi
    done
    
    if [ -n "$newest_arch" ]; then
        echo "$newest_arch"
    else
        # Fallback: check for toolchain directories (early build stage)
        # Select most recently modified toolchain directory
        local toolchain_dir=$(find "$ROOT_DIR/source" -maxdepth 1 -type d -name "toolchain-*" 2>/dev/null | \
            while read dir; do
                timestamp=$(find "$dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
                echo "${timestamp:-0} $dir"
            done | sort -rn | head -1 | cut -d' ' -f2)
        if [ -n "$toolchain_dir" ]; then
            # Extract architecture from toolchain name (e.g., toolchain-mips_gcc-8.4.0 -> mips)
            local toolchain_name=$(basename "$toolchain_dir")
            local arch=$(echo "$toolchain_name" | sed 's/^toolchain-\([^_]*\)_.*/\1/')
            echo "target-$arch"
        else
            # Last fallback: check for any target-* directory
            local arch_dir=$(find "$ROOT_DIR/source" -maxdepth 1 -type d -name "target-*" | head -1)
            if [ -n "$arch_dir" ]; then
                basename "$arch_dir"
            else
                echo ""
            fi
        fi
    fi
}

# Function to get package status from directory
get_status_from_dir() {
    local dir=$1
    local pkg_name=$2
    local build_arch=$3
    
    # Priority 1: Check packages directory first (most reliable for installed packages)
    if [ -n "$build_arch" ]; then
        local pkg_dir="$ROOT_DIR/packages/$build_arch"
        if [ -d "$pkg_dir" ]; then
            if ls "$pkg_dir"/.${pkg_name}_* >/dev/null 2>&1 || \
               ls "$pkg_dir"/.${pkg_name}-* >/dev/null 2>&1 || \
               find "$pkg_dir" -name "*${pkg_name}*" -type f | grep -q .; then
                return 4  # Compiled and installed
            fi
            # Special case for libstdcxx -> libstdc++
            if [ "$pkg_name" = "libstdcxx" ]; then
                if find "$pkg_dir" -name "*libstdc++*" -type f | grep -q .; then
                    return 4
                fi
            fi
        fi
    fi
    
    # Priority 2: Check source directory markers
    if [ ! -d "$dir" ]; then
        return 0  # Not started
    fi
    
    # Handle placeholder directories
    local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
    if [ "$file_count" -lt 5 ]; then
        case "$pkg_name" in
            libstdcxx|libgcc_s|libatomic)
                if ls "$ROOT_DIR/build/modified/filesystem/usr/lib/freetz/lib*.so*" >/dev/null 2>&1; then
                    return 4
                fi
                ;;
        esac
    fi
    
    if [ -f "$dir/.compiled" ]; then
        return 4  # Compiled
    elif [ -f "$dir/.configured" ]; then
        # Check if there are compiled artifacts (libraries or executables)
        if find "$dir" -name "*.so" -o -name "*.a" 2>/dev/null | grep -q .; then
            return 4  # Has compiled libraries
        fi
        # Check for compiled executables in common locations
        if find "$dir" -type f -executable \( -path "*/src/*" -o -path "*/bin/*" \) 2>/dev/null | grep -q .; then
            return 4  # Has compiled executables
        fi
        
        # Check if the package is installed in the final filesystem
        # This handles packages like bzip2 that install directly without .compiled marker
        local pkg_basename=$(basename "$dir" | sed 's/-[0-9].*//')
        if [ -d "$ROOT_DIR/build/modified/filesystem" ]; then
            # Check for libraries in /usr/lib or /lib
            if find "$ROOT_DIR/build/modified/filesystem/usr/lib" "$ROOT_DIR/build/modified/filesystem/lib" \
                -name "lib${pkg_basename}*.so*" -o -name "lib${pkg_basename}*.a" 2>/dev/null | grep -q .; then
                return 4  # Library installed in filesystem
            fi
            # Check for binaries in /usr/bin, /bin, /usr/sbin, /sbin
            if find "$ROOT_DIR/build/modified/filesystem/usr/bin" "$ROOT_DIR/build/modified/filesystem/bin" \
                "$ROOT_DIR/build/modified/filesystem/usr/sbin" "$ROOT_DIR/build/modified/filesystem/sbin" \
                -name "${pkg_basename}*" 2>/dev/null | grep -q .; then
                return 4  # Binary installed in filesystem
            fi
        fi
        
        return 2  # Configured
    elif [ -f "$dir/.unpacked" ]; then
        # Even if only unpacked, check if compilation artifacts exist
        # This handles cases where .compiled marker wasn't created
        if find "$dir" -name "*.so" -o -name "*.a" 2>/dev/null | grep -q .; then
            return 4  # Has compiled libraries
        fi
        # Check for compiled executables in common locations
        if find "$dir" -type f -executable \( -path "*/src/*" -o -path "*/bin/*" \) 2>/dev/null | grep -q .; then
            return 4  # Has compiled executables
        fi
        return 1  # Unpacked
    elif [ -d "$dir" ] && [ "$(ls -A $dir 2>/dev/null)" ]; then
        local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
        if [ "$file_count" -gt 10 ]; then
            return 1
        fi
    fi
    
    return 0  # Not started
}

# Function to get complexity (1-10 stars)
get_complexity() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        echo "1"
        return
    fi
    
    local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
    
    if [ "$file_count" -lt 100 ]; then
        echo "1"
    elif [ "$file_count" -lt 300 ]; then
        echo "2"
    elif [ "$file_count" -lt 500 ]; then
        echo "3"
    elif [ "$file_count" -lt 1000 ]; then
        echo "4"
    elif [ "$file_count" -lt 2000 ]; then
        echo "5"
    elif [ "$file_count" -lt 3000 ]; then
        echo "6"
    elif [ "$file_count" -lt 5000 ]; then
        echo "7"
    elif [ "$file_count" -lt 7000 ]; then
        echo "8"
    elif [ "$file_count" -lt 10000 ]; then
        echo "9"
    else
        echo "10"
    fi
}

# Function to get timestamp
get_timestamp() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        echo "0"
        return
    fi
    
    local newest=$(find "$dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
    if [ -z "$newest" ]; then
        echo "0"
    else
        echo "$newest"
    fi
}

# Function to truncate package name with ellipsis if too long
truncate_name() {
    local name=$1
    local max_len=${2:-35}  # Default max length 35 chars
    
    if [ ${#name} -le $max_len ]; then
        echo "$name"
    else
        # Truncate and add ellipsis
        echo "${name:0:$((max_len-3))}..."
    fi
}

BUILD_ARCH=$(get_build_arch)

if [ -z "$BUILD_ARCH" ]; then
    echo "Error: No build found"
    echo ""
    echo "The build has not been started yet."
    echo "Please run 'make' first to start the compilation process."
    echo ""
    echo "Tip: After starting the build, use this script to monitor progress."
    exit 1
fi

# Scan actual packages in source directory instead of predefined list
declare -a PKG_INFO
COMPLETED=0
IN_PROGRESS=0
NOT_STARTED=0
TOTAL=0
EARLY_BUILD_STAGE=false

# Check for toolchain and add its components first (if it exists)
# Select most recently modified toolchain directory
toolchain_dir=$(find "$ROOT_DIR/source" -maxdepth 1 -type d -name "toolchain-*" 2>/dev/null | \
    while read dir; do
        timestamp=$(find "$dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
        echo "${timestamp:-0} $dir"
    done | sort -rn | head -1 | cut -d' ' -f2)
if [ -n "$toolchain_dir" ]; then
    # Detect which toolchain component is currently being built
    current_component=""
    current_index=-1
    
    # Check if any make process is running (indicates active build) - exclude zombie processes
    if ps aux | grep -E "[m]ake" | grep -v "defunct" | grep -q .; then
        # Find the most recently modified KNOWN component directory in toolchain
        latest_component=""
        latest_timestamp=0
        
        # Known component patterns to look for (only major components worth tracking)
        known_patterns=("gcc.*-final" "gcc.*-initial" "gcc-initial" "gcc" "binutils" "uclibc" "uClibc")
        
        for component_dir in "$toolchain_dir"/*; do
            [ ! -d "$component_dir" ] && continue
            
            dir_name=$(basename "$component_dir")
            
            # Check if this matches a known pattern
            is_known=false
            for pattern in "${known_patterns[@]}"; do
                if [[ $dir_name =~ $pattern ]]; then
                    is_known=true
                    break
                fi
            done
            
            # Skip unknown components
            [ "$is_known" = "false" ] && continue
            
            # Get the most recent file modification time in this directory (as integer seconds)
            dir_timestamp=$(find "$component_dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | cut -d. -f1)
            dir_timestamp=${dir_timestamp:-0}
            
            # Simple integer comparison
            if [ "$dir_timestamp" -gt "$latest_timestamp" ]; then
                latest_timestamp=$dir_timestamp
                latest_component="$dir_name"
            fi
        done
        
        # Extract component from directory name (only major components)
        if [[ $latest_component =~ gcc.*-initial|gcc-initial ]]; then
            current_component="gcc-initial"
        elif [[ $latest_component =~ gcc.*-target|gcc-target ]]; then
            current_component="gcc_target"
        elif [[ $latest_component =~ gcc.*-final|gcc-final|gcc ]]; then
            current_component="gcc"
        elif [[ $latest_component =~ binutils.*-target|binutils-target ]]; then
            current_component="binutils_target"
        elif [[ $latest_component =~ binutils ]]; then
            current_component="binutils"
        elif [[ $latest_component =~ uclibc|uClibc ]]; then
            current_component="uclibc"
        fi
    fi
    
    # Define all toolchain components in build order
    # Note: GMP, MPFR, MPC, and Kernel headers are very fast and not worth tracking
    toolchain_order=(
        "binutils:Toolchain: Binutils"
        "gcc-initial:Toolchain: GCC (initial)"
        "uclibc:Toolchain: uClibc"
        "gcc:Toolchain: GCC compiler"
    )
    
    # Add on-device toolchain components only if GCC Toolchain package is selected
    if [ -f "$ROOT_DIR/.config" ] && grep -q "^FREETZ_PACKAGE_GCC_TOOLCHAIN=y$" "$ROOT_DIR/.config" 2>/dev/null; then
        toolchain_order+=(
            "binutils_target:Toolchain: Binutils on-device"
            "uclibc_target:Toolchain: uClibc on-device"
            "gcc_target:Toolchain: GCC on-device"
        )
    fi
    
    # Find the index of the current component
    for i in "${!toolchain_order[@]}"; do
        component_key="${toolchain_order[$i]%%:*}"
        if [ "$component_key" = "$current_component" ]; then
            current_index=$i
            break
        fi
    done
    
    # Process each toolchain component in order
    for i in "${!toolchain_order[@]}"; do
        IFS=':' read -r component_key component_name <<< "${toolchain_order[$i]}"
        
        # Use high priority timestamps (9000000000 range) to ensure toolchain appears first
        timestamp=$((9000000000 + i))
        
        status=0  # Not started
        percentage=0
        
        # Determine status based on build order
        if [ $current_index -ge 0 ]; then
            if [ $i -lt $current_index ]; then
                # Components before current = completed
                status=4
                percentage=100
                ((COMPLETED++))
            elif [ $i -eq $current_index ]; then
                # Current component - check if it's actually compiled
                # Map component key to directory pattern for marker check
                case "$component_key" in
                    gcc-initial) pattern="gcc-*-initial" ;;
                    gcc) pattern="gcc-*-final" ;;
                    gcc_target) pattern="gcc-*-target" ;;
                    binutils) pattern="binutils-*-build" ;;
                    binutils_target) pattern="binutils-*-target" ;;
                    uclibc|uclibc_target) pattern="uClibc-*" ;;
                    *) pattern="$component_key" ;;
                esac
                
                # Check if .compiled marker exists
                compiled_marker=$(find "$toolchain_dir"/$pattern -name ".compiled" 2>/dev/null | head -1)
                
                if [ -n "$compiled_marker" ]; then
                    # Actually compiled
                    status=4
                    percentage=100
                    ((COMPLETED++))
                else
                    # Currently compiling
                    status=3
                    percentage=50
                    ((IN_PROGRESS++))
                fi
            else
                # Components after current = not started
                status=0
                percentage=0
                ((NOT_STARTED++))
            fi
        else
            # No current component detected - check if target dir exists (toolchain likely complete)
            if [ -d "$ROOT_DIR/source/${BUILD_ARCH}" ]; then
                # Toolchain complete
                status=4
                percentage=100
                ((COMPLETED++))
            else
                # Toolchain not started
                status=0
                percentage=0
                ((NOT_STARTED++))
            fi
        fi
        
        ((TOTAL++))
        
        # Assign complexity based on component (GCC is much more complex)
        case "$component_key" in
            binutils) complexity=5 ;;
            gcc-initial) complexity=6 ;;
            uclibc) complexity=7 ;;
            gcc) complexity=10 ;;  # GCC final build is the most complex
            binutils_target) complexity=5 ;;  # Binutils on-device
            uclibc_target) complexity=7 ;;  # uClibc on-device
            gcc_target) complexity=10 ;;  # GCC on-device build (same complexity as GCC final)
            *) complexity=5 ;;
        esac
        
        # Add to package info with priority timestamp
        PKG_INFO+=("$timestamp|$component_name|$status|$percentage|$complexity")
    done
    
    # Set CURRENT_PKG if a toolchain component is being built
    if [ -n "$current_component" ] && [ $current_index -ge 0 ]; then
        # Find the display name for the current component
        for entry in "${toolchain_order[@]}"; do
            component_key="${entry%%:*}"
            component_name="${entry#*:}"
            if [ "$component_key" = "$current_component" ]; then
                CURRENT_PKG="$component_name"
                break
            fi
        done
    fi
fi

# Check if target directory exists (normal build stage)
if [ -d "$ROOT_DIR/source/${BUILD_ARCH}" ]; then
    # Find all package directories in source
    while IFS= read -r dir; do
        [ -z "$dir" ] && continue
        
        pkg_full=$(basename "$dir")
        
        # Skip the parent directory itself
        [ "$pkg_full" = "$BUILD_ARCH" ] && continue
        
        # Skip kernel references
        [[ "$pkg_full" =~ ^ref- ]] && continue
        
        # Normalize package name (remove version suffix like -1.2.3, but keep python3, gtk2, etc.)
        # Pattern: dash followed by digit and dot (version pattern)
        pkg_base=$(echo "$pkg_full" | sed 's/-[0-9]\+\.[0-9].*//')
        
        # If no version was found (no dash-digit-dot pattern), use the full name
        if [ "$pkg_base" = "$pkg_full" ]; then
            # Try alternative pattern: dash followed by just version numbers at the end
            pkg_base=$(echo "$pkg_full" | sed 's/-[0-9]\+$//')
        fi
        
        # Two-tier virtual package filtering (same as .config reading sections):
        # Tier 1: Pattern-based filtering - purely virtual packages
        [[ "$pkg_base" =~ ^(local|meta|script|config|docs)- ]] && continue
        [[ "$pkg_base" =~ -(host|external|headers|meta|virtual|dummy)$ ]] && continue
        
        # Tier 2: Content-based filtering - packages with directories but no compilable source
        if ! find "$dir" -type f \( -name "*.c" -o -name "*.cc" -o -name "*.cpp" -o -name "*.cxx" -o -name "Makefile*" -o -name "*.mk" \) 2>/dev/null | grep -q .; then
            # Exception: Keep meta-packages that orchestrate compiler/toolchain builds
            # These don't have source code but trigger significant compilation work
            if [[ ! "$pkg_base" =~ toolchain ]]; then
                # No compilable files found - skip it (script-only package)
                continue
            fi
        fi
        
        # Get status
        get_status_from_dir "$dir" "$pkg_base" "$BUILD_ARCH"
        status=$?
        
        # Get complexity (file-based heuristic)
        complexity=$(get_complexity "$dir")
        
        # Override complexity for known important packages
        case "$pkg_base" in
            gcc-toolchain) complexity=10 ;;  # Meta-package that orchestrates GCC target build (same complexity as GCC)
            python3|python) complexity=9 ;;
            openssl|gnutls) complexity=7 ;;
            busybox) complexity=8 ;;
            dropbear|openssh) complexity=5 ;;
            curl|wget) complexity=4 ;;
            haserl) complexity=4 ;;
            uclibcxx) complexity=5 ;;
        esac
        
        # Get timestamp
        timestamp=$(get_timestamp "$dir")
        
        case $status in
            0) percentage=0 ;;
            1) percentage=15 ;;
            2) percentage=30 ;;
            3) percentage=50 ;;
            4) percentage=100 ;;
        esac
        
        if [ $status -eq 4 ]; then
            ((COMPLETED++))
        elif [ $status -ge 1 ] && [ $status -le 3 ]; then
            ((IN_PROGRESS++))
        else
            ((NOT_STARTED++))
        fi
        
        ((TOTAL++))
        
        # Store info
        PKG_INFO+=("$timestamp|$pkg_base|$status|$percentage|$complexity")
        
    done < <(find "$ROOT_DIR/source/${BUILD_ARCH}" -maxdepth 1 -type d 2>/dev/null | sort)
    
    # Also add configured packages that don't exist physically yet
    if [ -f "$ROOT_DIR/.config" ]; then
        # Create associative array of packages already found
        declare -A existing_packages
        for info in "${PKG_INFO[@]}"; do
            IFS='|' read -r ts pkg st pct cplx <<< "$info"
            existing_packages["$pkg"]=1
        done
        
        # Get main packages from config that aren't already in the list
        while IFS= read -r line; do
            pkg_name=$(echo "$line" | sed 's/^FREETZ_PACKAGE_\([^=]*\)=y$/\1/' | tr '[:upper:]' '[:lower:]' | tr '_' '-')
            
            # Skip sub-options of main packages  
            # If package name has 3+ components (aa-bb-cc), check if parent (aa-bb) is also configured
            if [[ "$pkg_name" =~ ^([^-]+-[^-]+)- ]]; then
                parent_pkg="${BASH_REMATCH[1]}"
                if grep -q "^FREETZ_PACKAGE_$(echo "$parent_pkg" | tr '[:lower:]' '[:upper:]' | tr '-' '_')=y$" "$ROOT_DIR/.config" 2>/dev/null; then
                    # Parent package exists - this is a sub-option
                    continue
                fi
            fi
            
            # Two-tier virtual package filtering:
            # 1. Pattern-based: Fast exclusion of known virtual package patterns
            # 2. Content-based: Check if package directory has compilable source files
            
            # Tier 1: Pattern-based filtering (fast) - purely virtual packages
            [[ "$pkg_name" =~ ^(local|meta|script|config|docs)- ]] && continue           # Prefix patterns
            [[ "$pkg_name" =~ -(host|external|headers|meta|virtual|dummy)$ ]] && continue # Suffix patterns
            
            # Tier 2: Content-based filtering - packages with directories but no compilable source
            pkg_dir=$(find "$ROOT_DIR/source/${BUILD_ARCH}" -maxdepth 1 -type d -name "${pkg_name}-*" 2>/dev/null | head -1)
            # If not found, try with underscore instead of hyphen (e.g., juis-check -> juis_check)
            if [ -z "$pkg_dir" ]; then
                pkg_name_alt=$(echo "$pkg_name" | tr '-' '_')
                pkg_dir=$(find "$ROOT_DIR/source/${BUILD_ARCH}" -maxdepth 1 -type d -name "${pkg_name_alt}-*" 2>/dev/null | head -1)
            fi
            if [ -n "$pkg_dir" ]; then
                # Directory exists - check for compilable files (C/C++/Makefile)
                if ! find "$pkg_dir" -type f \( -name "*.c" -o -name "*.cc" -o -name "*.cpp" -o -name "*.cxx" -o -name "Makefile*" -o -name "*.mk" \) 2>/dev/null | grep -q .; then
                    # Exception: Keep meta-packages that orchestrate compiler/toolchain builds
                    if [[ ! "$pkg_name" =~ toolchain ]]; then
                        # No compilable files found - skip it (script-only package)
                        continue
                    fi
                fi
            fi
            # If no directory found, keep it (might be installed package or will be downloaded)
            
            # Only add if not already in list
            if [ -z "${existing_packages[$pkg_name]}" ]; then
                # Assign complexity based on known package characteristics
                complexity=0  # Default: unknown
                
                # High complexity packages
                case "$pkg_name" in
                    gcc-toolchain) complexity=10 ;;  # Meta-package that orchestrates GCC target build
                    python3|python) complexity=9 ;;
                    openssl|gnutls) complexity=7 ;;
                    busybox) complexity=8 ;;
                esac
                
                # Medium complexity packages
                case "$pkg_name" in
                    dropbear|openssh) complexity=5 ;;
                    curl|wget) complexity=4 ;;
                    haserl) complexity=4 ;;
                    uclibcxx) complexity=5 ;;
                    gcc-toolchain-headers) complexity=3 ;;
                esac
                
                # Low complexity packages - CGI scripts and simple tools
                case "$pkg_name" in
                    *-cgi|mod|modcgi|inetd) complexity=2 ;;
                esac
                
                PKG_INFO+=("0|$pkg_name|0|0|$complexity")
                ((NOT_STARTED++))
                ((TOTAL++))
            fi
        done < <(grep "^FREETZ_PACKAGE_[A-Z0-9_]*=y$" "$ROOT_DIR/.config" | grep -v "_WITH_\|_STATIC\|_DISABLE_\|_ENABLE_\|_AUTHORIZED_\|_VERSION_\|_SELECT_\|_IS_SELECTABLE\|_MOD_\|_PYC\|_COMPRESS_\|_PORT_\|_BAUD_\|_WEBINTERFACE\|_DAEMON\|_SFTP_\|_OMIT_\|_TINY\|_NORMAL\|_HUGE\|_READELF\|_OBJDUMP\|_OBJCOPY\|_NM\|_STRINGS\|_AR\|_RANLIB\|_STRIP\|_ADDR2LINE\|_SIZE\|_PATCHELF")
    fi
else
    # Early build stage - toolchain compilation only (no target dir yet)
    EARLY_BUILD_STAGE=true
    
    # Read configured packages from .config
    if [ -f "$ROOT_DIR/.config" ]; then
        # Get main packages (not python modules or sub-options)
        while IFS= read -r line; do
            # Extract package name from FREETZ_PACKAGE_PACKAGENAME=y
            pkg_name=$(echo "$line" | sed 's/^FREETZ_PACKAGE_\([^=]*\)=y$/\1/' | tr '[:upper:]' '[:lower:]' | tr '_' '-')
            
            # Skip python3 sub-modules and options (they'll be counted as part of python3)
            [[ "$pkg_name" =~ ^python3-mod- ]] && continue
            [[ "$pkg_name" =~ ^python3-pyc ]] && continue
            [[ "$pkg_name" =~ ^python3-compress ]] && continue
            
            # Skip sub-options of main packages
            # If package name has 3+ components (aa-bb-cc), check if parent (aa-bb) is also configured
            if [[ "$pkg_name" =~ ^([^-]+-[^-]+)- ]]; then
                parent_pkg="${BASH_REMATCH[1]}"
                if grep -q "^FREETZ_PACKAGE_$(echo "$parent_pkg" | tr '[:lower:]' '[:upper:]' | tr '-' '_')=y$" "$ROOT_DIR/.config" 2>/dev/null; then
                    # Parent package exists - this is a sub-option
                    continue
                fi
            fi
            
            # Two-tier virtual package filtering:
            # 1. Pattern-based: Fast exclusion of known virtual package patterns
            # 2. Content-based: Check if package directory has compilable source files
            
            # Tier 1: Pattern-based filtering (fast) - purely virtual packages
            [[ "$pkg_name" =~ ^(local|meta|script|config|docs)- ]] && continue           # Prefix patterns
            [[ "$pkg_name" =~ -(host|external|headers|meta|virtual|dummy)$ ]] && continue # Suffix patterns
            
            # Tier 2: Content-based filtering - packages with directories but no compilable source
            pkg_dir=$(find "$ROOT_DIR/source/${BUILD_ARCH}" -maxdepth 1 -type d -name "${pkg_name}-*" 2>/dev/null | head -1)
            # If not found, try with underscore instead of hyphen (e.g., juis-check -> juis_check)
            if [ -z "$pkg_dir" ]; then
                pkg_name_alt=$(echo "$pkg_name" | tr '-' '_')
                pkg_dir=$(find "$ROOT_DIR/source/${BUILD_ARCH}" -maxdepth 1 -type d -name "${pkg_name_alt}-*" 2>/dev/null | head -1)
            fi
            if [ -n "$pkg_dir" ]; then
                # Directory exists - check for compilable files (C/C++/Makefile)
                if ! find "$pkg_dir" -type f \( -name "*.c" -o -name "*.cc" -o -name "*.cpp" -o -name "*.cxx" -o -name "Makefile*" -o -name "*.mk" \) 2>/dev/null | grep -q .; then
                    # Exception: Keep meta-packages that orchestrate compiler/toolchain builds
                    if [[ ! "$pkg_name" =~ toolchain ]]; then
                        # No compilable files found - skip it (script-only package)
                        continue
                    fi
                fi
            fi
            # If no directory found, keep it (might be installed package or will be downloaded)
            
            # Assign complexity based on known package characteristics
            # Default complexity is 0 (unknown) - will show as "?"
            complexity=0
            
            # High complexity packages (7-10 stars)
            case "$pkg_name" in
                gcc-toolchain) complexity=10 ;;  # Meta-package that orchestrates GCC target build
                python3|python) complexity=9 ;;
                openssl|gnutls) complexity=7 ;;
                busybox) complexity=8 ;;
            esac
            
            # Medium complexity packages (4-6 stars)
            case "$pkg_name" in
                dropbear|openssh) complexity=5 ;;
                curl|wget) complexity=4 ;;
                haserl) complexity=4 ;;
                uclibcxx) complexity=5 ;;
            esac
            
            # Low complexity packages (1-3 stars) - CGI scripts and simple tools
            case "$pkg_name" in
                *-cgi|mod|modcgi|inetd) complexity=2 ;;
            esac
            
            # Add package as "Not started" (status=0, percentage=0)
            PKG_INFO+=("0|$pkg_name|0|0|$complexity")
            ((NOT_STARTED++))
            ((TOTAL++))
        done < <(grep "^FREETZ_PACKAGE_[A-Z0-9_]*=y$" "$ROOT_DIR/.config" | grep -v "_WITH_\|_STATIC\|_DISABLE_\|_ENABLE_\|_AUTHORIZED_\|_VERSION_\|_SELECT_\|_IS_SELECTABLE\|_MOD_\|_PYC\|_COMPRESS_\|_PORT_\|_BAUD_\|_WEBINTERFACE\|_DAEMON\|_SFTP_\|_OMIT_\|_TINY\|_NORMAL\|_HUGE\|_READELF\|_OBJDUMP\|_OBJCOPY\|_NM\|_STRINGS\|_AR\|_RANLIB\|_STRIP\|_ADDR2LINE\|_SIZE\|_PATCHELF")
    fi
fi

# Sort packages: first by status (descending: completed first), then by timestamp (descending: recent first)
# Status order: 4 (compiled), 3 (compiling), 2 (configured), 1 (unpacked), 0 (not started)
IFS=$'\n' SORTED_PKG_INFO=($(sort -t'|' -k3 -rn -k1 -rn <<<"${PKG_INFO[*]}"))
unset IFS

CURRENT_PKG=""
CURRENT_FILE=""
CURRENT_TIMESTAMP=0
for info in "${SORTED_PKG_INFO[@]}"; do
    IFS='|' read -r timestamp pkg status percentage complexity <<< "$info"
    if [ $status -ge 1 ] && [ $status -le 3 ]; then
        if (( $(echo "$timestamp > $CURRENT_TIMESTAMP" | bc -l 2>/dev/null || echo "0") )); then
            CURRENT_TIMESTAMP=$timestamp
            CURRENT_PKG=$pkg
        fi
    fi
done

# Override CURRENT_PKG by detecting active 'make' processes in package dirs
# (but only if not already set by toolchain detection)
if [ -z "$CURRENT_PKG" ]; then
    for m in $(pgrep -f "make"); do
        # Skip if process is stopped/suspended (state T)
        state=$(ps -o state= -p $m 2>/dev/null | tr -d ' ')
        [[ "$state" == "T" ]] && continue
        
        # Skip make menuconfig and similar non-build commands
        cmd=$(ps -o cmd= -p $m 2>/dev/null)
        [[ "$cmd" =~ "make menuconfig" ]] && continue
        [[ "$cmd" =~ "make config" ]] && continue
    
    cwd=$(readlink /proc/$m/cwd 2>/dev/null || true)
    
    # Check if make is running in toolchain directory
    if [[ $cwd == "$ROOT_DIR/source/toolchain-"* ]]; then
        # Toolchain compilation is active - set CURRENT_PKG to detected component
        # Already handled in toolchain component detection above
        continue
    fi
    
    if [[ $cwd == "$ROOT_DIR/source/${BUILD_ARCH}/"* && "$cwd" != "$ROOT_DIR/source/${BUILD_ARCH}" ]]; then
        CURRENT_PKG=$(basename "$cwd")
        
        # Check if this package exists in PKG_INFO
        pkg_exists=false
        pkg_index=-1
        for i in "${!PKG_INFO[@]}"; do
            IFS='|' read -r ts pkg st pct cplx <<< "${PKG_INFO[$i]}"
            if [ "$pkg" = "$CURRENT_PKG" ]; then
                pkg_exists=true
                pkg_index=$i
                break
            fi
        done
        
        if $pkg_exists; then
            # Package exists - update its status to "Compiling" if it was marked as compiled
            IFS='|' read -r ts pkg st pct cplx <<< "${PKG_INFO[$pkg_index]}"
            if [ $st -eq 4 ]; then
                # Package was compiled but is being rebuilt - update status
                pkg_dir="$ROOT_DIR/source/${BUILD_ARCH}/$CURRENT_PKG"
                timestamp=$(get_timestamp "$pkg_dir")
                PKG_INFO[$pkg_index]="$timestamp|$pkg|3|50|$cplx"
                
                # Update counters
                ((COMPILED--))
                ((IN_PROGRESS++))
                
                # Re-sort the array
                IFS=$'\n' SORTED_PKG_INFO=($(sort -t'|' -k3 -rn -k1 -rn <<<"${PKG_INFO[*]}"))
                unset IFS
            fi
        else
            # Package doesn't exist (e.g., automatic dependency like sqlite), add it
            # Normalize package name (remove version)
            pkg_base=$(echo "$CURRENT_PKG" | sed 's/-[0-9]\+\.[0-9].*//')
            if [ "$pkg_base" = "$CURRENT_PKG" ]; then
                pkg_base=$(echo "$CURRENT_PKG" | sed 's/-[0-9a-f]\{7,\}$//')
            fi
            
            # Get complexity and timestamp
            pkg_dir="$ROOT_DIR/source/${BUILD_ARCH}/$CURRENT_PKG"
            complexity=$(get_complexity "$pkg_dir")
            timestamp=$(get_timestamp "$pkg_dir")
            
            # Add as "Compiling" (status=3, percentage=50)
            PKG_INFO+=("$timestamp|$pkg_base|3|50|$complexity")
            ((IN_PROGRESS++))
            ((TOTAL++))
            
            # Re-sort the array
            IFS=$'\n' SORTED_PKG_INFO=($(sort -t'|' -k3 -rn -k1 -rn <<<"${PKG_INFO[*]}"))
            unset IFS
            
            CURRENT_PKG="$pkg_base"
        fi
        
        break
    fi
    done
fi

# Detect currently compiling file from active gcc/g++ processes
if [ -n "$CURRENT_PKG" ]; then
    for gcc_pid in $(pgrep -f "gcc|g\+\+"); do
        # Skip if process is stopped/suspended
        state=$(ps -o state= -p $gcc_pid 2>/dev/null | tr -d ' ')
        [[ "$state" == "T" ]] && continue
        
        # Get command line
        cmdline=$(ps -o cmd= -p $gcc_pid 2>/dev/null)
        
        # Check if it's a compilation command (has -c flag)
        if [[ "$cmdline" =~ \ -c\  ]]; then
            # Extract source file - usually the last argument with C/C++ extension
            # Try to find .c, .cc, .cpp, .cxx, .C files in the command line
            src_file=$(echo "$cmdline" | grep -oP '(\S+\.(c|cc|cpp|cxx|C))(?=\s|$)' | tail -1)
            
            if [ -n "$src_file" ]; then
                # Get just the filename without path
                CURRENT_FILE=$(basename "$src_file")
                break
            fi
        fi
    done
    
    # If no compilation detected, check for configure scripts
    if [ -z "$CURRENT_FILE" ]; then
        # Look for configure processes related to current package
        for conf_pid in $(pgrep -f "configure"); do
            cmdline=$(ps -o cmd= -p $conf_pid 2>/dev/null)
            
            # Check if it's an actual configure script (not just a command containing "configure")
            if [[ "$cmdline" =~ /configure\  ]] || [[ "$cmdline" =~ \ configure\  ]] || [[ "$cmdline" =~ /bin/(ba)?sh.*configure ]]; then
                # Check if the configure is running in a relevant directory
                cwd=$(readlink -f /proc/$conf_pid/cwd 2>/dev/null)
                
                # Check if it's in toolchain or target directory
                if [[ "$cwd" =~ toolchain ]] || [[ "$cwd" =~ target ]]; then
                    # Extract package name from path
                    # e.g., source/target-mips_.../openssh-10.2p1 -> openssh
                    pkg_dir=$(basename "$cwd")
                    pkg_name=$(echo "$pkg_dir" | sed -E 's/-[0-9]+.*$//')
                    
                    if [ -n "$pkg_name" ]; then
                        CURRENT_FILE="configuring $pkg_name..."
                    else
                        CURRENT_FILE="configuring..."
                    fi
                    break
                fi
            fi
        done
    fi
fi

# Firmware status
FIRMWARE_STATUS="Not started"
FIRMWARE_STATUS_TEXT="Not started"
FIRMWARE_PERCENTAGE=0
FIRMWARE_COLOR=$RED
FIRMWARE_SYMBOL="✗"

if [ -f "$ROOT_DIR/build/.unpacked" ]; then
    FIRMWARE_STATUS="Unpacked"
    FIRMWARE_STATUS_TEXT="Unpacked"
    FIRMWARE_PERCENTAGE=33
    FIRMWARE_COLOR=$YELLOW
    FIRMWARE_SYMBOL="→"
fi

if [ -f "$ROOT_DIR/build/.modified" ]; then
    FIRMWARE_STATUS="Modified"
    FIRMWARE_STATUS_TEXT="Modified"
    FIRMWARE_PERCENTAGE=66
    FIRMWARE_COLOR=$YELLOW
    FIRMWARE_SYMBOL="→"
fi

if [ -f "$ROOT_DIR/build/.image" ] || ls "$ROOT_DIR/images"/*.image >/dev/null 2>&1; then
    FIRMWARE_STATUS="Complete"
    FIRMWARE_STATUS_TEXT="Complete"
    FIRMWARE_PERCENTAGE=100
    FIRMWARE_COLOR=$GREEN
    FIRMWARE_SYMBOL="✓"
else
    # Check for active make processes (exclude stopped and menuconfig)
    # Also check for any active build-related processes (fwmod, signing, etc.)
    active_make=false
    for m in $(pgrep -f "make" 2>/dev/null); do
        state=$(ps -o state= -p $m 2>/dev/null | tr -d ' ')
        [[ "$state" == "T" ]] && continue
        cmd=$(ps -o cmd= -p $m 2>/dev/null)
        [[ "$cmd" =~ "make menuconfig" ]] && continue
        [[ "$cmd" =~ "make config" ]] && continue
        active_make=true
        break
    done
    
    # Also check for fwmod, signing, or other firmware build processes
    if ! $active_make; then
        if pgrep -f "fwmod\|signing\|pack.*firmware\|\.image" >/dev/null 2>&1; then
            active_make=true
        fi
    fi
    
    if $active_make; then
        if [ "$FIRMWARE_STATUS" = "Modified" ]; then
            FIRMWARE_STATUS="Packing"
            FIRMWARE_STATUS_TEXT="Packing/Signing..."
            FIRMWARE_PERCENTAGE=80
            FIRMWARE_COLOR=$CYAN
            FIRMWARE_SYMBOL="⚙"
        elif [ "$FIRMWARE_STATUS" = "Unpacked" ]; then
            FIRMWARE_STATUS="Modifying"
            FIRMWARE_STATUS_TEXT="Modifying..."
            FIRMWARE_PERCENTAGE=50
            FIRMWARE_COLOR=$CYAN
            FIRMWARE_SYMBOL="⚙"
        elif [ "$FIRMWARE_STATUS" != "Not started" ]; then
            # Only assume "Unpacking" if we've started firmware work
            FIRMWARE_STATUS="Unpacking"
            FIRMWARE_STATUS_TEXT="Unpacking..."
            FIRMWARE_PERCENTAGE=10
            FIRMWARE_COLOR=$CYAN
            FIRMWARE_SYMBOL="⚙"
        fi
        # If status is "Not started", keep it that way (building toolchain/packages)
    else
        # Only mark as failed if enough time has passed since last modification
        # Check if any marker file was recently modified (within last 30 seconds)
        recent_activity=false
        for marker in "$ROOT_DIR/build/.unpacked" "$ROOT_DIR/build/.modified"; do
            if [ -f "$marker" ]; then
                marker_age=$(($(date +%s) - $(stat -c %Y "$marker" 2>/dev/null || echo 0)))
                if [ "$marker_age" -lt 30 ]; then
                    recent_activity=true
                    break
                fi
            fi
        done
        
        if $recent_activity; then
            # Recent activity detected - assume still working
            if [ "$FIRMWARE_STATUS" = "Modified" ]; then
                FIRMWARE_STATUS="Packing"
                FIRMWARE_STATUS_TEXT="Packing/Signing..."
                FIRMWARE_PERCENTAGE=80
                FIRMWARE_COLOR=$CYAN
                FIRMWARE_SYMBOL="⚙"
            elif [ "$FIRMWARE_STATUS" = "Unpacked" ]; then
                FIRMWARE_STATUS="Modifying"
                FIRMWARE_STATUS_TEXT="Modifying..."
                FIRMWARE_PERCENTAGE=50
                FIRMWARE_COLOR=$CYAN
                FIRMWARE_SYMBOL="⚙"
            fi
        else
            # No recent activity and no processes - likely failed
            if [ "$FIRMWARE_STATUS" = "Modified" ]; then
                FIRMWARE_STATUS="PACK_FAILED"
                FIRMWARE_STATUS_TEXT="PACK FAILED"
                FIRMWARE_COLOR=$RED
                FIRMWARE_SYMBOL="✖"
            elif [ "$FIRMWARE_STATUS" = "Unpacked" ]; then
                FIRMWARE_STATUS="MODIFY_FAILED"
                FIRMWARE_STATUS_TEXT="MODIFY FAILED"
                FIRMWARE_PERCENTAGE=33
                FIRMWARE_COLOR=$RED
                FIRMWARE_SYMBOL="✖"
            fi
        fi
    fi
fi

TOTAL_ITEMS=$((TOTAL + 1))
COMPLETED_ITEMS=$COMPLETED
if [ "$FIRMWARE_STATUS" = "Complete" ]; then
    ((COMPLETED_ITEMS++))
elif [[ "$FIRMWARE_STATUS" =~ ^(Packing|Modifying|Unpacking)$ ]]; then
    IN_PROGRESS=$((IN_PROGRESS + 1))
fi

# Calculate overall percentage considering partial progress
# Each completed item = 100%, each in-progress item = 50% (approximation)
COMPLETED_POINTS=$((COMPLETED_ITEMS * 100))
IN_PROGRESS_POINTS=$((IN_PROGRESS * 50))
TOTAL_POINTS=$((TOTAL_ITEMS * 100))

if [ $TOTAL_POINTS -gt 0 ]; then
    OVERALL_PERCENTAGE=$(( (COMPLETED_POINTS + IN_PROGRESS_POINTS) / TOTAL_ITEMS ))
else
    OVERALL_PERCENTAGE=0
fi

# If --list-packages flag is set, output only package names and exit
if $LIST_PACKAGES_ONLY; then
    # Use associative array to ensure unique packages
    declare -A unique_pkgs
    for info in "${SORTED_PKG_INFO[@]}"; do
        IFS='|' read -r timestamp pkg status percentage complexity <<< "$info"
        # Skip toolchain components (they are not real packages)
        [[ "$pkg" =~ ^Toolchain: ]] && continue
        # Skip special toolchain packages that cannot be built standalone
        [[ "$pkg" == "gcc-toolchain" ]] && continue
        [[ "$pkg" == "binutils-toolchain" ]] && continue
        unique_pkgs["$pkg"]=1
    done
    # Output comma-separated list of unique packages
    pkg_list=""
    for pkg in "${!unique_pkgs[@]}"; do
        pkg_list="${pkg_list}${pkg},"
    done
    echo "${pkg_list%,}"
    exit 0
fi

if [ "$OUTPUT_FORMAT" = "terminal" ]; then
    if $SHOW_HEADER; then
        echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${BOLD}       Freetz-NG Build Progress Monitor${NC}"
        echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "Build Architecture: ${CYAN}$BUILD_ARCH${NC}"
        echo ""
        if $EARLY_BUILD_STAGE; then
            echo -e "${YELLOW}Build Stage: Toolchain Compilation${NC}"
            echo -e "${DIM}(Packages shown are from configuration - actual compilation pending)${NC}"
        else
            echo -e "Total packages: ${BOLD}$TOTAL${NC}"
        fi
        echo ""
    fi
    
    if $SHOW_PACKAGES; then
        if $SHOW_HEADER; then
            # Header with space for symbol column (2 chars: symbol + space)
            printf "  %-37s %-15s %-10s %-13s\n" "Package" "Status" "Progress" "Complexity"
            echo "────────────────────────────────────────────────────────────────────────────────"
        fi
        
        for info in "${SORTED_PKG_INFO[@]}"; do
            IFS='|' read -r timestamp pkg status percentage complexity <<< "$info"
            
            case $status in
                0) color=$RED; status_text="Not started"; symbol="${RED}✗${NC}" ;;
                1) color=$YELLOW; status_text="Unpacked"; symbol="${YELLOW}→${NC}" ;;
                2) color=$YELLOW; status_text="Configured"; symbol="${YELLOW}→${NC}" ;;
                3) color=$CYAN; status_text="Compiling..."; symbol="${CYAN}⚙${NC}" ;;
                4) color=$GREEN; status_text="Compiled"; symbol="${GREEN}✓${NC}" ;;
            esac
            
            # Show stars for known complexity, "?" for unknown
            if [ "$complexity" -eq 0 ]; then
                stars="${DIM}?${NC}"
            else
                # Highlight toolchain stars in yellow (exceptionally long compilation)
                if $EARLY_BUILD_STAGE || [[ "$pkg" =~ ^Toolchain: ]]; then
                    stars="${YELLOW}$(printf '★%.0s' $(seq 1 $complexity))${NC}"
                else
                    stars=$(printf '★%.0s' $(seq 1 $complexity))
                fi
            fi
            
            # Truncate package name if too long
            pkg_display=$(truncate_name "$pkg" 35)
            
            if [ "$pkg" = "$CURRENT_PKG" ]; then
                # Currently compiling - add markers around package name
                # Use shorter field width (35 instead of 37) to account for double symbol
                printf "%b %-35s %b%-15s%b %-10s %b\n" \
                    "${CYAN}⚙ ${MAGENTA}►${NC}" "${pkg_display}" \
                    "$color" "$status_text" "${NC}" \
                    "$percentage%" "$stars"
            else
                # Regular package - symbol already has color
                printf "%b %-37s %b%-15s%b %-10s %b\n" \
                    "$symbol" "$pkg_display" \
                    "$color" "$status_text" "${NC}" \
                    "$percentage%" "$stars"
            fi
        done
        
        echo ""
        printf "%b %-37s %b%-15s%b %-10s\n" \
            "${FIRMWARE_COLOR}${FIRMWARE_SYMBOL}${NC}" "Firmware Image" \
            "${FIRMWARE_COLOR}" "$FIRMWARE_STATUS_TEXT" "${NC}" \
            "$FIRMWARE_PERCENTAGE%"
        echo ""
        
        if $SHOW_SUMMARY; then
            echo "────────────────────────────────────────────────────────────────────────────────"
            echo ""
        fi
    fi
    
    if $SHOW_SUMMARY; then
        echo -e "${BOLD}Summary:${NC}"
        echo -e "  Completed:         ${GREEN}$COMPLETED_ITEMS${NC} / $TOTAL_ITEMS"
        echo -e "  In Progress:       ${CYAN}$IN_PROGRESS${NC}"
        echo -e "  Not Started:       ${RED}$NOT_STARTED${NC}"
        
        # Only show "Currently Compiling" if there are active build processes (not zombie)
        # Check for actual running make/gcc/g++ processes
        active_build_processes=$(ps aux | grep -E "[m]ake|[g]cc|[g]\+\+" | grep -v "defunct" | wc -l)
        
        if [ -n "$CURRENT_PKG" ] && [ "$active_build_processes" -gt 0 ]; then
            current_pkg_display=$(truncate_name "$CURRENT_PKG" 40)
            if [ -n "$CURRENT_FILE" ]; then
                file_display=$(truncate_name "$CURRENT_FILE" 30)
                echo -e "  Currently Compiling: ${CYAN}⚙ $current_pkg_display${NC} ${DIM}($file_display)${NC}"
            else
                echo -e "  Currently Compiling: ${CYAN}⚙ $current_pkg_display${NC}"
            fi
        fi
        echo ""
    fi
    
    if $SHOW_PROGRESS_BAR; then
        echo -e "${BOLD}Overall Progress: $OVERALL_PERCENTAGE%${NC}"
        
        BAR_WIDTH=50
        
        # Fix rounding for 100% - ensure bar is completely filled
        if [ "$OVERALL_PERCENTAGE" -eq 100 ]; then
            FILLED=$BAR_WIDTH
            EMPTY=0
        else
            FILLED=$(( OVERALL_PERCENTAGE * BAR_WIDTH / 100 ))
            EMPTY=$(( BAR_WIDTH - FILLED ))
        fi
        
        printf "["
        if [ $FILLED -gt 0 ]; then
            printf "${GREEN}"
            for i in $(seq 1 $FILLED); do printf "█"; done
            printf "${NC}"
        fi
        if [ $EMPTY -gt 0 ]; then
            for i in $(seq 1 $EMPTY); do printf "░"; done
        fi
        printf "] $OVERALL_PERCENTAGE%%\n"
        echo ""
        
        if $SHOW_HEADER; then
            echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
            echo ""
        fi
    fi
    
    if $SHOW_LEGEND; then
        # Don't show firmware build steps during early toolchain compilation
        if ! $EARLY_BUILD_STAGE; then
            STEP1_STATUS="✗ Not started"
            STEP1_COLOR=$RED
            STEP2_STATUS="✗ Not started"
            STEP2_COLOR=$RED
            STEP3_STATUS="✗ Not started"
            STEP3_COLOR=$RED
            
        if [ -f "$ROOT_DIR/build/.unpacked" ]; then
                STEP1_STATUS="✓ Completed"
                STEP1_COLOR=$GREEN
            fi
            
        if [ -f "$ROOT_DIR/build/.modified" ]; then
                STEP2_STATUS="✓ Completed"
                STEP2_COLOR=$GREEN
            fi
            
        if [ -f "$ROOT_DIR/build/.image" ] || ls "$ROOT_DIR/images"/*.image >/dev/null 2>&1; then
                STEP3_STATUS="✓ Completed"
                STEP3_COLOR=$GREEN
            elif [[ "$FIRMWARE_STATUS" == "PACK_FAILED" ]]; then
                STEP3_STATUS="✖ FAILED"
                STEP3_COLOR=$RED
            elif [[ "$FIRMWARE_STATUS" == "Packing" ]]; then
                STEP3_STATUS="⚙ In progress..."
                STEP3_COLOR=$CYAN
            fi
            
            if [[ "$FIRMWARE_STATUS" == "MODIFY_FAILED" ]]; then
                STEP2_STATUS="✖ FAILED"
                STEP2_COLOR=$RED
            elif [[ "$FIRMWARE_STATUS" == "Modifying" ]]; then
                STEP2_STATUS="⚙ In progress..."
                STEP2_COLOR=$CYAN
            fi
            
            if [[ "$FIRMWARE_STATUS" == "Unpacking" ]]; then
                STEP1_STATUS="⚙ In progress..."
                STEP1_COLOR=$CYAN
            fi
            
            echo -e "${BOLD}Firmware Build Steps:${NC}"
            echo -e "  STEP 1: UNPACK      - ${STEP1_COLOR}${STEP1_STATUS}${NC}"
            echo -e "  STEP 2: MODIFY      - ${STEP2_COLOR}${STEP2_STATUS}${NC}"
            echo -e "  STEP 3: PACK/SIGN   - ${STEP3_COLOR}${STEP3_STATUS}${NC}"
            echo ""
        fi
        
        echo -e "${BOLD}Package Status:${NC}"
        echo -e "  ${RED}✗${NC} Not started  - Package not yet downloaded/extracted (0%)"
        echo -e "  ${YELLOW}→${NC} Unpacked     - Source code extracted (15%)"
        echo -e "  ${YELLOW}→${NC} Configured   - ./configure completed, ready to compile (30%)"
        echo -e "  ${CYAN}⚙${NC} Compiling... - Actively compiling source code (50%)"
        echo -e "  ${GREEN}✓${NC} Compiled     - Build complete (100%)"
        echo -e "  ${MAGENTA}►${NC} Marker       - Indicates the package currently being compiled"
        echo ""
        echo -e "${BOLD}Firmware Image Status:${NC}"
        echo -e "  ${RED}✗${NC} Not started        - Firmware build not initiated (0%)"
        echo -e "  ${CYAN}⚙${NC} Unpacking...       - Extracting original firmware (10%)"
        echo -e "  ${YELLOW}→${NC} Unpacked           - Firmware extracted, ready to modify (33%)"
        echo -e "  ${CYAN}⚙${NC} Modifying...       - Applying patches and packages (50%)"
        echo -e "  ${YELLOW}→${NC} Modified           - Modifications applied, ready to pack (66%)"
        echo -e "  ${CYAN}⚙${NC} Packing/Signing... - Creating and signing image (80%)"
        echo -e "  ${GREEN}✓${NC} Complete           - Image signed and ready (100%)"
        echo -e "  ${RED}✖${NC} Failed             - Build step failed (check logs)"
    fi
fi
