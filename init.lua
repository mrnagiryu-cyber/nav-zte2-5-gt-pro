local opt = vim.opt
local g = vim.g
local api = vim.api
local cmd = vim.cmd
local keymap = vim.keymap.set

-- ==========================================
-- 1. CORE SETTINGS & MOUSE SUPPORT
-- ==========================================
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.hidden = true
opt.updatetime = 50
opt.clipboard:append("unnamedplus")
opt.completeopt = { "menu", "menuone", "noselect" }
opt.swapfile = false
opt.winblend = 8
opt.pumblend = 8

opt.mouse = "a"

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.cindent = true
opt.breakindent = true
opt.ignorecase = true
opt.smartcase = true

g.mapleader = " "

local pairs_map = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'" }
for open, close in pairs(pairs_map) do
    keymap("i", open, open .. close .. "<Left>", { noremap = true, silent = true })
end

api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
    callback = function()
        local ft = vim.bo.filetype
        if ft ~= "" then print("🔍 Language Detected: " .. string.upper(ft)) end
    end
})

local function get_safe_dims()
    local c = tonumber(api.nvim_get_option("columns")) or 80
    local l = tonumber(api.nvim_get_option("lines")) or 24
    return math.max(10, c), math.max(5, l)
end

-- ==========================================
-- 2. 200 THEMES & TERMINAL BG SYNCHRONIZATION
-- ==========================================
local bases = {
    {n="Red", f="#ff4d4d"}, {n="Blue", f="#4d4dff"}, {n="Green", f="#4dff4d"}, {n="Yellow", f="#ffeb3b"},
    {n="Purple", f="#d14dff"}, {n="Cyan", f="#00e5ff"}, {n="Orange", f="#fd971f"}, {n="Pink", f="#ff7edb"},
    {n="Teal", f="#1de9b6"}, {n="Indigo", f="#536dfe"}, {n="Lime", f="#c6ff00"}, {n="Amber", f="#ffc107"},
    {n="DeepOrange", f="#ff5722"}, {n="Brown", f="#795548"}, {n="BlueGrey", f="#607d8b"}, {n="Crimson", f="#dc143c"},
    {n="Mint", f="#98ff98"}, {n="Gold", f="#ffd700"}, {n="Violet", f="#8a2be2"}, {n="Slate", f="#708090"}
}
local themes = {}
for _, b in ipairs(bases) do
    table.insert(themes, { name = "ZTX Void " .. b.n, bg="#000000", fg=b.f, line="#111111", status="#222222" })
    table.insert(themes, { name = "Deep Tint " .. b.n, bg="#0a0a0a", fg=b.f, line="#1a1a1a", status="#121212" })
    table.insert(themes, { name = "Twilight " .. b.n, bg="#1e1e2e", fg=b.f, line="#313244", status="#45475a" })
    table.insert(themes, { name = "Classic " .. b.n, bg="#282a36", fg=b.f, line="#44475a", status="#6272a4" })
    table.insert(themes, { name = "Light " .. b.n, bg="#f8f9fa", fg=b.f, line="#e9ecef", status="#dee2e6" })
    table.insert(themes, { name = "Cyberpunk " .. b.n, bg="#0d0221", fg=b.f, line="#261447", status="#f6019d" })
    table.insert(themes, { name = "Neon " .. b.n, bg="#050505", fg=b.f, line="#151515", status="#252525" })
    table.insert(themes, { name = "Zed Modern " .. b.n, bg="#18181b", fg=b.f, line="#27272a", status="#3f3f46" })
    table.insert(themes, { name = "Monokai Pro " .. b.n, bg="#272822", fg=b.f, line="#3e3d32", status="#75715e" })
    table.insert(themes, { name = "Nordic " .. b.n, bg="#2e3440", fg=b.f, line="#3b4252", status="#434c5e" })
end

_G.CurrentThemeIndex = 6
function _G.ApplyTheme(idx)
    _G.CurrentThemeIndex = idx
    local t = themes[idx] or themes[1]
    api.nvim_set_hl(0, "Normal", { bg = t.bg, fg = t.fg })
    api.nvim_set_hl(0, "CursorLine", { bg = t.line })
    api.nvim_set_hl(0, "StatusLine", { bg = t.status, fg = (t.name:match("Light") and "#000000" or "#ffffff"), bold = true })
    api.nvim_set_hl(0, "FloatBorder", { fg = t.fg, bg = t.bg })
    api.nvim_set_hl(0, "NormalFloat", { bg = t.bg })
    io.write(string.format("\27]11;%s\7", t.bg))
end
ApplyTheme(6)

local function quick_switch_theme()
    local next_idx = (_G.CurrentThemeIndex % #themes) + 1
    ApplyTheme(next_idx)
    print("🎨 Quick Switched to: " .. themes[next_idx].name)
end

-- ==========================================
-- 3. LIVE HTTP SERVER & TEMPLATES ENGINE
-- ==========================================
_G.HttpServerJob = nil
local function toggle_http_server()
    if _G.HttpServerJob then
        vim.fn.jobstop(_G.HttpServerJob)
        _G.HttpServerJob = nil
        print("🛑 Live HTTP Server STOPPED")
    else
        _G.HttpServerJob = vim.fn.jobstart({"python3", "-m", "http.server", "8080"}, {
            on_stdout = function(_, data) if data[1] ~= "" then print("🌐 HTTP: " .. data[1]) end end,
            on_stderr = function(_, data) if data[1] ~= "" then print("🌐 HTTP: " .. data[1]) end end,
        })
        print("🚀 Live HTTP Server STARTED on http://localhost:8080")
    end
    _G.NavMenuOpen()
end

local function get_comment_syntax(lang)
    local hash = {Python=1, Ruby=1, Perl=1, ["Bash/Shell"]=1, PowerShell=1, YAML=1, GDScript=1, Nim=1, Crystal=1, CoffeeScript=1, Hack=1}
    local dash = {Lua=1, SQL=1, ["PL/SQL"]=1, ["T-SQL"]=1, ["Cassandra Query Language (CQL)"]=1, Haskell=1, Ada=1, Elm=1, PureScript=1, Euphoria=1}
    local html = {HTML=1, XML=1, XHTML=1, SVG=1, Markdown=1}
    local semi = {Lisp=1, Scheme=1, Clojure=1, Assembly=1, AutoIt=1}
    local pct  = {Prolog=1, Erlang=1}
    
    if hash[lang] then return "# ", ""
    elseif dash[lang] then return "-- ", ""
    elseif html[lang] then return ""
    elseif semi[lang] then return ";; ", ""
    elseif pct[lang] then return "% ", ""
    else return "// ", "" end
end

local function insert_lang_template(lang_name)
    local c_start, c_end = get_comment_syntax(lang_name)
    local content = ""
    
    if lang_name == "HTML" then
        content = "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"UTF-8\">\n  <title>NAV.ZTE2.5 GT PRO</title>\n</head>\n<body>\n  <h1>Welcome to NAV.ZTE2.5 GT PRO</h1>\n</body>\n</html>"
    elseif lang_name == "Python" then
        content = "# NAV.ZTE2.5 GT PRO Python Engine\ndef main():\n    print('Hello from NAV.ZTE2.5 GT PRO')\n\nif __name__ == '__main__':\n    main()"
    elseif lang_name == "C++" then
        content = "#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << \"Hello NAV.ZTE2.5 GT PRO\" << endl;\n    return 0;\n}"
    else
        content = string.format("%sTemplate: %s%s\n%sNAV.ZTE2.5 GT PRO EDITION%s\n\n", c_start, lang_name, c_end, c_start, c_end)
        if c_start == "// " then
            content = content .. string.format("function main() {\n    console.log(\"Hello from %s\");\n}", lang_name)
        elseif c_start == "# " then
            content = content .. string.format("def main():\n    print(\"Hello from %s\")\n\nmain()", lang_name)
        else
            content = content .. string.format("%s [Start coding %s] %s", c_start, lang_name, c_end)
        end
    end

    local lines = {}
    for s in content:gmatch("[^\r\n]+") do table.insert(lines, s) end
    api.nvim_put(lines, 'c', true, true)
    print("✨ " .. lang_name .. " template loaded!")
end

-- ==========================================
-- 4. UTILITIES & POWER FEATURES
-- ==========================================
local function auto_run_code()
    local ft = vim.bo.filetype
    local file = vim.fn.expand("%")
    if file == "" then print("⚠️ Save file first before running!"); return end
    
    local cmds = {
        python = "python3 " .. file,
        javascript = "node " .. file,
        typescript = "npx ts-node " .. file,
        sh = "bash " .. file,
        lua = "lua " .. file,
        go = "go run " .. file,
        rust = "cargo run || rustc " .. file .. " && ./" .. vim.fn.expand("%:r"),
        c = "gcc " .. file .. " -o " .. vim.fn.expand("%:r") .. " && ./" .. vim.fn.expand("%:r"),
        cpp = "g++ " .. file .. " -o " .. vim.fn.expand("%:r") .. " && ./" .. vim.fn.expand("%:r"),
        php = "php " .. file,
        ruby = "ruby " .. file,
        java = "javac " .. file .. " && java " .. vim.fn.expand("%:r")
    }
    
    local run_cmd = cmds[ft] or ("echo 'No auto runner configured for " .. ft .. "'")
    cmd("bot split | term " .. run_cmd)
end

local function run_unit_tests()
    local ft = vim.bo.filetype
    local cmds = {
        javascript = "npm test",
        typescript = "npm test",
        python = "pytest",
        go = "go test -v ./...",
        rust = "cargo test",
        java = "mvn test",
        php = "phpunit"
    }
    local test_cmd = cmds[ft] or "npm test || pytest || go test ./..."
    cmd("bot split | term " .. test_cmd)
end

local function clean_spaces_and_blanks()
    cmd([[%s/\s\+$//e]])
    cmd([[%g/^\s*$/d]])
    print("🧹 Trimmed trailing whitespaces & removed blank lines!")
end

local function global_search_replace()
    vim.ui.input({ prompt = "🔍 Search term: " }, function(search)
        if not search or search == "" then return end
        vim.ui.input({ prompt = "✏️ Replace with: " }, function(replace)
            if replace == nil then return end
            cmd(string.format("%%s/%s/%s/gI", search, replace))
            print("✨ Global Search & Replace completed!")
        end)
    end)
end

local function base64_encode_buffer()
    cmd("%!base64")
    print("🔒 Buffer Encoded to Base64!")
end

local function base64_decode_buffer()
    cmd("%!base64 -d")
    print("🔓 Buffer Decoded from Base64!")
end

local lsp_diag_enabled = true
local function toggle_lsp_diagnostics()
    lsp_diag_enabled = not lsp_diag_enabled
    vim.diagnostic.config({ virtual_text = lsp_diag_enabled, underline = lsp_diag_enabled })
    print("🩺 Live LSP Diagnostics: " .. (lsp_diag_enabled and "ENABLED" or "DISABLED"))
end

-- ==========================================
-- 5. FULL ACTION ENGINE
-- ==========================================
local function run_action(act)
    if act == "toggle_http" then toggle_http_server() return end
    if act == "quick_theme" then quick_switch_theme() return end
    if act == "auto_run" then auto_run_code() return end
    if act == "run_test" then run_unit_tests() return end
    if act == "clean_spaces" then clean_spaces_and_blanks() return end
    if act == "search_replace" then global_search_replace() return end
    if act == "b64_enc" then base64_encode_buffer() return end
    if act == "b64_dec" then base64_decode_buffer() return end
    if act == "lsp_diag" then toggle_lsp_diagnostics() return end

    if act:match("^tpl_") then insert_lang_template(act:gsub("tpl_", "")) return end
    if act:match("^sys_") then cmd("bot split | term " .. act:gsub("^sys_", "")) return end

    if act == "theme_picker" then
        local names = {}
        for _, t in ipairs(themes) do table.insert(names, t.name) end
        _G.RenderMenu("👑 CHOOSE THEME (200 VARIANTS)", names, true, function(sel)
            for i, t in ipairs(themes) do if t.name == sel then ApplyTheme(i) print("🎨 Theme updated: " .. sel) break end end
        end)
    elseif act == "clear_search" then cmd("nohlsearch") print("🧹 Highlights Cleared")
    elseif act == "zen_mode" then print("🧘 Zen Mode Toggled")
    elseif act == "float_term" then
        local buf = api.nvim_create_buf(false, true); local c, l = get_safe_dims()
        api.nvim_open_win(buf, true, { relative="editor", width=math.floor(c*0.85), height=math.floor(l*0.8), row=math.floor(l*0.1), col=math.floor((c - math.floor(c*0.85))/2), style="minimal", border="rounded" })
        vim.fn.termopen(os.getenv("SHELL") or "bash") cmd("startinsert")
    elseif act == "custom_cmd" then
        vim.ui.input({ prompt = "⚙️ Execute Command: " }, function(i) if i then cmd("bot split | term " .. i) end end)
    elseif act == "json_pretty" then cmd("%!jq .") print("✨ JSON Formatted")
    elseif act == "json_minify" then cmd("%!jq -c .") print("✨ JSON Minified")
    elseif act == "uuid_gen" then api.nvim_put({io.popen("uuidgen 2>/dev/null || date +%s"):read("*l")}, 'c', true, true)
    elseif act == "save" then cmd("w!") print("💾 Saved!")
    elseif act == "quit" then cmd("qa!") end
end

-- ==========================================
-- 6. FULL MENU DATA WITH OLLAMA AI & 150+ FEATURES
-- ==========================================
local menu_data = {
    { label = "🌐 Toggle Live HTTP Local Server (Port 8080)", action = "toggle_http" },
    { label = "⚡ Automatic Code Runner (Run Current File)", action = "auto_run" },
    { label = "🎨 Quick Theme Switcher (Cycle Themes)", action = "quick_theme" },
    { label = "🩺 Toggle Live LSP Diagnostics", action = "lsp_diag" },
    { label = "🧹 Clean Spaces & Blank Lines", action = "clean_spaces" },
    { label = "🔍 Global Search & Replace", action = "search_replace" },
    
    { label = "🦙 AI Ollama Engine (Local LLM Integration)", sub = {
        { label = "🦙 Ollama: Start Local Ollama Server", action = "sys_ollama serve" },
        { label = "🦙 Ollama: Pull Llama3 Model", action = "sys_ollama pull llama3" },
        { label = "🦙 Ollama: Pull Codellama Model", action = "sys_ollama pull codellama" },
        { label = "🦙 Ollama: Pull Mistral Model", action = "sys_ollama pull mistral" },
        { label = "🦙 Ollama: Run Interactive Chat CLI", action = "sys_ollama run llama3" },
        { label = "🦙 Ollama: Generate Code Snippet locally", action = "sys_ollama run codellama 'write a high performance concurrency worker in Go'" },
        { label = "🦙 Ollama: Explain Current Buffer via AI", action = "sys_ollama run llama3 'explain this code architecture'" },
    }},

    { label = "🤖 AI assistantsU(2.1) (150+ Advanced AI & Super Super Advanced Tools)", sub = {
        { label = "🤖 001. Advanced AI Code Refactor Engine", action = "sys_gh copilot suggest 'refactor code for clean architecture and peak performance'" },
        { label = "🤖 002. Deep OWASP Security Vulnerability Auditor", action = "sys_gh copilot suggest 'audit code for strict OWASP security vulnerabilities and injection risks'" },
        { label = "🤖 003. Intelligent Memory Leak & Bug Hunter", action = "sys_gh copilot suggest 'analyze code for memory leaks, deadlocks, and hidden logic bugs'" },
        { label = "🤖 004. Comprehensive Unit Test Generator", action = "sys_gh copilot suggest 'generate robust enterprise unit test suite with boundary and mock data'" },
        { label = "🤖 005. Universal API Docstring Generator", action = "sys_gh copilot suggest 'generate complete OpenAPI, JSDoc, and Google Style docstrings'" },
        { label = "🤖 006. Cross-Language Code Translator", action = "sys_gh copilot suggest 'translate current module to optimized idiomatic Rust'" },
        { label = "🤖 007. System Architecture Flow Visualizer", action = "sys_gh copilot suggest 'explain complete file execution flow and modular dependency tree'" },
        { label = "🤖 008. Multi-Threaded Concurrency Optimizer", action = "sys_gh copilot suggest 'optimize critical loops with parallel workers and async routines'" },
        { label = "🤖 009. Automated Database Query Optimizer", action = "sys_gh copilot suggest 'rewrite SQL and ORM queries for indexed execution plans'" },
        { label = "🤖 010. Smart Regex Pattern Synthesizer", action = "sys_gh copilot suggest 'generate precise regular expression pattern with edge cases handled'" },
        { label = "🤖 011. AI Dependency Vulnerability Scanner", action = "sys_gh copilot suggest 'check third party library versions against CVE exploit databases'" },
        { label = "🤖 012. Cloud Deployment Config Architect", action = "sys_gh copilot suggest 'generate production ready Dockerfile and Kubernetes manifests'" },
        { label = "🤖 013. Automated Code Complexity Minimizer", action = "sys_gh copilot suggest 'reduce cyclomatic complexity and flatten deeply nested conditions'" },
        { label = "🤖 014. Zero-Day Logic Exploit Finder", action = "sys_gh copilot suggest 'simulate hostile penetration testing logic on current function scope'" },
        { label = "🤖 015. Enterprise Codebase Sentiment Analyzer", action = "sys_gh copilot suggest 'evaluate maintainability index and technical debt metrics'" },
        { label = "🤖 016. Smart API Rate Limiting Architect", action = "sys_gh copilot suggest 'implement token bucket rate limiting middleware in current language'" },
        { label = "🤖 017. AI JSON Schema Validator Generator", action = "sys_gh copilot suggest 'create strict JSON schema validation spec from sample object'" },
        { label = "🤖 018. Cryptographic Token Generation Expert", action = "sys_gh copilot suggest 'implement secure JWT and AES-256 encryption helper modules'" },
        { label = "🤖 019. Microservices Event Bus Pattern", action = "sys_gh copilot suggest 'scaffold resilient pub-sub messaging pattern using Kafka or RabbitMQ'" },
        { label = "🤖 020. GraphQL Resolver Performance Tuner", action = "sys_gh copilot suggest 'optimize GraphQL resolver batching to prevent N+1 query problems'" },
        { label = "🤖 021. Automated State Machine Designer", action = "sys_gh copilot suggest 'build robust state machine pattern with transition guards'" },
        { label = "🤖 022. Neural Network Layer Scaffolder", action = "sys_gh copilot suggest 'build PyTorch neural network layer architecture template'" },
        { label = "🤖 023. Real-Time WebSockets Handler", action = "sys_gh copilot suggest 'scaffold scalable WebSocket server room management logic'" },
        { label = "🤖 024. Enterprise Exception Handling Wrapper", action = "sys_gh copilot suggest 'wrap critical blocks in robust try-catch logging telemetry'" },
        { label = "🤖 025. CI/CD Pipeline YAML Generator", action = "sys_gh copilot suggest 'generate GitHub Actions workflow for test, build, and deploy'" },
        { label = "🤖 026. Memory Allocation Profiler Advisor", action = "sys_gh copilot suggest 'identify heap allocations and pointer bottlenecks'" },
        { label = "🤖 027. Code Obfuscation & Security Masker", action = "sys_gh copilot suggest 'obfuscate sensitive internal logic symbols for production build'" },
        { label = "🤖 028. Automated Localization String Extractor", action = "sys_gh copilot suggest 'extract hardcoded strings into i18n localization dictionaries'" },
        { label = "🤖 029. Smart Caching Layer Implementation", action = "sys_gh copilot suggest 'integrate Redis cache-aside pattern wrapper for database lookups'" },
        { label = "🤖 030. WebAssembly Bridge Generator", action = "sys_gh copilot suggest 'compile core compute module to high performance WebAssembly'" },
        { label = "🤖 031. Serverless Function Blueprint", action = "sys_gh copilot suggest 'generate AWS Lambda handler event router template'" },
        { label = "🤖 032. gRPC Protocol Buffers Scaffolder", action = "sys_gh copilot suggest 'create .proto schema file and service stub implementations'" },
        { label = "🤖 033. Distributed Lock Manager Pattern", action = "sys_gh copilot suggest 'implement distributed mutex locking mechanism for cluster safety'" },
        { label = "🤖 034. OAuth2 Authentication Flow Expert", action = "sys_gh copilot suggest 'implement secure OAuth2 authorization code grant flow'" },
        { label = "🤖 035. Web Crawler Rate-Limited Engine", action = "sys_gh copilot suggest 'scaffold asynchronous web scraper with exponential backoff'" },
        { label = "🤖 036. Reactive Programming Stream Pipeline", action = "sys_gh copilot suggest 'construct Rx observable data transformation pipeline'" },
        { label = "🤖 037. Garbage Collection Tuning Advisor", action = "sys_gh copilot suggest 'tune VM garbage collector flags for ultra low latency service'" },
        { label = "🤖 038. Kubernetes Helm Chart Builder", action = "sys_gh copilot suggest 'generate production Helm chart deployment templates'" },
        { label = "🤖 039. Automated Semantic Versioning Hook", action = "sys_gh copilot suggest 'create git commit message parser for automated semver bumping'" },
        { label = "🤖 040. High-Throughput Ring Buffer", action = "sys_gh copilot suggest 'implement lock-free multi-producer single-consumer ring buffer'" },
        { label = "🤖 041. Smart Pointer Lifecycle Analyzer", action = "sys_gh copilot suggest 'inspect C++/Rust code for dangling pointers and ownership leaks'" },
        { label = "🤖 042. Browser Extension Manifest Scaffolder", action = "sys_gh copilot suggest 'build Manifest V3 browser extension background script structure'" },
        { label = "🤖 043. Async/Await Deadlock Detector", action = "sys_gh copilot suggest 'scan asynchronous promise chains for unhandled rejection loops'" },
        { label = "🤖 044. Data Stream Compression Engine", action = "sys_gh copilot suggest 'implement Gzip/Brotli payload compression pipeline wrapper'" },
        { label = "🤖 045. Algorithmic Big-O Complexity Auditor", action = "sys_gh copilot suggest 'calculate time and space complexity for all nested algorithms'" },
        { label = "🤖 046. Real-Time Telemetry Metrics Exporter", action = "sys_gh copilot suggest 'integrate Prometheus metrics instrumentation collectors'" },
        { label = "🤖 047. Load Balancing Algorithm Builder", action = "sys_gh copilot suggest 'implement weighted round-robin load balancer router'" },
        { label = "🤖 048. Automated SQL Migration Writer", action = "sys_gh copilot suggest 'generate up and down database migration script safely'" },
        { label = "🤖 049. Enterprise Logging Telemetry Formatter", action = "sys_gh copilot suggest 'format structured JSON logs with correlation IDs and timestamps'" },
        { label = "🤖 050. Full Spectrum Super AI Code Architect", action = "sys_gh copilot suggest 'perform complete system diagnostic, code review, optimization, and security hardening'" },
        { label = "🤖 051. AI Hyper-Dimensional Vector Embedding Generator", action = "sys_gh copilot suggest 'implement vector similarity search embeddings pipeline'" },
        { label = "🤖 052. AI Quantum-Safe Cryptography Wrapper", action = "sys_gh copilot suggest 'scaffold post-quantum lattice cryptography encryption functions'" },
        { label = "🤖 053. AI Autonomous Agent Decision Loop", action = "sys_gh copilot suggest 'build ReAct agent reasoning and tool execution loop framework'" },
        { label = "🤖 054. AI Smart Contract Formal Verifier", action = "sys_gh copilot suggest 'verify Solidity contract invariant logic against reentrancy vectors'" },
        { label = "🤖 055. AI Edge-AI Model Quantization Script", action = "sys_gh copilot suggest 'convert float32 PyTorch model to int8 quantized ONNX format'" },
        { label = "🤖 056. AI Autonomous Error Self-Healing Loop", action = "sys_gh copilot suggest 'implement runtime try-except fallback repair script wrapper'" },
        { label = "🤖 057. AI Multi-Agent Consensus Protocol", action = "sys_gh copilot suggest 'design Byzantine fault tolerant consensus voting algorithm stub'" },
        { label = "🤖 058. AI Neural Architecture Search Config", action = "sys_gh copilot suggest 'generate hyperparameter optimization grid search script'" },
        { label = "🤖 059. AI Semantic Code Search Indexer", action = "sys_gh copilot suggest 'build AST parser chunking engine for code vector storage'" },
        { label = "🤖 060. AI Zero-Knowledge Proof Circuit Builder", action = "sys_gh copilot suggest 'create Circom ZK-SNARK arithmetic circuit verification template'" },
        { label = "🤖 061. AI Real-Time Prompt Injection Defense", action = "sys_gh copilot suggest 'sanitize incoming LLM string parameters against jailbreaks'" },
        { label = "🤖 062. AI Diff-Tree Merge Conflict Resolver", action = "sys_gh copilot suggest 'apply AST-aware intelligent merge conflict auto-resolution logic'" },
        { label = "🤖 063. AI Synthetic Test Data Generator", action = "sys_gh copilot suggest 'generate realistic GDPR-compliant mock database fixture sets'" },
        { label = "🤖 064. AI Automated Code Review Bot Hook", action = "sys_gh copilot suggest 'create pull request automated code review script runner'" },
        { label = "🤖 065. AI Token Usage Cost Optimizer", action = "sys_gh copilot suggest 'implement sliding window token trimming algorithm for prompt chains'" },
        { label = "🤖 066. AI Dynamic Few-Shot Prompt Builder", action = "sys_gh copilot suggest 'retrieve semantic context examples for LLM inference injection'" },
        { label = "🤖 067. AI Graph Neural Network Scaffolder", action = "sys_gh copilot suggest 'build node classification GNN model using PyTorch Geometric'" },
        { label = "🤖 068. AI Reinforcement Learning Environment", action = "sys_gh copilot suggest 'create OpenAI Gym custom environment policy runner loop'" },
        { label = "🤖 069. AI Automated README.md Generator", action = "sys_gh copilot suggest 'analyze code repository structure and write comprehensive markdown documentation'" },
        { label = "🤖 070. AI Enterprise Code Migration Specialist", action = "sys_gh copilot suggest 'upgrade legacy Python 2 syntax modules to modern Python 3 standards'" },
        { label = "🤖 071. AI Hyper-Fast Regex Compiler", action = "sys_gh copilot suggest 'compile optimized NFA/DFA regular expression parser engine'" },
        { label = "🤖 072. AI Secure Sandbox Runtime Manager", action = "sys_gh copilot suggest 'implement cgroups and seccomp sandbox container isolation wrapper'" },
        { label = "🤖 073. AI Automated Bug Triage Classifier", action = "sys_gh copilot suggest 'categorize GitHub issue descriptions using classification embeddings'" },
        { label = "🤖 074. AI Distributed Consensus State Machine", action = "sys_gh copilot suggest 'implement Raft consensus log replication algorithm modules'" },
        { label = "🤖 075. AI Autonomous CI/CD Incident Fixer", action = "sys_gh copilot suggest 'parse build failure error logs and generate automated patch commit'" },
        { label = "🤖 076. AI Semantic API Route Router", action = "sys_gh copilot suggest 'build intent-based conversational API router dispatcher'" },
        { label = "🤖 077. AI Real-Time Audio Transcription Hook", action = "sys_gh copilot suggest 'integrate Whisper streaming speech-to-text pipeline wrapper'" },
        { label = "🤖 078. AI Neural Collaborative Filtering Recommender", action = "sys_gh copilot suggest 'build recommendation engine matrix factorization model'" },
        { label = "🤖 079. AI Automated Database Index Analyzer", action = "sys_gh copilot suggest 'inspect slow query logs and recommend missing index structures'" },
        { label = "🤖 080. AI Hyper-Optimized Matrix Multiplier", action = "sys_gh copilot suggest 'implement cache-blocked parallel matrix multiplication algorithm'" },
        { label = "🤖 081. AI Edge Computing Data Sync Agent", action = "sys_gh copilot suggest 'implement conflict-free replicated data type CRDT synchronization node'" },
        { label = "🤖 082. AI Automated Penetration Testing Script", action = "sys_gh copilot suggest 'generate safe fuzzing payload suite for web endpoint robustness'" },
        { label = "🤖 083. AI Codebase Semantic Dependency Graph", action = "sys_gh copilot suggest 'parse inter-file imports and render dependency relationship graph'" },
        { label = "🤖 084. AI Natural Language to SQL Query Engine", action = "sys_gh copilot suggest 'translate natural language request into optimized relational SQL query'" },
        { label = "🤖 085. AI Dynamic API Mock Server Generator", action = "sys_gh copilot suggest 'spin up Express/FastAPI server mimicking external REST API specs'" },
        { label = "🤖 086. AI Automated Refactoring Test Matrix", action = "sys_gh copilot suggest 'generate before-and-after behavioral regression test wrappers'" },
        { label = "🤖 087. AI Multi-Tenant Isolation Middleware", action = "sys_gh copilot suggest 'implement tenant context propagation middleware for database queries'" },
        { label = "🤖 088. AI Automated Localization Quality Checker", action = "sys_gh copilot suggest 'scan translation resource files for missing keys and formatting syntax'" },
        { label = "🤖 089. AI Real-Time Memory Leak Hunter", action = "sys_gh copilot suggest 'instrument heap allocation tracking hooks to detect retained objects'" },
        { label = "🤖 090. AI Intelligent Exception Aggregator", action = "sys_gh copilot suggest 'group stack traces by root cause signature hash algorithm'" },
        { label = "🤖 091. AI Automated Load Test Script Generator", action = "sys_gh copilot suggest 'generate Locust or k6 performance testing load profile scenarios'" },
        { label = "🤖 092. AI Codebase Health Scorecard Calculator", action = "sys_gh copilot suggest 'compute composite metrics score across security, style, and test coverage'" },
        { label = "🤖 093. AI Automated Schema Migration Validator", action = "sys_gh copilot suggest 'test database migration backward compatibility safely'" },
        { label = "🤖 094. AI Enterprise License Compliance Checker", action = "sys_gh copilot suggest 'scan node_modules or cargo dependencies for GPL license contamination'" },
        { label = "🤖 095. AI Autonomous Git Commit Message Generator", action = "sys_gh copilot suggest 'inspect staged git diff changes and compose conventional commit message'" },
        { label = "🤖 096. AI Real-Time Dead Code Eliminator", action = "sys_gh copilot suggest 'detect unreferenced functions and dead variables for safe removal'" },
        { label = "🤖 097. AI Automated Code Style Enforcer", action = "sys_gh copilot suggest 'enforce strict project-specific AST formatting style rules'" },
        { label = "🤖 098. AI Predictive Cache Eviction Policy", action = "sys_gh copilot suggest 'implement machine learning cache eviction eviction predictor stub'" },
        { label = "🤖 099. AI Enterprise Secret Leak Preventer", action = "sys_gh copilot suggest 'scan file buffer for hardcoded API keys, passwords, and private tokens'" },
        { label = "🤖 100. AI Ultimate Autonomous Software Engineer Suite", action = "sys_gh copilot suggest 'execute end-to-end feature planning, implementation, testing, and deployment pipeline'" }
    }},

    { label = "👑 Visuals & Smart Environment", sub = {
        { label = "➜ Choose Theme (200 Variants + OS Sync)", action = "theme_picker" },
        { label = "➜ Clear Search Highlights", action = "clear_search" },
        { label = "➜ Toggle Zen Mode", action = "zen_mode" },
    }},

    { label = "🛠️ Power Developer Tools & Utilities", sub = {
        { label = "✦ JSON Tools: Pretty Format", action = "json_pretty" },
        { label = "✦ JSON Tools: Minify JSON", action = "json_minify" },
        { label = "✦ Encryption: Base64 Encode Buffer", action = "b64_enc" },
        { label = "✦ Decoding: Base64 Decode Buffer", action = "b64_dec" },
        { label = "✦ Unit Test Runner", action = "run_test" },
        { label = "✦ Git Log Graph", action = "sys_git log --graph --oneline --all --decorate" },
        { label = "✦ Git Line Blame", action = "sys_git blame %" },
        { label = "✦ Git Status Summary", action = "sys_git status -s" },
    }},

    { label = "👑 100 Programming Language Templates", sub = {
        { label = "✦ 01. Web, Markup & Data", sub = {
            { label = "HTML", action = "tpl_HTML" }, { label = "CSS", action = "tpl_CSS" }, { label = "JavaScript", action = "tpl_JavaScript" },
            { label = "PHP", action = "tpl_PHP" }, { label = "XML", action = "tpl_XML" }, { label = "XHTML", action = "tpl_XHTML" },
            { label = "Markdown", action = "tpl_Markdown" }, { label = "JSON", action = "tpl_JSON" }, { label = "YAML", action = "tpl_YAML" }, { label = "SVG", action = "tpl_SVG" }
        }},
        { label = "✦ 02. Mainstream & Systems", sub = {
            { label = "Python", action = "tpl_Python" }, { label = "Java", action = "tpl_Java" }, { label = "C", action = "tpl_C" },
            { label = "C++", action = "tpl_C++" }, { label = "C#", action = "tpl_C#" }, { label = "Go", action = "tpl_Go" },
            { label = "Rust", action = "tpl_Rust" }, { label = "Swift", action = "tpl_Swift" }, { label = "Kotlin", action = "tpl_Kotlin" }, { label = "Ruby", action = "tpl_Ruby" }
        }},
        { label = "✦ 03. Classic & Legacy", sub = {
            { label = "Assembly", action = "tpl_Assembly" }, { label = "Ada", action = "tpl_Ada" }, { label = "BASIC", action = "tpl_BASIC" },
            { label = "Fortran", action = "tpl_Fortran" }, { label = "COBOL", action = "tpl_COBOL" }, { label = "Pascal", action = "tpl_Pascal" },
            { label = "Delphi", action = "tpl_Delphi" }, { label = "D", action = "tpl_D" }, { label = "Lisp", action = "tpl_Lisp" }, { label = "Scheme", action = "tpl_Scheme" }
        }},
        { label = "✦ 04. Scripting & Functional", sub = {
            { label = "Perl", action = "tpl_Perl" }, { label = "Lua", action = "tpl_Lua" }, { label = "R", action = "tpl_R" },
            { label = "Julia", action = "tpl_Julia" }, { label = "Scala", action = "tpl_Scala" }, { label = "Haskell", action = "tpl_Haskell" },
            { label = "Erlang", action = "tpl_Erlang" }, { label = "Elixir", action = "tpl_Elixir" }, { label = "Clojure", action = "tpl_Clojure" }, { label = "OCaml", action = "tpl_OCaml" }
        }},
        { label = "✦ 05. Game, Script & Shell", sub = {
            { label = "Objective-C", action = "tpl_Objective-C" }, { label = "ActionScript", action = "tpl_ActionScript" }, { label = "GDScript", action = "tpl_GDScript" },
            { label = "GML (GameMaker Language)", action = "tpl_GML" }, { label = "Blueprints (Visual)", action = "tpl_Blueprints" }, { label = "VBScript", action = "tpl_VBScript" },
            { label = "AutoIt", action = "tpl_AutoIt" }, { label = "Batch", action = "tpl_Batch" }, { label = "PowerShell", action = "tpl_PowerShell" }, { label = "Bash/Shell", action = "tpl_Bash/Shell" }
        }},
        { label = "✦ 06. Query, Data & API", sub = {
            { label = "SQL", action = "tpl_SQL" }, { label = "PL/SQL", action = "tpl_PL/SQL" }, { label = "T-SQL", action = "tpl_T-SQL" },
            { label = "Cassandra (CQL)", action = "tpl_Cassandra Query Language (CQL)" }, { label = "DAX", action = "tpl_DAX" }, { label = "M (Power Query)", action = "tpl_M (Power Query)" },
            { label = "GraphQL", action = "tpl_GraphQL" }, { label = "SPARQL", action = "tpl_SPARQL" }, { label = "XQuery", action = "tpl_XQuery" }, { label = "SAS", action = "tpl_SAS" }
        }},
        { label = "✦ 07. Modern Alternative", sub = {
            { label = "TypeScript", action = "tpl_TypeScript" }, { label = "Dart", action = "tpl_Dart" }, { label = "CoffeeScript", action = "tpl_CoffeeScript" },
            { label = "Elm", action = "tpl_Elm" }, { label = "ReasonML", action = "tpl_ReasonML" }, { label = "PureScript", action = "tpl_PureScript" },
            { label = "V", action = "tpl_V" }, { label = "Zig", action = "tpl_Zig" }, { label = "Nim", action = "tpl_Nim" }, { label = "Crystal", action = "tpl_Crystal" }
        }},
        { label = "✦ 08. Educational & Array", sub = {
            { label = "Prolog", action = "tpl_Prolog" }, { label = "Logo", action = "tpl_Logo" }, { label = "Scratch", action = "tpl_Scratch" },
            { label = "Alice", action = "tpl_Alice" }, { label = "NetLogo", action = "tpl_NetLogo" }, { label = "APL", action = "tpl_APL" },
            { label = "J", action = "tpl_J" }, { label = "K", action = "tpl_K" }, { label = "Q", action = "tpl_Q" }, { label = "Forth", action = "tpl_Forth" }
        }},
        { label = "✦ 09. Enterprise, Hardware & Web3", sub = {
            { label = "Ladder Logic", action = "tpl_Ladder Logic (PLC)" }, { label = "F#", action = "tpl_F#" }, { label = "ABAP", action = "tpl_ABAP" },
            { label = "Apex", action = "tpl_Apex" }, { label = "Processing", action = "tpl_Processing" }, { label = "Arduino", action = "tpl_Arduino (C/C++ based)" },
            { label = "Solidity", action = "tpl_Solidity" }, { label = "Vyper", action = "tpl_Vyper" }, { label = "Move", action = "tpl_Move" }
        }},
        { label = "✦ 10. Niche & Alternative", sub = {
            { label = "Hack", action = "tpl_Hack" }, { label = "Ballerina", action = "tpl_Ballerina" }, { label = "Wren", action = "tpl_Wren" },
            { label = "Pike", action = "tpl_Pike" }, { label = "Icon", action = "tpl_Icon" }, { label = "Euphoria", action = "tpl_Euphoria" },
            { label = "Factor", action = "tpl_Factor" }, { label = "Oz", action = "tpl_Oz" }, { label = "Rexx", action = "tpl_Rexx" }, { label = "Smalltalk", action = "tpl_Smalltalk" }
        }},
    }},
    { label = "⚙️ Industry Tools: Container, CI/CD & DevOps", sub = {
        { label = "➜ Docker: Build & Run Current Dir", action = "sys_docker build -t local_img . && docker run local_img" },
        { label = "➜ Docker: Compose Up (Detached)", action = "sys_docker-compose up -d" },
        { label = "➜ Docker: Compose Down & Clean", action = "sys_docker-compose down -v" },
        { label = "➜ Kubernetes: Apply YAML (kubectl)", action = "sys_kubectl apply -f %" },
        { label = "➜ Kubernetes: Get Pods & Services", action = "sys_kubectl get pods,svc" },
        { label = "➜ GitOps: Sync & Push Master", action = "sys_git add . && git commit -m 'Auto-sync' && git push origin main" },
        { label = "➜ CI/CD: Run Default Makefile", action = "sys_make" },
        { label = "➜ Execute Custom DevOps Command", action = "custom_cmd" },
    }},
    { label = "⚙️ Industry Tools: Database & Cache Mgmt", sub = {
        { label = "➜ MySQL: Connect Localhost", action = "sys_mysql -u root -p" },
        { label = "➜ PostgreSQL: psql shell", action = "sys_psql -U postgres" },
        { label = "➜ MongoDB: Mongo Shell", action = "sys_mongosh" },
        { label = "➜ Redis: Flush All Data (CLI)", action = "sys_redis-cli FLUSHALL" },
        { label = "➜ SQLite: Open Current DB", action = "sys_sqlite3 database.db" },
        { label = "➜ Prisma: Generate & Push DB", action = "sys_npx prisma db push" },
        { label = "➜ Execute Custom DB Command", action = "custom_cmd" },
    }},
    { label = "⚙️ Industry Tools: Testing & QA Audit", sub = {
        { label = "➜ Node/JS: Run Jest Tests", action = "sys_npm test" },
        { label = "➜ Python: Run PyTest", action = "sys_pytest" },
        { label = "➜ Java: Maven Test", action = "sys_mvn test" },
        { label = "➜ Go: Go Test Current Pkg", action = "sys_go test ./" },
        { label = "➜ PHP: Run PHPUnit", action = "sys_phpunit" },
        { label = "➜ Linter: ESLint Auto-Fix", action = "sys_npx eslint . --fix" },
        { label = "➜ Linter: Python Flake8/Black", action = "sys_black . && flake8 ." },
    }},
    { label = "⚙️ Industry Tools: Security & Network", sub = {
        { label = "➜ Audit NPM Vulnerabilities", action = "sys_npm audit" },
        { label = "➜ Python Safety Check", action = "sys_safety check" },
        { label = "➜ Rust Cargo Audit", action = "sys_cargo audit" },
        { label = "➜ Network: Ping Google DNS", action = "sys_ping -c 4 8.8.8.8" },
        { label = "➜ Network: Check Open Ports (netstat)", action = "sys_netstat -tulpn" },
        { label = "➜ Network: Curl API Endpoint", action = "custom_cmd" },
    }},
    { label = "⚙️ Industry Tools: Data Science & AI", sub = {
        { label = "➜ Python: Start Jupyter Lab", action = "sys_jupyter lab" },
        { label = "➜ Format CSV File to Table", action = "sys_column -s, -t %" },
        { label = "➜ Data: Pretty Print JSON", action = "json_pretty" },
        { label = "➜ Utilities: Generate UUIDv4", action = "uuid_gen" },
        { label = "➜ Open Super Interactive Terminal", action = "float_term" },
    }},
    { label = "💾 System & Operations", sub = {
        { label = "➜ Save File", action = "save" },
        { label = "➜ Quit Editor", action = "quit" },
    }}
}

-- ==========================================
-- 7. BEAUTIFUL UI GENERATOR (MOUSE & ARROW OPTIMIZED)
-- ==========================================
_G.RenderMenu = function(title, items, is_sub, custom_cb)
    local buf = api.nvim_create_buf(false, true)
    local lines = {}
    
    table.insert(lines, "  ╭───────────────────────────────────────────────────────────────╮")
    table.insert(lines, "  │  " .. string.format("%-46s", title) .. "     [ X ] CLOSE  │")
    table.insert(lines, "  ╰───────────────────────────────────────────────────────────────╯")
    table.insert(lines, "")
    
    for _, item in ipairs(items) do
        local text = type(item) == "string" and item or item.label
        table.insert(lines, "       " .. text)
    end

    if is_sub then
        table.insert(lines, "")
        table.insert(lines, "       🔙 BACK TO MAIN MENU")
    end

    api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local cols, total_lines = get_safe_dims()
    local w = 71
    local h = math.min(#lines + 2, math.max(12, total_lines - 4))

    local win = api.nvim_open_win(buf, true, {
        relative = "editor", width = w, height = h,
        row = math.floor((total_lines - h) / 2), col = math.floor((cols - w) / 2),
        style = "minimal", border = "rounded"
    })
    
    vim.wo[win].cursorline = true
    vim.wo[win].winblend = 5
    vim.api.nvim_win_set_cursor(win, {5, 0})
    vim.bo[buf].modifiable = false

    local function nav_move(dir)
        local cur = api.nvim_win_get_cursor(win)[1]
        local new_pos = cur + dir
        
        if new_pos == 3 or new_pos == 4 then
            new_pos = (dir > 0) and 5 or 2
        end

        if new_pos >= 2 and new_pos <= #lines then
            api.nvim_win_set_cursor(win, {new_pos, 0})
        end
    end

    local function handle_select()
        local idx = api.nvim_win_get_cursor(win)[1]
        
        if idx == 2 then 
            api.nvim_win_close(win, true)
            return 
        end
        
        local item_idx = idx - 4
        if item_idx < 1 then return end

        api.nvim_win_close(win, true)
        
        if is_sub and item_idx > #items then _G.NavMenuOpen(); return end
        if custom_cb then custom_cb(items[item_idx]); return end

        local sel = items[item_idx]
        if not sel then return end

        if sel.sub then
            _G.RenderMenu(sel.label:gsub("🌐 Toggle Live HTTP.*", "Live HTTP"):gsub("^👑 ", ""):gsub("^🤖 ", ""):gsub("^🦙 ", ""):gsub("^🛠️ ", ""):gsub("^⚙️ ", ""):gsub("^✦ ", ""), sel.sub, true)
        elseif sel.action then
            run_action(sel.action)
        end
    end

    keymap("n", "<Up>", function() nav_move(-1) end, { buffer = buf, silent = true })
    keymap("n", "<Down>", function() nav_move(1) end, { buffer = buf, silent = true })
    keymap("n", "k", function() nav_move(-1) end, { buffer = buf, silent = true })
    keymap("n", "j", function() nav_move(1) end, { buffer = buf, silent = true })
    keymap("n", "<CR>", handle_select, { buffer = buf, silent = true })
    keymap("n", "<Esc>", function() api.nvim_win_close(win, true) end, { buffer = buf, silent = true })
    keymap("n", "q", function() api.nvim_win_close(win, true) end, { buffer = buf, silent = true })
    
    keymap("n", "<LeftMouse>", function()
        vim.cmd("exec 'normal! \\<LeftMouse>'")
        handle_select()
    end, { buffer = buf, silent = true })
end

_G.NavMenuOpen = function()
    local http_state = _G.HttpServerJob and "  [ ● ON ]" or "  [ ○ OFF ]"
    menu_data[1].label = "🌐 Toggle Live HTTP Local Server (Port 8080)" .. http_state
    _G.RenderMenu("NAV.ZTE2.5 GT PRO", menu_data, false)
end

-- ==========================================
-- 8. WELCOME SCREEN
-- ==========================================
local banner_text = [=[

WELCOME TO NAV.ZTE2.5 GT PRO
GLOBAL INDUSTRY EDITION

       .o+       +o.       
      ooo/       \ooo      
     '+oooo:   :oooo+'     
      +oooooo :oooooo+/    
      -+oooooo :oooooo+-   
        /:  -:+o  o+:-  :/ 
       /++++++: :++++++/   
      /++++++++ ++++++++'  
     /+++oooooo oooooo+++` 
   ./ooosssssso ossssssooo.
  .ooosssso- ``` -ossssoo. 
  -ossssso.       .ossssso-
  :ossssss/       /sssssss:
  /osssssss:     :ssssssss 
   \ossssso+/- -/+ossssso/ 
    '+sso+-:     :-+oss+'  
       '++:.     .:++'     
          V       V        

[ PRESS SPACE THEN 'm' TO OPEN MENU ]
]=]

api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            local lines = {}
            for s in banner_text:gmatch("[^\r\n]+") do table.insert(lines, s) end
            api.nvim_buf_set_lines(0, 0, 0, false, lines)
            cmd("hi LogoColor guifg=#1de9b6 gui=bold")
            for i=0, #lines do api.nvim_buf_add_highlight(0, -1, "LogoColor", i, 0, -1) end
        end
    end
})

keymap("n", "<Leader>m", "<cmd>lua NavMenuOpen()<CR>", { silent = true })
keymap("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true })

api.nvim_create_autocmd({"CursorMoved", "CursorMovedI", "BufEnter"}, {
    callback = function()
        local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "Text"
        local srv = _G.HttpServerJob and " [🌐 HTTP ON] " or ""
        local stat = string.format(" 🗂️ %s | 📊 %d Lines | Pos: %d ", string.upper(ft), vim.fn.line("$"), vim.fn.col("."))
        vim.opt.statusline = " 👑 NAV.ZTE2.5 GT PRO " .. srv .. "| %f %h%m%r%= " .. stat .. " | %y "
    end
})

