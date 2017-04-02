# Elliston-Poetry-Archive-Sonification-Project
This repository has all the code written for this project. The objective of this project is to convert the Poetry archive into text and performing Text analytics on it. This project is a part of Digital Humanities Center - University of Cincinnati.

Below 3 transcription methods were used to identify the best one suited for our application.    
1.  [CMU Sphinx](http://cmusphinx.sourceforge.net/)   
2.  [HPE Haven Speech to Text](https://dev.havenondemand.com/apis/recognizespeech#overview)
3.  [IBM Watson](https://www.ibm.com/watson/developercloud/speech-to-text.html)

IBM Watson outperformed all others for wave files having bandwidth 8kHz as well as 16kHz.

Once we have the transciptions the next step was to model the text using LDA (Latent Dirichlet Allocation) to get the similarities in the semantics in different poems.

Different packages that leverage LDA are Mallet(Java), Topicmodel(R), gensim(Python).  
I used Mallet(Java) initially and then used the R wrapper for it - mallet(R).   
For Visualization I used LDAVis, ggplot2.

How to determine the number of topics?
1. Intuitive approach: See the destribution of topic-document; topic-words, word clouds of the topics and then decide the number of topics
2. Use measured like Perplexity, Griffiths2004 etc. to detemine the #of topics. a detailed explanation can be found [here](http://www.rpubs.com/MNidhi/NumberoftopicsLDA)
