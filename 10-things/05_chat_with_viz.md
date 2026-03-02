# 5: Chat with your data viz


## Refining your data visuals with ggbot2

The R package [`ggbot2`](https://github.com/tidyverse/ggbot2) takes the
idea of chatbot to the next level. Rather than type commands (“Make a
scatter plot.”), just say them out loud to `ggbot2` and it will generate
code.

> You can install this package on your own computer with the command
> `pak::pak("tidyverse/ggbot2")`. Note that `ggbot2` requires you to
> create an [OpenAI API key](https://platform.openai.com/api-keys) and
> to buy a few credits. Then, you can add it to this project’s .Renviron
> file by using the command `usethis::edit_r_environ(scope = "project")`
> and setting a environmental variable, `OPEN_AI_KEY=your_api_key_here`.

## Demo: The diamonds data, revisited

Let’s revisit the `diamonds` built-in data we were using earlier with
`gander`. This time, we’ll try out a few visualizations aloud with
ChatGPT.

``` r
# Launch ggbot2
# ggbot2::ggbot(ggplot2::diamonds)
```

> Tip: Make sure to give your browser access to your microphone when
> prompted and press the space bar to unmute yourself.

## More to explore

Data journalist and R expert [Sharon Machlis](https://www.machlis.com/)
has a [great
tutorial](https://www.infoworld.com/article/4072500/how-to-run-an-r-data-visualization-chatbot-you-can-talk-to.html)
and [short video](https://www.youtube.com/watch?v=UlQ5jA3-m3M)
test-driving `ggbot2`.
