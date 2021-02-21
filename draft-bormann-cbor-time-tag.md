---
title: >
  Concise Binary Object Representation (CBOR) Tags for Time, Duration, and Period
abbrev: CBOR tag for extended time
docname: draft-bormann-cbor-time-tag-latest
# date: 2021-02-21

stand_alone: true

ipr: trust200902
keyword: Internet-Draft
cat: info

pi: [toc, sortrefs, symrefs, compact, comments]

author:
  -
    ins: C. Bormann
    name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org
  - name: Ben Gamari
    org: Well-Typed
    email: ben@well-typed.com
    street: 117 Middle Rd.
    city: Portsmouth
    region: NH
    code: '03801'
    country:  United States
  - ins: H. Birkholz
    name: Henk Birkholz
    org: Fraunhofer Institute for Secure Information Technology
    abbrev: Fraunhofer SIT
    email: henk.birkholz@sit.fraunhofer.de
    street: Rheinstrasse 75
    code: '64295'
    city: Darmstadt
    country: Germany


normative:
  RFC8949:
  TIME_T:
    target: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_16
    author:
      org: The Open Group Base Specifications
    title: >
      Vol. 1: Base Definitions, Issue 7
    date: 2016
    seriesinfo:
      "Section 4.15": "'Seconds Since the Epoch'"
      "IEEE Std": "1003.1-2008"
      "2016": "Edition"
  RESOLUTION:
    target: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_328
    author:
      org: The Open Group Base Specifications
    title: >
      Vol. 1: Base Definitions, Issue 7
    date: 2016
    seriesinfo:
      "Section 3.328": "'(Time) Resolution'"
      "IEEE Std": "1003.1-2008"
      "2016": "Edition"
  SI-SECOND:
    author:
      org: International Organization for Standardization (ISO)
    title: >
      Quantities and units — Part 3: Space and time
    date: 2006-03-01
    seriesinfo:
      ISO: 80000-3
  IEEE1588-2008:
    target: http://standards.ieee.org/findstds/standard/1588-2008.html
    title: >
      1588-2008 - IEEE Standard for a Precision Clock
      Synchronization Protocol for Networked Measurement and Control
      Systems
    author:
      org: IEEE
    date: 2008-07
  IANA.cbor-tags: tags
  RFC8610: cddl

informative:
  RFC8575:

--- abstract

The Concise Binary Object Representation (CBOR, RFC 8949) is a data
format whose design goals include the possibility of extremely small
code size, fairly small message size, and extensibility without the
need for version negotiation.

In CBOR, one point of extensibility is the definition of CBOR tags.
RFC 8949 defines two tags for time: CBOR tag 0 (RFC3339 time as a string) and tag
1 (Posix time as int or float).  Since then, additional requirements have
become known.  The present document defines a CBOR tag for time that
allows a more elaborate representation of time, as well as related
CBOR tags for duration and time period.  It is
intended as the reference document for the IANA registration of the
CBOR tags defined.

--- note_Note_to_Readers

Version -00 of the present draft opened up the possibilities provided
by extended representations of time in CBOR.
Version -01 consolidated this draft to non-speculative
content, the normative parts of which are believed will stay unchanged
during further development of the draft.  This version is provided to
aid the registration of the CBOR tag immediately needed.
Versions -02 and -03 made use of the IANA allocations registered and
made other editorial updates.
Further versions will re-introduce some of the material from -00, but
in a more concrete form.

--- middle

Introduction        {#intro}
============

The Concise Binary Object Representation (CBOR, {{RFC8949}}) provides
for the interchange of structured data without a requirement for a
pre-agreed schema.
RFC 8949 defines a basic set of data types, as well as a tagging
mechanism that enables extending the set of data types supported via
an IANA registry.

(TBD: Expand on text from abstract here.)

Terminology         {#terms}
------------

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and
"OPTIONAL" in this document are to be interpreted as described in
RFC 2119 {{!RFC2119}}.

The term "byte" is used in its now customary sense as a synonym for
"octet".
Where bit arithmetic is explained, this document uses the notation
familiar from the programming language C (including C++14's 0bnnn
binary literals), except that the operator "\*\*" stands for
exponentiation.

{::comment}
Background
----------

Additional information about the complexities of time representation
can be found in {{TIME}}.  This specification uses a number of terms
that should be familiar to connoisseurs of precise time; references
for these may need to be added.
{:/}

Objectives
==========

For the time tag,
the present specification addresses the following objectives that go
beyond the original tags 0 and 1:

* Additional resolution for epoch-based time (as in tag 1).  CBOR tag
  1 only provides for integer and up to binary64 floating point
  representation of times, limiting resolution to approximately
  microseconds at the time of writing (and progressively becoming
  worse over time).

Not currently addressed, but possibly covered by the definition of
additional map keys for the map inside the tag:

* Indication of time scale.  Tags 0 and 1 are for UTC; however, some
  interchanges are better performed on TAI.  Other time scales may be
  registered once they become relevant (e.g., one of the proposed
  successors to UTC that might no longer use leap seconds, or a
  scale based on smeared leap seconds).

* Direct representation of natural platform time formats.  Some
  platforms use epoch-based time formats that require some computation
  to convert them into the representations allowed by tag 1; these
  computations can also lose precision and cause ambiguities.
  (TBD: The present specification does not take a position on whether tag 1 can be
  "fixed" to include, e.g., Decimal or BigFloat representations.  It
  does define how to use these with the extended time format.)

* Additional indication of intents about the interpretation of the
  time given, in particular for future times.
  Intents might include information about time zones, daylight savings
  times, etc.
  <!--
  (TBD: This is not yet a well-developed part of the spec; there needs
  to be some effort to avoid the kitchen sink.)
  -->

Additional tags might later be defined for duration and period.
The objectives for such duration and period tags are likely similar.

Time Format
===========

An extended time is indicated by CBOR tag 1001, which tags a map data
item (CBOR major type 5).  The map may contain integer (major types 0
and 1) or text string (major type 3) keys, with the value type
determined by each specific key.   Implementations MUST ignore
key/value types they do not understand for negative integer and text
string values of the key.
Not understanding key/value for unsigned keys is an error.
<!-- (Discussion: Do we need "critical" keys?) -->

The map must contain exactly one unsigned integer key, which
specifies the "base time", and may also contain one or more negative
integer or text-string keys, which may encode supplementary
information such as:

* a higher precision time offset to be added to the base time,

Future keys may add:

* a reference time scale and epoch different from the default UTC and 1970-01-01

* information about clock source and precision, accuracy, and resolution

* intent information such as timezone and daylight savings time,
  and/or possibly positioning coordinates, to express information that
  would indicate a local time.

While this document does not define supplementary text keys, a number
of unsigned and negative-integer keys are defined below.

{::comment}

Keys 0 and 1
------------

Keys 0 and 1 indicate values that are exactly like the data items that
would be tagged by CBOR tag 0 (RFC 3339 date/time string) or tag 1
(Posix time {{TIME_T}} as int or float), respectively.

{:/}

Key 1
-----

Key 1 indicates a value that is exactly like the data item that would
be tagged by CBOR tag 1 (Posix time {{TIME_T}} as int or float).
The time value indicated by the value under this key can be further
modified by other keys.

Keys 4 and 5
------------

Keys 4 and 5 are like key 1, except that the data item is an array as
defined for CBOR tag 4 or 5, respectively.  This can be used to include
a Decimal or Bigfloat epoch-based float {{TIME_T}} in an extended time.

Keys -3, -6, -9, -12, -15, -18
------------------------------

The keys -3, -6, -9, -12, -15 and -18 indicate additional decimal fractions by
giving an unsigned integer (major type 0) and scaling this with the
scale factor 1e-3, 1e-6, 1e-9, 1e-12, 1e-15, and 1e-18, respectively (see {{decfract}}).  More than one
of these keys MUST NOT be present in one extended time data item.
These additional fractions are added to a base time in seconds {{SI-SECOND}}
indicated by a Key 1, which then MUST also be present and MUST have an
integer value.

| Key | meaning      | example usage   |
|  -3 | milliseconds | Java time       |
|  -6 | microseconds | (old) UNIX time |
|  -9 | nanoseconds  | (new) UNIX time |
| -12 | picoseconds  | Haskell time    |
| -15 | femtoseconds | (future)        |
| -18 | attoseconds  | (future)        |
{: #decfract title="Key for decimally scaled Fractions"}

Key -1 {#key-m1}
------

Key -1 is used to indicate a time scale.  The value 0 indicates UTC,
with the POSIX epoch {{TIME_T}}; the value 1 indicates TAI, with the
PTP (Precision Time Protocol) epoch {{IEEE1588-2008}}.

If key -1 is not present, time scale value 0 is implied.
Additional values can be registered in the (TBD define name for time
scale registry); values MUST be integers or text strings.

(Note that there should be no time scales "GPS" or "NTP" — instead,
the time should be converted to TAI using a single subtraction.)

~~~ math
t_{ntp} = t_{utc} + 2208988800
~~~
~~~ math
t_{gps} = t_{tai} - 315964819
~~~
{: #offset title="Converting Common Offset Time Scales"}

{::comment}
Key -2
------

Key -2 can be used to indicate the quality of the point in time:
The value 0 indicates a time obtained from a clock (past or "current" time).
The value -1 indicates a future time that has been scheduled by a human.
The value 1 indicates a time derived from a time obtained from a clock
(such as the timestamp of a record in a log file).
(TBD: Is this well-defined enough?
What other cases should be considered here?)

If key -2 is not present, no information is available about the
quality of the time.

Key -4
------

Key -4 can be used to indicate the resolution of the time provided
{{RESOLUTION}}:
"The minimum time interval that a clock can measure or whose passage a
timer can detect."
The value is expressed in SI seconds {{SI-SECOND}} and
can be any positive number, such as an integer, a floating point
value (major type 7 or Tag 5), or a decimal value (Tag 4).
{:/}

Key -5: Accuracy
------

Key -5 can be used to indicate the accuracy of the time {{IEEE1588-2008}}:
"The mean of the time or frequency error between the clock under test
and a perfect reference clock, over an ensemble of measurements."
The value is expressed in SI seconds {{SI-SECOND}} and
can be any positive number, such as an integer, a floating point
value (major type 7 or Tag 5), or a decimal value (Tag 4).

(This could be extended into more information about the way the clock
source is synchronized, e.g. manually, GPS, NTP, PTP, roughtime, ...)

{::comment}

Key -7
------

Key -7 can be used to indicate the time zone that would best fit for
displaying the time given to humans.
(TBD: Format for the time zone information; possibly including DST
information.  No default; generally, the time can by default be
presented as UTC/"Zulu time".)

Key -8
------

Key -8 can be used to indicate the location in which the time given
should be interpreted (e.g., for deriving time zone information).
(TBD: Format for the coordinate information; may need to contain the
Datum information.)

Key -10
------

Key -10 can be used to indicate the calendar that would best fit for
displaying the time given to humans.
(TBD: Format for the calendar information.  This should probably
default to Gregorian.)

Duration Format
===============

(TBD; this can probably use most of the same keys as for time.
Clearly, ISO8601 durations are a bit different.)

Period Format
=============

(TBD; this could be a pair of times, a time and a duration, a duration
and a time or v.v., or a RFC 3339 period.)

{:/}

CDDL typenames
==========

For the use with the CBOR Data Definition Language, CDDL {{-cddl}}, the
type names defined in {{tag-cddl}} are recommended:

~~~ CDDL
etime = #6.1001({* (int/tstr) => any})
duration = #6.1002({* (int/tstr) => any})
period = #6.1003({* (int/tstr) => any})
~~~
{: #tag-cddl title="Recommended type names for CDDL"}

-->

IANA Considerations
============

In the registry {{-tags}},
IANA has allocated the tags in {{tab-tag-values}} from the
FCFS space, with the present document as the specification reference.

|  Tag | Data Item | Semantics               |
| 1001 | map       | [RFCthis] extended time |
| 1002 | map       | [RFCthis] duration      |
| 1003 | map       | [RFCthis] period        |
{: #tab-tag-values cols='r l l' title="Values for Tags"}

Although duration and period are not yet defined in the present
version of this document, the tag values for duration and period have been
requested at the same time as the value for extended time in order to
achieve allocation of all three values as a contiguous set.

<!--

(TBD: Add registry for time scales.
Add registry for map keys and allocation policies for additional keys.)

-->

Security Considerations
============

The security considerations of RFC 8949 apply; the tags introduced
here are not expected to raise security considerations beyond those.

Time, of course, has significant security considerations; these
include the exploitation of ambiguities where time is security
relevant (e.g., for freshness or in a validity span) or the disclosure
of characteristics of the emitting system (e.g., time zone, or clock
resolution and wall clock offset).

----

--- back

<!--
Contributors
============
{: numbered="no"}

Add reference to [TIME] once available.

Ben Gamari suggested being able to use decimally scaled fractional
seconds in CBOR time.
 -->

Acknowledgements
================
{: numbered="no"}

<!--  LocalWords:  CBOR extensibility IANA uint sint IEEE endian
 -->
<!--  LocalWords:  signedness endianness
 -->
