module Main exposing
    ( x
    , increment, escapedCharacters
    )

{-| Example of markdown in doc comments.


# Section

@docs x
@docs increment, escapedCharacters


# Another section

Simple paragraph.

Paragraph with
soft breaks in
the text.

Paragraph with _italics_, **bold**.

Paragraph with [link], [reference link][reflink],
[url link](http://example.com). [link](http://example.com "with title")
Images ![][img],
![image loaded from URL](http://example.com/favicon.ico).
![alt text](http://example.com/favicon.ico "and title").
URL as link: <http://elm-lang.org>

[link]: http://example.com#link "with title"
[reflink]: http://example.com#reflink
[img]: http://example.com/favicon.ico

  - List item 1
  - List item 2
  - List item 3
      - Sub item
      - Sub item

1.  First
2.  Second
3.  Third


# HTML blocks

<strong>some HTML</strong>

  - <pre>raw HTML block</pre>

<table></table>

Followed by a paragraph.


## Example Elm declarations

    import MyModule

    myResult =
        x


## Example Elm expressions

    x == ()

```bash
echo "non-Elm code block"
```

---

> Blockquote
>
>     code
>
>   - first
>   - second

1.  Item 1, paragraph.

    Item 2. paragraph. Long paragraph
    with soft breaks in the
    middle.

2.  Item 2.

3.  Item 3.


## Nested lists

  - One
      - Two
          - Three

Another:

1.  First
2.  Second
      - AAA
      - BBB
      - CCC
3.  Third

Nested with loose items

1.  First

2.  Second
      - AAA
      - BBB
      - CCC

3.  Third

-}


x =
    ()


{-| Code block following a list. In this case we fallback to a fenced code block
because some markdown implementations parse this differently (notably, marked and
elm-markdown differ from commonmark). marked will parse an indented code block
after an indented list as a code block, but commonmark will parse it as a paragraph
inside of the list item.

Increment a number.

  - The given number will be incremented by 1.
  - This function is really simple.

```
increment x =
    x + 1
```

-}
increment : Int -> Int
increment x =
    x + 1


{-| Escaped characters should not be changed ¯\\\_(ツ)\_/¯

  - (\\\\) asd
  - not-quite shruggie ¯\_(ツ)\_/¯

-}
escapedCharacters =
    ()
