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
                 (username . "testuser")
                 (unread_mail . 2)))
    (daemon . ((running . t) (pid . 12345)))
    (dolt . ((running . t) (pid . 23456) (port . 3307)
             (data_dir . "/tmp/gt-test/.dolt-data")))
    (tmux . ((socket . "gt") (running . t) (session_count . 5)))
    (agents . [((name . "mayor") (address . "mayor/") (session . "hq-mayor")
                (role . "coordinator") (running . t) (has_work . :json-false)
                (unread_mail . 0))
               ((name . "patrol") (address . "gastown_el/patrol") (session . "ge-patrol")
                (role . "polecat") (running . t) (has_work . t)
                (unread_mail . 3))])
    (rigs . [((name . "beads_el")
              (polecats . ["jasper" "obsidian"])
              (crews . ["roman"])
              (polecat_count . 2)
              (crew_count . 1)
              (has_witness . t)
              (has_refinery . t))]))
  "Sample status data for tests.")

;;; Mode Tests

(ert-deftest gastown-status-buffer-test-mode-defined ()
  "Test that gastown-status-mode is defined."
  (should (fboundp 'gastown-status-mode)))

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

;;; Rendering Tests

(ert-deftest gastown-status-buffer-test-render-town-section ()
  "Test that rendering inserts town name."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Town" nil t))
    (goto-char (point-min))
    (should (search-forward "gt" nil t))))

(ert-deftest gastown-status-buffer-test-render-location ()
  "Test that rendering inserts location."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "/tmp/gt-test" nil t))))

(ert-deftest gastown-status-buffer-test-render-overseer ()
  "Test that rendering inserts overseer info."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Test User" nil t))
    (goto-char (point-min))
    (should (search-forward "testuser" nil t))))

(ert-deftest gastown-status-buffer-test-render-services-section ()
  "Test that rendering inserts Services section."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Services" nil t))))

(ert-deftest gastown-status-buffer-test-render-daemon-status ()
  "Test that rendering shows daemon status."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Daemon" nil t))))

(ert-deftest gastown-status-buffer-test-render-dolt-status ()
  "Test that rendering shows dolt status."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Dolt" nil t))))

(ert-deftest gastown-status-buffer-test-render-dolt-data-dir ()
  "Test that rendering includes dolt data directory."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "/tmp/gt-test/.dolt-data" nil t))))

(ert-deftest gastown-status-buffer-test-render-tmux-status ()
  "Test that rendering shows tmux status."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Tmux" nil t))))

(ert-deftest gastown-status-buffer-test-render-agents-section ()
  "Test that rendering inserts Agents section."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Agents" nil t))))

(ert-deftest gastown-status-buffer-test-render-agent-name ()
  "Test that rendering includes agent names."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "mayor" nil t))))

(ert-deftest gastown-status-buffer-test-render-agent-role ()
  "Test that rendering includes agent roles."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "coordinator" nil t))))

(ert-deftest gastown-status-buffer-test-render-rigs-section ()
  "Test that rendering inserts Rigs section."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "Rigs" nil t))))

(ert-deftest gastown-status-buffer-test-render-rig-name ()
  "Test that rendering includes rig names."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "beads_el" nil t))))

(ert-deftest gastown-status-buffer-test-render-polecat-names ()
  "Test that rendering lists polecat names."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "jasper" nil t))
    (goto-char (point-min))
    (should (search-forward "obsidian" nil t))))

(ert-deftest gastown-status-buffer-test-render-crew-names ()
  "Test that rendering lists crew names."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (goto-char (point-min))
    (should (search-forward "roman" nil t))))

(ert-deftest gastown-status-buffer-test-render-point-at-top ()
  "Test that point is at buffer top after rendering."
  (with-temp-buffer
    (gastown-status-mode)
    (gastown-status--render gastown-status-buffer-test--sample-data)
    (should (= 1 (point)))))

;;; Method Override Test

(ert-deftest gastown-status-buffer-test-method-override ()
  "Test that gastown-command-status has execute-interactive override."
  (require 'gastown-command-status)
  (should (cl-find-method
           #'gastown-command-execute-interactive
           '()
           '(gastown-command-status))))

(provide 'gastown-status-buffer-test)
;;; gastown-status-buffer-test.el ends here
