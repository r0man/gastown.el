;;; gastown-types.el --- EIEIO types for Gas Town -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;; This file is part of gastown.el.

;;; Commentary:

;; This module defines EIEIO classes for all Gas Town types, providing
;; an object-oriented interface to gt CLI data structures.
;;
;; The classes mirror the JSON output from `gt status --json',
;; `gt rig list --json', `gt session list --json', etc. and provide:
;; - Type safety through EIEIO class system
;; - Conversion from JSON (gt --json output)
;; - Conversion to alist (for backwards compatibility)
;;
;; Main classes:
;; - gastown-daemon: Daemon service status
;; - gastown-dolt-service: Dolt database service status
;; - gastown-tmux-service: Tmux session manager status
;; - gastown-overseer: Overseer agent data
;; - gastown-agent: Individual agent (polecat, witness, refinery, etc.)
;; - gastown-hook-status: Hook status entry in a rig (from gt status --json)
;; - gastown-rig: Rig (from gt status --json or gt rig list --json)
;; - gastown-status: Root status object from gt status --json
;; - gastown-session: Session from gt session list --json
;; - gastown-convoy: Convoy from gt convoy list --json
;; - gastown-mail-message: Mail message from gt mail inbox --json
;; - gastown-work-item: Bead item from bd list --json
;; - gastown-polecat-entry: Polecat from gt polecat list --json
;; - gastown-crew-worker-data: Crew worker from gt crew list --json
;; - gastown-merge-request: Merge request from gt mq list --json
;; - gastown-ready-issue: Issue from gt ready --json sources
;; - gastown-ready-source: Source section from gt ready --json
;;
;; Usage:
;;
;;   ;; Parse status JSON into typed objects
;;   (let* ((data (gastown-command-status! :json t))
;;          (status (gastown-gt-status-from-json data)))
;;     (message "Town: %s" (oref status name)))
;;
;;   ;; Access nested objects
;;   (let ((agents (oref status agents)))
;;     (dolist (agent agents)
;;       (message "Agent: %s" (oref agent name))))
;;
;;   ;; Convert back to alist for backwards compat
;;   (gastown-agent-to-alist agent)

;;; Code:

(require 'eieio)
(require 'cl-lib)
(require 'json)

;;; ============================================================
;;; Utility: JSON boolean conversion
;;; ============================================================

(defun gastown-types--json-bool (value)
  "Convert JSON boolean VALUE to Emacs Lisp boolean.
Handles `:json-false' from `json-read' (nil → nil, :json-false → nil, t → t)."
  (and value (not (eq value :json-false))))

(defun gastown-types--json-list (value)
  "Convert JSON array VALUE to a proper list.
Handles both vectors (from `json-array-type' vector) and lists."
  (when value
    (if (vectorp value) (append value nil) value)))

;;; ============================================================
;;; Daemon Service
;;; ============================================================

(defclass gastown-daemon ()
  ((running
    :initarg :running
    :type boolean
    :initform nil
    :documentation "Whether the Gas Town daemon is running.")
   (pid
    :initarg :pid
    :type (or null integer)
    :initform nil
    :documentation "Process ID of the Gas Town daemon."))
  "Represents the Gas Town daemon service status.")

(defun gastown-daemon-from-json (json)
  "Create a `gastown-daemon' object from JSON alist."
  (when json
    (gastown-daemon
     :running (gastown-types--json-bool (alist-get 'running json))
     :pid (alist-get 'pid json))))

(defun gastown-daemon-to-alist (obj)
  "Convert OBJ (gastown-daemon) to alist."
  `((running . ,(oref obj running))
    (pid . ,(oref obj pid))))

;;; ============================================================
;;; Dolt Service
;;; ============================================================

(defclass gastown-dolt-service ()
  ((running
    :initarg :running
    :type boolean
    :initform nil
    :documentation "Whether the Dolt server is running.")
   (pid
    :initarg :pid
    :type (or null integer)
    :initform nil
    :documentation "Process ID of the Dolt server.")
   (port
    :initarg :port
    :type (or null integer)
    :initform nil
    :documentation "Port number the Dolt server is listening on.")
   (data-dir
    :initarg :data-dir
    :type (or null string)
    :initform nil
    :documentation "Path to the Dolt data directory."))
  "Represents the Dolt database service status.")

(defun gastown-dolt-service-from-json (json)
  "Create a `gastown-dolt-service' object from JSON alist."
  (when json
    (gastown-dolt-service
     :running (gastown-types--json-bool (alist-get 'running json))
     :pid (alist-get 'pid json)
     :port (alist-get 'port json)
     :data-dir (alist-get 'data_dir json))))

(defun gastown-dolt-service-to-alist (obj)
  "Convert OBJ (gastown-dolt-service) to alist."
  `((running . ,(oref obj running))
    (pid . ,(oref obj pid))
    (port . ,(oref obj port))
    (data_dir . ,(oref obj data-dir))))

;;; ============================================================
;;; Tmux Service
;;; ============================================================

(defclass gastown-tmux-service ()
  ((socket
    :initarg :socket
    :type (or null string)
    :initform nil
    :documentation "Tmux socket name")
   (running
    :initarg :running
    :type boolean
    :initform nil
    :documentation "Whether the tmux server is running.")
   (pid
    :initarg :pid
    :type (or null integer)
    :initform nil
    :documentation "Tmux server process ID.")
   (session-count
    :initarg :session-count
    :type (or null integer)
    :initform nil
    :documentation "Number of active tmux sessions.")
   (socket-path
    :initarg :socket-path
    :type (or null string)
    :initform nil
    :documentation "Full path to the tmux socket file."))
  "Represents the tmux session manager service status.")

(defun gastown-tmux-service-from-json (json)
  "Create a `gastown-tmux-service' object from JSON alist."
  (when json
    (gastown-tmux-service
     :socket (alist-get 'socket json)
     :running (gastown-types--json-bool (alist-get 'running json))
     :pid (alist-get 'pid json)
     :session-count (alist-get 'session_count json)
     :socket-path (alist-get 'socket_path json))))

(defun gastown-tmux-service-to-alist (obj)
  "Convert OBJ (gastown-tmux-service) to alist."
  `((socket . ,(oref obj socket))
    (running . ,(oref obj running))
    (pid . ,(oref obj pid))
    (session_count . ,(oref obj session-count))
    (socket_path . ,(oref obj socket-path))))

;;; ============================================================
;;; DND (Do Not Disturb)
;;; ============================================================

(defclass gastown-dnd-status ()
  ((enabled
    :initarg :enabled
    :type boolean
    :initform nil
    :documentation "Whether DND mode is enabled.")
   (level
    :initarg :level
    :type (or null string)
    :initform nil
    :documentation "Notification level (e.g., \"normal\", \"quiet\").")
   (agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent managing the DND setting."))
  "Represents the Do Not Disturb status.")

(defun gastown-dnd-status-from-json (json)
  "Create a `gastown-dnd-status' object from JSON alist."
  (when json
    (gastown-dnd-status
     :enabled (gastown-types--json-bool (alist-get 'enabled json))
     :level (alist-get 'level json)
     :agent (alist-get 'agent json))))

(defun gastown-dnd-status-to-alist (obj)
  "Convert OBJ (gastown-dnd-status) to alist."
  `((enabled . ,(oref obj enabled))
    (level . ,(oref obj level))
    (agent . ,(oref obj agent))))

;;; ============================================================
;;; Overseer
;;; ============================================================

(defclass gastown-overseer ()
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Overseer name.")
   (email
    :initarg :email
    :type (or null string)
    :initform nil
    :documentation "Overseer email address.")
   (username
    :initarg :username
    :type (or null string)
    :initform nil
    :documentation "Overseer username (e.g., git config user.name).")
   (source
    :initarg :source
    :type (or null string)
    :initform nil
    :documentation "Source of the overseer identity (e.g., \"git-config\").")
   (unread-mail
    :initarg :unread-mail
    :type (or null integer)
    :initform nil
    :documentation "Number of unread mail messages."))
  "Represents the Gas Town overseer agent.")

(defun gastown-overseer-from-json (json)
  "Create a `gastown-overseer' object from JSON alist."
  (when json
    (gastown-overseer
     :name (alist-get 'name json)
     :email (alist-get 'email json)
     :username (alist-get 'username json)
     :source (alist-get 'source json)
     :unread-mail (alist-get 'unread_mail json))))

(defun gastown-overseer-to-alist (obj)
  "Convert OBJ (gastown-overseer) to alist."
  `((name . ,(oref obj name))
    (email . ,(oref obj email))
    (username . ,(oref obj username))
    (source . ,(oref obj source))
    (unread_mail . ,(oref obj unread-mail))))

;;; ============================================================
;;; Agent
;;; ============================================================

(defclass gastown-agent ()
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Agent name (e.g., \"nux\", \"witness\").")
   (address
    :initarg :address
    :type (or null string)
    :initform nil
    :documentation "Agent address in rig/name format (e.g., \"gastown_el/nux\").")
   (role
    :initarg :role
    :type (or null string)
    :initform nil
    :documentation "Agent role (polecat, witness, refinery, crew, coordinator).")
   (running
    :initarg :running
    :type boolean
    :initform nil
    :documentation "Whether the agent is currently running.")
   (session
    :initarg :session
    :type (or null string)
    :initform nil
    :documentation "Tmux session name for this agent.")
   (agent-info
    :initarg :agent-info
    :type (or null string)
    :initform nil
    :documentation "Short info string shown in status (e.g., bead ID).")
   (agent-alias
    :initarg :agent-alias
    :type (or null string)
    :initform nil
    :documentation "Agent model alias (e.g., \"claude-opus\", \"claude-sonnet\").")
   (unread-mail
    :initarg :unread-mail
    :type (or null integer)
    :initform nil
    :documentation "Number of unread mail messages.")
   (first-subject
    :initarg :first-subject
    :type (or null string)
    :initform nil
    :documentation "Subject of the first/most recent mail message.")
   (has-work
    :initarg :has-work
    :type boolean
    :initform nil
    :documentation "Whether the agent has hooked work (polecats only).")
   (work-title
    :initarg :work-title
    :type (or null string)
    :initform nil
    :documentation "Title of the hooked work item (polecats only).")
   (hook-bead
    :initarg :hook-bead
    :type (or null string)
    :initform nil
    :documentation "Bead ID of the hooked work item (polecats only).")
   (state
    :initarg :state
    :type (or null string)
    :initform nil
    :documentation "Polecat lifecycle state (working, idle, done, stuck, zombie)."))
  "Represents a Gas Town agent (polecat, witness, refinery, crew, or global agent).")

(defun gastown-agent-from-json (json)
  "Create a `gastown-agent' object from JSON alist."
  (when json
    (gastown-agent
     :name (alist-get 'name json)
     :address (alist-get 'address json)
     :role (alist-get 'role json)
     :running (gastown-types--json-bool (alist-get 'running json))
     :session (alist-get 'session json)
     :agent-info (alist-get 'agent_info json)
     :agent-alias (alist-get 'agent_alias json)
     :unread-mail (alist-get 'unread_mail json)
     :first-subject (alist-get 'first_subject json)
     :has-work (gastown-types--json-bool (alist-get 'has_work json))
     :work-title (alist-get 'work_title json)
     :hook-bead (alist-get 'hook_bead json)
     :state (alist-get 'state json))))

(defun gastown-agent-to-alist (obj)
  "Convert OBJ (gastown-agent) to alist.
Produces the same keys as the original `gt status --json' output."
  `((name . ,(oref obj name))
    (address . ,(oref obj address))
    (role . ,(oref obj role))
    (running . ,(oref obj running))
    (session . ,(oref obj session))
    (agent_info . ,(oref obj agent-info))
    (agent_alias . ,(oref obj agent-alias))
    (unread_mail . ,(oref obj unread-mail))
    (first_subject . ,(oref obj first-subject))
    (has_work . ,(oref obj has-work))
    (work_title . ,(oref obj work-title))
    (hook_bead . ,(oref obj hook-bead))
    (state . ,(oref obj state))))

;;; ============================================================
;;; Hook Status
;;; ============================================================

(defclass gastown-hook-status ()
  ((agent
    :initarg :agent
    :type (or null string)
    :initform nil
    :documentation "Agent address (e.g., \"gastown_el/nux\").")
   (role
    :initarg :role
    :type (or null string)
    :initform nil
    :documentation "Agent role (polecat, witness, refinery, crew).")
   (has-work
    :initarg :has-work
    :type boolean
    :initform nil
    :documentation "Whether the agent has hooked work."))
  "Represents a hook status entry in a rig (from `gt status --json').")

(defun gastown-hook-status-from-json (json)
  "Create a `gastown-hook-status' object from JSON alist."
  (when json
    (gastown-hook-status
     :agent (alist-get 'agent json)
     :role (alist-get 'role json)
     :has-work (gastown-types--json-bool (alist-get 'has_work json)))))

(defun gastown-hook-status-to-alist (obj)
  "Convert OBJ (gastown-hook-status) to alist."
  `((agent . ,(oref obj agent))
    (role . ,(oref obj role))
    (has_work . ,(oref obj has-work))))

;;; ============================================================
;;; Rig
;;; ============================================================

(defclass gastown-rig-data ()
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Rig name (e.g., \"gastown_el\").")
   ;; Fields from gt status --json
   (polecats
    :initarg :polecats
    :type list
    :initform nil
    :documentation "List of polecat names in this rig (from status).")
   (polecat-count
    :initarg :polecat-count
    :type (or null integer)
    :initform nil
    :documentation "Number of polecat agents.")
   (crews
    :initarg :crews
    :type list
    :initform nil
    :documentation "List of crew worker names in this rig (from status).")
   (crew-count
    :initarg :crew-count
    :type (or null integer)
    :initform nil
    :documentation "Number of crew agents.")
   (has-witness
    :initarg :has-witness
    :type boolean
    :initform nil
    :documentation "Whether the rig has a witness agent.")
   (has-refinery
    :initarg :has-refinery
    :type boolean
    :initform nil
    :documentation "Whether the rig has a refinery agent.")
   (hooks
    :initarg :hooks
    :type list
    :initform nil
    :documentation "List of gastown-hook-status objects for all agents in this rig.")
   (agents
    :initarg :agents
    :type list
    :initform nil
    :documentation "List of gastown-agent objects in this rig (from status).")
   ;; Fields from gt rig list --json
   (beads-prefix
    :initarg :beads-prefix
    :type (or null string)
    :initform nil
    :documentation "Beads ID prefix for this rig (e.g., \"ge\").")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Rig operational status (operational, degraded, etc.).")
   (witness
    :initarg :witness
    :type (or null string)
    :initform nil
    :documentation "Witness agent status string (e.g., \"running\").")
   (refinery
    :initarg :refinery
    :type (or null string)
    :initform nil
    :documentation "Refinery agent status string (e.g., \"running\")."))
  "Represents a Gas Town rig.
Combines fields from both `gt status --json' (agents list, hooks) and
`gt rig list --json' (status, witness, refinery strings).")

(defun gastown-rig-data-from-json (json)
  "Create a `gastown-rig-data' object from JSON alist (gt status --json format).
The agents array is converted to a list of `gastown-agent' objects.
The hooks array is converted to a list of `gastown-hook-status' objects."
  (when json
    (gastown-rig-data
     :name (alist-get 'name json)
     :polecats (gastown-types--json-list (alist-get 'polecats json))
     :polecat-count (alist-get 'polecat_count json)
     :crews (gastown-types--json-list (alist-get 'crews json))
     :crew-count (alist-get 'crew_count json)
     :has-witness (gastown-types--json-bool (alist-get 'has_witness json))
     :has-refinery (gastown-types--json-bool (alist-get 'has_refinery json))
     :hooks (mapcar #'gastown-hook-status-from-json
                    (gastown-types--json-list (alist-get 'hooks json)))
     :agents (mapcar #'gastown-agent-from-json
                     (gastown-types--json-list (alist-get 'agents json))))))

(defun gastown-rig-data-info-from-json (json)
  "Create a `gastown-rig-data' object from JSON alist (gt rig list --json format)."
  (when json
    (gastown-rig-data
     :name (alist-get 'name json)
     :beads-prefix (alist-get 'beads_prefix json)
     :status (alist-get 'status json)
     :witness (alist-get 'witness json)
     :refinery (alist-get 'refinery json)
     :polecat-count (alist-get 'polecats json)
     :crew-count (alist-get 'crew json))))

(defun gastown-rig-data-to-alist (obj)
  "Convert OBJ (gastown-rig-data) to alist."
  `((name . ,(oref obj name))
    (polecats . ,(oref obj polecats))
    (polecat_count . ,(oref obj polecat-count))
    (crews . ,(oref obj crews))
    (crew_count . ,(oref obj crew-count))
    (has_witness . ,(oref obj has-witness))
    (has_refinery . ,(oref obj has-refinery))
    (hooks . ,(mapcar #'gastown-hook-status-to-alist (oref obj hooks)))
    (agents . ,(mapcar #'gastown-agent-to-alist (oref obj agents)))
    (beads_prefix . ,(oref obj beads-prefix))
    (status . ,(oref obj status))
    (witness . ,(oref obj witness))
    (refinery . ,(oref obj refinery))))

;;; ============================================================
;;; Status (root)
;;; ============================================================

(defclass gastown-gt-status ()
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Gas Town workspace name.")
   (location
    :initarg :location
    :type (or null string)
    :initform nil
    :documentation "Workspace root path.")
   (daemon
    :initarg :daemon
    :type (or null gastown-daemon)
    :initform nil
    :documentation "Daemon service status.")
   (dolt
    :initarg :dolt
    :type (or null gastown-dolt-service)
    :initform nil
    :documentation "Dolt database service status.")
   (tmux
    :initarg :tmux
    :type (or null gastown-tmux-service)
    :initform nil
    :documentation "Tmux session manager service status.")
   (overseer
    :initarg :overseer
    :type (or null gastown-overseer)
    :initform nil
    :documentation "Overseer agent data.")
   (rigs
    :initarg :rigs
    :type list
    :initform nil
    :documentation "List of gastown-rig objects.")
   (dnd
    :initarg :dnd
    :type (or null gastown-dnd-status)
    :initform nil
    :documentation "Do Not Disturb status.")
   (agents
    :initarg :agents
    :type list
    :initform nil
    :documentation "List of global gastown-agent objects (mayor, deacon, etc.)."))
  "Represents the root status object from `gt status --json'.")

(defun gastown-gt-status-from-json (json)
  "Create a `gastown-gt-status' object from JSON alist (gt status --json output)."
  (when json
    (gastown-gt-status
     :name (alist-get 'name json)
     :location (alist-get 'location json)
     :daemon (gastown-daemon-from-json (alist-get 'daemon json))
     :dolt (gastown-dolt-service-from-json (alist-get 'dolt json))
     :tmux (gastown-tmux-service-from-json (alist-get 'tmux json))
     :overseer (gastown-overseer-from-json (alist-get 'overseer json))
     :dnd (gastown-dnd-status-from-json (alist-get 'dnd json))
     :rigs (mapcar #'gastown-rig-data-from-json
                   (gastown-types--json-list (alist-get 'rigs json)))
     :agents (mapcar #'gastown-agent-from-json
                     (gastown-types--json-list (alist-get 'agents json))))))

;;; ============================================================
;;; Session
;;; ============================================================

(defclass gastown-session ()
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name this session belongs to.")
   (polecat
    :initarg :polecat
    :type (or null string)
    :initform nil
    :documentation "Polecat name for this session.")
   (session-id
    :initarg :session-id
    :type (or null string)
    :initform nil
    :documentation "Tmux session identifier.")
   (running
    :initarg :running
    :type boolean
    :initform nil
    :documentation "Whether the session is currently active."))
  "Represents a Gas Town session from `gt session list --json'.")

(defun gastown-session-from-json (json)
  "Create a `gastown-session' object from JSON alist."
  (when json
    (gastown-session
     :rig (alist-get 'rig json)
     :polecat (alist-get 'polecat json)
     :session-id (alist-get 'session_id json)
     :running (gastown-types--json-bool (alist-get 'running json)))))

(defun gastown-session-to-alist (obj)
  "Convert OBJ (gastown-session) to alist."
  `((rig . ,(oref obj rig))
    (polecat . ,(oref obj polecat))
    (session_id . ,(oref obj session-id))
    (running . ,(oref obj running))))

;;; ============================================================
;;; Convoy
;;; ============================================================

(defclass gastown-convoy-data ()
  ((id
    :initarg :id
    :type (or null string)
    :initform nil
    :documentation "Convoy unique identifier.")
   (title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Convoy title/description.")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Convoy status (active, completed, etc.).")
   (created-at
    :initarg :created-at
    :type (or null string)
    :initform nil
    :documentation "Creation timestamp (ISO 8601).")
   (completed
    :initarg :completed
    :type (or null integer)
    :initform nil
    :documentation "Number of completed tasks in this convoy.")
   (total
    :initarg :total
    :type (or null integer)
    :initform nil
    :documentation "Total number of tasks in this convoy."))
  "Represents a Gas Town convoy from `gt convoy list --json'.")

(defun gastown-convoy-data-from-json (json)
  "Create a `gastown-convoy-data' object from JSON alist."
  (when json
    (gastown-convoy-data
     :id (alist-get 'id json)
     :title (alist-get 'title json)
     :status (alist-get 'status json)
     :created-at (alist-get 'created_at json)
     :completed (alist-get 'completed json)
     :total (alist-get 'total json))))

(defun gastown-convoy-data-to-alist (obj)
  "Convert OBJ (gastown-convoy-data) to alist."
  `((id . ,(oref obj id))
    (title . ,(oref obj title))
    (status . ,(oref obj status))
    (created_at . ,(oref obj created-at))
    (completed . ,(oref obj completed))
    (total . ,(oref obj total))))

;;; ============================================================
;;; Mail Message
;;; ============================================================

(defclass gastown-mail-message ()
  ((id
    :initarg :id
    :type (or null string)
    :initform nil
    :documentation "Mail message unique identifier.")
   (from
    :initarg :from
    :type (or null string)
    :initform nil
    :documentation "Sender address (rig/role format).")
   (subject
    :initarg :subject
    :type (or null string)
    :initform nil
    :documentation "Message subject line.")
   (timestamp
    :initarg :timestamp
    :type (or null string)
    :initform nil
    :documentation "Message timestamp (ISO 8601).")
   (read
    :initarg :read
    :type boolean
    :initform nil
    :documentation "Whether the message has been read.")
   (priority
    :initarg :priority
    :type (or null string)
    :initform nil
    :documentation "Message priority (low, normal, high, critical)."))
  "Represents a Gas Town mail message from `gt mail inbox --json'.")

(defun gastown-mail-message-from-json (json)
  "Create a `gastown-mail-message' object from JSON alist."
  (when json
    (gastown-mail-message
     :id (alist-get 'id json)
     :from (alist-get 'from json)
     :subject (alist-get 'subject json)
     :timestamp (alist-get 'timestamp json)
     :read (gastown-types--json-bool (alist-get 'read json))
     :priority (alist-get 'priority json))))

(defun gastown-mail-message-to-alist (obj)
  "Convert OBJ (gastown-mail-message) to alist."
  `((id . ,(oref obj id))
    (from . ,(oref obj from))
    (subject . ,(oref obj subject))
    (timestamp . ,(oref obj timestamp))
    (read . ,(oref obj read))
    (priority . ,(oref obj priority))))

;;; ============================================================
;;; Bead (from bd list --json)
;;; ============================================================

(defclass gastown-work-item ()
  ((id
    :initarg :id
    :type (or null string)
    :initform nil
    :documentation "Bead unique identifier (e.g., \"ge-abc123\").")
   (title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Bead title.")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Bead status (open, in_progress, closed, etc.)."))
  "Represents a Beads issue item from `bd list --json'.
For full Beads type support, use `beads-issue' from beads-types.el.")

(defun gastown-work-item-from-json (json)
  "Create a `gastown-work-item' object from JSON alist."
  (when json
    (gastown-work-item
     :id (alist-get 'id json)
     :title (alist-get 'title json)
     :status (alist-get 'status json))))

(defun gastown-work-item-to-alist (obj)
  "Convert OBJ (gastown-work-item) to alist."
  `((id . ,(oref obj id))
    (title . ,(oref obj title))
    (status . ,(oref obj status))))

;;; ============================================================
;;; Polecat Entry (from gt polecat list --json)
;;; ============================================================

(defclass gastown-polecat-entry ()
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Polecat name.")
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name this polecat belongs to.")
   (state
    :initarg :state
    :type (or null string)
    :initform nil
    :documentation "Polecat lifecycle state (working, idle, done, stuck, zombie).")
   (issue
    :initarg :issue
    :type (or null string)
    :initform nil
    :documentation "Currently assigned issue ID (if any).")
   (session-running
    :initarg :session-running
    :type boolean
    :initform nil
    :documentation "Whether the polecat tmux session is active."))
  "Represents a polecat worker from `gt polecat list --json'.
Mirrors the Go polecat.Polecat struct summary output.")

(defun gastown-polecat-entry-from-json (json)
  "Create a `gastown-polecat-entry' object from JSON alist."
  (when json
    (gastown-polecat-entry
     :name (alist-get 'name json)
     :rig (alist-get 'rig json)
     :state (alist-get 'state json)
     :issue (alist-get 'issue json)
     :session-running (gastown-types--json-bool (alist-get 'session_running json)))))

(defun gastown-polecat-entry-to-alist (obj)
  "Convert OBJ (gastown-polecat-entry) to alist."
  `((name . ,(oref obj name))
    (rig . ,(oref obj rig))
    (state . ,(oref obj state))
    (issue . ,(oref obj issue))
    (session_running . ,(oref obj session-running))))

;;; ============================================================
;;; Crew Worker (from gt crew list --json)
;;; ============================================================

(defclass gastown-crew-worker-data ()
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Crew worker name.")
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig name this crew worker belongs to.")
   (clone-path
    :initarg :clone-path
    :type (or null string)
    :initform nil
    :documentation "Path to the crew worker's git clone.")
   (branch
    :initarg :branch
    :type (or null string)
    :initform nil
    :documentation "Current git branch.")
   (created-at
    :initarg :created-at
    :type (or null string)
    :initform nil
    :documentation "Creation timestamp (ISO 8601).")
   (updated-at
    :initarg :updated-at
    :type (or null string)
    :initform nil
    :documentation "Last update timestamp (ISO 8601)."))
  "Represents a crew worker from `gt crew list --json'.
Mirrors the Go crew.CrewWorker struct.")

(defun gastown-crew-worker-data-from-json (json)
  "Create a `gastown-crew-worker-data' object from JSON alist."
  (when json
    (gastown-crew-worker-data
     :name (alist-get 'name json)
     :rig (alist-get 'rig json)
     :clone-path (alist-get 'clone_path json)
     :branch (alist-get 'branch json)
     :created-at (alist-get 'created_at json)
     :updated-at (alist-get 'updated_at json))))

(defun gastown-crew-worker-data-to-alist (obj)
  "Convert OBJ (gastown-crew-worker-data) to alist."
  `((name . ,(oref obj name))
    (rig . ,(oref obj rig))
    (clone_path . ,(oref obj clone-path))
    (branch . ,(oref obj branch))
    (created_at . ,(oref obj created-at))
    (updated_at . ,(oref obj updated-at))))

;;; ============================================================
;;; Merge Request (from gt mq list --json)
;;; ============================================================

(defclass gastown-merge-request ()
  ((id
    :initarg :id
    :type (or null string)
    :initform nil
    :documentation "Unique merge request ID (beads issue ID).")
   (branch
    :initarg :branch
    :type (or null string)
    :initform nil
    :documentation "Source branch name (e.g., \"polecat/slit/ge-abc\").")
   (worker
    :initarg :worker
    :type (or null string)
    :initform nil
    :documentation "Polecat name that created this branch.")
   (issue-id
    :initarg :issue-id
    :type (or null string)
    :initform nil
    :documentation "Beads issue being worked on.")
   (target-branch
    :initarg :target-branch
    :type (or null string)
    :initform nil
    :documentation "Target branch for merge (usually main).")
   (created-at
    :initarg :created-at
    :type (or null string)
    :initform nil
    :documentation "Creation timestamp (ISO 8601).")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "MR status (open, in_progress, closed).")
   (close-reason
    :initarg :close-reason
    :type (or null string)
    :initform nil
    :documentation "Reason for closing (merged, rejected, conflict, superseded).")
   (error
    :initarg :error
    :type (or null string)
    :initform nil
    :documentation "Error details if the MR failed."))
  "Represents a merge request from `gt mq list --json'.
Mirrors the Go refinery.MergeRequest struct.")

(defun gastown-merge-request-from-json (json)
  "Create a `gastown-merge-request' object from JSON alist."
  (when json
    (gastown-merge-request
     :id (alist-get 'id json)
     :branch (alist-get 'branch json)
     :worker (alist-get 'worker json)
     :issue-id (alist-get 'issue_id json)
     :target-branch (alist-get 'target_branch json)
     :created-at (alist-get 'created_at json)
     :status (alist-get 'status json)
     :close-reason (alist-get 'close_reason json)
     :error (alist-get 'error json))))

(defun gastown-merge-request-to-alist (obj)
  "Convert OBJ (gastown-merge-request) to alist."
  `((id . ,(oref obj id))
    (branch . ,(oref obj branch))
    (worker . ,(oref obj worker))
    (issue_id . ,(oref obj issue-id))
    (target_branch . ,(oref obj target-branch))
    (created_at . ,(oref obj created-at))
    (status . ,(oref obj status))
    (close_reason . ,(oref obj close-reason))
    (error . ,(oref obj error))))

;;; ============================================================
;;; Ready Command Types (from gt ready --json)
;;; ============================================================

(defclass gastown-ready-issue ()
  ((id
    :initarg :id
    :type (or null string)
    :initform nil
    :documentation "Bead issue ID.")
   (title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Issue title.")
   (priority
    :initarg :priority
    :type (or null integer)
    :initform nil
    :documentation "Issue priority (0=critical, 1=high, 2=medium, 3=low, 4=backlog).")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Issue status (open, in_progress, etc.).")
   (assignee
    :initarg :assignee
    :type (or null string)
    :initform nil
    :documentation "Issue assignee address."))
  "Represents a ready issue from `gt ready --json' sources array.")

(defun gastown-ready-issue-from-json (json)
  "Create a `gastown-ready-issue' object from JSON alist."
  (when json
    (gastown-ready-issue
     :id (alist-get 'id json)
     :title (alist-get 'title json)
     :priority (alist-get 'priority json)
     :status (alist-get 'status json)
     :assignee (alist-get 'assignee json))))

(defun gastown-ready-issue-to-alist (obj)
  "Convert OBJ (gastown-ready-issue) to alist."
  `((id . ,(oref obj id))
    (title . ,(oref obj title))
    (priority . ,(oref obj priority))
    (status . ,(oref obj status))
    (assignee . ,(oref obj assignee))))

(defclass gastown-ready-source ()
  ((name
    :initarg :name
    :type (or null string)
    :initform nil
    :documentation "Source name (rig name or \"town\").")
   (issues
    :initarg :issues
    :type list
    :initform nil
    :documentation "List of gastown-ready-issue objects in this source."))
  "Represents a source section in `gt ready --json' output.")

(defun gastown-ready-source-from-json (json)
  "Create a `gastown-ready-source' object from JSON alist."
  (when json
    (gastown-ready-source
     :name (alist-get 'name json)
     :issues (mapcar #'gastown-ready-issue-from-json
                     (gastown-types--json-list (alist-get 'issues json))))))

(defun gastown-ready-source-to-alist (obj)
  "Convert OBJ (gastown-ready-source) to alist."
  `((name . ,(oref obj name))
    (issues . ,(mapcar #'gastown-ready-issue-to-alist (oref obj issues)))))

;;; ============================================================
;;; Status Buffer Section Types
;;; ============================================================
;;
;; These classes serve as typed containers for context detection
;; (see `gastown-status-current-section' and gastown-context.el).
;; They are attached to buffer text via `gastown-status-section'
;; text property.

(defclass gastown-services-section ()
  nil
  "Data container for the services overview line.")

(defclass gastown-service-section ()
  ((service :initarg :service :initform nil))
  "Data container for an individual service.")

(defclass gastown-agents-section ()
  nil
  "Data container for the global agents block.")

(defclass gastown-agent-section ()
  ((agent  :initarg :agent  :initform nil)
   (parent :initarg :parent :initform nil))
  "Data container for an individual agent row.")

(defclass gastown-rig-section ()
  ((rig    :initarg :rig    :initform nil)
   (parent :initarg :parent :initform nil))
  "Data container for a rig section.")

(defclass gastown-polecat-section ()
  ((polecat  :initarg :polecat  :initform nil)
   (rig-name :initarg :rig-name :initform nil)
   (parent   :initarg :parent   :initform nil))
  "Data container for an individual polecat row.")

;;; ============================================================
;;; Completion Summary Types
;;; ============================================================

(defclass gastown-completion-rig ()
  ((name
    :initarg :name
    :type string
    :documentation "Rig name.")
   (beads-prefix
    :initarg :beads-prefix
    :type (or null string)
    :initform nil
    :documentation "Beads issue prefix for this rig.")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Rig status (operational, degraded, docked, parked).")
   (witness
    :initarg :witness
    :type (or null string)
    :initform nil
    :documentation "Witness service status.")
   (refinery
    :initarg :refinery
    :type (or null string)
    :initform nil
    :documentation "Refinery service status.")
   (polecats
    :initarg :polecats
    :type (or null integer)
    :initform nil
    :documentation "Number of polecats in this rig.")
   (crew
    :initarg :crew
    :type (or null integer)
    :initform nil
    :documentation "Number of crew members."))
  :documentation "A Gas Town rig summary.")

(defclass gastown-completion-polecat ()
  ((name
    :initarg :name
    :type string
    :documentation "Polecat name.")
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig this polecat belongs to.")
   (state
    :initarg :state
    :type (or null string)
    :initform nil
    :documentation "Polecat state (working, idle, etc.).")
   (issue
    :initarg :issue
    :type (or null string)
    :initform nil
    :documentation "Current issue the polecat is working on.")
   (session-running
    :initarg :session-running
    :type boolean
    :initform nil
    :documentation "Whether the polecat session is running."))
  :documentation "A Gas Town polecat summary.")

(defclass gastown-completion-convoy ()
  ((id
    :initarg :id
    :type string
    :documentation "Convoy ID.")
   (title
    :initarg :title
    :type (or null string)
    :initform nil
    :documentation "Convoy title.")
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Convoy status (open, completed, cancelled).")
   (completed
    :initarg :completed
    :type (or null integer)
    :initform nil
    :documentation "Number of completed tasks.")
   (total
    :initarg :total
    :type (or null integer)
    :initform nil
    :documentation "Total number of tasks."))
  :documentation "A Gas Town convoy summary.")

(defclass gastown-completion-formula ()
  ((name
    :initarg :name
    :type string
    :documentation "Formula name.")
   (type
    :initarg :type
    :type (or null string)
    :initform nil
    :documentation "Formula type (workflow, convoy, etc.).")
   (description
    :initarg :description
    :type (or null string)
    :initform nil
    :documentation "Formula description.")
   (vars
    :initarg :vars
    :type (or null integer)
    :initform nil
    :documentation "Number of variables in the formula."))
  :documentation "A Gas Town formula summary.")

(defclass gastown-completion-crew ()
  ((name
    :initarg :name
    :type string
    :documentation "Crew worker name.")
   (rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Rig this crew worker belongs to.")
   (branch
    :initarg :branch
    :type (or null string)
    :initform nil
    :documentation "Current git branch.")
   (has-session
    :initarg :has-session
    :type boolean
    :initform nil
    :documentation "Whether the crew worker has an active session."))
  :documentation "A Gas Town crew worker summary.")

;;; ============================================================
;;; Filter Spec Types
;;; ============================================================

(defclass gastown-agent-spec ()
  ((rig
    :initarg :rig
    :type (or null string)
    :initform nil
    :documentation "Filter to agents in this rig, or nil for all")
   (role
    :initarg :role
    :type (or null string)
    :initform nil
    :documentation "Filter by role string: \"polecat\", \"witness\", \"refinery\", \"crew\".
Nil means no role filter")
   (running
    :initarg :running
    :type (or null boolean)
    :initform nil
    :documentation "When non-nil, filter to running agents only")
   (order
    :initarg :order
    :type symbol
    :initform 'name
    :documentation "Sort order symbol: name, rig, or status.
Default \\='name is omitted from CLI args."))
  :documentation "Filter spec for the Gas Town agent/session list view.")

(defclass gastown-rig-spec ()
  ((status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Filter to rigs with this status: \"operational\", \"degraded\",
\"docked\", or \"parked\".  Nil means no status filter")
   (order
    :initarg :order
    :type symbol
    :initform 'name
    :documentation "Sort order symbol: name or status.
Default \\='name is omitted from CLI args."))
  :documentation "Filter spec for the Gas Town rig list view.")

(defclass gastown-convoy-spec ()
  ((status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Filter to convoys with this status, or nil for all")
   (order
    :initarg :order
    :type symbol
    :initform 'newest
    :documentation "Sort order symbol: newest or oldest.
Default \\='newest is omitted from CLI args.")
   (limit
    :initarg :limit
    :type integer
    :initform 50
    :documentation "Maximum number of convoys to show"))
  :documentation "Filter spec for the Gas Town convoy list view.")

(defclass gastown-mail-spec ()
  ((unread-only
    :initarg :unread-only
    :type (or null boolean)
    :initform nil
    :documentation "When non-nil, show only unread messages")
   (from
    :initarg :from
    :type (or null string)
    :initform nil
    :documentation "Filter to messages from this sender, or nil for all")
   (priority
    :initarg :priority
    :type (or null string)
    :initform nil
    :documentation "Filter by priority tag, or nil for all")
   (order
    :initarg :order
    :type symbol
    :initform 'newest
    :documentation "Sort order symbol: newest or oldest.
Default \\='newest is omitted from CLI args.")
   (limit
    :initarg :limit
    :type integer
    :initform 100
    :documentation "Maximum number of messages to show"))
  :documentation "Filter spec for the Gas Town mail inbox view.")

(provide 'gastown-types)
;;; gastown-types.el ends here
