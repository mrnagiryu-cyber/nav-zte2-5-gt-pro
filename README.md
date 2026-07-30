# 👑 NAV.ZTE2.5 GT PRO – Global Industry Edition

> *"Built with passion, not hardware. A full-stack IDE running on a 4GB RAM smartphone."*

---

## 📖 Table of Contents
1. [Introduction & Philosophy](#-introduction--philosophy)
2. [Key Features Overview](#-key-features-overview)
3. [The Core Engine: How It Works](#-the-core-engine-how-it-works)
4. [The AI & Ollama Ecosystem](#-the-ai--ollama-ecosystem)
5. [Industry Tools & DevOps Integration](#-industry-tools--devops-integration)
6. [File Structure & Architecture](#-file-structure--architecture)
7. [Installation Guide (Step-by-Step)](#-installation-guide-step-by-step)
8. [How to Use the Main Menu (UI/UX)](#-how-to-use-the-main-menu-uiux)
9. [Available AI & Advanced Commands](#-available-ai--advanced-commands)
10. [Troubleshooting & Debugging Guide](#-troubleshooting--debugging-guide)
11. [How to Contribute & Customize](#-how-to-contribute--customize)
12. [Author, License & Acknowledgements](#-author-license--acknowledgements)

---

## 1. 📖 Introduction & Philosophy

**NAV.ZTE2.5 GT PRO** is not just a Neovim configuration.  
It is a **philosophy** — a belief that you don't need a high-end laptop to build world-class software.

Created by **Nagiryu**, a 15-year-old developer from Indonesia, this project was built entirely on a **4GB RAM smartphone** using **Termux** and **Arch Linux ARM**.

It transforms Neovim into a **full-stack Integrated Development Environment (IDE)** that rivals commercial editors like VS Code, IntelliJ IDEA, and Sublime Text — all while remaining lightweight, open-source, and completely free.

**Key Philosophy:**
- **Performance over bloat.** Every line of code is optimized for mobile hardware.
- **Local-first AI.** No internet, no cloud, no vendor lock-in.
- **Industrial-grade tools.** From Docker to Kubernetes, from SQL to AI.

---

## 2. ✨ Key Features Overview

| **Category** | **Features** |
| :--- | :--- |
| **🎨 Theme Engine** | 200+ built-in themes with real-time OSC 11 terminal background sync. |
| **🦙 AI Ollama Engine** | Local LLM integration. Pull, serve, and chat with Llama3, CodeLlama, Mistral. |
| **🤖 AI Assistants** | 100+ commands via `gh copilot` (Refactor, Security, Tests, Docs, Translate). |
| **🌐 Live Server** | Toggle HTTP server on port 8080 with live status indicator. |
| **⚡ Code Runner** | Auto-detect & run Python, JS, TS, Go, Rust, C, C++, PHP, Ruby, Java. |
| **🔐 Security Tools** | Base64 Encode/Decode, UUID v4, JSON Pretty/Minify. |
| **🐙 Git Integration** | Log Graph, Blame, Status, Push, Pull, Stash. |
| **🛠️ DevOps Suite** | Docker (Build, Compose), Kubernetes (Apply, Get Pods), Prisma. |
| **🗄️ Database Tools** | MySQL, PostgreSQL, MongoDB, Redis, SQLite shells. |
| **🧪 Testing Suite** | Jest, PyTest, Maven, Go Test, PHPUnit, ESLint, Black/Flake8. |
| **📚 Language Templates** | 100+ boilerplates across 10 categories (Web, Systems, Game, etc.). |
| **👑 UI/UX** | Zen Mode, Quick Theme Switch, Floating Terminal, Mouse Support. |

---

## 3. 🧠 The Core Engine: How It Works

### 3.1. The Floating Menu System (`_G.RenderMenu`)
The main interface is built using **pure Lua** and Neovim's native floating window API.

**Key logic:**
- Generates a dynamic UI based on the `menu_data` table.
- Supports both **keyboard** (`j`, `k`, `Enter`) and **mouse** interactions.
- Auto-adjusts window size based on terminal dimensions (`get_safe_dims()`).
- Features a **"Close [ X ]"** button at the top for easy exit.

**Example snippet:**
```lua
api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w, height = h,
    style = "minimal", border = "rounded"
})
```

3.2. The Theme Engine & OSC 11 Integration

The theme system stores 200+ color schemes in a Lua table. When a theme is selected:

1. api.nvim_set_hl updates Neovim's highlight groups.
2. OSC 11 sends an escape sequence to change the terminal background color.

How OSC 11 works:

```lua
io.write(string.format("\27]11;%s\7", t.bg))
```

3.3. The Action Engine (run_action)

Every menu option is routed through a central function:

· toggle_http → Starts/stops the live server.
· auto_run → Detects file type and runs the appropriate command.
· quick_theme → Cycles through themes instantly.

---

4. 🦙 The AI & Ollama Ecosystem

NAV.ZTE2.5 GT PRO is built for the future of local AI.

4.1. What is Ollama?

Ollama is an open-source framework for running Large Language Models (LLMs) locally on your own device.
It is completely free, private, and works offline — no internet required.

4.2. Integrated Ollama Commands

Command Description
Ollama: Start Local Server Starts the Ollama service on your device.
Ollama: Pull Llama3 Model Downloads the Llama3 model (offline-ready).
Ollama: Pull CodeLlama Downloads the CodeLlama model (for coding).
Ollama: Pull Mistral Downloads the Mistral model (general chat).
Ollama: Run Chat CLI Starts an interactive chat session.
Ollama: Generate Code Snippet Asks AI to write code for a specific task.
Ollama: Explain Buffer Asks AI to explain the currently opened file.

4.3. 100+ AI Assistant Commands

The editor includes 100+ commands that use gh copilot suggest or ollama to perform tasks like:

· Refactoring – Clean up code architecture.
· Security Auditing – Detect OWASP vulnerabilities.
· Bug Hunting – Find memory leaks and deadlocks.
· Unit Test Generation – Create comprehensive test suites.
· API Documentation – Generate OpenAPI, JSDoc, Google-style docs.
· Cross-Language Translation – Convert code to Rust, Go, Python.

---

5. ⚙️ Industry Tools & DevOps Integration

5.1. Containerization & Cloud

· Docker: Build, Compose Up, Compose Down, Clean.
· Kubernetes: Apply YAML, Get Pods & Services.
· GitOps: Auto-sync and push to production.

5.2. Database Management

· MySQL: mysql -u root -p
· PostgreSQL: psql -U postgres
· MongoDB: mongosh
· Redis: FLUSHALL
· SQLite: sqlite3 database.db
· Prisma: npx prisma db push

5.3. Testing & QA

· Node/JS: npm test
· Python: pytest
· Java: mvn test
· Go: go test ./...
· PHP: phpunit
· Linting: ESLint, Black/Flake8

5.4. Security & Networking

· Audit: npm audit, safety check, cargo audit.
· Network: ping, netstat, curl.

---

6. 📁 File Structure & Architecture

```
~/.config/nvim/
├── init.lua          # Main configuration file
└── README.md         # Documentation (this file)
```

Note: All features are written in pure Lua and Vimscript.
No external plugins are required — everything is built-in.

---

7. 📦 Installation Guide (Step-by-Step)

Prerequisites

· Neovim 0.9.0 or higher.
· Git (for cloning).
· Termux (for Android) or any Linux-based terminal.
· Optional: python3, node, docker, kubectl, jq, ollama.

Steps

```bash
# 1. Remove old configuration (if any)
rm -rf ~/.config/nvim

# 2. Clone the repository
git clone https://github.com/mrnagiryu-cyber/nav-zte2-5-gt-pro.git ~/.config/nvim

# 3. Open Neovim
nvim
```

---

8. 🎮 How to Use the Main Menu (UI/UX)

1. Open Neovim: nvim
2. Press Space + m to open the menu.
3. Use Arrow keys or j / k to navigate.
4. Press Enter to select an option.
5. Press Esc or q to close.
6. Click [ X ] with your mouse to close the menu.

---

9. 🤖 Available AI & Advanced Commands

The editor includes over 100 AI-powered commands. Here are the key ones:

ID Command Name Description
001 Advanced AI Code Refactor Engine Optimize and restructure your code.
002 Deep OWASP Security Auditor Scan for security vulnerabilities.
003 Memory Leak & Bug Hunter Detect hidden memory issues.
004 Unit Test Generator Create robust test suites.
005 API Docstring Generator Generate OpenAPI, JSDoc, Google-style docs.
006 Cross-Language Translator Translate code to Rust, Go, Python, etc.
007 System Architecture Visualizer Explain file flow and dependencies.
008 Concurrency Optimizer Optimize parallel and async tasks.
009 SQL & ORM Query Optimizer Rewrite queries for better performance.
010 Regex Pattern Synthesizer Generate precise regular expressions.
... ... ...
100 Ultimate Autonomous Engineer Full-spectrum planning, coding, and deployment.

---

10. 🛠️ Troubleshooting & Debugging Guide

Common Issues & Fixes

1. "Git clone fails"

· Ensure Git is installed: pacman -S git or pkg install git.
· Check internet connectivity.

2. "Ollama not found"

· Install Ollama in Termux: pkg install ollama.
· Or download from the official Ollama website.

3. "Theme doesn't change background"

· Ensure your terminal supports OSC 11 (most modern terminals do).
· Try switching between themes to verify.

4. "Live Server won't start"

· Ensure python3 is installed.
· Check if port 8080 is already in use.

5. "Menu doesn't open"

· Press Space + m correctly.
· Re-run nvim to reload the config.

---

11. 🧑‍💻 How to Contribute & Customize

This project is open-source and welcomes contributions.

Ways to contribute:

1. Fork the repository and submit a Pull Request.
2. Add new themes by extending the themes table.
3. Add new AI commands by extending the menu_data table.
4. Improve documentation by updating README.md.
5. Test and report bugs via GitHub Issues.

Customization tips:

· Modify menu_data to reorder or remove menu items.
· Update the themes table to add your own color schemes.
· Add new actions to run_action() for custom functionality.

---

12. 👑 Author, License & Acknowledgements

Author

MR. Nagiryu

· GitHub: mrnagiryu-cyber
· Built on Arch Linux ARM + Termux with a 4GB RAM smartphone.

License

This project is Open Source and distributed under the MIT License.
You are free to use, modify, and distribute this software.

Acknowledgements

· Neovim – The core editor.
· Ollama – Local AI engine.
· Termux – Terminal emulator for Android.
· Arch Linux ARM – The operating system.
