#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#  RON'S STATUSLINE — a 5-line dashboard for Claude Code
# ═══════════════════════════════════════════════════════════════

# --- Colors -----------------------------------------------------------
RST=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RED=$'\033[31m';   GRN=$'\033[32m';  YEL=$'\033[33m'
BLU=$'\033[34m';   MAG=$'\033[35m';  CYN=$'\033[36m'
WHT=$'\033[37m';   ORG=$'\033[38;5;208m'
DGRY=$'\033[38;5;242m'
LCYN=$'\033[38;5;117m'
LGRN=$'\033[38;5;149m'
LMAG=$'\033[38;5;183m'
LYEL=$'\033[38;5;229m'

# --- Cache setup ------------------------------------------------------
CACHE_DIR=~/.claude/statusline-data
mkdir -p "$CACHE_DIR"
FULL_CACHE="$CACHE_DIR/full_output"
GIT_CACHE="$CACHE_DIR/git_info"
GIT_CACHE_TS="$CACHE_DIR/git_info_ts"
MEM_CACHE="$CACHE_DIR/mem_info"
MEM_CACHE_TS="$CACHE_DIR/mem_info_ts"
SPARK_CACHE="$CACHE_DIR/spark_info"
SPARK_CACHE_TS="$CACHE_DIR/spark_info_ts"
HOOK_CACHE="$CACHE_DIR/hook_info"
HOOK_CACHE_TS="$CACHE_DIR/hook_info_ts"

# --- Read JSON from stdin ---------------------------------------------
input=$(cat)
cwd=$(echo "$input"       | jq -r '.workspace.current_dir // empty')
model=$(echo "$input"      | jq -r '.model.display_name // empty')
used_pct=$(echo "$input"   | jq -r '.context_window.used_percentage // empty')
cc_version=$(echo "$input" | jq -r '.version // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
cost_usd=$(echo "$input"   | jq -r '.cost.total_cost_usd // empty')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')


# --- Fast path: if no session data yet and we have cached output, use it ---
if [ -z "$used_pct" ] && [ -z "$model" ] && [ -f "$FULL_CACHE" ]; then
    cat "$FULL_CACHE"
    exit 0
fi

[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || cd "$HOME"

# --- Helper: check if cache is fresh ---------------------------------
cache_fresh() {
    local ts_file=$1 max_age=$2
    [ -f "$ts_file" ] || return 1
    local last now
    last=$(cat "$ts_file" 2>/dev/null)
    now=$(date +%s)
    [ -n "$last" ] && [ $(( now - last )) -lt "$max_age" ]
}

# --- Helpers ----------------------------------------------------------
sep="${DIM}│${RST}"

short_ver() {
    echo "$1" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
}


# --- Tool versions: use cache to avoid slow subprocess calls ----------
tool_cache="$CACHE_DIR/tool_versions"
tool_cache_ts="$CACHE_DIR/tool_versions_ts"

if cache_fresh "$tool_cache_ts" 3600 && [ -f "$tool_cache" ]; then
    { IFS=$'\n' read -r py_v; read -r node_v; read -r php_v; read -r aws_v; } < "$tool_cache"
else
    py_v=$(short_ver "$(python3 --version 2>&1)")
    node_v=$(short_ver "$(node --version 2>&1)")
    php_v=$(short_ver "$(php -r 'echo PHP_VERSION;' 2>/dev/null)")
    aws_v=$(short_ver "$(aws --version 2>&1)")
    printf "%s\n%s\n%s\n%s\n" "$py_v" "$node_v" "$php_v" "$aws_v" > "$tool_cache"
    date +%s > "$tool_cache_ts"
fi

# Count hooks from settings.json (cache for 60s)
if cache_fresh "$HOOK_CACHE_TS" 60 && [ -f "$HOOK_CACHE" ]; then
    hook_count=$(cat "$HOOK_CACHE")
else
    hook_count=0
    if [ -f ~/.claude/settings.json ]; then
        hook_count=$(jq '[.hooks // {} | to_entries[] | .value[] | .hooks[]?] | length' ~/.claude/settings.json 2>/dev/null || echo 0)
    fi
    echo "$hook_count" > "$HOOK_CACHE"
    date +%s > "$HOOK_CACHE_TS"
fi

line1b="${DGRY}ENV:${RST} ${WHT}CC:${BOLD}${cc_version:-?}${RST}"
line1b+="  ${sep} ${WHT}Py:${CYN}${py_v:-?}${RST}"
line1b+="  ${sep} ${WHT}Node:${GRN}${node_v:-?}${RST}"
line1b+="  ${sep} ${WHT}PHP:${MAG}${php_v:-?}${RST}"
line1b+="  ${sep} ${WHT}AWS:${YEL}${aws_v:-?}${RST}"
line1b+="  ${sep} ${WHT}Hooks:${ORG}${hook_count}${RST}"

# --- Line 2: Context bar + model -------------------------------------
ctx_line=""
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    bar_width=40
    filled=$(( used_int * bar_width / 100 ))
    empty=$(( bar_width - filled ))

    if [ "$used_int" -ge 80 ]; then
        bar_color="$RED"
    elif [ "$used_int" -ge 50 ]; then
        bar_color="$YEL"
    else
        bar_color="$GRN"
    fi

    bar="${bar_color}"
    for ((i=0; i<filled; i++)); do bar+="━"; done
    bar+="${DGRY}"
    for ((i=0; i<empty; i++)); do bar+="─"; done
    bar+="${RST}"

    ctx_line="${LGRN}◉ CONTEXT:${RST} ${bar} ${bar_color}${BOLD}${used_int}%${RST}"
    if [ -n "$model" ] && [ "$model" != "null" ]; then
        ctx_line+="  ${sep} ${LMAG}${model}${RST}"
    fi
    if [ -n "$cost_usd" ] && [ "$cost_usd" != "null" ] && [ "$cost_usd" != "0" ]; then
        cost_fmt=$(printf '$%.2f' "$cost_usd")
        ctx_line+="  ${sep} ${DGRY}${cost_fmt}${RST}"
    fi
fi

# --- Line 3: PWD, branch, session age, memory stats ------------------
dir_display=$(echo "$cwd" | sed "s|^$HOME|~|")
# Shorten to last 2 path components if long
if [ ${#dir_display} -gt 30 ]; then
    dir_display="…/$(echo "$dir_display" | rev | cut -d/ -f1-2 | rev)"
fi

# Git info (cache for 30s, keyed by cwd)
git_info=""
git_cache_key="$CACHE_DIR/git_info_$(echo "$cwd" | md5 -q 2>/dev/null || echo "$cwd" | md5sum | cut -d' ' -f1)"
git_cache_key_ts="${git_cache_key}_ts"

if cache_fresh "$git_cache_key_ts" 30 && [ -f "$git_cache_key" ]; then
    git_info=$(cat "$git_cache_key")
else
    if git rev-parse --git-dir > /dev/null 2>&1; then
        branch=$(git branch --show-current 2>/dev/null)
        [ -z "$branch" ] && branch="detached"
        git_flags=""
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            git_flags="±"
        fi
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]; then
            git_flags="${git_flags}?"
        fi
        if [ -n "$git_flags" ]; then
            git_info="${YEL}${branch} ${git_flags}${RST}"
        else
            git_info="${GRN}${branch}${RST}"
        fi
    fi
    echo "$git_info" > "$git_cache_key"
    date +%s > "$git_cache_key_ts"
fi

# Session age
session_age=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    ts_birth=$(stat -f %B "$transcript" 2>/dev/null || stat -c %W "$transcript" 2>/dev/null)
    if [ -n "$ts_birth" ] && [ "$ts_birth" -gt 0 ] 2>/dev/null; then
        now=$(date +%s)
        elapsed=$(( now - ts_birth ))
        if [ $elapsed -ge 3600 ]; then
            session_age="$(( elapsed / 3600 ))h$(( (elapsed % 3600) / 60 ))m"
        elif [ $elapsed -ge 60 ]; then
            session_age="$(( elapsed / 60 ))m"
        else
            session_age="${elapsed}s"
        fi
    fi
fi

# Memory stats (cache for 60s)
if cache_fresh "$MEM_CACHE_TS" 60 && [ -f "$MEM_CACHE" ]; then
    { IFS=$'\n' read -r mem_count; read -r proj_count; } < "$MEM_CACHE"
else
    mem_count=$(find ~/.claude/projects/ -path "*/memory/*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    proj_count=$(ls -d ~/.claude/projects/*/ 2>/dev/null | wc -l | tr -d ' ')
    printf "%s\n%s\n" "$mem_count" "$proj_count" > "$MEM_CACHE"
    date +%s > "$MEM_CACHE_TS"
fi


# --- Line 4: Activity sparklines (cache for 30s) ---------------------
if cache_fresh "$SPARK_CACHE_TS" 30 && [ -f "$SPARK_CACHE" ]; then
    sparkline=$(cat "$SPARK_CACHE")
else
    sparkline=""
    activity_log=~/.claude/statusline-data/activity.log
    if [ -f "$activity_log" ] && [ -s "$activity_log" ]; then
        now=$(date +%s)
        blocks=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

        # Single awk pass computes all 3 sparklines at once (was 72 separate invocations!)
        # Uses "s,b" composite keys since macOS awk lacks multidimensional arrays
        read -r spark_1h spark_1d spark_1w < <(awk -v now="$now" '
        BEGIN {
            w[0]=150;   w[1]=3600;  w[2]=25200
            n=24
        }
        {
            ts = $1 + 0
            for (s=0; s<3; s++) {
                start = now - w[s] * n
                if (ts >= start) {
                    b = int((ts - start) / w[s])
                    if (b >= 0 && b < n) c[s "," b]++
                }
            }
        }
        END {
            split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", blk, " ")
            for (s=0; s<3; s++) {
                mx=0
                for (b=0; b<n; b++) { v=c[s "," b]+0; if (v>mx) mx=v }
                sp=""
                for (b=0; b<n; b++) {
                    v=c[s "," b]+0
                    if (mx==0) idx=1
                    else { idx=int(v*7/mx)+1; if(idx>8) idx=8 }
                    sp = sp blk[idx]
                }
                printf "%s ", sp
            }
            printf "\n"
        }' "$activity_log")

        sparkline="${LYEL}✧ ACTIVITY:${RST}"
        sparkline+="  ${DGRY}1h:${RST}${CYN}${spark_1h}${RST}"
        sparkline+="  ${DGRY}1d:${RST}${GRN}${spark_1d}${RST}"
        sparkline+="  ${DGRY}1w:${RST}${ORG}${spark_1w}${RST}"
    else
        sparkline="${LYEL}✧ ACTIVITY:${RST} ${DGRY}(collecting data...)${RST}"
    fi
    echo "$sparkline" > "$SPARK_CACHE"
    date +%s > "$SPARK_CACHE_TS"
fi

# --- Line 5: Random quote ---------------------------------------------
quote_line=""
quote_dir=~/.claude/quotes
quote_cache=~/.claude/statusline-data/quote_cache
quote_ts=~/.claude/statusline-data/quote_ts

# Refresh quote every 10 minutes
refresh=true
if [ -f "$quote_ts" ] && [ -f "$quote_cache" ]; then
    last=$(cat "$quote_ts")
    now_s=$(date +%s)
    if [ $(( now_s - last )) -lt 60 ]; then
        refresh=false
    fi
fi

if $refresh; then
    # Pick a random quote file, then a random quote from it
    quote_files=("$quote_dir"/*.txt)
    if [ ${#quote_files[@]} -gt 0 ]; then
        rnd_file="${quote_files[$((RANDOM % ${#quote_files[@]}))]}"
        # fortune-style: split on % lines
        quote=$(awk 'BEGIN{RS="%"; FS="\n"} NF>0 {gsub(/^\n|\n$/,""); a[n++]=$0} END{srand(); print a[int(rand()*n)]}' "$rnd_file")
        source_name=$(basename "$rnd_file" .txt | tr '_' ' ')
        echo "$quote" > "$quote_cache"
        echo "$source_name" > "${quote_cache}_source"
        date +%s > "$quote_ts"
    fi
fi

if [ -f "$quote_cache" ]; then
    q=$(cat "$quote_cache")
    src=$(cat "${quote_cache}_source" 2>/dev/null)
    # Truncate if too long
    if [ ${#q} -gt 90 ]; then
        q="${q:0:87}..."
    fi
    quote_line="${MAG}✦${RST} ${DIM}${q}${RST}"
fi

# --- Line 1: Dense summary (shown even on initial session render) ------
summary=""
# Context % (compact)
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    if [ "$used_int" -ge 80 ]; then sc="$RED"
    elif [ "$used_int" -ge 50 ]; then sc="$YEL"
    else sc="$GRN"; fi
    summary+="${sc}${BOLD}${used_int}%${RST}"
else
    summary+="${DGRY}?%${RST}"
fi
# Model (short)
if [ -n "$model" ] && [ "$model" != "null" ]; then
    summary+=" ${sep} ${LMAG}${model}${RST}"
fi
# PWD
summary+=" ${sep} ${BLU}${dir_display}${RST}"
# Branch
[ -n "$git_info" ] && summary+=" ${sep} ${git_info}"
# Session age
[ -n "$session_age" ] && summary+=" ${sep} ${LYEL}${session_age}${RST}"
# Memory stats
summary+=" ${sep} ${ORG}◆${RST} ${BOLD}Mem:${RST} ${LMAG}${mem_count}${RST}${DGRY}/${RST}${DGRY}${proj_count}proj${RST}"

# --- Output (progressive — print each line immediately) ---------------
# This ensures partial output is visible even if the script is cancelled
# mid-execution by a new statusline refresh.
{
    printf "%s\n" "$summary"
    printf "%s\n" "$line1b"
    [ -n "$ctx_line" ] && printf "%s\n" "$ctx_line"
    printf "%s\n" "$sparkline"
    [ -n "$quote_line" ] && printf "%s\n" "$quote_line"
} | tee "$FULL_CACHE"
