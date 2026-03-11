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
  "Running polecat row renders a button whose help-echo references the polecat."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should (gastown-status-buffer-test--find-button-echo "jasper"))))

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

;;; Method Override Test

(ert-deftest gastown-status-buffer-test-method-override ()
  "gastown-command-status has execute-interactive override."
  (require 'gastown-command-status)
  (should (cl-find-method
           #'gastown-command-execute-interactive
           '()
           '(gastown-command-status))))

(provide 'gastown-status-buffer-test)
;;; gastown-status-buffer-test.el ends here
