---
title: 'Create bilingual books yourself'
description: 'I describe a simple approach to create bilingual books for own usage'
image: bilingual_books2.png
---
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://stand-with-ukraine.pp.ua)

# Create bilingual books yourself

_February 2023_

Bilingual books are very useful in language learning. 

I'll describe a relatively simple approach one can create a bilingual books for own usage.
    
### 1. Acquire  PDF

First, buy online or find somewhere a PDF of the book you want to turn into bilingual. The book must be in a language you learn.  

### 2. Translate PDF

Now you need to translate the text of the source PDF to the language you know. 

As complex as it sounds, as easy it is. I've used the online service [https://www.onlinedoctranslator.com/en/translationform](https://www.onlinedoctranslator.com/en/translationform). You upload source PDF, and receive translated (with Google Translate) PDF.

*To those who say using Google Translate is not OK:*

Indeed, the translation can be not ideal, but:
- No big deal, since you use authentic source text, and it's fine to use less perfect translation
- Google Translation is much better nowadays

### 3. Merge source & translated PDFs
               
This step is a bit tricky and technical. You need to merge the two PDFs, but in a specific way. 

You need to build a merged PDF where the source and target PDF pages go interleaved. That is: 1st page source, 1st page target, 2nd page source, 2nd page target, and so on.

I used a pdftk tool for that 

```
sudo apt install pdftk
```

And came up with a small automation to do the job: [prepare_joined.awk](https://github.com/xonixx/bilingual_books/blob/main/prepare_joined.awk)

![](bilingual_books1.png)

### 3. Generate final bilingual book PDF
                                        
To do so just open merged PDF in Google Chrome and Print.

The key point here is to use *Pages per sheet: 2* here.

![](bilingual_books2.png)

### 4. Profit!
  
Now you can just print the final PDF to paper or put in on your Kindle, and enjoy your bilingual book!

![](bilingual_books3.png)