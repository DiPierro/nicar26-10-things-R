# 2: Chat with your documents


## What’s RAG? Using R and AI to chat with your documents

We all know that large language models (LLMs) can hallucinate, give
generic answers to specific questions or extrapolate from out-of-date
information. The idea behind Retrieval-Augmented Generation (RAG) is to
combine what the LLM already knows – the gobs of data it was trained on
– with specific new context we send to it, such as documents or data.
This way, when we ask a question, the LLM can retrieve relevant
information from the new context we’ve provided.

In this module, we’ll walk through a brief example that demonstrates how
to use RAG to chat with documents using the R package `ragnar`.

> If you’re on your laptop, don’t forget to install ellmer and ragnar:
> install.packages(“ragnar”, “ellmer”). And check out
> `01_coding_assistant.qmd` for a refresher on downloading Ollama.

## Example: California’s Bureau for Private Postsecondary Education

California’s Bureau for Private Postsecondary Education is the consumer
protection agency that regulates and oversees certain private colleges
and other postsecondary programs such as beauty and trucking schools.
Here’s its [mission statement](https://www.bppe.ca.gov/about_us/):

> The Bureau protects students and consumers in California and beyond,
> through the oversight of California’s private postsecondary
> educational institutions, by conducting qualitative reviews of
> educational programs and operating standards, proactively combating
> unlicensed activity, impartially resolving student and consumer
> complaints, and providing support and financial relief to harmed
> students.

The Bureau publishes PDFs describing [disciplinary
actions](https://www.bppe.ca.gov/enforcement/disciplinary_actions.shtml)
on its website. These documents may shed light on how schools are
treating students and what the Bureau is doing to hold them accountable.
They typically explain the factual allegations leading to discipline and
how a case was resolved, among other important details. The folder
`sample-pdfs` includes a very small sample of the type of disciplinary
documents typically published by the Bureau.

## Hello, ragnar

To get started, open up the Terminal or another bash shell and pull an
[embedding model from Ollama](https://ollama.com/search?c=embedding)
using a command like `ollama pull embeddinggemma`.

In the code below, we create an empty knowledge store. This is where
we’ll stash the documents we want `ragnar` to reference later.

``` r
library(ragnar)

# Set parameter for the model
# Choose a different one from ollama if you like
model_embed <- "embeddinggemma"

# Set up DuckDB storage
store_location_demo <- "bppe-demo.ragnar.duckdb"

store <- 
  ragnar_store_create(
    store_location_demo,
    embed = \(x) embed_ollama(x, model = model_embed),
    overwrite = TRUE # If you need to run more than once
  )
```

For the purpose of this demo, we’ll only select the first 10 documents
and ingest them into the knowledge store, which is a [DuckDB
database](https://duckdb.org/).

``` r
# Generate a list of sample PDFs
dir_pdf <- here::here("sample-pdfs")
pdfs <- list.files(dir_pdf, full.names = TRUE)

# Ingest pages into DuckDB

# Loop through the first 10 PDFs
for (pdf in pdfs[1:10]) {
  message("ingesting: ", pdf)
  chunks <- 
    pdf |> 
    # Convert each PDF into markdown; this all can use URLs as input!
    read_as_markdown() |> 
    # Intelligently split each document into shorter, overlapping pieces.
    # This can be tailored in various ways, including to make the chunks larger or smaller 
    markdown_chunk()
  # Insert chunks into the empty store
  ragnar_store_insert(store, chunks)
}
```

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/10_2025_american.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/1stacademy_acc.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/1stamdacc_14960906.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/1stamdsoi_14960906.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/1stamdsoi_coding.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/1stamsoi_1001548.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/2ndmodcit_1617026.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/3d_microblading_inc_ord.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/3dbrowsbymh_appaff.pdf

    ingesting: /Users/amydipierro/GitHub/nicar26-obscure-R/sample-pdfs/3rdmod_1314002.pdf

> Note: Under the hood, `ragnar` is running a bunch of packages that
> python users might already use, such as `pandas` and `pdfminer-six`.

Before we can retrieve documents in answer to a query, we have to create
a search index. That’s just one more line of code.

``` r
# Build index
ragnar_store_build_index(store)

# If you already have a store, you can read it in like this 
# store <- ragnar_store_connect(store_location_demo, read_only = TRUE)
```

## Trying out retrieval

The hard part is over. Now, it’s time to interview some documents!

``` r
# Query index
response <- ragnar_retrieve(store, "Which institution faced the most serious disciplinary action?")
response
```

    # A tibble: 5 × 9
      origin         doc_id chunk_id start   end cosine_distance bm25  context text 
      <chr>           <int> <list>   <int> <int> <list>          <lis> <chr>   <chr>
    1 /Users/amydip…      2 <int>    16037 18424 <dbl [2]>       <dbl> ""      "Res…
    2 /Users/amydip…      3 <int>     3210  4975 <dbl [1]>       <dbl> ""      "req…
    3 /Users/amydip…      4 <int>     8023  9478 <dbl [1]>       <dbl> ""      "\"T…
    4 /Users/amydip…      4 <int>    48037 49563 <dbl [1]>       <dbl> ""      "717…
    5 /Users/amydip…      4 <int>    54403 55997 <dbl [1]>       <dbl> ""      "b.\…

Let’s explore this response. Here’s a few things to notice:

- `ragnar` has returned five chunks from two different documents. We can
  see their titles in the column `origin`.
- We can read the underlying chunk text in the column `text`.
- `ragnar` also computes [Best Matching
  25](http://en.wikipedia.org/wiki/Okapi_BM25) (`bm25`), a ranking
  function used by search engines to estimate relevance to our query,
  and [cosine
  distance](https://www.ibm.com/think/topics/cosine-similarity).

We can inspect the most-relevant text returned like this:

``` r
response$text[1]
```

    [1] "Respondent is  subject to  disciplinary action under Regulations section 71650,\n\nsubdivision (a) and section 94893 of the California Education Code, in that Respondent failed to\n\nobtain authorization from BPPE for  a substantive change in operation of the institution. The\n\ncircumstances are as follows:\n\n30.  On or about May 16, 2018, Respondent taught a class in Vietnamese; however,\n\nRespondent did not have approval from BPPE to provide instruction in a language other than\n\nEnglish.  Specifically, instructors taught the manicuring students in Vietnamese, the instructor\n\n10\n\nhad to translate for the students to complete aBPPE survey, and some of the students\n\n11\n\nrequested the Vietnamese version of the survey.  Complainant refers to,  and by this reference\n\nincorporates, the allegations set forth above  in paragraphs 18 through 30, as though set forth fully\n\nherein.\n\nSECOND CAUSE FOR DISCIPLINE\n\n(Failure to Notify the Bureau of Non-Substantive Changes)\n\n31.  Respondent is subject to disciplinary action under Regulations section 71660, in that\n\nRespondent failed to notify BPPE of a non-substantive change. On or about May 16, 2018,\n\nRespondent admitted the building space at 8819 Garvey A venue was sub-leased, because she\n\nwas no longer offering the massage program, and no longer needed the space.  Respondent\n\nfailed to notify BPPE that she was no longer offering the massage instruction at the 8819\n\nGarvey Avenue location. Complainant refers to, and by this reference incorporates, the\n\nallegations set forth above in paragraphs 18 through 30, as though set forth fully herein.\n\nTHIRD CAUSE FOR DISCIPLINE\n\n(Failure to Maintain and Provide Student Records)\n\n32.  Respondent is  subject to disciplinary action under Regulations section 71930,\n\nsubdivision (e),  in that on or about May 16, 2018, Respondent failed to provide BPPE the\n\ncomplete SPFS and  STRF supporting documents during the m1am1ounced compliance\n\n12\n\n13\n\n14\n\n15\n\n16\n\n17\n\n18\n\n19\n\n20\n\n21\n\n22\n\n23\n\n24\n\n25\n\n26\n\n27\n\n28\n\n9\n\n(1ST ACADEMY OF BEAUTY) ACCUSATION\n\n\n\n---\n\n1\n\n2\n\n3\n\n4\n\n5\n\n6\n\n7\n\n8\n\n9\n\ninspection Complainant refers to,  and by this reference incorporates, the allegations set forth\n\nabove in paragraphs 18 through 30, as though set forth fully herein.\n\nFOURTH CAUSE FOR DISCIPLINE\n\n(Failure to  Maintain Records)\n\n33.  Respondent is subject to disciplinary action under Regulations section 71920,\n\n"

Try some other queries on your own. Perhaps something like:

- Which investigations had to do with teaching in a language other than
  English without approval?
- How frequently does the Bureau start an investigation because of a tip
  or a complaint?

> Warning: There’s no substitute for reading complicated documents like
> these. RAG is not a cure-all against LLMs making mistakes.

## Combining ragnar and ellmer

One of the nicest features of `ragnar` is that it integrates nicely with
another AI for R library, `ellmer`. We can use a free and open model
from Ollama to chat with our documents, but I’ve gotten the best results
with the free tier from Google Gemini and Anthropic’s Claude.

> You can set your ANTHROPIC_API_KEY environment variable with
> usethis::edit_r_environ(). You’ll also need to create a Claude account
> and buy some credits.

``` r
# Create a system prompt. This one is borrowed from the ragnar docs
system_prompt <- 
  stringr::str_squish(
"
Before responding, retrieve relevant material from the knowledge store. Quote or paraphrase passages, clearly marking your own words versus the source. Provide a working link for every source cited, as well as any additional relevant links. Do not answer unless you have retrieved and cited a source.
"
  )

# Create a chat object as before
chat <- ellmer::chat_google_gemini(system_prompt)
```

    Using model = "gemini-2.5-flash".

``` r
# Alternative code for Antrhopic
# chat <- ellmer::chat_anthropic(system_prompt, model = "claude-haiku-4-5-20251001")

# Alternative code for Ollama implementation
# chat <- ellmer::chat_ollama(system_prompt, model = "llama3.1")

# Register a 'retrieve' tool with ellmer
ragnar_register_tool_retrieve(chat, store, top_k = 10)
```

Now, we can test the results.

``` r
chat$chat("What are some of the most surprising factual allegations described in these documents?")
```

Keep experimenting. How reliable are the answers? What could you do to
improve the response?
