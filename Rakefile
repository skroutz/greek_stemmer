require "bundler/gem_tasks"
require "greek_stemmer"

desc "Update the stems of the sample words"
task :update_greek_stemming_sample do

  words = Set.new
  File.open("benchmarks/stemming_sample.txt", "r") do |sample|
    while(line = sample.gets)
      word, _ = line.split(",")
      words << word
    end
  end

  File.open("benchmarks/stemming_sample.txt", "w") do |sample|
    words.each do |word|
      sample.puts "#{word},#{GreekStemmer.stem(word)}"
    end
  end
end
