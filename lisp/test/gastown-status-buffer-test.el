;;; gastown-status-buffer-test.el --- Tests for gastown-status-buffer -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for the gastown-status-buffer module (vui.el based).

;;; Code:

(require 'ert)
(require 'gastown-status-buffer)
(require 'gastown-types)

;;; Test Data

(defconst gastown-status-buffer-test--sample-data
  (gastown-gt-status
   :name "gt"
   :location "/tmp/gt-test"
   :overseer (gastown-overseer
              :name "Test User"
              :email "test@example.com"
              :unread-mail 2)
   :dnd (gastown-dnd-status
         :enabled nil
         :level "normal"
         :agent "hq-mayor")
   :daemon (gastown-daemon :pid 12345)
   :dolt (gastown-dolt-service
          :pid 23456
          :port 3307
          :data-dir "/tmp/gt-test/.dolt-data")
   :tmux (gastown-tmux-service
          :socket "gt"
          :socket-path "/tmp/tmux-gt"
          :pid 34567
          :session-count 5)
   :agents (list (gastown-agent
                  :name "mayor" :session "hq-mayor"
                  :role "coordinator" :running t
                  :has-work nil :unread-mail 0 :agent-info "claude")
                 (gastown-agent
                  :name "deacon" :session "hq-deacon"
                  :role "health-check" :running t
                  :has-work nil :unread-mail 3 :agent-info "claude"))
   :rigs (list (gastown-rig-data
                :name "beads_el"
                :agents (list
                         (gastown-agent :name "witness" :role "witness" :running t
                                        :unread-mail 0 :agent-info "claude"
                                        :session "be-witness")
                         (gastown-agent :name "refinery" :role "refinery" :running t
                                        :unread-mail 0 :agent-info "claude"
                                        :session "be-refinery")
                         (gastown-agent :name "roman" :role "crew" :running nil
                                        :unread-mail 0 :agent-info "claude/sonnet"
                                        :session "be-crew-roman")
                         (gastown-agent :name "fred" :role "crew" :running t
                                        :unread-mail 0 :agent-info "claude/sonnet"
                                        :session "be-crew-fred")
                         (gastown-agent :name "jasper" :role "polecat" :running t
                                        :unread-mail 0 :agent-info "claude"
                                        :session "be-jasper")
                         (gastown-agent :name "obsidian" :role "polecat" :running nil
                                        :unread-mail 0 :agent-info "claude/sonnet"
                                        :session "be-obsidian")))))
  "Sample status data for tests.")

;;; Mode Tests

(ert-deftest gastown-status-buffer-test-mode-defined ()
  "Test that gastown-status-mode is defined."
  (should (fboundp 'gastown-status-mode)))

(ert-deftest gastown-status-buffer-test-mode-derives-from-vui ()
  "gastown-status-mode must derive from vui-mode."
  (should (get 'gastown-status-mode 'derived-mode-parent))
  (with-temp-buffer
    (gastown-status-mode)
    (should (derived-mode-p 'vui-mode))))

;;; Section Class Tests

(ert-deftest gastown-status-buffer-test-rig-section-class-defined ()
  "gastown-rig-section EIEIO class must exist."
  (should (class-p 'gastown-rig-section)))

(ert-deftest gastown-status-buffer-test-agent-section-class-defined ()
  "gastown-agent-section EIEIO class must exist."
  (should (class-p 'gastown-agent-section)))

(ert-deftest gastown-status-buffer-test-services-section-class-defined ()
  "gastown-services-section EIEIO class must exist."
  (should (class-p 'gastown-services-section)))

(ert-deftest gastown-status-buffer-test-rig-section-has-rig-slot ()
  "gastown-rig-section must have a :rig slot."
  (should (slot-exists-p 'gastown-rig-section 'rig)))

(ert-deftest gastown-status-buffer-test-agent-section-has-agent-slot ()
  "gastown-agent-section must have an :agent slot."
  (should (slot-exists-p 'gastown-agent-section 'agent)))

(ert-deftest gastown-status-buffer-test-agent-section-has-parent-slot ()
  "gastown-agent-section must have a :parent slot."
  (should (slot-exists-p 'gastown-agent-section 'parent)))

(ert-deftest gastown-status-buffer-test-polecat-section-class-defined ()
  "gastown-polecat-section EIEIO class must exist with required slots."
  (should (class-p 'gastown-polecat-section))
  (should (slot-exists-p 'gastown-polecat-section 'polecat))
  (should (slot-exists-p 'gastown-polecat-section 'rig-name))
  (should (slot-exists-p 'gastown-polecat-section 'parent)))

;;; Keymap Tests

(ert-deftest gastown-status-buffer-test-keymap-g-refresh ()
  "Test that 'g' is bound to gastown-status-refresh."
  (should (eq #'gastown-status-refresh
              (lookup-key gastown-status-mode-map "g"))))

(ert-deftest gastown-status-buffer-test-keymap-q-quit ()
  "Test that 'q' is bound to quit-window."
  (should (eq #'quit-window
              (lookup-key gastown-status-mode-map "q"))))

(ert-deftest gastown-status-buffer-test-keymap-w-watch ()
  "Test that 'w' is bound to gastown-status-toggle-watch."
  (should (eq #'gastown-status-toggle-watch
              (lookup-key gastown-status-mode-map "w"))))

(ert-deftest gastown-status-buffer-test-keymap-question-options ()
  "Test that '?' is bound to gastown-status-options."
  (should (eq #'gastown-status-options
              (lookup-key gastown-status-mode-map "?"))))

(ert-deftest gastown-status-buffer-test-gastown-status-bound ()
  "Test that gastown-status is a function that invokes the buffer directly."
  (should (fboundp 'gastown-status)))

(ert-deftest gastown-status-buffer-test-keymap-ret-activate ()
  "Test that RET is bound to gastown-status--activate-button."
  (should (eq #'gastown-status--activate-button
              (lookup-key gastown-status-mode-map (kbd "RET")))))

(ert-deftest gastown-status-buffer-test-activate-button-defined ()
  "Test that gastown-status--activate-button is defined."
  (should (fboundp 'gastown-status--activate-button)))

(ert-deftest gastown-status-buffer-test-buffer-name-constant ()
  "Test that buffer name constant is defined and correct."
  (should (boundp 'gastown-status-buffer-name))
  (should (equal "*gastown-status*" gastown-status-buffer-name)))

;;; Rendering Tests — Town

(ert-deftest gastown-status-buffer-test-render-town ()
  "Render inserts 'Town: gt' header."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Town: gt" nil t))))

(ert-deftest gastown-status-buffer-test-render-location ()
  "Render inserts location on its own line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "/tmp/gt-test" nil t))))

;;; Rendering Tests — Overseer

(ert-deftest gastown-status-buffer-test-render-overseer-name ()
  "Render inserts overseer name."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Test User" nil t))))

(ert-deftest gastown-status-buffer-test-render-overseer-email ()
  "Render inserts overseer email."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "test@example.com" nil t))))

;;; Rendering Tests — DND

(ert-deftest gastown-status-buffer-test-render-dnd-status ()
  "Render includes DND status line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "DND:" nil t))))

(ert-deftest gastown-status-buffer-test-render-dnd-off ()
  "Render shows DND as 'off' when disabled."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "DND: off" nil t))))

(ert-deftest gastown-status-buffer-test-render-dnd-agent ()
  "Render includes DND agent name."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "hq-mayor" nil t))))

(ert-deftest gastown-status-buffer-test-render-dnd-level ()
  "Render includes DND notification level."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "notifications normal" nil t))))

;;; Rendering Tests — Services

(ert-deftest gastown-status-buffer-test-render-services-line ()
  "Render inserts compact Services line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Services:" nil t))))

(ert-deftest gastown-status-buffer-test-render-daemon-in-services ()
  "Render includes daemon in services line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "daemon" nil t))))

(ert-deftest gastown-status-buffer-test-render-dolt-in-services ()
  "Render includes dolt in services line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "dolt" nil t))))

(ert-deftest gastown-status-buffer-test-render-dolt-data-dir ()
  "Render includes dolt data directory."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward ".dolt-data" nil t))))

(ert-deftest gastown-status-buffer-test-render-tmux-in-services ()
  "Render includes tmux in services line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "tmux" nil t))))

;;; Rendering Tests — Global Agents

(ert-deftest gastown-status-buffer-test-render-mayor-agent ()
  "Render includes mayor agent."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "mayor" nil t))))

(ert-deftest gastown-status-buffer-test-render-agent-info ()
  "Render includes agent info in brackets."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "[claude]" nil t))))

(ert-deftest gastown-status-buffer-test-render-running-indicator ()
  "Render includes running indicator (●) for active agents."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "●" nil t))))

;;; Rendering Tests — Rig Sections

(ert-deftest gastown-status-buffer-test-render-rig-separator ()
  "Render includes rig separator line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "beads_el/" nil t))))

(ert-deftest gastown-status-buffer-test-render-polecat-names ()
  "Render lists polecat names in polecats block."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "jasper" nil t))
    (goto-char (point-min))
    (should (search-forward "obsidian" nil t))))

(ert-deftest gastown-status-buffer-test-render-crew-names ()
  "Render lists crew names in crew block."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "roman" nil t))))

(ert-deftest gastown-status-buffer-test-render-polecats-header ()
  "Render shows Polecats group header."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Polecats" nil t))))

(ert-deftest gastown-status-buffer-test-render-crew-header ()
  "Render shows Crew group header."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Crew" nil t))))

(ert-deftest gastown-status-buffer-test-render-point-at-top ()
  "Point is at buffer top after rendering."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should (= 1 (point)))))

;;; Helper Tests

(ert-deftest gastown-status-buffer-test-abbreviate-path-home ()
  "Abbreviate home directory with ~."
  (let ((home (expand-file-name "~")))
    (should (string-prefix-p
             "~"
             (gastown-status--abbreviate-path (concat home "/foo"))))))

(ert-deftest gastown-status-buffer-test-abbreviate-path-non-home ()
  "Non-home paths are returned unchanged."
  (should (string= "/tmp/foo"
                   (gastown-status--abbreviate-path "/tmp/foo"))))

(ert-deftest gastown-status-buffer-test-role-icon-coordinator ()
  "Coordinator role maps to 🎩."
  (should (string= "🎩" (gastown-status--role-icon "coordinator"))))

(ert-deftest gastown-status-buffer-test-role-icon-polecat ()
  "Polecat role maps to 😺."
  (should (string= "😺" (gastown-status--role-icon "polecat"))))

(ert-deftest gastown-status-buffer-test-role-icon-witness ()
  "Witness role maps to 🦉."
  (should (string= "🦉" (gastown-status--role-icon "witness"))))

(ert-deftest gastown-status-buffer-test-running-indicator-running ()
  "Running indicator is ● for running agents."
  (let ((result (gastown-status--running-indicator t)))
    (should (string= "●" result))
    (should (eq 'gastown-status-running (get-text-property 0 'face result)))))

(ert-deftest gastown-status-buffer-test-running-indicator-stopped ()
  "Stopped indicator is ○ for stopped agents."
  (let ((result (gastown-status--running-indicator nil)))
    (should (string= "○" result))
    (should (eq 'gastown-status-stopped (get-text-property 0 'face result)))))

;;; Tmux Command Helper Tests

(ert-deftest gastown-status-buffer-test-tmux-command-default-socket ()
  "tmux-command uses plain tmux for \"default\" socket."
  (should (string= "tmux select-window -t hq-mayor"
                   (gastown-status--tmux-command "hq-mayor" "default"))))

(ert-deftest gastown-status-buffer-test-tmux-command-nil-socket ()
  "tmux-command uses plain tmux when socket is nil."
  (should (string= "tmux select-window -t ge-nux"
                   (gastown-status--tmux-command "ge-nux" nil))))

(ert-deftest gastown-status-buffer-test-tmux-command-named-socket ()
  "tmux-command includes -L flag for a named socket."
  (should (string= "tmux -L gt select-window -t hq-mayor"
                   (gastown-status--tmux-command "hq-mayor" "gt"))))

;;; Agent Button Action Tests

(defun gastown-status-buffer-test--find-button-echo (pattern)
  "Search current buffer for a widget button whose help-echo matches PATTERN.
Returns t when found, nil otherwise.  Call after `gastown-status--render'."
  (let ((found nil))
    (goto-char (point-min))
    (while (and (not found) (< (point) (point-max)))
      (let* ((w (widget-at (point)))
             (echo (when w (widget-get w :help-echo))))
        (when (and echo (string-match-p pattern echo))
          (setq found t)))
      (forward-char 1))
    found))

(ert-deftest gastown-status-buffer-test-agent-button-help-echo ()
  "Running agent row renders a button whose help-echo names the tmux session."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should (gastown-status-buffer-test--find-button-echo "hq-mayor"))))

(ert-deftest gastown-status-buffer-test-polecat-button-help-echo ()
  "Running polecat row renders a button whose help-echo names the tmux session."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should (gastown-status-buffer-test--find-button-echo "be-jasper"))))

(ert-deftest gastown-status-buffer-test-polecat-click-opens-tmux-not-detail ()
  "Clicking a running polecat row opens tmux session, not polecat detail view."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (let ((detail-called nil)
          (terminal-cmd nil))
      (cl-letf (((symbol-function 'gastown-polecat-detail-show)
                 (lambda (&rest _) (setq detail-called t)))
                ((symbol-function 'gastown-command--run-in-terminal)
                 (lambda (cmd &rest _) (setq terminal-cmd cmd) nil)))
        (goto-char (point-min))
        (let ((found nil))
          (while (and (not found) (< (point) (point-max)))
            (let ((w (widget-at (point))))
              (when (and w
                         (let ((echo (widget-get w :help-echo)))
                           (and (stringp echo) (string-match-p "be-jasper" echo))))
                (widget-apply-action w)
                (setq found t)))
            (forward-char 1))))
      (should-not detail-called)
      (should terminal-cmd)
      (should (string-match-p "be-jasper" terminal-cmd)))))

(ert-deftest gastown-status-buffer-test-agent-click-uses-terminal-backend ()
  "Running agent click uses gastown-command--run-in-terminal, not shell-command."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (let ((shell-command-called nil)
          (start-process-called nil)
          (terminal-cmd nil))
      (cl-letf (((symbol-function 'shell-command)
                 (lambda (&rest _) (setq shell-command-called t) ""))
                ((symbol-function 'start-process-shell-command)
                 (lambda (&rest _) (setq start-process-called t) nil))
                ((symbol-function 'gastown-command--run-in-terminal)
                 (lambda (cmd &rest _) (setq terminal-cmd cmd) nil))
                ((symbol-function 'gastown-status--agent-working-dir)
                 (lambda (_session _socket) "/tmp/")))
        ;; Find and activate the button whose help-echo matches "hq-mayor"
        (goto-char (point-min))
        (let ((found nil))
          (while (and (not found) (< (point) (point-max)))
            (let ((w (widget-at (point))))
              (when (and w
                         (let ((echo (widget-get w :help-echo)))
                           (and (stringp echo) (string-match-p "hq-mayor" echo))))
                (widget-apply-action w)
                (setq found t)))
            (forward-char 1))))
      (should-not shell-command-called)
      (should-not start-process-called)
      (should terminal-cmd)
      (should (string-match-p "attach-session" terminal-cmd))
      (should (string-match-p "hq-mayor" terminal-cmd)))))

(ert-deftest gastown-status-buffer-test-show-agent-tmux-function-defined ()
  "gastown-status--show-agent-tmux must be defined."
  (should (fboundp 'gastown-status--show-agent-tmux)))

(ert-deftest gastown-status-buffer-test-show-agent-tmux-calls-terminal ()
  "gastown-status--show-agent-tmux calls gastown-command--run-in-terminal."
  (let ((captured-cmd nil))
    (cl-letf (((symbol-function 'gastown-command--run-in-terminal)
               (lambda (cmd &rest _) (setq captured-cmd cmd) nil))
              ((symbol-function 'gastown-status--agent-working-dir)
               (lambda (_session _socket) "/tmp/")))
      (gastown-status--show-agent-tmux "hq-mayor" nil))
    (should captured-cmd)
    (should (string-match-p "attach-session" captured-cmd))
    (should (string-match-p "hq-mayor" captured-cmd))))

(ert-deftest gastown-status-buffer-test-show-agent-tmux-uses-socket ()
  "gastown-status--show-agent-tmux includes -L socket flag when socket is named."
  (let ((captured-cmd nil))
    (cl-letf (((symbol-function 'gastown-command--run-in-terminal)
               (lambda (cmd &rest _) (setq captured-cmd cmd) nil))
              ((symbol-function 'gastown-status--agent-working-dir)
               (lambda (_session _socket) "/tmp/")))
      (gastown-status--show-agent-tmux "ge-nux" "gt"))
    (should (string-match-p "-L gt" captured-cmd))
    (should (string-match-p "ge-nux" captured-cmd))))

(ert-deftest gastown-status-buffer-test-show-agent-tmux-no-socket-for-default ()
  "gastown-status--show-agent-tmux omits -L when socket is \"default\"."
  (let ((captured-cmd nil))
    (cl-letf (((symbol-function 'gastown-command--run-in-terminal)
               (lambda (cmd &rest _) (setq captured-cmd cmd) nil))
              ((symbol-function 'gastown-status--agent-working-dir)
               (lambda (_session _socket) "/tmp/")))
      (gastown-status--show-agent-tmux "hq-mayor" "default"))
    (should-not (string-match-p "-L" captured-cmd))
    (should (string-match-p "hq-mayor" captured-cmd))))

(ert-deftest gastown-status-buffer-test-show-agent-tmux-uses-provided-dir ()
  "gastown-status--show-agent-tmux passes explicit DIR argument to run-in-terminal."
  (let ((captured-dir nil))
    (cl-letf (((symbol-function 'gastown-command--run-in-terminal)
               (lambda (_cmd _buf-name dir) (setq captured-dir dir) nil)))
      (gastown-status--show-agent-tmux "ge-nux" nil "/home/roman/gt/gastown_el/polecats/nux/gastown_el"))
    (should (equal captured-dir "/home/roman/gt/gastown_el/polecats/nux/gastown_el"))))

(ert-deftest gastown-status-buffer-test-show-agent-tmux-queries-tmux-when-no-dir ()
  "gastown-status--show-agent-tmux queries tmux working dir when DIR is nil."
  (let ((captured-dir nil))
    (cl-letf (((symbol-function 'gastown-command--run-in-terminal)
               (lambda (_cmd _buf dir) (setq captured-dir dir) nil))
              ((symbol-function 'gastown-status--agent-working-dir)
               (lambda (_session _socket) "/home/roman/gt/beads_el/witness/")))
      (let ((default-directory "/some/other/dir/"))
        (gastown-status--show-agent-tmux "be-witness" nil)))
    (should (equal captured-dir "/home/roman/gt/beads_el/witness/"))))

(ert-deftest gastown-status-buffer-test-polecat-click-uses-worktree-dir ()
  "Clicking a running polecat row opens terminal in the polecat's worktree directory."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (let ((captured-dir nil))
      (cl-letf (((symbol-function 'gastown-command--run-in-terminal)
                 (lambda (_cmd _buf-name dir) (setq captured-dir dir) nil)))
        (goto-char (point-min))
        (let ((found nil))
          (while (and (not found) (< (point) (point-max)))
            (let ((w (widget-at (point))))
              (when (and w
                         (let ((echo (widget-get w :help-echo)))
                           (and (stringp echo) (string-match-p "be-jasper" echo))))
                (widget-apply-action w)
                (setq found t)))
            (forward-char 1))))
      (should captured-dir)
      ;; location="/tmp/gt-test", rig="beads_el", polecat="jasper"
      (should (string-match-p "beads_el/polecats/jasper/beads_el" captured-dir)))))

;;; Agent Working Directory Tests

(ert-deftest gastown-status-buffer-test-agent-working-dir-from-tmux ()
  "gastown-status--agent-working-dir queries tmux for pane_current_path."
  (cl-letf (((symbol-function 'shell-command-to-string)
             (lambda (_cmd) "/home/roman/gt/beads_el/witness\n"))
            ((symbol-function 'file-directory-p)
             (lambda (_path) t)))
    (should (equal (gastown-status--agent-working-dir "be-witness" nil)
                   "/home/roman/gt/beads_el/witness/"))))

(ert-deftest gastown-status-buffer-test-agent-working-dir-with-socket ()
  "gastown-status--agent-working-dir uses -L flag for named socket."
  (let ((captured-cmd nil))
    (cl-letf (((symbol-function 'shell-command-to-string)
               (lambda (cmd) (setq captured-cmd cmd) "/tmp\n")))
      (gastown-status--agent-working-dir "hq-mayor" "gt"))
    (should (string-match-p "-L gt" captured-cmd))
    (should (string-match-p "hq-mayor" captured-cmd))))

(ert-deftest gastown-status-buffer-test-agent-working-dir-fallback ()
  "gastown-status--agent-working-dir falls back to default-directory on empty result."
  (let ((default-directory "/fallback/dir/"))
    (cl-letf (((symbol-function 'shell-command-to-string)
               (lambda (_cmd) "")))
      (should (equal (gastown-status--agent-working-dir "bad-session" nil)
                     "/fallback/dir/")))))

;;; Context Detection Tests

(ert-deftest gastown-status-buffer-test-current-section-nil-outside-buffer ()
  "gastown-status-current-section returns nil when no text property at point."
  (with-temp-buffer
    (should (null (gastown-status-current-section)))))

(ert-deftest gastown-status-buffer-test-current-section-reads-text-property ()
  "gastown-status-current-section reads gastown-status-section text property."
  (with-temp-buffer
    (let ((sec (gastown-agent-section :agent (gastown-agent :name "test"))))
      (insert (propertize "line" 'gastown-status-section sec))
      (goto-char (point-min))
      (should (eq sec (gastown-status-current-section))))))

;;; Regression Tests

(ert-deftest gastown-status-buffer-test-services-vnode-dolt-no-nested-list ()
  "Services vnode with dolt renders dolt port without nested-list corruption.
Regression for ge-hc6: (when dolt (list ...)) produced a nested list inside
the outer (list ...), corrupting the vnode tree when apply #\\='vui-hstack
received it as a single argument."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    ;; Dolt port and PID must appear as plain text, not as a list artifact
    (should (search-forward "3307" nil t))
    (goto-char (point-min))
    (should (search-forward "23456" nil t))))

;;; Rig Sort Tests

(ert-deftest gastown-status-buffer-test-rigs-sorted-alphabetically ()
  "Rigs appear in alphabetical order by name regardless of data order."
  (let ((data (gastown-gt-status
               :name "gt"
               :location "/tmp"
               :rigs (list (gastown-rig-data :name "zebra_el" :agents nil)
                           (gastown-rig-data :name "apple_el" :agents nil)
                           (gastown-rig-data :name "mango_el" :agents nil)))))
    (with-temp-buffer
      (gastown-status-mode)
      (gastown-status--render data)
      (let ((apple-pos  (progn (goto-char (point-min))
                               (search-forward "apple_el/" nil t)
                               (point)))
            (mango-pos  (progn (goto-char (point-min))
                               (search-forward "mango_el/" nil t)
                               (point)))
            (zebra-pos  (progn (goto-char (point-min))
                               (search-forward "zebra_el/" nil t)
                               (point))))
        (should (< apple-pos mango-pos))
        (should (< mango-pos zebra-pos))))))

;;; Face Attribute Tests

(ert-deftest gastown-status-buffer-test-link-face-no-underline ()
  "gastown-status-link face must explicitly suppress underline from link inherit."
  ;; The face-attribute with t (resolve-aliases=t, inherit=t) gives the effective value.
  ;; We want :underline nil to be set directly on the face so the link underline is suppressed.
  (let ((underline (face-attribute 'gastown-status-link :underline)))
    ;; Direct attribute on face should be nil (explicitly suppressed), not 'unspecified
    (should (null underline))))

;;; Method Override Test

(ert-deftest gastown-status-buffer-test-method-override ()
  "gastown-command-status has execute-interactive override."
  (require 'gastown-command-status)
  (should (cl-find-method
           #'gastown-command-execute-interactive
           '()
           '(gastown-command-status))))

;;; Navigation Keymap Tests

(ert-deftest gastown-status-buffer-test-keymap-n-next-item ()
  "Test that 'n' is bound to gastown-status-next-item."
  (should (eq #'gastown-status-next-item
              (lookup-key gastown-status-mode-map "n"))))

(ert-deftest gastown-status-buffer-test-keymap-p-prev-item ()
  "Test that 'p' is bound to gastown-status-prev-item."
  (should (eq #'gastown-status-prev-item
              (lookup-key gastown-status-mode-map "p"))))

(ert-deftest gastown-status-buffer-test-keymap-N-next-section ()
  "Test that 'N' is bound to gastown-status-next-section."
  (should (eq #'gastown-status-next-section
              (lookup-key gastown-status-mode-map "N"))))

(ert-deftest gastown-status-buffer-test-keymap-P-prev-section ()
  "Test that 'P' is bound to gastown-status-prev-section."
  (should (eq #'gastown-status-prev-section
              (lookup-key gastown-status-mode-map "P"))))

(ert-deftest gastown-status-buffer-test-keymap-tab-action ()
  "Test that TAB is bound to gastown-status-tab-action."
  (should (eq #'gastown-status-tab-action
              (lookup-key gastown-status-mode-map (kbd "TAB")))))

(ert-deftest gastown-status-buffer-test-keymap-d-dired ()
  "Test that 'd' is bound to gastown-status-dired-at-point."
  (should (eq #'gastown-status-dired-at-point
              (lookup-key gastown-status-mode-map "d"))))

;;; Navigation Functional Tests

(ert-deftest gastown-status-buffer-test-next-item-moves-to-item ()
  "gastown-status-next-item moves point to the next item with a section property."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (gastown-status-next-item)
    ;; Point should now be on a line with a gastown-status-section property
    (should (gastown-status--find-section-on-line))))

(ert-deftest gastown-status-buffer-test-prev-item-moves-to-item ()
  "gastown-status-prev-item moves point to a previous item line."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-max))
    (gastown-status-prev-item)
    (should (gastown-status--find-section-on-line))))

(ert-deftest gastown-status-buffer-test-next-item-advances ()
  "Successive gastown-status-next-item calls visit distinct lines."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (gastown-status-next-item)
    (let ((first-line (line-number-at-pos)))
      (gastown-status-next-item)
      (should (> (line-number-at-pos) first-line)))))

(ert-deftest gastown-status-buffer-test-next-section-reaches-rig ()
  "gastown-status-next-section stops at a rig section header."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (gastown-status-next-section)
    (should (gastown-rig-section-p (gastown-status--find-section-on-line)))))

;;; Progressive Disclosure Tests

(ert-deftest gastown-status-buffer-test-expanded-items-initially-nil ()
  "gastown-status--expanded-items is nil in a fresh buffer."
  (with-temp-buffer
    (gastown-status-mode)
    (should (null gastown-status--expanded-items))))

(ert-deftest gastown-status-buffer-test-toggle-expanded-adds-key ()
  "gastown-status--toggle-expanded adds key to hash on first call."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--toggle-expanded "agent:mayor")
    (should (gastown-status--item-expanded-p "agent:mayor"))))

(ert-deftest gastown-status-buffer-test-toggle-expanded-removes-key ()
  "gastown-status--toggle-expanded removes key on second call."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--toggle-expanded "agent:mayor")
    (gastown-status--toggle-expanded "agent:mayor")
    (should-not (gastown-status--item-expanded-p "agent:mayor"))))

(ert-deftest gastown-status-buffer-test-expanded-item-shows-detail ()
  "Expanded agent shows detail block (role, session) in rendered buffer."
  (with-temp-buffer
    (gastown-status-mode)
    (setq gastown-status--expanded-items (make-hash-table :test 'equal))
    (puthash "polecat:beads_el/jasper" t gastown-status--expanded-items)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    ;; The expanded polecat should show its role in the detail block
    (should (search-forward "polecat" nil t))))

(ert-deftest gastown-status-buffer-test-collapsed-item-no-detail ()
  "Non-expanded agent row does not show detail block."
  (with-temp-buffer
    (gastown-status-mode)
    ;; No items expanded
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    ;; Detail prefix "↳" should not appear
    (should-not (search-forward "↳" nil t))))

(ert-deftest gastown-status-buffer-test-agent-detail-vnode-defined ()
  "gastown-status--agent-detail-vnode is defined."
  (should (fboundp 'gastown-status--agent-detail-vnode)))

(ert-deftest gastown-status-buffer-test-agent-detail-shows-role ()
  "Expanded agent row shows role field in detail block."
  (with-temp-buffer
    (gastown-status-mode)
    ;; Expand mayor (role = coordinator)
    (setq gastown-status--expanded-items (make-hash-table :test 'equal))
    (puthash "agent:mayor" t gastown-status--expanded-items)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "↳ role:" nil t))))

(ert-deftest gastown-status-buffer-test-agent-detail-shows-hook ()
  "Expanded polecat row shows hook bead when agent has work."
  (let* ((polecat-with-hook
          (gastown-agent :name "worker" :role "polecat"
                         :session "test-worker" :running t
                         :has-work t :work-title "Fix bug" :hook-bead "ge-abc"
                         :agent-info "claude" :unread-mail 0))
         (test-data
          (gastown-gt-status
           :name "gt" :location "/tmp"
           :rigs (list (gastown-rig-data
                        :name "test_rig"
                        :agents (list polecat-with-hook))))))
    (with-temp-buffer
      (gastown-status-mode)
      (setq gastown-status--expanded-items (make-hash-table :test 'equal))
      (puthash "polecat:test_rig/worker" t gastown-status--expanded-items)
      (gastown-status--render test-data)
      (goto-char (point-min))
      (should (search-forward "ge-abc" nil t)))))

;;; Polecat Detail Integration Tests

(ert-deftest gastown-status-buffer-test-polecat-detail-at-point-defined ()
  "gastown-status-polecat-detail-at-point must be defined."
  (should (fboundp 'gastown-status-polecat-detail-at-point)))

(ert-deftest gastown-status-buffer-test-keymap-i-polecat-detail ()
  "Test that 'i' is bound to gastown-status-polecat-detail-at-point."
  (should (eq #'gastown-status-polecat-detail-at-point
              (lookup-key gastown-status-mode-map "i"))))

(ert-deftest gastown-status-buffer-test-polecat-detail-calls-show ()
  "gastown-status-polecat-detail-at-point calls gastown-polecat-detail-show."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (let ((detail-polecat nil)
          (detail-rig nil))
      (cl-letf (((symbol-function 'gastown-polecat-detail-show)
                 (lambda (p r &optional _sock)
                   (setq detail-polecat p detail-rig r)
                   nil)))
        ;; Find the jasper polecat button in beads_el
        (goto-char (point-min))
        (let ((found nil))
          (while (and (not found) (< (point) (point-max)))
            (let ((sec (gastown-status-current-section)))
              (when (and (gastown-polecat-section-p sec)
                         (equal "jasper" (oref (oref sec polecat) name)))
                (gastown-status-polecat-detail-at-point)
                (setq found t)))
            (forward-char 1))))
      (should detail-polecat)
      (should (equal "jasper" (oref detail-polecat name)))
      (should (equal "beads_el" detail-rig)))))

(ert-deftest gastown-status-buffer-test-polecat-detail-error-on-non-polecat ()
  "gastown-status-polecat-detail-at-point signals error when not on polecat."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    ;; Go to start — no polecat section there
    (goto-char (point-min))
    (should-error (gastown-status-polecat-detail-at-point)
                  :type 'user-error)))

;;; Dired Integration Tests

(ert-deftest gastown-status-buffer-test-dired-at-point-defined ()
  "gastown-status-dired-at-point is defined."
  (should (fboundp 'gastown-status-dired-at-point)))

(ert-deftest gastown-status-buffer-test-dired-rig-opens-rig-dir ()
  "gastown-status-dired-at-point opens dired on rig root dir for rig section."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    ;; Navigate to the rig section header
    (goto-char (point-min))
    (gastown-status-next-section)
    (let ((dired-path nil))
      (cl-letf (((symbol-function 'dired)
                 (lambda (path) (setq dired-path path) nil))
                ((symbol-function 'file-directory-p)
                 (lambda (_) t)))
        (gastown-status-dired-at-point))
      (should dired-path)
      (should (string-match-p "beads_el" dired-path)))))

;;; find-section-on-line Tests

(ert-deftest gastown-status-buffer-test-find-section-on-line-nil-on-blank ()
  "gastown-status--find-section-on-line returns nil on a blank line."
  (with-temp-buffer
    (insert "\n\n")
    (goto-char (point-min))
    (should (null (gastown-status--find-section-on-line)))))

(ert-deftest gastown-status-buffer-test-find-section-on-line-finds-prop ()
  "gastown-status--find-section-on-line finds property anywhere on the line."
  (with-temp-buffer
    (let ((sec (gastown-agent-section :agent (gastown-agent :name "test"))))
      ;; Property starts in the middle of the line
      (insert "  ")
      (insert (propertize "agent-text" 'gastown-status-section sec))
      (insert "\n")
      (goto-char (point-min))
      (should (eq sec (gastown-status--find-section-on-line))))))

;;; Crew Start/Stop Action Tests

(ert-deftest gastown-status-buffer-test-crew-action-function-defined ()
  "gastown-status--crew-action must be defined."
  (should (fboundp 'gastown-status--crew-action)))

(ert-deftest gastown-status-buffer-test-crew-start-button-rendered ()
  "Non-running crew member renders a [start] action button."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should (gastown-status-buffer-test--find-button-echo "Start crew member: roman"))))

(ert-deftest gastown-status-buffer-test-crew-stop-button-rendered ()
  "Running crew member renders a [stop] action button."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should (gastown-status-buffer-test--find-button-echo "Stop crew member: fred"))))

(ert-deftest gastown-status-buffer-test-crew-no-start-for-polecat ()
  "Polecat (non-running) does NOT get a [start] button."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should-not (gastown-status-buffer-test--find-button-echo "Start crew member: obsidian"))))

(ert-deftest gastown-status-buffer-test-crew-start-calls-gt-crew ()
  "Clicking [start] on a stopped crew member calls gt crew start."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (let ((captured-cmd nil))
      (cl-letf (((symbol-function 'make-process)
                 (lambda (&rest args)
                   (setq captured-cmd (plist-get args :command))
                   nil)))
        (goto-char (point-min))
        (let ((found nil))
          (while (and (not found) (< (point) (point-max)))
            (let ((w (widget-at (point))))
              (when (and w
                         (let ((echo (widget-get w :help-echo)))
                           (and (stringp echo)
                                (string-match-p "Start crew member: roman" echo))))
                (widget-apply-action w)
                (setq found t)))
            (forward-char 1))))
      (should captured-cmd)
      (should (member "crew" captured-cmd))
      (should (member "start" captured-cmd))
      (should (member "roman" captured-cmd)))))

(ert-deftest gastown-status-buffer-test-crew-stop-calls-gt-crew ()
  "Clicking [stop] on a running crew member calls gt crew stop."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (let ((captured-cmd nil))
      (cl-letf (((symbol-function 'make-process)
                 (lambda (&rest args)
                   (setq captured-cmd (plist-get args :command))
                   nil)))
        (goto-char (point-min))
        (let ((found nil))
          (while (and (not found) (< (point) (point-max)))
            (let ((w (widget-at (point))))
              (when (and w
                         (let ((echo (widget-get w :help-echo)))
                           (and (stringp echo)
                                (string-match-p "Stop crew member: fred" echo))))
                (widget-apply-action w)
                (setq found t)))
            (forward-char 1))))
      (should captured-cmd)
      (should (member "crew" captured-cmd))
      (should (member "stop" captured-cmd))
      (should (member "fred" captured-cmd)))))

(provide 'gastown-status-buffer-test)
;;; gastown-status-buffer-test.el ends here
