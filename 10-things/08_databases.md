# 8: Query larger-than-memory databases


## When your data is too big for memory

When I was first learning R a few years ago, I was fascinated by the
[Federal Judicial Center’s Integrated
Database](https://www.fjc.gov/research/idb) (IDB), which provides
case-related data about federal civil, criminal, bankruptcy and
appellate court cases dating from 1970 to the present. Basically, it
keeps tabs on every case in PACER.[^1]

There was one problem: Some of these files are pretty big. They’re not
*enormous*, but they’re large enough that they can be slow to load and
clunky to analyze in R. They didn’t easily fit into memory on my laptop
at the time, so it would freeze and RStudio would crash.

Typically, for a larger database of this kind, it will probably make
sense to query the data using SQL. But depending on your comfort level
with SQL, and the rest of your workflow, there are a growing number of R
packages that make it easier to handle large databases without leaving
R.

Let’s talk about two of those packages: `dbplyr` and `duckplyr`.

## Large-ish data with dplyr: The old way

Suppose you want to analyze all federal civil court cases that were
filed, terminated or pending between the late 1980s and the present.
That data is available from the Federal Judicial Center
[here](https://www.fjc.gov/research/idb/civil-cases-filed-terminated-and-pending-sy-1988-present).

If you were working with `dplyr` only, you might do something like this.

> For the purpose of this demo, I’ve created a sample file that only
> contains the first 100 rows of FJC’s most-recent civil data file. You
> can find the original data
> [here](https://www.fjc.gov/sites/default/files/idb/textfiles/cv88on.zip).
> You can read the rendered version of this fall to see accurate runtime
> estimates for analyzing the complete file in 08_databases.md.

``` r
## Run this code during demo ##
# fjc_old <- readr::read_csv(here::here("sample_fjc.csv"))

## Or you can read it from the repo
# url_fjc <- "https://raw.githubusercontent.com/DiPierro/nicar26-10-things-R/refs/heads/main/sample-data/sample_fjc.csv"
# fjc_old <- readr::read_csv(url_fjc)
```

Here’s the full dataset.

``` r
# Do not run during demo ##
# This code actually downloads and reads in FJC data ##

# Set parameter for link to compressed file
zip_fjc <- "https://www.fjc.gov/sites/default/files/idb/textfiles/cv88on.zip"

# Create temporary file and directory to avoid a large download
temp_zip <- tempfile()
temp_dir <- tempfile()
dir.create(temp_dir)

# Download the file
download.file(zip_fjc, temp_zip, mode = "wb")
unzip(zipfile = temp_zip, exdir = temp_dir)
file_path <- file.path(temp_dir, "cv88on.txt")
file_details <- file.info(file_path)

# Read the file using readr::read_tsv
start_readr <- Sys.time()
fjc_old <- readr::read_tsv(file_path, col_names = TRUE, col_types = "c")
```

    Warning: One or more parsing issues, call `problems()` on your data frame for details,
    e.g.:
      dat <- vroom(...)
      problems(dat)

``` r
end_readr <- Sys.time()

print(end_readr - start_readr)
```

    Time difference of 1.232782 mins

Here’s the problem: The file is 2 GiB and has 10,760,870 rows. Just
reading it into R will take a long time.

Running even simple `dplyr` operations will also be a little sluggish.

``` r
library(dplyr)
```


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
start_analyze <- Sys.time()

fjc_old |> 
  # Remove cases with a dummy termination date
  filter(TERMDATE != "01/01/1900") |> 
  # Add a column computing how long cases are pending
  mutate(time_pending = lubridate::mdy(TERMDATE) - lubridate::mdy(FILEDATE)) |> 
  # Summarize the average time it takes to resolve a lawsuit 
  # for each nature of suit (NOS) in each circuit court
  summarize(
    .by = c(NOS, CIRCUIT),
    mean_time_pending = mean(time_pending, na.rm = TRUE)
  ) |> 
  arrange(desc(mean_time_pending))
```

    # A tibble: 1,309 × 3
         NOS CIRCUIT mean_time_pending
       <dbl> <chr>   <drtn>           
     1   420 9       3033.667 days    
     2   930 3       2674.000 days    
     3   420 7       2491.000 days    
     4   420 3       2314.000 days    
     5   420 2       2285.500 days    
     6   421 2       1992.000 days    
     7   535 9       1963.156 days    
     8   420 4       1938.000 days    
     9   310 0       1878.071 days    
    10   421 4       1815.000 days    
    # ℹ 1,299 more rows

``` r
end_analyze <- Sys.time()
```

Here’s how long that took to compute.

``` r
print(end_analyze - start_analyze)
```

    Time difference of 12.76302 secs

## Hello, dbplyr

`dbplyr` is a handy R package that could be useful for situations like
this one – and especially if your data is an order of magnitude larger.
To quote its [documentation](https://dbplyr.tidyverse.org/):

> The goal of dbplyr is to automatically generate SQL for you so that
> you’re not forced to use it.

Its developers suggest that it’s best for when:

- Your data is already in a database.

- Your data is too big to fit in memory.

We can give it a whirl with our FJC file like so. This is a little
complex. What we’re doing is that we’re using two other R packages to
connect to a database from R. The first package is called `DBI`. The
second is called `RSQLite` and it’s one of [several R
packages](https://dbplyr.tidyverse.org/articles/dbplyr.html#getting-started)
that you can use to connect to a database backend such as MySQL,
Postgres or Google’s BigQuery.

In our case, we’re creating a temporary SQLite database with no data in
it.

``` r
# Run once
# install.packages("RSQLite")

library(dbplyr)
```


    Attaching package: 'dbplyr'

    The following objects are masked from 'package:dplyr':

        ident, sql

``` r
con <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
```

Next, we’re going to copy the FJC data to our empty database. We’ll also
create a reference to it by using `tbl()`.

``` r
copy_to(
  dest = con, 
  df = 
    fjc_old |> 
    # Add a column computing how long cases are pending
    # dbplyr will struggle to find the SQL equivalent of this code
    mutate(time_pending = lubridate::mdy(TERMDATE) - lubridate::mdy(FILEDATE)), 
  name = "fjc_db",
  temporary = FALSE, 
  indexes = list("CIRCUIT", "NOS"),
  overwrite = TRUE
)

fjc_db <- tbl(con, "fjc_db")
```

Now, we can run the same code as we did before.

``` r
start_dbplyr <- Sys.time()
fjc_db |> 
  # Remove cases with a dummy termination date
  filter(TERMDATE != "01/01/1900") |> 
  # Summarize the average time it takes to resolve a lawsuit 
  # for each nature of suit (NOS) in each circuit court
  summarize(
    .by = c(NOS, CIRCUIT),
    mean_time_pending = mean(time_pending, na.rm = TRUE)
  ) |> 
  arrange(desc(mean_time_pending))
```

    # Source:     SQL [?? x 3]
    # Database:   sqlite 3.51.2 [:memory:]
    # Ordered by: desc(mean_time_pending)
         NOS CIRCUIT mean_time_pending
       <dbl> <chr>               <dbl>
     1   420 9                   3034.
     2   930 3                   2674 
     3   420 7                   2491 
     4   420 3                   2314 
     5   420 2                   2286.
     6   421 2                   1992 
     7   535 9                   1963.
     8   420 4                   1938 
     9   310 0                   1878.
    10   421 4                   1815 
    # ℹ more rows

``` r
end_dbplyr <- Sys.time()
```

I have to admit that the FJC database is a little on the small side for
`dbplyr` to be super useful. But as you work with larger data – or tap
into databases that are already being kept in BigQuery or some other
database – `dbplyr` is a useful tool to have in your kit. Here’s how
long the query took to run:

``` r
end_dbplyr - start_dbplyr
```

    Time difference of 8.436154 secs

## Hello, duckplyr

The R package `duckplyr` combines the ease of writing `dplyr` commands
like `filter()` and `summarize()` with the speed of the database
management system [DuckDB](https://duckdb.org/).

Similar to `dbplyr` his magic sentence from the
[documentation](https://duckplyr.tidyverse.org/) explains why this is so
cool:

> The duckplyr package will run all of your existing dplyr code with
> identical results, using DuckDB where possible to compute the results
> faster. In addition, you can analyze larger-than-memory datasets
> straight from files on your disk or from the web.

Firing up `duckplyr` is as simple as…

``` r
# Installation - Run once if on personal laptop
# install.packages("duckplyr")

# Load libraries
library(duckplyr)
```

    The duckplyr package is configured to fall back to dplyr when it encounters an
    incompatibility. Fallback events can be collected and uploaded for analysis to
    guide future development. By default, data will be collected but no data will
    be uploaded.
    ℹ Automatic fallback uploading is not controlled and therefore disabled, see
      `?duckplyr::fallback()`.
    ✔ Number of reports ready for upload: 2.
    → Review with `duckplyr::fallback_review()`, upload with
      `duckplyr::fallback_upload()`.
    ℹ Configure automatic uploading with `duckplyr::fallback_config()`.

    ✔ Overwriting dplyr methods with duckplyr methods.
    ℹ Turn off with `duckplyr::methods_restore()`.

``` r
library(dplyr)
conflicted::conflict_prefer("filter", "dplyr")
```

    [conflicted] Will prefer dplyr::filter over any other package.

If you want to ingest a large file without downloading it, you can use
this workflow:

``` r
# DuckDB extension that makes it possible to query files in R without downloading them first
db_exec("INSTALL httpfs")
db_exec("LOAD httpfs")

# Another DuckDB extension that makes it possible to ingest zip files
# You can see the source code here: https://github.com/isaacbrodsky/duckdb-zipfs
db_exec("INSTALL zipfs FROM community")
db_exec("LOAD zipfs")

# Set a new parameter with the full zip file address
zip_fjc <- "zip://https://www.fjc.gov/sites/default/files/idb/textfiles/cv88on.zip/cv88on.txt"

# Read in FJC database using DuckDB
start_duck_read <- Sys.time()
fjc <- 
  read_csv_duckdb(
    file_path, 
    prudence = "thrifty", # We'll talk about this step in a moment
  )
end_duck_read <- Sys.time()
print(end_duck_read - start_duck_read)
```

    Time difference of 0.202529 secs

Great. That was fast and easy.

``` r
start_duck_analyze <- Sys.time()

fjc |> 
  # Filter out any cases in which a case was 'terminated' before it was filed
  # This typically indicates there is a placeholder termination date; the case might be open
  filter(TERMDATE > FILEDATE) |> 
  # Add a column computing how long cases are pending
  mutate(time_pending = TERMDATE - FILEDATE) |> 
  # Summarize the average time it takes to resolve a lawsuit 
  # for each nature of suit (NOS) in each circuit court
  summarize(
    .by = c(NOS, CIRCUIT),
    mean_time_pending = mean(time_pending, na.rm = TRUE)
  ) |> 
  arrange(desc(mean_time_pending))
```

    # A duckplyr data frame: 3 variables
         NOS CIRCUIT mean_time_pending
       <dbl>   <dbl>             <dbl>
     1   420       9             3034.
     2   930       3             2674 
     3   420       7             2491 
     4   420       3             2314 
     5   420       2             2286.
     6   535       9             2009.
     7   421       2             1992 
     8   420       4             1938 
     9   310       0             1896.
    10   421       4             1815 
    # ℹ more rows

``` r
end_duck_analyze <- Sys.time()
```

Now, our computation time should be a little faster, too.

``` r
print(end_duck_analyze - start_duck_analyze)
```

    Time difference of 3.768225 secs

## Working with ‘prudence’ in duckplyr

The joy of `duckplyr` is that you can control when to *materialize*
data, which helps us to avoid using too much memory by accident. The
package lets users choose from three levels of *prudence*:

- *lavish* (careless about resources): Runs the computation with no
  questions asked. The FJC data, with just over 1 million rows and 46
  columns, could be just slightly too big for this setting.

- *stingy* (avoid spending at all cost): Always throws an error when
  accessing a column or printing the number of rows. You can override
  this by calling the function `collect()` before using any `dplyr`
  verbs.

- *thrifty* (use resources wisely): A compromise. Runs the computation
  if the data is small enough.

For anything that you can’t do with `ducklyr`, the package will fallback
to `dplyr` – but only if a dataframe is lavish or thrifty.

As an example, the following code will fail:

``` r
# This code throws an error
# fjc |> nrow()
```

But we can override the *thrifty* setting by using `collect()`.

``` r
fjc |> 
  # Select first column to avoid read errors in the CSV
  select(CIRCUIT) |> 
  # Use collect() to override thrifty prudence setting
  collect() |> 
  nrow()
```

    [1] 10760870

## More to explore

- [“R for Data Science” - Chapter 21,
  Databases](https://r4ds.hadley.nz/databases.html)

- [“Working with databases and SQL in
  RStudio”](https://posit.co/blog/working-with-databases-and-sql-in-rstudio/)

[^1]: If you want to use the IDB in your own work, I highly recommend
    reading this post from the [Free Law
    Project](https://free.law/idb-facts/) and this one from [SCALES
    OKN](https://livingreports.scales-okn.org/#/idbCrosswalkReport).
