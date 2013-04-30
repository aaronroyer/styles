# Styles

plain text stylesheets

## Installation

Install with RubyGems.

```
$ gem install styles
```

## Usage

### Create a stylesheet

```
$ styles --edit my_styles
```
This will create a new stylesheet in ~/.styles (by default) called my_styles.rb and open it in your $EDITOR. If you don't specify a name it will use 'default'. There will be a bunch of example stuff commented out so you can just go for it and get started. Add some styles.

```ruby
'important' - {
  color: blue,
  font_weight: bold
}

/annoying/i - {
  display: none
}

/\d{3}-\d{3}-\d{4}/ - {
  match_color: green
}

:blank - {
  display: none
}
```
Stylesheets are written in a pure Ruby DSL that is vaguely similar to CSS. Instead of operating on DOM elements, rules operate on **lines of text**. Rules are specified with a selector, a ```-```, and a hash of properties. A selector can be one of three things.

  - String - matches if a line contains the string
  - Regexp - matches if the line matches regular expression
  - Symbol - matches certain special types of lines, examples include ```:blank``` and ```:any```

To leverage you CSS knowledge, some familiar properties are available. You may notice that their form and the syntax in general is altered to make everything valid Ruby. There are also some others that have no CSS counterparts. See below for a list of all properties and values.

### Apply the stylesheet to some text

Pipe some text to ```styles```, specifying which stylesheet you want to use.

Lets say example.txt contains this

<pre>
this is an important line
THIS line is super ANNOYING!
here is my phone number: 555-234-6789

the line before this is blank
</pre>

Let’s use the stylesheet we just created above.

<pre>
$ cat example.txt | styles my_styles
<span style="color:blue; font-weight:bold;">this is an important line</span>
here is my phone number: <span style="color:green;">555-234-6789</span>
the line before this is blank
</pre>

The annoying and blank lines have been hidden and, if your terminal supports it, you should see the colors applied as you expect them.

## License

Styles is MIT licensed
