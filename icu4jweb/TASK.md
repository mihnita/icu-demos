The current folder contains a JSP application. 
Each page is a demonstration of some i18n functionality implemented using ICU4J. 

Add an extra page that to investigate IDNA, using com.ibm.icu.text.IDNA and
whatever other ICU4J classes you might need.

Use this page as a model: https://icu4c-demos.unicode.org/icu-bin/idnbrowser. 
Spend some time to understand all the pages and view modes there, because it is quite deep, 
and you need to implement something as close as you can. 
Follow the de model of that page closely. Not necesarily all styles, but all content and functionality. 

Do not touch anything else, only what is needed to do the job. 
If you get stuck, don't guess, ask.

Use `mvn package cargo:run` to run the server. 
Then connect to it using http://localhost:8080/ and check that it works correctly.
