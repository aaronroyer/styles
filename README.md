# Styles

plain text stylesheets

## Introduction

_Styles_ is an attempt to apply useful CSS concepts to plain text processing. Rules operate on lines of text rather than DOM elements. Not all concepts from CSS are applicable. The most useful ones are:

* Selectors (including String and Regexp) to match lines
* Application of properties to matched lines with the familiar last-one-wins model

## Dependencies

- Ruby 1.9 or better

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
This will create a new stylesheet in ~/.styles (by default) called my_styles.rb and open it in your $EDITOR. If you don't specify a stylesheet name it will use 'default'.

```ruby
'important' - {
  color: blue,
  font_weight: bold,
  text_decoration: underline
}

'warning' - {
  background_color: yellow
}

/annoying/i - {
  display: none
}

/\d{3}-\d{3}-\d{4}/ - {
  # match_color is like color except it applies to the matched portion of the line
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

<pre style="background-color:#f8f8ff; padding:5px;">
this is an important line
this line is warning you about something
THIS LINE IS SUPER ANNOYING!
here is my phone number: 555-234-6789

the line before this is blank
</pre>

Let’s use the stylesheet we just created above.

<img src="http://i.imgur.com/Bf0LHzy.png" width="450px" />

The annoying and blank lines have been hidden and, if your terminal supports it, you should see the colors applied as you expect them.

## More Examples

#### Only display interesting lines

Stylesheet

```ruby
:all - {
  display: none
}

'interesting' - {
  display: block # Could also use: display: true
}

/(very|quite|most) interesting/i - {
  background_color: green
}
```

Input

<pre style="background-color:#f8f8ff; padding:5px;">
a line
another line
nothing to see here
this is interesting
this is VERY interesting
this is not
</pre>

Output

<img src="http://i.imgur.com/YcN7UGv.png" width="400px" />

#### Do crazy stuff with CSS-style layout properties

Stylesheet

```ruby
'gimmicky' - {
  padding: 1,
  margin: 2,
  border: 'solid blue',
  width: 30,
  text_align: right
}
```

Input

<pre style="background-color:#f8f8ff; padding:5px;">
a bit gimmicky
</pre>

Output

<img src="http://i.imgur.com/jhkgBic.png" width="450px" />


#### Do arbitrary processing on lines

Stylesheet

```ruby
'password' - {
  function: ->(line) { line.sub(/(password is:) (\S+)/, '\1 XXXXXX') }
}
```

Input

<pre style="background-color:#f8f8ff; padding:5px;">
the password is: 5up3rs3cr3t
</pre>

Output

<img src="http://i.imgur.com/HAkOPKU.png" width="500px" />


# Reference

## Selectors

Selectors are used to match lines of input. They are like CSS selectors but instead of matching DOM elements they match some or all of the content of a line.

There are three types of selector: String, Regexp, and Symbol.

### String

Strings are the simplest type of selector. A line matches a String selector when the line text includes the string. The string must exactly match and is case-sensitive.

The String selector

```ruby
'example'
```

matches these lines.

```
example
  example
this is an example
example is here
```

And does not match these lines.

```
random other stuff
EXAMPLE
this is an Example
```

ANSI color codes in the line are ignored when matching. So a selector ```'is red'``` will match the following line.

```this is \e[31mred\e[0m```

Note that in your terminal the 3rd word would be red and you would not see the color code characeters, even though they are present in the line. These are stripped before attempting the match to do what (I think) is expected.

### Regexp

Regexp selectors are perhaps the most versatile. If any part of the line matches the Regexp then the line matches the selector.

You can use this to make simple string matches case-insensitive, for example you could use

```ruby
/example/i
```

for a case-insensitive version of the example for the String selector. You can, of course, do more complicated things using the crazy power of Ruby Regexps.

ANSI color codes in the line are ignored when matching, as with String selectors.

### Symbol

Symbol selectors match some common types of lines, for convenience.

Right now there are four valid Symbol selectors: ```:blank```, ```:empty```, ```:any```, and ```:all```

```:blank``` - matches lines that are either completely empty or only contain whitespace

```:empty``` - matches lines that are completely empty

```:any``` - matches any line

```:all``` - matches any line (synonym of ```:any```)

## All Properties

Text Styling:

* [background_color](#background_color)
* [color](#color)
* [font_weight](#font_weight)
* [text_decoration](#text_decoration)
* [match_background_color](#match_background_color)
* [match_color](#match_color)
* [match_font_weight](#match_font_weight)
* [match_text_decoration](#match_text_decoration)

Layout:

* [border](#border)
* [display](#display)
* [margin](#margin)
* [padding](#padding)
* [text_align](#text_align)
* [width](#width)

Miscellaneous:

* [function](#function)

### Text Styling Properties

----

#### background_color
<a name="background_color" />

Sets the background color (where supported) for the matched line

Valid values: ```black, red, green, yellow, blue, magenta, cyan, white```

_See also: match_background_color_

##### Example

```ruby
'back' - {
  background_color: blue
}
```

<img src="http://i.imgur.com/V4IZ04C.png" width="450px" />

----

#### color
<a name="color" />

Sets the foreground color (where supported) for the matched line

Valid values: ```black, red, green, yellow, blue, magenta, cyan, white```

_See also: match_color_

##### Example

```ruby
/color/i - {
  color: red
}
```

<img src="http://i.imgur.com/9OVwEvu.png" width="500px" />

----

#### font_weight
<a name="font_weight" />

Makes the text bold (where supported) or normal weight for the matched line

Valid values: ```normal, bold```

##### Examples

```ruby
'bold' - {
  font_weight: bold
}
```

<img src="http://i.imgur.com/ujS2mHq.png" width="500px" />

```ruby
'normal' - {
  font_weight: normal
}
```

<img src="http://i.imgur.com/0XlMxOW.png" width="500px" />

----

#### text_decoration
<a name="text_decoration" />

Applies various text decorations (where supported) to the matched line

Valid values: ```none, underline, line_through, strikethrough, blink```

_```strikethrough``` is a synonym for ```line_through```_

##### Example

```ruby
/^decor/ - {
  text_decoration: underline
}
```

<img src="http://i.imgur.com/yW3Cv3U.png" width="500px" />

----

#### match_background_color
<a name="match_background_color" />

Sets the background color (where supported) for the matched portion of a line

Valid values: ```black, red, green, yellow, blue, magenta, cyan, white```

Multiple colors are applied in the same way as with [match_color](#match_color).

##### Examples

```ruby
'test' - {
  match_background_color: blue
}
```

<img src="http://i.imgur.com/PwKwkZo.png" width="500px" />

```ruby
/\d+/ - {
  match_background_color: red
}
```

<img src="http://i.imgur.com/edUPk8A.png" width="500px" />

----

#### match_color
<a name="match_color" />

Sets the color (where supported) for the matched portion of a line

Valid values: ```black, red, green, yellow, blue, magenta, cyan, white```

If a String selector is used then the color is applied to each matching portion of the string in
the matched line. For a Regexp selector, if there are no groups the color is applied portions of
the line that the whole Regexp matches. If there are groups then you can specify an Array of colors
to be applied to the respective groups in the Regexp.

##### Examples

```ruby
'test' - {
  match_color: blue
}
```

<img src="http://i.imgur.com/GDNOGUA.png" width="500px" />

```ruby
/\d+/ - {
  match_color: red
}
```

<img src="http://i.imgur.com/8j7EVv5.png" width="500px" />

```ruby
/(m\w*) (m\w*)/ - {
  match_color: [blue, green]
}
```

<img src="http://i.imgur.com/rFwlovk.png" width="500px" />

----

#### match_font_weight
<a name="match_font_weight" />

Makes the text bold (where supported) or normal weight for the matched portion of a line

Valid values: ```normal, bold```

Multiple match font weights are applied in the same way as with [match_color](#match_color).

##### Example

```ruby
'bold' - {
  match_font_weight: bold
}
```

<img src="http://i.imgur.com/eugXKTg.png" width="500px" />

----

#### match_text_decoration
<a name="match_text_decoration" />

Applies various text decorations (where supported) to the matched portion of a line

Valid values: ```none, underline, line_through, strikethrough, blink```

_```strikethrough``` is a synonym for ```line_through```_

##### Example

```ruby
/^decor\w+/ - {
  match_text_decoration: underline
}
```

<img src="http://i.imgur.com/IW0vFCp.png" width="500px" />

----

### Layout Properties

----

#### border
<a name="border" />

Adds a one-character width border around matched lines. There are two attributes of the border
that can be configured: style and color.

Valid style values: ```solid, dashed, dotted, double```

_```dotted``` is a synonym for ```dashed```_

Valid color values: ```black, red, green, yellow, blue, magenta, cyan, white```

Style _must_ be specified, color is optional. There is no border width configuration as with CSS.
If only a style is specified you do not need to put the value in a string. If you are specifying a
color along with the style you must use a string.

##### Example

```ruby
'test' - {
  border: 'solid red'
}
```

<img src="http://i.imgur.com/7GYvGPT.png" width="500px" />

----

#### display
<a name="display" />

This may do more in the future, but for now just basically specifies whether to hide or show
particular lines. This is generally useful for filtering out lines you don't want to see and
overriding the hiding later if necessary.

```none``` and ```false``` will cause the line to not display. Any other value will cause it to
display as normal. It is recommended to use ```true``` or ```block``` to show lines as values
line ```inline``` may have a different meaning later.

Valid values: ```block, inline, inline_block, none, true, false```

##### Examples

```ruby
# Hide lines that contain a particular string

'test' - {
  display: none
}
```

```ruby
# Hide all lines except ones that contain a phone number

:all - {
  display: none
}

/\d{3}-\d{3}-\d{4}/ - {
  display: block
}
```

----

#### margin
<a name="margin" />

Adds space around a line, outside any border or padding, if present. For top and bottom margins,
lines are added above and below the line. For left and right margins spaces are added on either
side of the line.

Values are specified as integers with no units. If the margin should be the same on every side,
use a single integer for a value. If margins should be different, use a string with multiple integers.
A value of ```auto``` can also be used and will center the line in the terminal if specified for
the left or right margin.

Like CSS, sides are configured in this order: top, right, bottom, left. Any number of sides can be
specified (that is: if you only give 2 integers then only top and right will be set).

You can also use the property names ```margin_top```, ```margin_right```, ```margin_bottom```, and
```margin_left``` to specify a margin for a single side.

##### Examples

```ruby
'special' - {
  margin: 1
}
```

<img src="http://i.imgur.com/avanMqe.png" width="500px" />

```ruby
# Different margins can be specified for each side
# Order is: top, right, bottom, left
'special' - {
  margin: '2 1 1 5'
}

# You can also just set the margin for one side
'move me to the right' - {
  margin_left: 10
}

# The following sets a margin of 3 on every side except for the bottom, which is 1
'another example' - {
  margin: 3,
  margin_bottom: 1
}
```

----

#### padding
<a name="padding" />

Adds space around a line, inside any border or margin, if present. For top and bottom padding,
lines are added above and below the line. For left and right padding spaces are added on either
side of the line.

Valid values are integers with no units. If the padding should be the same on every side, use a
single integer for a value. If padding should be different, use a string with multiple integers.

Like CSS, sides are configured in this order: top, right, bottom, left. Any number of sides can be
specified (that is: if you only give 2 integers then only top and right will be set).

You can also use the property names ```padding_top```, ```padding_right```, ```padding_bottom```, and
```padding_left``` to specify padding for a single side.

##### Examples

```ruby
# Different padding can be specified for each side
# Order is: top, right, bottom, left
'special' - {
  padding: '2 1 1 5'
}

# You can also just set the padding for one side
'move me to the right' - {
  padding_left: 10
}

# The following sets padding of 3 on every side except for the bottom, which is 1
'another example' - {
  padding: 3,
  padding_bottom: 1
}
```

----

#### text_align
<a name="text_align" />

Aligns text within the available width it can occupy. This behaves differently depending on whether
other layout properties are applied to the line.

If there is no padding, border, or margin applied to the line, the text is aligned according to
the terminal width. ```right``` aligned lines will be moved as far right in the terminal as
possible. ```center``` aligned lines will appear in the middle of the terminal. ```left```
alignment usually does nothing, but it can be used to override previous ```text_align``` settings.
If the terminal width cannot be determined, 80 is used. If the line is longer than the terminal is
wide then no alignment will be applied.

If there is any of padding, border, or margin applied to the line, then the text of the line is
aligned, inside any border and padding, within the width of the line, set by the ```width```
property. If no width is specified, or the length of the line text exceeds the width, then nothing
is done.

Valid values: ```left, right, center```

----

#### width
<a name="width" />

Sets the width of the line. The W3C box model is used, so this specifies the horizontal area inside
any border and padding for the line.

A valid value is an integer with no units.

----

### Miscellaneous Properties

----

#### function
<a name="function" />

This is a catch-all property that allows you to process a line with arbitrary Ruby code.

The value for the ```function``` property is any callable object (like a lambda or a proc). The
"stabby lambda" may be the most convenient to use.

The callable should have one parameter. The callable will be called with the text of the matched
line as its only argument. Whatever is returned will replace the line. An empty string will cause
a blank line to be output. To skip the line, return ```nil```.

```function``` processing works with the line exactly as it was input, before any other properties
are applied. Other properties are applied afterward, if any.

##### Examples

Stylesheet

```ruby
/loud/i - {
  function: ->(line) { line.downcase }
}
```

Input

<pre style="background-color:#f8f8ff; padding:5px;">
normal volume
TOO LOUD
ALSO TOO LOUD
this is ok
</pre>

Output

<pre style="color:white; background-color:black; padding: 5px;">
normal volume
too loud
also too loud
this is ok
</pre>


Stylesheet

```ruby
'temperature' - {
  function: lambda do |line|
    temp = line.scan(/\d+/).first.to_i
    if temp < 80
      nil # No output, line is skipped
    elsif temp >= 90 && temp < 100
      "WARNING: #{line}"
    elsif temp >= 100
      "EMERGENCY: #{line}"
    else
      line
    end
  end
}
```

Input

<pre style="background-color:#f8f8ff; padding:5px;">
the temperature is 75 degrees
the temperature is 82 degrees
the temperature is 90 degrees
the temperature is 103 degrees
the temperature is 95 degrees
the temperature is 88 degrees
the temperature is 77 degrees
</pre>

Output

<pre style="color:white; background-color:black; padding: 5px;">
the temperature is 82 degrees
WARNING: the temperature is 90 degrees
EMERGENCY: the temperature is 103 degrees
WARNING: the temperature is 95 degrees
the temperature is 88 degrees
</pre>

----

## License

Styles is MIT licensed (see LICENSE.txt)
