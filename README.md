# [Reacco](http://ricostacruz.com/reacco)
#### Readme documentation prettifier

Reacco is a dead simple documentation generator that lets you document your 
project using Markdown.

## Usage

#### Installation
Install Reacco first. It is a Ruby gem.

    $ gem install reacco

#### Generation
To generate documentation, type `reacco`. This takes your `README.md` file and 
prettifies it.

    $ reacco

#### Literate style blocks
To make literate-style blocks (that is, code on the right, explanation on the
left), use `reacco --literate`.

    $ reacco --literate

## Documenting API
To extract documentation from your code files, add `--api <path here>`. This 
extracts comment blocks from files in that path.

As Reacco only parses out Markdown from your comments, almost all programming 
languages are supported. It does not care about code at all, just comments.

    $ reacco --literate --api lib/

#### Documenting classes
You will need to add Markdown comment blocks to your code. The first line needs 
to be a Markdown heading in the form of `### <heading name>`.

Classes are often made to be H2's.

``` ruby
# ## Reacco [class]
# The main class.
#
# Class documentation goes here in Markdown form.
#
class Reacco
  ...
end
```

#### Documenting class methods
Class methods are often made as H3's. Sub-sections are often always H4's.

``` ruby
# ## Reacco [class]
# The main class.
#
class Reacco
  # ### version [class method]
  # Returns a string of the library's version.
  #
  # #### Example
  # This example returns the version.
  #
  #     Reacco.version
  #     #=> "0.0.1"
  #
  def self.version
    ...
  end
end
```

#### Adding the placeholder
To specify where the docs will be in the README, put a line with the text 
`[](#api_reference)`. This will tell Reacco where to "inject" your API 
documentation.

    # README.md:
    Please see http://you.github.com/project. [](#api_reference)

# API reference

For usage and API reference, please see http://ricostacruz.com/reacco. [](#api_reference)

Warning
-------

**Here be dragons!** this is mostly made for my own projects, so I may change 
things quite often (though I'd try to be mostly API-compatible with older
versions).

Acknowledgements
----------------

© 2011, Rico Sta. Cruz. Released under the [MIT 
License](http://www.opensource.org/licenses/mit-license.php).

Reacco is authored and maintained by [Rico Sta. Cruz][rsc] with help from it's 
[contributors][c]. It is sponsored by my startup, [Sinefunc, Inc][sf].

 * [My website](http://ricostacruz.com) (ricostacruz.com)
 * [Sinefunc, Inc.](http://sinefunc.com) (sinefunc.com)
 * [Github](http://github.com/rstacruz) (@rstacruz)
 * [Twitter](http://twitter.com/rstacruz) (@rstacruz)

[rsc]: http://ricostacruz.com
[c]:   http://github.com/rstacruz/reacco/contributors
[sf]:  http://sinefunc.com
