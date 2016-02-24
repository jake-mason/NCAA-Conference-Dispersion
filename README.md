# NCAA-Conference-Dispersion

With all of the conference realignment occuring in the NCAA over the past few years (most of this action has since died down), I wondered about the geographic reasoning behind the transferring schools' decisions. Most of the realignment emerged out of concerns for money, but what if we took a purely geostatistical look at the issue? For example, it seemed strange that Rutgers, a team from way out East, moved to the Big Ten, when that conference traditionally contained teams from the Midwest.

## On the map:

The blue rectangle represents the average location (i.e. the centroid) of a given conference. The exact location is usually meaningless, because most conferences' centroids end up in a lake or a forest somewhere, but this gives us an general idea, geographically, of where a conference is.

The green circles represent individual universities.

## Variable definitions:

### In the *Raw Data* tab:

  **zLatitude** and **zLongitude**: standardized (on z-distribution) values of a particular school's latitude/longitude, relative to the rest of the conference to which it belongs
  
  **absLongLat**: sum of the absolute values of zLatitude and zLongitude -- this gives a sense of just how "outlying" a school is, geographically, relative to the rest of the conference


### In the *Conference Dispersion* tab:

  **meanLatitude** and **meanLongitude**: mean values of the schools in a given conference's latitudes and longitudes -- this is the centroid of the conference.
  
  **avgZScore**: average z-score for the schools in a conference -- how far are each of the schools from each other, on average?
  
  As you might imagine, the variables **absLongLat** and **avgZScore** give great insight as to how far an individual school is from its conference's centroid, and how spread out a conference is, respectively.

## Want the data?
Go [here](https://www.dropbox.com/s/1j8z3yvo30fhqlt/colleges_fixed.csv?dl=0). All 11 major NCAA football conferences are represented.
