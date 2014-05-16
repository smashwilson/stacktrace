# Stack traces shared among several specs.

module.exports =
  RUBY_TRACE: """
              /home/smash/tmp/tracer/dir/file1.rb:3:in `innerfunction': Oh shit (RuntimeError)
                from /home/smash/tmp/tracer/otherdir/file2.rb:5:in `outerfunction'
                from entry.rb:7:in `toplevel'
                from entry.rb:10:in `<main>'
              """
