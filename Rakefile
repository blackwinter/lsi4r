require_relative 'lib/lsi4r/version'

begin
  require 'hen'

  Hen.lay! {{
    gem: {
      name:         %q{lsi4r},
      version:      Lsi4R::VERSION,
      summary:      %q{Latent semantic indexing for Ruby.},
      description:  %q{LSI processing for Ruby.},
      author:       %q{Jens Wille},
      email:        %q{jens.wille@gmail.com},
      license:      %q{AGPL-3.0},
      homepage:     :blackwinter,
      dependencies: { gsl: '~> 2.1' },

      required_ruby_version: '>= 1.9.3'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
