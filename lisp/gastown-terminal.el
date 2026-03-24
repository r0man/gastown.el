;;; gastown-terminal.el --- Terminal utilities for gastown -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026

;;; Commentary:

;; Terminal enhancements for vterm buffers, including mouse wheel
;; forwarding for applications like tmux that enable mouse tracking.

;;; Code:

(defun gastown-terminal--send-mouse-wheel (event button)
  "Send SGR mouse wheel escape sequence for BUTTON at EVENT position.
Falls back to normal scrolling when not in a vterm buffer with a
live process."
  (let* ((pos (event-start event))
         (window (posn-window pos))
         (coords (posn-col-row pos))
         (col (1+ (car coords)))
         (row (1+ (cdr coords))))
    (with-current-buffer (window-buffer window)
      (if-let ((proc (and (derived-mode-p 'vterm-mode)
                          (get-buffer-process (current-buffer)))))
          (when (process-live-p proc)
            (process-send-string proc
                                 (format "\e[<%d;%d;%dM" button col row)))
        (mwheel-scroll event)))))

(defun gastown-terminal-send-mouse-wheel-up (event)
  "Send mouse wheel up to the terminal process."
  (interactive "e")
  (gastown-terminal--send-mouse-wheel event 64))

(defun gastown-terminal-send-mouse-wheel-down (event)
  "Send mouse wheel down to the terminal process."
  (interactive "e")
  (gastown-terminal--send-mouse-wheel event 65))

;;;###autoload
(define-minor-mode gastown-terminal-mouse-mode
  "Forward mouse wheel events to the terminal process.
When enabled, mouse wheel scrolling is sent to the application
running in the terminal (e.g. tmux with mouse mode) instead of
scrolling the Emacs buffer."
  :lighter " TM"
  :keymap (let ((map (make-sparse-keymap)))
            (dolist (dir '(wheel-up wheel-down))
              (let ((fn (intern (format "gastown-terminal-send-mouse-%s"
                                        (symbol-name dir)))))
                (dolist (prefix '(nil double- triple-))
                  (define-key map (vector (intern (concat (when prefix
                                                           (symbol-name prefix))
                                                         (symbol-name dir))))
                              fn))))
            map))

(provide 'gastown-terminal)
;;; gastown-terminal.el ends here
