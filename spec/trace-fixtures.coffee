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
  COFFEESCRIPT:
    ERROR: """
           Error: yep
             at asFrame (/home/smash/code/stacktrace/lib/trace-parser.coffee:36:13)
             at t.recognize.emitFrame (/home/smash/code/stacktrace/lib/trace-parser.coffee:95:35)
             at Object.module.exports.recognize (/home/smash/code/stacktrace/lib/parsers/ruby-trace-parser.coffee:19:5)
             at traceParser (/home/smash/code/stacktrace/lib/trace-parser.coffee:93:11)
             at Function.Stacktrace.parse (/home/smash/code/stacktrace/lib/stacktrace.coffee:43:5)
             at [object Object].<anonymous> (/home/smash/code/stacktrace/spec/stacktrace-spec.coffee:9:28)
           """
