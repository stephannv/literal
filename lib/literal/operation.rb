# frozen_string_literal: true

class Literal::Operation
	extend Literal::Types
	extend Literal::Schema

	class << self
		def call(...) = new(...).call

		def attribute(name, type)
			__schema__[name] = type

			class_eval <<~RUBY, __FILE__, __LINE__ + 1
				# frozen_string_literal: true

				def initialize(#{
					__schema__.map { |n, t|
						"#{n}: #{t.nil? ? 'nil' : ''}"
					}.join(', ')
				})
					@__schema__ = self.class.__schema__

					#{
						__schema__.each_key.map { |n|
							"raise ::Literal::TypeError unless @__schema__[:#{n}] === #{n}"
						}.join("\n")
					}

					#{
						__schema__.each_key.map { |n|
							"@#{n} = #{n}"
						}.join("\n")
					}
				end
			RUBY

			name
		end
	end
end