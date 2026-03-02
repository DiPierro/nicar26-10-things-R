# 10: Fetch YouTube data


## Downloading comments and metadata from YouTube

By some [recent
estimates](https://www.bbc.com/future/article/20250213-youtube-at-20-a-computer-that-drunk-dials-online-videos-reveals-statistics-that-google-doesnt-want-you-to-know),
YouTube reaches almost one-third of people on earth.

Journalists and academic researchers are among those investigating the
degree to which YouTube’s recommendation algorithm may [have a
radicalizing
effect](https://www.asc.upenn.edu/news-events/news/youtube-algorithm-isnt-radicalizing-people)
or [contribute to the spread of
disinformation](https://www.npr.org/2021/04/13/986678544/exploring-youtube-and-the-spread-of-disinformation).
And YouTube’s size alone means that individual YouTubers can be globally
influential.

In short, YouTube can be a rich data source. An R package called
[`tuber`](https://github.com/gojiplus/tuber) makes it easier to tap into
that data using R.

## Getting started

> Warning: This process can be tricky and difficult to debug. Feel free
> to sit back and watch the demo for now.

1.  Go to the [Google APIs
    dashboard](https://console.developers.google.com/apis/dashboard) and
    enable APIs and services if you haven’t already.

2.  Create a new project. Call it ‘tuber’ or something else descriptive.

3.  Use the search bar to find the YouTube Data API v3 and click
    ‘Enable’.

4.  Go to ‘Create credentials’ \> ‘OAuth client ID’ and select ‘Desktop
    application’ as the application type. Name the application
    ‘tuber-rstudio’ or something similar so you know what it is later.

5.  Go to ‘Audience’ in the side panel and add your own gmail address as
    a test user.

Make sure to save your app ID and password. You can then stash them in
your .Renviron the usual way.

``` r
# Set YT_ID and YT_PASSWORD variables, then restart R
usethis::edit_r_environ(scope = "project")
```

    ✔ Setting active project to "/Users/amydipierro/GitHub/nicar26-obscure-R".

    ☐ Edit '.Renviron'.

    ☐ Restart R for changes to take effect.

Then, you can authenticate like this.

``` r
# Libraries
library(tuber)
library(dplyr)
```


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
library(scales)

# Here's how to authenticate
app_id <- Sys.getenv("YT_ID")
app_password <- Sys.getenv("YT_PASSWORD")
yt_oauth(app_id, app_password, token = "")
```

    Warning in value[[3L]](cond): Could not save OAuth token to file: 'file' must
    be a non-empty string

## Hello, tuber

By many metrics, [MrBeast](https://en.wikipedia.org/wiki/MrBeast) ranks
among the most popular YouTube channels of all time. Among the channel’s
most popular videos as of this writing is November 2021’s [“\$456,000
Squid Game In Real Life!”](https://www.youtube.com/watch?v=0e3GPea1Tyg)
has more than 900 million views to date.

Using `tuber`, we can start to peruse its impressive statistics with a
few lines of code:

``` r
video_id <- "0e3GPea1Tyg"

# See how many times a video was viewed and liked
video_stats <- get_stats(video_id = video_id)

cat(
  "The video has", 
  comma(as.double(video_stats$viewCount)),
  "views,",
  comma(as.double(video_stats$likeCount)),
  "likes and",
  comma(as.double(video_stats$commentCount)),
  "comments."
)
```

    The video has 910,026,757 views, 19,875,662 likes and 644,125 comments.

We can also dig into other details, including tags and more:

``` r
# See tags, video description and more
details <- get_video_details(video_id)

# Grab all of the video tags
details$items[[1]]$snippet$tags |>
  unlist() |> 
  as_data_frame()
```

    Warning: `as_data_frame()` was deprecated in tibble 2.0.0.
    ℹ Please use `as_tibble()` (with slightly different semantics) to convert to a
      tibble, or `as.data.frame()` to convert to a data frame.

    # A tibble: 0 × 0

Here’s where to find the video description:

``` r
cat(details$items[[1]]$snippet$description) 
```

    MAKE SURE YOU WATCH UNTIL GLASS BRIDGE IT'S INSANE!

    Watch Beast Games now on Prime Video!!! https://www.beastgames.com

    Thank you GoPro for supplying us with cameras to get some of these shots. You can get them here: https://prf.hn/l/6bNbQB3

    Shoutout to SOKRISPYMEDIA for helping with visuals!

    Check out Viewstats! - https://www.viewstats.com/

    For any questions or inquiries regarding this video please reach out to chucky@mrbeastbusiness.com

    ----------------------------------------------------------------
    follow all of these or i will kick you
    • Facebook - https://www.facebook.com/MrBeast6000/
    • Twitter - https://twitter.com/MrBeast
    •  Instagram - https://www.instagram.com/mrbeast
    --------------------------------------------------------------------

## More to explore

Unfortunately, there are a lot of useful things you can’t use `tuber` to
do. If working with YouTube videos and data becomes a part of your
reporting, there is a lot of software outside of R that you can explore.
For example:

- You can’t lift captions off a YouTube video.

- You also can’t download YouTube videos. For that, you might try
  [`yt-dlp`](https://github.com/yt-dlp/yt-dlp).

- Also, Google long ago ditched a parameter [used to retrieve related
  videos](https://developers.google.com/youtube/v3/revision_history#release_notes_06_12_2023)
  and is [suing a
  company](https://blog.google/innovation-and-ai/technology/safety-security/serpapi-lawsuit/)
  that provides a workaround.
