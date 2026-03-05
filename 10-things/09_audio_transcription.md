# 9: Audio transcription


## Transcribing audio

Transcribing interviews, public meetings and other reporting situations
can be a huge time-saver. But if you don’t have the budget for
[Otter.ai](https://otter.ai/) – or if you’re working with confidential
or sensitive audio – you might want to use a local model. OpenAI’s
[Whisper](https://en.wikipedia.org/wiki/Whisper_(speech_recognition_system))
is an open source, automatic speech recognition and transcription model.
There are lots of ways to use Whisper, including a [brand new
implementation available in R](https://github.com/cornball-ai/whisper).

> Note: The `whisper` R package is brand new – it was first committed to
> GitHub a few months ago and is actively being developed. It’s
> available on [the Comprehensive R Archive Network, or
> CRAN](https://cran.r-project.org/web/packages/whisper/index.html),
> which distributes packages that meet certain quality standards.
>
> Under the hood, it uses another useful R package,
> [`hfhub`](https://mlverse.github.io/hfhub/), which makes it easier to
> download files from [Hugging Face
> Hub](https://huggingface.co/docs/hub/en/index), a platform for open
> source models and datasets.

## Example: Transcribing oral arguments in court

One thing you *don’t* need to transcribe right now are [oral
arguments](https://www.courtlistener.com/help/coverage/oral-arguments/)
from the Supreme Court and the Federal Circuit Courts, which are
available in a great archive managed by the [Free Law
Project](https://free.law/).

But as a test, let’s see how a small version of the Whisper model
compares to the Free Law Project’s [transcript of a recent
hearing](https://www.courtlistener.com/audio/102770/asucena-velazquez-olais-v-pamela-bondi/?type=oa&type=oa&q=&order_by=score+desc&argued_after=02%2F01%2F2026&page=2)
in the Court of Appeals for the Seventh Circuit.

The code to use `whisper` is straightforward.

``` r
library(whisper)

# Download the .mp3 file
url <- "https://media.ca7.uscourts.gov/sound/external/ch.25-1244.25-1244_02_19_2026.mp3"
olais_v_bondi <- curl::curl_download(url = url, destfile = "olais_v_bondi.mp3")

# You can also access the file locally with
# olais_v_bondi <- here::here("olais_v_bondi.mp3)

# Transcribe! This line will download a `tiny` version of Whisper the first time you run it.
# Larger models are also available: base, small, medium and large-v3
result <- transcribe(file = olais_v_bondi, model = "tiny", language = "en")
```

    Loading model: tiny

    Loading weights from: /Users/amydipierro/.cache/huggingface/hub/models--openai--whisper-tiny/snapshots/169d4a4341b33bc18d8881c4b69c2e104e1cc0af/model.safetensors

    Audio duration: 827.5s

    Processing 29 chunks...

      Chunk 1/29

      Chunk 2/29

      Chunk 3/29

      Chunk 4/29

      Chunk 5/29

      Chunk 6/29

      Chunk 7/29

      Chunk 8/29

      Chunk 9/29

      Chunk 10/29

      Chunk 11/29

      Chunk 12/29

      Chunk 13/29

      Chunk 14/29

      Chunk 15/29

      Chunk 16/29

      Chunk 17/29

      Chunk 18/29

      Chunk 19/29

      Chunk 20/29

      Chunk 21/29

      Chunk 22/29

      Chunk 23/29

      Chunk 24/29

      Chunk 25/29

      Chunk 26/29

      Chunk 27/29

      Chunk 28/29

      Chunk 29/29

``` r
# Check out the result
cat(result$text)
```

    Our last case of the day is the lock-aid O'lay against the Bundy. Mr. Breastman. >> May please the court. The agency had jurisdiction to reopen this removal order. Pursuing to its own authority. >> Let me tell you what I say is the problem in this case. I understand that the removal order in 19, the 2018 removal order has, in fact, been executed. Correct. And your client was removed under this order. >> Right. >> So what is left? What is left, I can understand that the agency could reinstate it and propose to remove or could follow new proceeding. Has it reinstated the 2018 order? Not at this time. No. The agency's brief says it's opening a new proceeding. And that leads to the question. Since there appears to be no outstanding removal order binding your client, what there can possibly be, you have to wait until a new removal order is entered. Well, you're on a thank you for bringing that up. We believe the fact that there still is this removal order that has not been rescinded as your Honor said. It's over. But it has like a prison sentence that's been fully served. You can't challenge it after it's over. But there are ongoing legal consequences for this. There might be ongoing legal consequences if it's reinstated. Well, even so hasn't been well, you're on a The government has not agreed not to reinstate the order. If they reinstate the order, then your client will have whatever rights are available to an alien whose removal order is reinstated. But it hasn't been reinstate. The 1926 where they say her remedy would be that it pinopily of rights that she has in a criminal proceeding. Your honor and what's still affecting her now is the removal of her. She has not been indicted for illegal reentry. That all things that might happen, this is goes back to our first case. Things that might happen in the future and haven't happened aren't litigable. You have to wait till they happen that there's something else that we mentioned in our reply. Well, you're on a, we certainly haven't petition for review and we have not challenged the 2018 order directly. If this court wanted to construe our petition as challenging the 2018 order, I think this court could now after Riley considering the 30 days is not jurisdictional, but that's something we certainly have an argued. You're on a, one thing that is still in place addressing your question, Judge Easterbroke, is that she is that she is inadmissible to the country under 1182 A9C because of this removal order now. It creates an inadmissibility bar to adjust her status or get a green card through a US consular abroad through her US citizen life. So that is an ongoing consequence right now. The inadmissibility provisions that the 2018 removal order erects and bars her from the US. from adjusting status or getting her green card abrupt. But your email asks that they rescind the final administrative removal order Farrow. What authority would they even have to do that? Well, they have, it's done. Well, thank you for the question. They have their own inherent authority to review their own decisions to make sure that the administrative process has integrity and they also have authority under 8 CFR And are 8 CFR 103.5. final action. They received our request, our motion to reopen. Motion to reopen our subject to time limits. Do you understand that you met the time limit? Your honor, we certainly talked about equitable tolling in our motion. In other words, you don't. We did not, we did not file within 30 days. It's 90 days. I think for motion to reopen. Well, administrative or 30 days. Well, it's CFR. Thank you, Your honor. We did not file what we did was we filed within 30 days of the final agency action definitively resolving denying our request to reopen and this was not informal chatter your honor that your honors this was after months of review we filed a motion to reopen in July We got a response in January They discussed with us that they were reviewing the motion they as they conceded it was after consultation with the HS supervisor supervisor after consultation with DHS attorneys and they issued a response that as I mentioned definitively denied our reopening and firmly left in place the removal order from 2018. This is classic final agency action, consummation of the agency process and definitive consequences. So yes, they have not reinstated, but they certainly can reinstate the order right now. There's nothing preventing them from reinstating the order under 8 USC 1231A5. As I mentioned, there's nothing preventing them from trying to indict her. Right now under 8 USC 1326 and the fact that the removal order is outstanding and existed makes her inadmissible to the country under 8 USC 1182 A9C. So your honors, this certainly has has ongoing legal consequences. And our position is narrow. Review was available when there's a denied motion to reopen, which asserts a concrete legal defect affecting the validity of the removal law. And that's what we did here. We asserted a defect. The agency was presented with evidence that the sole predicate conviction to the removal law had been vacated, They did not understand what their basis was. This was a one line email response, not engaging agencies binding precedent, not engaging with any of the facts and not leaving us with any idea why they decided what they did. I see, I'm into my rebuttal time, I'd like to reserve the balance of my time. Mr. Insanio. Good morning, Your Honor. Please, Cork. And your Insanio on behalf of the Attorney General. Good evening. Particip your keep saying. I would like you to bring us up to date on what's going on for proceeding begun in July. My brief speech as of September 9. What's happened since then? My understanding is removal proceedings are ongoing Your Honor. And? Nothing has happened since September 9. Not that I'm aware of Your Honor. No. As I understand the agency's position, it's been pressing quite a number of courts. Is that somebody who is not eligible for admission to the United States at all, custody is mandatory, but I take it as an occurred. there's been more complexity because an NTA has been issued, whether or not petition will or will not be detained is really not up to the point. - But basically where we were on September 9, which is the last date in your brief. - Correct, you know, and really look, this court is well aware that jurisdiction is asserted here under Section 1252. That requires fine, all of remove the order. It doesn't require what position it keeps saying today to this quote, which is final agency action. That sounds an awful lot like an attempt to import APA language into this case. But again, jurisdiction was a surge under 1252. jurisdiction was a surge review. The email, not the underlying removal order. So any attempt so far in this process to try to even suggest this quote review, 2018 order. It's well-linked appropriate at this point. You know, we are so far into we are so far into these proceedings. So really, there's no great complexity here. Where's the final removal order? There is none. It was executed in 2018. It has not been reinstated. There's been no removal order issued by the immigration judge. And at the time, when the immigration judge, if the immigration judge issues removal order, then improper due course, the court can review it and any decisions made there in. That includes the newly raised concerns about inadmissibility And the possibility, which whether that's correct or not, that's up to the immigration judge deciding the first instance. But again, your honor is just nothing left for this court to review. There's no removal order and that's the basis of this court's jurisdiction. There's really nothing more than I need to say unless your honor is having it for the questions. Thank you, Your Honor. - Thank you, Council. Anything further than Mr. Breastwood? - Thank you. Section 1252A1 authorizes review of final orders of removal. In the Supreme Court, and this court has long recognized that denials of reopening tied to those orders are reviewable because they determine whether the order remains in effect. And that's 1252B6. The fact that the removal order has been executed should have no effect on this court's jurisdiction. The final administrative removals orders are reviewable under 1252. The only removal order that's not reviewable under 1252 is under 8 USC 1225 and that is not what we're here for. We're challenging the agencies refusal to reopen the removal order and this court has jurisdiction to review that under 1252 B6. And I know that Riley Guzman Chavez and Nassralla are discussed a lot by my friend and those cases involve collateral proceedings that do not affect the validity of the underlying remover. And this is where the government's brief is incorrect on pages seven, a 13 where they claim that we're not challenging the validity of a remover and we are. That is precisely what we're doing. And this case is rather unusual when this sole statutory predicate must. I don't even understand that argument. You are contending that legal developments in state court after the removal order was entered. Might affect the prospective force of an order that's already been executed. What happened in state court after your client illegally re-entered the United States? Doesn't affect the validity of the the validity of the 2018 order. That's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's why the -- that's of 2018. Your Honor, the 2018 order is still hanging over her head and that's what we're challenging through our emotion to reopen. Thank you. Thank you. The case is taken under advisement and the court will be in recent.

Whoa! What’s up with “that’s why the” over and over again? This tiny
version of `whisper` is not perfect and definitely will need to be
double-checked. But given it’s free and fairly fast.
