;;; nasy-emacs-ai.el --- Nasy's Emacs AI features    -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Nasy

;; Author: Nasy <nasyxx@gmail.com>
;; Package-Requires: ((emacs "28.1") (openai "0.1.0") (spinner "1.7.4"))
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


(defun nasy-openai-chat-parse (data)
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


(defun nasy-openai-chat-create (prompt msg)
  "Create a chat completion for opneai wih system PROMPT and user MSG."
  `[(("role" . "system") ("content" . ,prompt))
    (("role" . "user") ("content" . ,msg))])


;;;###autoload
(defun nasy-tozh (msg)
  "Translate MSG to Chinese."
  (interactive "MMSG: ")
  (openai-chat
   (nasy-openai-chat-create "翻译为中文" msg)
   (lambda (data) (message "%s" (nasy-openai-chat-parse data)))))


;;;###autoload
(defun nasy-tozh-at-point (start end)
  "Translate region from START to END to Chinese."
  (interactive "r")
  (nasy-tozh (buffer-substring-no-properties start end)))


;;;###autoload
(defun nasy-pdf-tozh-at-point ()
  "Translate PDF region to Chinese."
  (interactive)
  (when (functionp 'pdf-view-active-region-text)
    (let ((text (pdf-view-active-region-text)))
      (nasy-tozh (car text)))))


(provide 'nasy-emacs-ai)
;;; nasy-emacs-ai.el ends here
