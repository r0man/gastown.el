;;; gastown-status-buffer-test.el --- Tests for gastown-status-buffer -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; ERT tests for the gastown-status-buffer module.

;;; Code:

(require 'ert)
(require 'gastown-status-buffer)

;;; Test Data

(defconst gastown-status-buffer-test--sample-data
  `((name . "gt")
    (location . "/tmp/gt-test")
    (overseer . ((name . "Test User")
                 (email . "test@example.com")
                 (username . "testuser")
                 (unread_mail . 2)))
    (daemon . ((running . t) (pid . 12345)))
    (dolt . ((running . t) (pid . 23456) (port . 3307)
             (data_dir . "/tmp/gt-test/.dolt-data")))
    (tmux . ((socket . "gt") (socket_path . "/tmp/tmux-gt")
             (running . t) (pid . 34567) (session_count . 5)))
    (agents . [((name . "mayor") (address . "mayor/") (session . "hq-mayor")
                (role . "coordinator") (running . t) (has_work . :json-false)
                (unread_mail . 0) (agent_info . "claude"))
               ((name . "deacon") (address . "hq-deacon") (session . "hq-deacon")
                (role . "health-check") (running . t) (has_work . :json-false)
                (unread_mail . 3) (agent_info . "claude"))])
    (rigs . [((name . "beads_el")
              (polecat_count . 2)
              (crew_count . 1)
              (has_witness . t)
              (has_refinery . t)
              (agents . [((name . "witness") (role . "witness") (running . t)
                          (unread_mail . 0) (agent_info . "claude")
                          (session . "be-witness"))
                         ((name . "refinery") (role . "refinery") (running . t)
                          (unread_mail . 0) (agent_info . "claude")
                          (session . "be-refinery"))
                         ((name . "roman") (role . "crew") (running . :json-false)
                          (unread_mail . 0) (agent_info . "claude/sonnet")
                          (session . "be-crew-roman"))
                         ((name . "jasper") (role . "polecat") (running . t)
                          (unread_mail . 0) (agent_info . "claude")
                          (session . "be-jasper"))
                         ((name . "obsidian") (role . "polecat") (running . :json-false)
                          (unread_mail . 0) (agent_info . "claude/sonnet")
                          (session . "be-obsidian"))]))]))
  "Sample status data for tests.")

;;; Mode Tests

(ert-deftest gastown-status-buffer-test-mode-defined ()
  "Test that gastown-status-mode is defined."
  (should (fboundp 'gastown-status-mode)))

(ert-deftest gastown-status-buffer-test-mode-derives-from-magit-section ()
  "gastown-status-mode must derive from magit-section-mode."
  (should (get 'gastown-status-mode 'derived-mode-parent))
  (with-temp-buffer
    (gastown-status-mode)
    (should (derived-mode-p 'magit-section-mode))))

;;; Section Hook Tests

(ert-deftest gastown-status-buffer-test-sections-hook-defined ()
  "gastown-status-sections-hook defcustom must be defined."
  (should (boundp 'gastown-status-sections-hook)))

(ert-deftest gastown-status-buffer-test-sections-hook-default-functions ()
  "gastown-status-sections-hook default must include the three insert functions."
  (should (memq #'gastown-insert-services gastown-status-sections-hook))
  (should (memq #'gastown-insert-global-agents gastown-status-sections-hook))
  (should (memq #'gastown-insert-rigs gastown-status-sections-hook)))

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

;;; Visit Function Tests

(ert-deftest gastown-status-buffer-test-visit-section-defined ()
  "gastown-status-visit-section interactive function must be defined."
  (should (fboundp 'gastown-status-visit-section)))

(ert-deftest gastown-status-buffer-test-keymap-ret-visit ()
  "RET must be bound to gastown-status-visit-section."
  (should (eq #'gastown-status-visit-section
              (lookup-key gastown-status-mode-map (kbd "RET")))))

(ert-deftest gastown-status-buffer-test-buffer-name-constant ()
  "Test that buffer name constant is defined and correct."
  (should (boundp 'gastown-status-buffer-name))
  (should (equal "*gastown-status*" gastown-status-buffer-name)))

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
