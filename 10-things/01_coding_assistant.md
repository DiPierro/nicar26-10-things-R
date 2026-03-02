# 1: Using a coding assistant in RStudio


## Introduction

Having a LLM-powered code assistant from within RSTudio can help you to
write and debug code faster. Here’s one way to set one up for free using
Ollama and a package called
[`gander`](https://simonpcouch.github.io/gander/articles/gander.html).

## Set up ollama

1)  Download ollama: https://ollama.com/download.

2)  Open Terminal on your computer.

3)  Run a coder model. You can use the command line and type something
    like `ollama run qwen2.5-coder`, `ollama run qwen3-coder` or
    `ollama run devstral-small-2`. Or, you can choose another ollama
    model.

## Install packages

Here are a few packages you’ll need to install to get going:

``` r
# Run once
# install.packages(c("gander", "ellmer", "btw"))
```

## Make keyboard shortcut

You’ll want your code assistant to be quick and easy to access, not
something you need to hunt around to use. So, let’s set a keyboard
shortcut to makes it easy to access `gander`.

The [documentation](https://simonpcouch.github.io/gander/) recommends:

> In RStudio, navigate to Tools \> Modify Keyboard Shortcuts \> Search
> “gander”—we suggest Ctrl+Alt+G (or Ctrl+Cmd+G on macOS).

## Configure .Rprofile

You can use any model supported by
[`ellmer`](https://simonpcouch.github.io/gander/articles/gander.html) in
`gander`. To set a default chat model, run this cell:

``` r
usethis::edit_r_profile()
```

    ☐ Edit '/Users/amydipierro/.Rprofile'.

    ☐ Restart R for changes to take effect.

Then, paste this code into your `.Rprofile`, or modify it with your
preferred model:

``` r
options(.gander_chat = ellmer::chat_ollama(model = "qwen2.5-coder"))
```

> Note: You can use `gander` with all kinds of other models

Restart R for the changes in your `.Rprofile` to take effect.

## Test an example

Type your new shortcut, `Ctrl+Cmd+G` on a Mac or `Ctrl+Alt+G` on a PC.

Then, type in a prompt like, ‘Given a list of links to PDF documents,
write code to download each PDF to a folder called pdfs’. You can also
highlight a code snippet and then type your shortcut to ask a more
specific question.

> Note: On my laptop, local models tend to be slower to write code. Your
> mileage may vary. Wait a beat. It might take a moment for the model to
> start generating code.

## What’s happening under the hood

It’s important to remember that when we use `gander`, we’re giving a
model intimate access to information about our global environment, the
code we’re writing and even the data we’re analyzing. This makes
`gander` very powerful, but it’s also a good reason to use a local model
if you’re working with sensitive data.

Here’s how the library’s documentation describes what `gander` is doing:

> gander automatically incorporates two kinds of context about your
> analyses under the hood:

> *Code context*: The assistant will automatically inform the model
> about the type of file you’re working in and relevant lines of code
> surrounding your cursor.

> *Environment context*: The assistant also interfaces directly with
> your global environment to describe the relevant data frames you have
> loaded, including their column names and type. This allows you to
> describe the analyses you’d like to carry out in plain language while
> gander takes care of describing your computational environment to the
> model.

You can also start to familiarize yourself with the instructions
`gander` is sending to the model by running `gander::gander_peek()`.

``` r
gander::gander_peek()
```

    NULL

## What if I want a chat interface?

`gander` is great if you want a model to write or fix code for you. But
you might like to chat over multiple interactions. You might try to the
library [`btw`](https://posit-dev.github.io/btw/) on for size. Here’s
how to launch an interactive chat window.

``` r
# You'll want to pull a more general purpose model for chat functionality.
# For example, you could try this: `ollama run llama3.1:latest`
# btw::btw_app(client = ellmer::chat_ollama(model = "llama3.1"))
```

## Caveats

> TODO: Haven’t tested this much

## More to explore

> TODO: Add this https://positron.posit.co/databot.html and
> https://positron.posit.co/assistant.html

That’s it! Now you have a built-in code assistant and don’t have to copy
and paste boatloads of code into Claude or another LLM chat interface.

If this brief introduction has you curious about other LLM and R
integrations, know that there’s much more to explore. You might use
`gander` in combination with other R libraries such as `chores` (which
is great for repeat use cases, such as writing documentation) and
[`gptstudio`](https://github.com/MichelNivard/gptstudio/discussions/210)
(which provides a chat interface). Here’s some further reading.

From the `tidyverse` blog:

- [Three experiments in LLM code assist with RStudio and
  Positron](https://tidyverse.org/blog/2025/01/experiments-llm/):
  Probably already a little outdated. Note that `pal` is now renamed
  [`chores`](https://github.com/simonpcouch/chores).

- [Learning the tidyverse with the help of AI
  tools](https://tidyverse.org/blog/2025/04/learn-tidyverse-ai/)

From Matt Waite, a journalism professor at the University of
Nebraska-Lincoln:

- [An academic integrity-friendly code pal for R
  Studio](https://mattwaite.github.io/posts/an-academic-integrity-friendly-pal/):
  Again, note that `pal` is now called `chores`.

- [An R + LLM starter
  kit](https://mattwaite.github.io/posts/r-llm-starter-pack/): More
  great advice for prompting LLMs from within R.
