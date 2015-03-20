congressional-district-boundaries
=================================
Jeffrey B. Lewis, Brandon DeVine, and Lincoln Pritcher with Kenneth C. Martis

The webpage for this project can be found at
http://amypond.sscnet.ucla.edu/districts.

Description
-----------

These repositiories provides digital boundary definitions in GeoJson
format for every U.S. Congressional District in use between 1789 and
2012. These were produced as part of NSF grant SBE-SES-0241647 between
2009 and 2013.

The current release of these data is experimental. We have had done a
good deal of work to validate all of the shapes. However, it is quite
likely that some irregulaties remain. Please email jblewis@ucla.edu
with questions or suggestions for improvement. We hope to have a
ticketing system for bugs and a versioning system up soon. The
district definitions currently available should be considered a
pre-release version.

Many districts were formed by aggregragating complete county shapes
obtained from the National Historical Geographic Information System
(NHGIS) project and the Newberry Library's Atlas of Historical County
Boundaries. Where Congressional Districts boundaries did not coincide
with county boundaries districts shapes were constructed
district-by-district using a wide variety of legal and cartographic
resources. Detailed descriptions of how particular districts were
constructed and the authorities upon which we relied are available (at
the moment) by request.  


Project Team
------------

The Principal Investigator on the project was Jeffrey
B. Lewis. Brandon DeVine and Lincoln Pitcher researched district
definitions and produced thousands of digital district boundaries. The
project relied heavily on Kenneth C. Martis' The Historical Atlas of
United States Congressional Districts: 1789-1983. (New York: The Free
Press, 1982). Martis also provided guidance, advice, and source
materials used in the project.  


How to cite
-----------

Jeffrey B. Lewis, Brandon DeVine, Lincoln Pitcher, and Kenneth
C. Martis. (2013) Digital Boundary Definitions of U.S. Congressional
Districts, 1789-2012. [Data file and code book]. Retrieved from
http://amypond.sscnet.ucla.edu/districts on [date of download].

If you use the shapes in your research, please send along an email
describing your project and giving a citations to resulting to working
papers and publications Geographic information

The district definitions are organized by state and the range of
Congresses in which they were operative.  Each unique district has
been given a unique identifier with the following format SSNNBBBEEE
where SS is the state fips code, NN is the district number, BBB is the
number of first Congress in which that district was used and EEE is
the last Congress in which that district was used.

District geographic definitions are encoded in US Census standard
unprojected format using the NAD83 coordinate datum (PostGIS SRID
4269). The PROJ.4 string is:

+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs
Download

The files provide districts shapes for each Congress in ERSI's
Shapefile format. The current files are version 1.00 (June 20, 2013).


Documentation
=============

Our enumeration of Congressional districts in effect in a particular
Congress follows Martis. At large districts are numbered "0". In a few
cases, shapes describing Indian territories within states during the
18th and early 19th centuries are included in the shape files. These
territories are always assigned district number "-1". The
Congressional districts in the shape files match districts contained
in rollcall voting data files and Congressional roster files available
on Keith Poole's Voteview site here and here. There are a very few
instances in which there is no member representing a particular
district in a particular Congress (a file enumerating all known
discrepancies between the Voteview data and these shapes is available
here.

Starting with the 103rd Congress, district boundary files are produced
by the US Census and we rely on those shapes for Congresses beginning
with the 103rd. US Census Tigerline files associated the 1990
Decennial Census were used to construct districts from the 98th to the
102nd Congress (except where noted in the documentation files
below). For Congresses between the 1st and the 97th, district
boundaries were formed in one of two ways. For districts that were
made up of collections of complete counties, historical county
boundaries from NHGIS or were dissolved to form district
boundaries. Districts that divided one or more counties were formed on
a case-by-case basis. Sources relied upon for these districts are
described in the documentation files below.

Access to Excel .xlsx files containing references and documentation
related to how each district shape was drawn are available at the
http://amypond.sscnet.ucla.edu/districts. Access to these files is
limited due to possible copyright issues (some of the documentation
files include images of maps). To obtain access to these materials for
research purposes, please email jblewis@ucla.edu. File names indicate
the state and range of Congresses covered by districts described in a
particular documentation file.  [Click to show available documentation
files]

Copyright Jeffrey B. Lewis, 2013.

