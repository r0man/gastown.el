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
;; - gastown-rig: Rig (from gt status --json or gt rig list --json)
;; - gastown-status: Root status object from gt status --json
;; - gastown-session: Session from gt session list --json
;; - gastown-convoy: Convoy from gt convoy list --json
;; - gastown-mail-message: Mail message from gt mail inbox --json
;; - gastown-work-item: Bead item from bd list --json
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
  ((pid
    :initarg :pid
    :type (or null integer)
    :initform nil
    :documentation "Process ID of the Gas Town daemon."))
  "Represents the Gas Town daemon service status.")

(defun gastown-daemon-from-json (json)
  "Create a `gastown-daemon' object from JSON alist."
  (when json
    (gastown-daemon
     :pid (alist-get 'pid json))))

(defun gastown-daemon-to-alist (obj)
  "Convert OBJ (gastown-daemon) to alist."
  `((pid . ,(oref obj pid))))

;;; ============================================================
;;; Dolt Service
;;; ============================================================

(defclass gastown-dolt-service ()
  ((pid
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
     :pid (alist-get 'pid json)
     :port (alist-get 'port json)
     :data-dir (alist-get 'data_dir json))))

(defun gastown-dolt-service-to-alist (obj)
  "Convert OBJ (gastown-dolt-service) to alist."
  `((pid . ,(oref obj pid))
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
    :documentation "Tmux socket name (-L argument).")
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
     :pid (alist-get 'pid json)
     :session-count (alist-get 'session_count json)
     :socket-path (alist-get 'socket_path json))))

(defun gastown-tmux-service-to-alist (obj)
  "Convert OBJ (gastown-tmux-service) to alist."
  `((socket . ,(oref obj socket))
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
     :unread-mail (alist-get 'unread_mail json))))

(defun gastown-overseer-to-alist (obj)
  "Convert OBJ (gastown-overseer) to alist."
  `((name . ,(oref obj name))
    (email . ,(oref obj email))
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
    :documentation "Whether the agent has hooked work (polecats only)."))
  "Represents a Gas Town agent (polecat, witness, refinery, crew, or global agent).")

(defun gastown-agent-from-json (json)
  "Create a `gastown-agent' object from JSON alist."
  (when json
    (gastown-agent
     :name (alist-get 'name json)
     :role (alist-get 'role json)
     :running (gastown-types--json-bool (alist-get 'running json))
     :session (alist-get 'session json)
     :agent-info (alist-get 'agent_info json)
     :unread-mail (alist-get 'unread_mail json)
     :first-subject (alist-get 'first_subject json)
     :has-work (gastown-types--json-bool (alist-get 'has_work json)))))

(defun gastown-agent-to-alist (obj)
  "Convert OBJ (gastown-agent) to alist.
Produces the same keys as the original `gt status --json' output."
  `((name . ,(oref obj name))
    (role . ,(oref obj role))
    (running . ,(oref obj running))
    (session . ,(oref obj session))
    (agent_info . ,(oref obj agent-info))
    (unread_mail . ,(oref obj unread-mail))
    (first_subject . ,(oref obj first-subject))
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
   (agents
    :initarg :agents
    :type list
    :initform nil
    :documentation "List of gastown-agent objects in this rig (from status).")
   ;; Fields from gt rig list --json
   (status
    :initarg :status
    :type (or null string)
    :initform nil
    :documentation "Rig operational status (operational, degraded, etc.).")
   (witness
    :initarg :witness
    :type (or null string)
    :initform nil
    :documentation "Witness agent name.")
   (refinery
    :initarg :refinery
    :type (or null string)
    :initform nil
    :documentation "Refinery agent name.")
   (polecats
    :initarg :polecats
    :type (or null integer)
    :initform nil
    :documentation "Number of polecat agents.")
   (crew
    :initarg :crew
    :type (or null integer)
    :initform nil
    :documentation "Number of crew agents."))
  "Represents a Gas Town rig.
Combines fields from both `gt status --json' (agents list) and
`gt rig list --json' (status, witness, refinery counts).")

(defun gastown-rig-data-from-json (json)
  "Create a `gastown-rig' object from JSON alist (gt status --json format).
The agents array is converted to a list of `gastown-agent' objects."
  (when json
    (gastown-rig-data
     :name (alist-get 'name json)
     :agents (mapcar #'gastown-agent-from-json
                     (gastown-types--json-list (alist-get 'agents json))))))

(defun gastown-rig-data-info-from-json (json)
  "Create a `gastown-rig' object from JSON alist (gt rig list --json format)."
  (when json
    (gastown-rig-data
     :name (alist-get 'name json)
     :status (alist-get 'status json)
     :witness (alist-get 'witness json)
     :refinery (alist-get 'refinery json)
     :polecats (alist-get 'polecats json)
     :crew (alist-get 'crew json))))

(defun gastown-rig-data-to-alist (obj)
  "Convert OBJ (gastown-rig-data) to alist."
  `((name . ,(oref obj name))
    (agents . ,(mapcar #'gastown-agent-to-alist (oref obj agents)))
    (status . ,(oref obj status))
    (witness . ,(oref obj witness))
    (refinery . ,(oref obj refinery))
    (polecats . ,(oref obj polecats))
    (crew . ,(oref obj crew))))

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

(provide 'gastown-types)
;;; gastown-types.el ends here
