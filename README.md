# GreekStemmer

A simple Greek stemmer algorithm.

This algorithm is based on this [paper](http://people.dsv.su.se/~hercules/papers/Ntais_greek_stemmer_thesis_final.pdf) from George Ntais.

## Installation

Add this line to your application's Gemfile:

    gem 'greek_stemmer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install greek_stemmer

## Usage

In order to use this stemmer you should normalize input.
Normalization means two things for this algorithm: detone and upcase.

```ruby
  require 'greek_stemmer'

  GreekStemmer.stem("ΠΟΣΟΤΗΤΑ") # => "ΠΟΣΟΤΗΤ"
```

If your input not ready to use, you can do normalizeing in one step

```ruby
  require 'greek_stemmer'

  GreekStemmer.normalize_and_stem("ποσοτητα") # => "ΠΟΣΟΤΗΤ"
```

## References

* [Development of a Stemmer for the Greek Language](http://people.dsv.su.se/~hercules/papers/Ntais_greek_stemmer_thesis_final.pdf)

## Credits

Original work: [bandito](https://github.com/bandito)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/greek_stemmer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Perform changes and run `bundle exec rake update_greek_stemming_sample` to
   update the stemming samples
4. Commit your changes (`git commit -a`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License

greek_stemmer is licensed under MIT License. See [LICENSE](LICENSE.txt) for details.

