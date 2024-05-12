# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    NilableHooksType = T.type_alias do
      T.nilable(T::Set[T.proc.void])
    end
  end
end
