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
require 'gsl'

class Lsi4R

  include Enumerable

  extend Forwardable

  DEFAULT_EPSILON   = Float::EPSILON * 10

  DEFAULT_TRANSFORM = :tfidf

  DEFAULT_CUTOFF    = 0.75

  class << self

    def build(items, options = {})
      lsi = new(items)
      lsi if lsi.build(options)
    end

    def each_norm(items, options = {}, build_options = {}, &block)
      lsi = new(items)
      lsi.each_norm(nil, options, &block) if lsi.build(build_options)
    end

  end

  def initialize(items = {})
    reset
    items.each { |k, v| self[k] = v || k }
  end

  def_delegators :@hash, :[], :each, :include?, :key, :keys, :size

  def_delegator  :@hash, :values,    :docs
  def_delegator  :@hash, :values_at, :docs_at

  def_delegator  :@list, :keys, :terms

  alias_method :doc, :[]

  def []=(key, value)
    @hash[key] = Doc.new(key, value, @list, @freq)
  end

  def add(key, value = key)
    self[key] = value
    self
  end

  def <<(value)
    add(value.object_id, value)
  end

  def each_vector(key = nil, norm = true)
    return enum_for(:each_vector, key, norm) unless block_given?

    block = lambda { |doc|
      vec = norm ? doc.norm : doc.vector
      yield doc, vec if vec
    }

    key.nil? ? docs.each(&block) : begin
      doc = self[key] and block[doc]
    end

    self
  end

  # min:: minimum value to consider
  # abs:: minimum absolute value to consider
  # nul:: exclude null values (true or Float)
  # new:: exclude original terms / only yield new ones
  def each_term(key = nil, options = {})
    return enum_for(:each_term, key, options) unless block_given?

    min, abs, nul, new = options.values_at(:min, :abs, :nul, :new)
    nul = DEFAULT_EPSILON if nul == true

    list = @invlist

    each_vector(key, options[:norm]) { |doc, vec|
      vec.enum_for(:each).with_index { |v, i|
        yield doc, list[i], v unless v.nan? ||
                                     (min && v < min) ||
                                     (abs && v.abs < abs) ||
                                     (nul && v.abs < nul) ||
                                     (new && doc.include?(i))
      }
    }
  end

  def each_norm(key = nil, options = {}, &block)
    each_term(key, options.merge(norm: true), &block)
  end

  alias_method :each, :each_norm

  def related(key, num = 5)
    each_vector(key) { |_, vec|
      tmp, del = block_given? ? yield(vec) :
        [sort_by { |_, v| -vec * v.norm.col }.map! { |k,| k }]

      tmp.delete(del || key)

      return tmp[0, num]
    }

    nil
  end

  def related_score(key, num = 5, threshold = 0)
    related(key, num) { |vec|
      [tmp = map { |k, v|
        score = vec * v.norm.col
        [k, score] if score > threshold
      }.compact.sort_by { |_, i| -i }, tmp.assoc(key)]
    }
  end

  def build(options = {})
    build!(docs, @list, options.is_a?(Hash) ?
      options : { cutoff: options }) if size > 1
  end

  def reset
    @hash, @list, @freq, @invlist =
      {}, Hash.new { |h, k| h[k] = h.size }, Hash.new(0), {}

    self
  end

  def inspect
    '%s@%d/%d' % [self.class, size, @list.size]
  end

  def to_a(norm = true)
    (norm ? map { |_, doc| doc.norm.to_a } :
            map { |_, doc| doc.vector.to_a }).transpose
  end

  private

  def build!(docs, list, options)
    Doc.transform = options.fetch(:transform, DEFAULT_TRANSFORM)

    @invlist = list.invert

    # TODO: GSL::ERROR::EUNIMPL: Ruby/GSL error code 24, svd of
    # MxN matrix, M<N, is not implemented (file svd.c, line 61)
    u, v, s = matrix(docs, list.size, size = docs.size).SV_decomp

    (u * reduce(s, options.fetch(:cutoff, DEFAULT_CUTOFF)) * v.trans).
      enum_for(:each_col).with_index { |c, i| docs[i].vector = c.row }

    size
  end

  def matrix(d = docs, m = @list.size, n = d.size)
    x = GSL::Matrix.alloc(m, n)
    d.each_with_index { |i, j| x.set_col(j, i.transformed_vector(m, n)) }
    x
  end

  # k == nil:: keep all
  # k >= 1::   keep this many
  # k < 1::    keep (at most) this proportion
  def reduce(s, k, m = s.size)
    if k && k < m
      k > 0 ? s[k = (k < 1 ? m * k : k).floor, m - k] = 0 : s.set_zero
    end

    s.to_m_diagonal
  end

end

require_relative 'lsi4r/version'
require_relative 'lsi4r/doc'
