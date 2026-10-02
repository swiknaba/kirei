# typed: strict
# frozen_string_literal: true

module Utils
  class MetricTypes < T::Enum
    enums do
      AIRPORTS_SEARCH_TERM = new('airports_search_term')
    end
  end
end
