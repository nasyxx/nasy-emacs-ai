;;; nasy-emacs-ai.el --- Nasy's Emacs AI features    -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Nasy

;; Author: Nasy <nasyxx@gmail.com>
;; Package-Requires: ((emacs "28.1") (openai "0.1.0") (spinner "1.7.4") (let-alist "1.0.6"))
;; Keywords: comm, tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Nasy's Emacs AI features.

;;; Code:

(require 'openai)


(defgroup nasy-ai nil
  "Nasy's Emacs AI features."
  :prefix "nasy-ai-"
  :group 'comm)


(defcustom nasy-ai-show-function #'nasy-ai-show-in-sidewindow
  "Function to show AI result."
  :type 'function
  :group 'nasy-ai)


(defcustom nasy-ai-name "<AI>"
  "Buffer to show AI result."
  :type 'string
  :group 'nasy-ai)


(defcustom nasy-ai-buffer " *Nasy AI*"
  "Buffer to show AI result."
  :type 'string
  :group 'nasy-ai)


(defcustom nasy-ai-model "gpt-3.5-turbo"
  "Model for openai."
  :type 'string
  :group 'nasy-ai)


(defcustom nasy-ai-sidewindow-parametrs
  '((side . bottom)
    (slot . 0)
    (window-height . fit-window-to-buffer)
    (window-weight . fit-window-to-buffer)
    (cursor-type . nil))
  "Parameters for side window."
  :type 'list
  :group 'nasy-ai)


(defun nasy-ai-openai-chat-parse (data)
  "Get content from DATA alist.

 DATA:
 ((id . \"chatcmpl-xxxx\")
  (object . \"chat.completion\")
  (created . 1680288868)
  (model . \"gpt-3.5-turbo-0301\")
  (usage
   (prompt_tokens . 9)
   (completion_tokens . 9)
   (total_tokens . 18))
  (choices .
           [((message
              (role . \"assistant\")
              (content . \"XXX\"))
             (finish_reason . \"stop\")
             (index . 0))]))"
  (let-alist data
    (let-alist (aref .choices 0)
      .message.content)))


(defun nasy-ai-openai-chat-create (prompt msg)
  "Create a chat completion for opneai wih system PROMPT and user MSG."
  `[(("role" . "system") ("content" . ,prompt))
    (("role" . "user") ("content" . ,msg))])


;;;###autoload
(defun nasy-ai-tozh (msg)
  "Translate MSG to Chinese."
  (interactive "MMSG: ")
  (openai-chat
   (nasy-ai-openai-chat-create "翻译为中文" msg)
   (lambda (data) (funcall nasy-ai-show-function (nasy-ai-openai-chat-parse data)))
   :model nasy-ai-model))


;;;###autoload
(defun nasy-ai-toen (msg)
  "Translate MSG to Engilsh."
  (interactive "MMSG: ")
  (openai-chat
   (nasy-ai-openai-chat-create "Translate to english" msg)
   (lambda (data) (funcall nasy-ai-show-function (nasy-ai-openai-chat-parse data)))
   :model nasy-ai-model))


;;;###autoload
(defun nasy-ai-tozh-at-point (start end)
  "Translate region from START to END to Chinese."
  (interactive "r\nP")
  (message "%s %s %s %s" start end arg msg)
  (nasy-ai-tozh (buffer-substring-no-properties start end)))


;;;###autoload
(defun nasy-ai-toen-at-point (start end)
  "Translate region from START to END to English."
  (interactive "r")
  (nasy-ai-toen (buffer-substring-no-properties start end)))


;;;###autoload
(defun nasy-ai-pdf-tozh-at-point ()
  "Translate PDF region to Chinese."
  (interactive)
  (when (functionp 'pdf-view-active-region-text)
    (let ((text (pdf-view-active-region-text)))
      (nasy-ai-tozh (car text)))))


(defun nasy-ai-show-in-message (msg)
  "Show MSG in message."
  (message "%s" msg))


(defun nasy-ai-show-in-sidewindow (msg)
  "Show MSG in side window."
  (let ((buffer (get-buffer-create nasy-ai-buffer)))
    (with-current-buffer buffer
      (read-only-mode -1)
      (erase-buffer)
      (setq-local cursor-type nil)
      (insert nasy-ai-name ": ")
      (insert msg)
      (nasy-ai-sidewindow-mode 1))
    (nasy-ai-show-buffer buffer)))


;;;###autoload
(defun nasy-ai-show-buffer (&optional buffer)
  "Nasy AI show BUFFER."
  (interactive)
  (display-buffer-in-side-window
   (or buffer (get-buffer-create nasy-ai-buffer))
   nasy-ai-sidewindow-parametrs))


;;;###autoload
(defun nasy-ai-hide-buffer ()
  "Nasy AI hide buffer."
  (interactive)
  (delete-window (get-buffer-window nasy-ai-buffer)))


;;;###autoload
(define-minor-mode nasy-ai-sidewindow-mode
  "A minor mode named 'nasy-ai-sidewindow-mode'."
  :lighter " Nasy-AI"   ; Mode-line indicator
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "q") 'quit-window)
            map)
  ;; Mode body
  (if nasy-ai-sidewindow-mode
      (progn
        ;; Actions to perform when the mode is enabled
        (read-only-mode 1))
    ;; Actions to perform when the mode is disabled
    (read-only-mode -1)))


(provide 'nasy-emacs-ai)
;;; nasy-emacs-ai.el ends here
