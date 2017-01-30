require 'parallel'
require 'benchmark'

class Text
  attr_reader :content
  def initialize(content)
    @content = content
  end

  def +(other)
    Text.new(self.content + " " + other.content)
  end

  def ==(other)
    self.content == other.content
  end
end

def word_count(text)
  text.content.split(' ').length
end


n = 2_000_000
texts = [ Text.new("text " * n), Text.new("other " * n), Text.new("wow " * n) ]

Benchmark.bmbm(20) do |x|
  x.report("reduce text") do
    word_count(texts.reduce(&:+))
  end
  x.report("map and reduce") do
    texts.map { |t| word_count(t) }.reduce(&:+)
  end
  x.report("parallel map in threads") do
    Parallel.map(texts, in_threads: 3) { |text| word_count(text) }.reduce(&:+)
  end
  x.report("parallel map in processes") do
    Parallel.map(texts, in_processes: 3) { |text| word_count(text) }.reduce(&:+)
  end
end
