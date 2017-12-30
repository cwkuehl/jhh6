@rem Start for programm JHH6 (c) 2018 cwkuehl.de

@rem For using a specific Java version
@rem set path=C:\Programme\Java\jdk1.8.0\bin;%path%

set classpath=.
set classpath=%classpath%;./Jhh-1.0.jar
start javaw -Djhh6.properties=.jhh6.properties de.cwkuehl.jhh6.app.Jhh6
@rem java -Djhh6.properties=.jhh6.properties de.cwkuehl.jhh6.app.Jhh6

@rem pause
