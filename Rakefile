require "bundler/gem_tasks"
require "greek_stemmer"

desc "Update the stems of the sample words"
task :update_greek_stemming_sample do

  words = Set.new
  File.open('benchmarks/stemming_sample.txt', 'r').each do |line|
    words << line.strip.split(',').first
  end

  new_data = words.map { |w| [w, GreekStemmer.stem(w)].join(',') }.join("\n")
  File.write('benchmarks/stemming_sample.txt', new_data)
end
