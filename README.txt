= RestEasy
  by Ken Robertson (ken@invalidlogic.com)
  http://invalidlogic.com/resteasy/

== DESCRIPTION:

RestEasy is a Ruby library for working with just about any REST webservice.
It returns any data as a Hash, as opposed to trying to construct a full class.
Rather than having to find a specific library for every service, such as Flickr,
Yahoo, Twitter, or whomever, RestEasy aims to be a library that can be used with
any REST API it comes across.

It also includes some specialized handling to preserve the original XML format
and mixtures of attributes and element strings.

For instance, the following XML:

  <Message Id="480ca9fb-53ce-45b2-bcc8-afa82e3e73e">
    <Body>This is a test</Body>
  </Message>

Will be returned as a specialized has containing:

  {"Body"=>"This is a test", "Id"=>"480ca9fb-53ce-45b2-bcc8-afa82e3e73e"}

And if that hash is later sent back to the server, it will be reconstructed
preserving the Id as an attribute and Body as a string.

The library also supports JSON.  It will determine which to use based on
the content type of the response.  If the response is neither text/xml or
text/json, it will just return the string.

== REQUIREMENTS:

* activesupport (or at least xmlsimple)
    Tested against 2.0.2

== INSTALL:

  $ gem install resteasy

== SOURCE:

RestEasy is available as a git repository through GitHub, which can be browsed at:

  http://github.com/krobertson/resteasy

and cloned from:

  git://github.com/krobertson/resteasy.git

== USAGE:

To use the library in your own program, you just need to load in the gem.

  require 'resteasy'

To begin talking to a webservice, just create a new instance of RestEasy.

  s = RestEasy.new
  s.get('http://api.flickr.com/services/rest/?method=flickr.test.echo&name=value')
  # => {"err"=>{"msg"=>"Invalid API Key (Key not found)", "code"=>"100"}, "stat"=>"fail"}

Need to post an object with authentication?

  s.set_auth('user', 'pass')
  s.post('http://somesite/app/users', obj)

Or maybe the application you are using needs special headers for authentication.
You can either prime the headers it will use for all requests when instantiating,
or access them afterwards.

  s = RestEasy.new 'Auth-Token' => 'abcd1234'
  s.headers['Auth-Token']  # => 'abcd1234'  Access/set after instantiating

If a request fails, it will return the Net::HTTPResponse that was returned.  It would
be good to check all responses to see if they're of that type first and handle them.

  s.get('http//localhost/oops')
  # => #<Net::HTTPNotFound 404 Not Found readbody=true>

The service will also handle redirections internally.  If it gets a 3xx response and
a location, it will follow it with a maximum of 3 redirects in a row.  More than that,
and it will raise a RedirectLoopException.

== LICENSE:

(The MIT License)

Copyright (c) 2008 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
