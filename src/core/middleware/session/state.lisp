#|
  This file is a part of Clack package.
  URL: http://github.com/fukamachi/clack
  Copyright (c) 2011 Eitarow Fukamachi <e.arrows@gmail.com>

  Clack is freely distributable under the LLGPL License.
|#

(clack.util:namespace clack.session.state
  (:use :cl
        :anaphora)
  (:import-from :clack.util
                :generate-random-id)
  (:import-from :cl-ppcre :scan)
  (:export :session-key
           :sid-generator
           :sid-validator))

(cl-syntax:use-syntax :annot)

@export
(defclass <clack-session-state> ()
     ((session-key :type keyword
                   :initarg :session-key
                   :initform :clack.session
                   :accessor session-key)
      (sid-generator :type function
                     :initarg :sid-generator
                     :initform
                     #'(lambda (&rest args)
                         @ignore args
                         (clack.util:generate-random-id))
                     :accessor sid-generator)
      (sid-validator :type function
                     :initarg :sid-validator
                     :initform
                     #'(lambda (sid)
                         (not (null (ppcre:scan "\\A[0-9a-f]{40}\\Z" sid))))
                     :accessor sid-validator)))

@export
(defmethod expire ((this <clack-session-state>)
                   id res &optional options)
  @ignore (this id res options))

@export
(defmethod session-id ((this <clack-session-state>) env)
  (getf env (session-key this)))

@export
(defmethod valid-sid-p ((this <clack-session-state>) id)
  (funcall (sid-validator this) id))

@export
(defmethod extract-id ((this <clack-session-state>) env)
  (aand (session-id this env)
        (valid-sid-p this it)
        it))

@export
(defmethod generate-id ((this <clack-session-state>) &rest args)
  (apply (sid-generator this) args))

@export
(defmethod finalize ((this <clack-session-state>) id res options)
  @ignore (this id options)
  res)

(doc:start)

@doc:NAME "
Clack.Session.State - Basic parameter-based session state.
"

@doc:DESCRIPTION "
Clack.Session.State maintains session state by passing the session through the request params. Usually you wouldn't use this because this cannot keep session through each HTTP request. This is just for creating new session state manager.
"

@doc:AUTHOR "
Eitarow Fukamachi (e.arrows@gmail.com)
"

@doc:SEE "
* Clack.Middleware.Session
"
