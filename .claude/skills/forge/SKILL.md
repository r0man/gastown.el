---
name: forge
description: Expert guide for working with and extending the forge Emacs package (magit/forge). Use when implementing forge database operations, topic/issue/PR types, notification handling, or any forge extension integrating with GitHub/GitLab/Gitea.
---

# Forge Developer Reference

Forge is a Magit extension for working with Git forges (GitHub, GitLab, Gitea,
Gogs, Bitbucket, Forgejo) from Emacs. It stores forge metadata in a local
SQLite database and integrates with magit's status buffer.

## When to Use This Skill

Invoke when:
- Querying or extending forge's SQLite database
- Working with `forge-topic`, `forge-issue`, `forge-pullreq` objects
- Building extensions that read/display forge data
- Integrating forge sections into magit buffers
- Working with forge's notification system
- Implementing forge-aware commands

## Core Architecture

Three-layer stack:
- **Forge** — UI, commands, API integration
- **Closql** — EIEIO object ↔ SQLite table mapping
- **Emacsql** — High-level SQLite front-end

Forge metadata lives in `.git/magit/forge.sqlite` (per repository).
All forge objects are EIEIO instances stored via closql.

Key source files:
```
forge.el           — Entry point, configuration
forge-core.el      — Core classes, utilities
forge-db.el        — Database layer
forge-repo.el      — Repository support
forge-topic.el     — Topic (issue/PR) support
forge-post.el      — Comment support
forge-commands.el  — Command implementations
forge-list.el      — Tabulated list interface
forge-github.el    — GitHub-specific implementation
forge-gitlab.el    — GitLab-specific implementation
forge-notify.el    — Notification handling
```

## Class Hierarchy

```
closql-object
└── forge-object
    ├── forge-repository (abstract)
    │   ├── forge-github-repository
    │   ├── forge-gitlab-repository
    │   ├── forge-bitbucket-repository
    │   ├── forge-gitea-repository
    │   ├── forge-gogs-repository
    │   └── forge-forgejo-repository
    ├── forge-topic (abstract)
    │   ├── forge-issue
    │   ├── forge-pullreq
    │   └── forge-discussion
    └── forge-post
```

## Database Layer

### Accessing the Database

```elisp
;; Get the forge database object
(forge-db)

;; Get the repository object for current directory
(forge-get-repository :tracked?)   ; nil if not tracked
(forge-get-repository :stub)       ; Create stub if needed
(forge-get-repository 'full)       ; Full object

;; Get repository by remote URL
(forge-get-repository "https://github.com/owner/repo")

;; Get a topic by ID or number
(forge-get-topic repo number)
(forge-get-topic id)               ; By database ID

;; Get all issues for a repository
(forge-ls-issues repo)
(forge-ls-issues repo :state 'open)
(forge-ls-issues repo :state 'closed)

;; Get all pull requests
(forge-ls-pullreqs repo)
(forge-ls-pullreqs repo :state 'open)
```

### Direct Database Queries (emacsql)

```elisp
;; Low-level SQL queries via emacsql
(emacsql (forge-db)
         [:select [number title state]
          :from pullreq
          :where (= repository $s1)
          :order-by [(desc number)]]
         (oref repo id))

;; S-expression SQL syntax:
;; :select — columns (symbols) or [col1 col2]
;; :from — table name
;; :where — predicate with $s1, $s2... for parameters
;; :order-by, :limit, :join — standard clauses
```

### Database Schema Overview

**forge_repository table columns:**
- `id` — Database ID
- `forge-id` — Remote forge ID
- `forge`, `owner`, `name` — Identity
- `apihost`, `githost`, `remote` — Network
- `created`, `updated`, `pushed` — Timestamps
- `description`, `homepage`, `default-branch`
- `archived-p`, `fork-p`, `locked-p`, `mirror-p`, `private-p`
- `issues-p`, `wiki-p`

**forge_issue / forge_pullreq shared columns:**
- `id`, `forge-id`, `repository`, `number`
- `title`, `body`, `state` (`open`/`closed`)
- `created`, `updated`
- `author` (user login)
- `assignees`, `labels`, `milestone`

**forge_pullreq additional columns:**
- `source-repo`, `source-branch`
- `target-repo`, `target-branch`
- `head-ref`, `head-oid`
- `draft-p`, `mergeable-p`, `merged-p`
- `merged-at`, `merged-by`
- `review-decision`, `requested-reviewers`
- `editable-p`

## Repository Types

```elisp
;; Configure in forge-alist (default covers github.com, gitlab.com):
;; Format: (GITHOST APIHOST FORGE-ID CLASS)
(add-to-list 'forge-alist
             '("git.mycompany.com"
               "git.mycompany.com/api/v4"
               "git.mycompany.com"
               forge-gitlab-repository))

;; Accessing repository slots
(let ((repo (forge-get-repository :tracked?)))
  (oref repo owner)          ; "octocat"
  (oref repo name)           ; "hello-world"
  (oref repo githost)        ; "github.com"
  (oref repo apihost)        ; "api.github.com"
  (oref repo remote)         ; "origin"
  (oref repo default-branch) ; "main"
  (oref repo fork-p)         ; t/nil
  (oref repo private-p))     ; t/nil
```

## Topic Types

### forge-issue

```elisp
;; Accessing issue slots
(let ((issue (forge-get-topic repo 42)))
  (oref issue number)    ; 42
  (oref issue title)     ; "Bug: something broken"
  (oref issue body)      ; Issue description (markdown)
  (oref issue state)     ; 'open or 'closed
  (oref issue author)    ; "username"
  (oref issue created)   ; timestamp string
  (oref issue updated)   ; timestamp string
  (oref issue assignees) ; list of user objects
  (oref issue labels))   ; list of label objects

;; List issues
(forge-ls-issues repo)
(forge-ls-issues repo :assignee "username")
(forge-ls-issues repo :label "bug")
```

### forge-pullreq

```elisp
;; Accessing pullreq slots (extends forge-topic)
(let ((pr (forge-get-topic repo 123)))
  (oref pr source-branch)      ; "feature/my-feature"
  (oref pr target-branch)      ; "main"
  (oref pr draft-p)            ; t/nil
  (oref pr mergeable-p)        ; t/nil
  (oref pr merged-p)           ; t/nil
  (oref pr merged-by)          ; username or nil
  (oref pr review-decision)    ; 'approved, 'changes-requested, nil
  (oref pr requested-reviewers)) ; list of user objects

;; List pull requests
(forge-ls-pullreqs repo)
(forge-ls-pullreqs repo :reviewer "username")
```

### forge-post (Comments)

```elisp
;; Get posts (comments) for a topic
(forge-ls-posts topic)

;; Post slots
(let ((post (car (forge-ls-posts topic))))
  (oref post author)   ; "username"
  (oref post body)     ; Comment body (markdown)
  (oref post created)  ; timestamp
  (oref post updated)) ; timestamp
```

## API Patterns

### Pulling Data from Forge

```elisp
;; Pull all data for current repository
(forge-pull)          ; Interactive, also via `f y`

;; Pull single topic
(forge-pull-topic topic)   ; Interactive, also via `N f t`

;; Pull notifications
(forge-pull-notifications)
```

### Creating Topics

```elisp
;; Create issue (opens transient → edit form → submits)
(forge-create-issue)

;; Create pull request
(forge-create-pullreq)

;; These go through transient menus then edit buffers
;; Data is POSTed to the forge API via ghub
```

### Generic Method Dispatch

Forge uses EIEIO generic functions — behavior differs by repository type:

```elisp
;; Define forge-specific behavior:
(cl-defmethod forge--pull ((repo forge-github-repository) callback)
  "GitHub-specific pull implementation."
  ...)

(cl-defmethod forge--pull ((repo forge-gitlab-repository) callback)
  "GitLab-specific pull implementation."
  ...)

;; Dispatch happens automatically based on repo object class
(forge--pull repo callback)
```

## Notification System

```elisp
;; Notifications are stored in the database
;; They're fetched during forge-pull

;; forge-notification slots:
;; - id, forge-id
;; - repository (link to forge-repository)
;; - topic (link to forge-issue or forge-pullreq)
;; - type ('issue, 'pullreq, 'commit, etc.)
;; - reason ('mentioned, 'subscribed, 'author, etc.)
;; - unread-p (t/nil)
;; - title, url
;; - updated

;; List notifications
(forge-ls-notifications :unread t)
(forge-ls-notifications :repo repo)
```

## Magit Section Integration

Forge adds sections to the magit status buffer via hooks:

```elisp
;; Forge adds these to magit-status-sections-hook:
;; - forge-insert-pullreqs
;; - forge-insert-issues

;; Custom filter for what shows in status buffer:
(setq forge-status-buffer-default-topic-filters
      '((state . open) (draft-p)))

;; Topics menu in status buffer: N m f
;; Temporarily change filters: forge-topics-menu
```

### Building Custom Forge Sections

```elisp
(defun my-forge-insert-section ()
  "Insert custom forge section into magit status."
  (when-let ((repo (forge-get-repository :tracked?)))
    (magit-insert-section (my-forge-section)
      (magit-insert-heading "My Forge Data:")
      (dolist (issue (forge-ls-issues repo))
        (magit-insert-section (issue (oref issue id))
          (insert (format "  #%d %s\n"
                          (oref issue number)
                          (oref issue title)))))
      (insert "\n"))))

(add-hook 'magit-status-sections-hook #'my-forge-insert-section t)
```

## Transient Integration

```elisp
;; Main forge dispatch (available in all magit buffers as 'N')
forge-dispatch

;; Topic menu (RET on a topic section)
forge-topic-menu

;; Extend forge-dispatch with custom commands
(transient-append-suffix 'forge-dispatch '(0 -1)
  ["My Extension"
   ("x" "My forge command" my-forge-command)])
```

## Authentication (Ghub)

Forge uses ghub for API access. Token storage via Auth-Source:

```
# In ~/.authinfo or ~/.authinfo.gpg:
machine api.github.com login USERNAME^forge password TOKEN
machine gitlab.com/api/v4 login USERNAME^forge password TOKEN
```

**GitHub token scopes needed**: `repo`, `read:org`, `user`
**GitLab token scopes needed**: `api` or `read_api`

```elisp
;; Setup wizard (interactive)
(forge-add-repository "https://github.com/owner/repo")
;; Prompts for token setup on first use
```

## Key Commands

```
forge-pull                  — Fetch all forge data (f y)
forge-pull-topic            — Fetch single topic (N f t)
forge-create-issue          — Create new issue
forge-create-pullreq        — Create new pull request
forge-list-issues           — List issues in tabulated buffer
forge-list-pullreqs         — List PRs in tabulated buffer
forge-browse-topic          — Open topic in browser
forge-visit-topic           — Open topic buffer in Emacs
forge-copy-url              — Copy forge URL to clipboard
forge-dispatch              — Main forge menu (N in magit)
forge-topic-menu            — Topic menu (RET on topic section)
forge-add-repository        — Add repo to forge tracking
forge-remove-repository     — Remove repo from tracking
```

## Quick Reference

| Function | Purpose |
|----------|---------|
| `forge-db` | Get database object |
| `forge-get-repository` | Get current repo object |
| `forge-get-topic` | Get topic by number or ID |
| `forge-ls-issues` | List issues for repo |
| `forge-ls-pullreqs` | List PRs for repo |
| `forge-ls-posts` | List comments for topic |
| `forge-ls-notifications` | List notifications |
| `forge-pull` | Fetch data from forge API |
| `forge-pull-topic` | Fetch single topic |
| `forge-create-issue` | Create issue via transient |
| `forge-create-pullreq` | Create PR via transient |
| `forge-insert-pullreqs` | Insert PRs section in magit |
| `forge-insert-issues` | Insert issues section in magit |
| `oref obj slot` | Read EIEIO slot (e.g., `oref issue title`) |
| `oset obj slot val` | Write EIEIO slot |

## Reference

- Manual: https://docs.magit.vc/forge/
- Source: https://github.com/magit/forge
- Closql: https://github.com/magit/closql
- Emacsql: https://github.com/magit/emacsql
- Ghub: https://github.com/magit/ghub
