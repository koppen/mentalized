---
layout: post
title: 5 ways to run shell commands from Ruby
date: '2010-03-08 12:40:33 +0100'
mt_id: 2029
categories:
- programming
- projects
description: "An overview of different ways to call external commands in Ruby applications. What are the benefits and downsides of each of them."
---
Every so often I have the need to execute a command line application from a Ruby script. And every single time I fail to remember what the different command-executing methods Ruby provides us with do.

This post is primarily a brain dump to aid my failing memory, and it was triggered by an [issue](https://github.com/koppen/redmine_github_hook/issues/issue/2) with my [Redmine Github Hook plugin](https://github.com/koppen/redmine_github_hook) where STDERR messages were not being logged.

The goal of this is to figure out how to run a shell command and capture all its output - both STDOUT and STDERR - so that the output can be used in the calling script.

<!--more-->

## err.rb

The test script I'll be running basically outputs two lines, one on STDOUT, the other on STDERR:

``` ruby
#!/usr/bin/env ruby
puts "out"
STDERR.puts "error"
```


## <a href="http://ruby-doc.org/core/classes/Kernel.html#M005960">Kernel#`</a> (backticks)

> Returns the standard output of running cmd in a subshell. The built-in syntax %x{...} uses this method. Sets $? to the process status.

``` ruby
>> `./err.rb`
err
=> "out\n"
```

* STDERR is output, but not captured
* STDOUT is captured


## <a href="http://ruby-doc.org/core/classes/Kernel.html#M005968">Kernel#exec</a>

> Replaces the current process by running the given external command.

``` ruby
>> exec('./err.rb')
out
err
```

* Both STDERR and STDOUT is output. They aren't captured as your process has been replaced so there is nothing to capture the output to.


## <a href="http://ruby-doc.org/core/classes/Kernel.html#M005971">Kernel#system</a>

> Executes cmd in a subshell, returning true if the command was found and ran successfully, false otherwise. An error status is available in $?. The arguments are processed in the same way as for Kernel::exec.

``` ruby
>> system('./err.rb')
out
err
=> true
```

* Both STDERR and STDOUT is output, but not captured.


## <a href="http://ruby-doc.org/core/classes/IO.html#M002242">IO#popen</a>

> Runs the specified command string as a subprocess; the subprocess's standard input and output will be connected to the returned IO object.

``` ruby
>> output = IO.popen('./err.rb')
=> #<IO:0x1017511b8>
>> err
output.readlines
=> ["out\n"]
```

* STDOUT is captured in a nice IO object
* STDERR is output


## <a href="http://ruby-doc.org/core/classes/Open3.html">Open3#popen3</a>

> Open stdin, stdout, and stderr streams and start external executable.

``` ruby
>> require 'open3'
=> true
>> stdin, stdout, stderr = Open3.popen3('./err.rb')
=> [#<IO:0x101769da8>, #<IO:0x101769d30>, #<IO:0x101769c68>]
>> stdout.readlines
=> ["out\n"]
>> stderr.readlines
=> ["err\n"]
```

* Both STDOUT and STDERR are captured into nice IO objects.


## <a href="https://ruby-doc.org/3.3.5/stdlibs/open3/Open3.html#method-i-capture3">Open3#capture3</a>

An alternative to `Open#popen3`, which is perhaps simpler, is using `Open3#capture3`. It basically wraps `Open3#popen3` and returns STDERR and STDOUT as strings:

``` ruby
>> require 'open3'
=> true
>> stdout, stderr = Open3.capture3('./err.rb')
=> ["out\n", "error\n", #<Process::Status: pid 68154 exit 0>]
>> stdout
=> ["out\n"]
>> stderr
=> ["err\n"]
```

* Both STDOUT and STDERR are captured into String objects.


## Alternative: Using 'nix redirection

Another alternative to `Open#popen3`, that still gives us both STDOUT and STDERR, is using <a href="http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-3.html">standard output redirection</a>:

``` ruby
>> `./err.rb 2>&amp;1`
=> "err\nout\n"
```

This gives you both STDOUT and STDERR in one big string, which might be perfectly fine if you don't require the granular control that popen3 brings to the table.

I am guessing this method would work for <a href="http://ruby-doc.org/core/classes/IO.html#M002242">IO#popen</a> as well as for the backticks.

## What to choose?

There is a great discussion about the different ways to call shell commands over at [Stack Overflow](https://stackoverflow.com/questions/2232/how-to-call-shell-commands-from-ruby), and in particular an excellent flowchart that can help you [decide what method to use when launching a subprocess](https://stackoverflow.com/a/37329716).
