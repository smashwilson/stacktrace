# Stack traces shared among several specs.

module.exports =
  RUBY:
    FUNCTION: """
              /home/smash/samples/tracer/otherdir/file2.rb:6:in `block in outerfunction': whoops (RuntimeError)
                from /home/smash/samples/tracer/dir/file1.rb:3:in `innerfunction'
                from /home/smash/samples/tracer/otherdir/file2.rb:5:in `outerfunction'
                from /home/smash/samples/tracer/entry.rb:7:in `toplevel'
                from /home/smash/samples/tracer/entry.rb:10:in `<main>'
              """
