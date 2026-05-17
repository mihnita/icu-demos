The current folder contains a JSP application. 
Each page is a demonstration of some i18n functionality implemented using ICU4J. 

Add an extra page that to investigate locale properties, using ICU4J classes.

Use this page as a model: http://192.168.1.5:8888/icu-bin/locexp 
Spend some time to understand all the pages and view modes there, because it is quite deep, 
and you need to implement something as close as you can. 

Do not touch anything else, only what is needed to do the job. 
If you get stuck, don't guess, ask.

Use `mvn package cargo:run` to run the server. 
Then connect to it using http://localhost:8080/localeExplorer.jsp and check that it works correctly.
