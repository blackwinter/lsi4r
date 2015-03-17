#--
###############################################################################
#                                                                             #
# lsi4r -- Latent semantic indexing for Ruby                                  #
#                                                                             #
# Copyright (C) 2014-2015 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
#                                                                             #
# lsi4r is free software; you can redistribute it and/or modify it under the  #
# terms of the GNU Affero General Public License as published by the Free     #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# lsi4r is distributed in the hope that it will be useful, but WITHOUT ANY    #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with lsi4r. If not, see <http://www.gnu.org/licenses/>.               #
#                                                                             #
###############################################################################
#++

require 'forwardable'

class Lsi4R

  class Doc

    include Enumerable

    extend Forwardable

    TOKEN_RE = %r{\s+}

    class << self

      attr_reader :transform

      def transform=(transform)
        method = :transformed_vector

        @transform = case transform ||= :raw
          when Symbol, String
            alias_method(method, "#{transform}_vector")
            transform.to_sym
          when Proc, UnboundMethod
            define_method(method, transform)
            transform.to_s
          else
            raise TypeError, "wrong argument type #{transform.class} " <<
                             '(expected Symbol/String or Proc/UnboundMethod)'
        end
      end

    end

    def initialize(key, value, list, freq)
      @key, @list, @freq, @total, @map = key, list, freq, 1, hash = Hash.new(0)

      value.is_a?(Hash) ?
        value.each { |k, v| hash[i = list[k]] = v; freq[i] += 1 } :
        build_hash(value, list, hash).each_key { |i| freq[i] += 1 }

      self.vector = raw_vector
    end

    attr_reader :key, :vector, :norm

    def_delegators :@map, :each, :include?

    def_delegator :raw_vector, :sum, :size

    def raw_vector(size = @list.size, *)
      vec = GSL::Vector.calloc(size)
      each { |k, v| vec[k] = v }
      vec
    end

    # TODO: "first-order association transform" ???
    def foat_vector(*args)
      vec, q = raw_vector(*args), 0
      return vec unless (s = vec.sum) > 1

      vec.each { |v| q -= (w = v / s) * Math.log(w) if v > 0 }
      vec.map { |v| Math.log(v + 1) / q }
    end

    def tfidf_vector(*args)
      vec, f = raw_vector(*args), @freq
      s, d = vec.sum, @total = args.fetch(1, @total).to_f

      vec.enum_for(:map).with_index { |v, i|
        v > 0 ? Math.log(d / f[i]) * v / s : v }
    end

    self.transform = DEFAULT_TRANSFORM

    def vector=(vec)
      @vector, @norm = vec, vec.normalize
    end

    def inspect
      '%s@%p/%d' % [self.class, key, size]
    end

    private

    def build_hash(value, list, hash)
      build_enum(value).each { |i| hash[list[i]] += 1 }
      hash
    end

    def build_enum(value, re = TOKEN_RE)
      value = value.read if value.respond_to?(:read)
      value = value.split(re) if value.respond_to?(:split)
      value
    end

  end

end
