# 1: Set up an RStudio coding assistant


## So many AI assistants, so little time

If you’ve ever tried [GitHub
Copilot](https://github.com/features/copilot),
[Cursor](https://cursor.com/) or another code assistant, you know that a
little help from your friendly neighborhood large language model (LLM)
can be a boon.

But if you’ve exhausted the free tier on those services and don’t have
the budget for a subscription – or if you simply prefer to do all of
your exploratory data analysis in RStudio – you have options.

This module is a gentle introduction to two packages,
[`ellmer`](https://ellmer.tidyverse.org/index.html)
[`gander`](https://simonpcouch.github.io/gander/articles/gander.html).
Each makes it possible to interact with LLMs for coding help without
leaving RStudio. You can hook them up to paid models from companies like
OpenAI and Anthropic or you can use them to tap into open, free models.

> Note: Posit, the open-source data science software company that makes
> RStudio, debuted its own native [AI
> assistant](https://positron.posit.co/assistant.html) extension last
> year. It’s available as part of another free code editor they make,
> [Positron](https://positron.posit.co/), and requires an API key to
> access paid LLMs.

## Working with open models

> If you’re following along from a personal laptop, you can download the
> specific packages you’ll need for this part of the session like this:
> `install.packages(c("gander", "ellmer"))`.

[Ollama](https://ollama.com/) is a handy way to work with open, free
models – including many small enough that they can comfortably run on a
laptop. You can get started by:

1)  Downloading [Ollama](https://ollama.com/download).

2)  Opening a bash shell, such as the Terminal app on a MacBook.

3)  Downloading a model that’s designed for coding. From the command
    line, type something like `ollama run qwen2.5-coder`,
    `ollama run qwen3-coder` or `ollama run devstral-small-2`. Or, you
    can choose another ollama model. I’m running the 7B size for
    Qwen2.5-Coder with `ollama run qwen2.5-coder:7b`.

> In my experience, the trade off between smaller and larger local
> models is that smaller models tend to generate code faster, while
> larger models tend to generate better quality code.

## Taking a `gander`

Once you’ve installed Ollama, pulled a model and installed the R
packages, you’re only a few more clicks away from a new code assistant.
Here’s what to do next.

### Make a keyboard shortcut

You’ll want your code assistant to be quick and easy to access, not
something you need to hunt around to find. Here’s what the package’s
[documentation](https://simonpcouch.github.io/gander/) recommends:

> In RStudio, navigate to Tools \> Modify Keyboard Shortcuts \> Search
> “gander”. We suggest Ctrl+Alt+G (or Ctrl+Cmd+G on macOS).

### Configure a default model in your .Rprofile

To use `gander`, we’re tapping into another R package, `ellmer`. You can
use any model supported by
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
# Code for the model I'm running
options(.gander_chat = ellmer::chat_ollama(model = "qwen2.5-coder:7b"))

# You can also use Gemini's free tier if you get an API key with Google AI Studio.
# 1 - Create a key: https://aistudio.google.com/api-keys
# 2 - usethis::edit_r_environ(scope = "project") 
# 3 - Paste your API key into the variable GEMINI_API_KEY.
# 4 - Restart R.
# options(.gander_chat = ellmer::chat_google_gemini())
```

> Note: Remember that you can use `gander` with all kinds of other
> models from Ollama as well as models such as Amazon Bedrock, Microsoft
> Azure, etc.

Once you’ve saved your `.Rprofile`, restart R for the changes to take
effect. (Session \> Restart R.) Then, you’ll be ready to use `gander`.

## Trying out an example

Consider the built-in `diamonds` data set in R. Let’s ask `gander`to run
a simple analysis.

To get started, highlight the word `diamonds`. Then, type your new
shortcut, `Ctrl+Cmd+G` on a Mac or `Ctrl+Alt+G` on a PC. A small window
with the prompt “Enter text” should appear. Type in a command or
question for `gander`. You might try something like:

- Make a scatterplot of carat v price.
- Summarize the median price for every carat and sort by price.

> Note: If you’re using a local model, it may take half a minute or so
> for `gander` to start writing code. Also,
> [chattiness](https://github.com/simonpcouch/gander/issues/30) is a
> known issue when working with gander to edit code in a .qmd file. For
> better results, switch to the file
> [01_coding_assistant.R](https://github.com/DiPierro/nicar26-10-things-R/blob/main/10-things/%2001_coding_assistant.R).

## What’s happening under the hood

It’s important to remember that when we use `gander`, we’re giving a
model access to information about the code we’re writing and even [the
data we’re
analyzing](https://simonpcouch.github.io/gander/reference/gander_options.html#data-context).
This is another good reason to use a local model if you’re working with
sensitive data.

Here’s how the library’s documentation describes what `gander` is doing:

> gander automatically incorporates two kinds of context about your
> analyses under the hood:
>
> *Code context*: The assistant will automatically inform the model
> about the type of file you’re working in and relevant lines of code
> surrounding your cursor.
>
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
you might like to chat over multiple interactions. You can open a
general purpose chatbot using
[`ellmer`](https://ellmer.tidyverse.org/reference/chat_ollama.html).

``` r
 # Using a prompt suggested in the docs: https://ellmer.tidyverse.org/articles/prompt-design.html#be-explicit
chat <- 
  ellmer::chat_ollama(
    system_prompt = "
  You are an expert R programmer who prefers the tidyverse.
  Just give me the code. I don't want any explanation or sample data.

  Follow the tidyverse style guide:
  
  * Spread long function calls across multiple lines.
  * Where needed, always indent function calls with two spaces.
  * Only name arguments that are less commonly used.
  * Always use double quotes for strings.
  * Use the base pipe, `|>`, not the magrittr pipe `%>%`.
", 
    model = "llama3.1"
  )

# You can open an interactive chat console like this:
# ellmer::live_console(chat)
# Or chat inside this very document like this:
chat$chat("How do I set an API key as an environmental variable?")
```

    ```
    Sys.setenv(
      api_key = "your_api_key_here"
    )
    ```

> This example only scratches the surface of what is possible in
> `ellmer`. Take a look at the vignettes about [structured data
> extraction](https://ellmer.tidyverse.org/articles/structured-data.html)
> and [tool
> calling](https://ellmer.tidyverse.org/articles/tool-calling.html) for
> more ideas.

## More to explore

That’s it! Now you have a built-in code assistant and don’t have to copy
and paste boatloads of code into Claude or another LLM chat interface.

If this brief introduction has you curious about other ways to integrate
LLMs into R, know there’s much more to explore. You might use `gander`
in combination with other R libraries such as `chores` (which is
intended for repeat use cases, such as writing documentation) and
[`btw`](https://posit-dev.github.io/btw/index.html) (which integrates
context such as preferred coding style, environment, files and more into
a chatbot).

Finally, here’s some further reading.

From Matt Waite, a journalism professor at the University of
Nebraska-Lincoln:

- [An academic integrity-friendly code pal for R
  Studio](https://mattwaite.github.io/posts/an-academic-integrity-friendly-pal/):
  Again, note that `pal` is now called `chores`.

- [An R + LLM starter
  kit](https://mattwaite.github.io/posts/r-llm-starter-pack/): More
  great advice for prompting LLMs from within R.

From Posit, the makers of RStudio:

- [Positron Assistant](https://positron.posit.co/assistant.html). Per
  Posit: “Positron Assistant is an AI coding assistant; it helps you
  write code or modify code on disk and can execute arbitrary code in
  Agent mode.”

- [Databot](https://positron.posit.co/databot.html): Per Posit: “Databot
  is a purpose-built exploratory data analysis agent. It writes and
  executes its own code on the fly to help you understand your data. It
  doesn’t care very much about the code you’ve already written.”

From the `tidyverse` blog:

- [Three experiments in LLM code assist with RStudio and
  Positron](https://tidyverse.org/blog/2025/01/experiments-llm/):
  Probably already a little outdated. Note that `pal` is now renamed
  [`chores`](https://github.com/simonpcouch/chores).

- [Learning the tidyverse with the help of AI
  tools](https://tidyverse.org/blog/2025/04/learn-tidyverse-ai/)
