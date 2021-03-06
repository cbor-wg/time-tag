---
title: >
  Concise Binary Object Representation (CBOR) Tags for Time, Duration, and Period
abbrev: CBOR tag for extended time
docname: draft-ietf-cbor-time-tag-latest
date: 2021-05-19

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
#  RESOLUTION:
#    target: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_328
#    author:
#      org: The Open Group Base Specifications
#    title: >
#      Vol. 1: Base Definitions, Issue 7
#    date: 2016
#    seriesinfo:
#      "Section 3.328": "'(Time) Resolution'"
#      "IEEE Std": "1003.1-2008"
#      "2016": "Edition"
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
  GUM:
    target: https://www.bipm.org/en/publications/guides/gum.html
    title: >
      Evaluation of measurement data —
      Guide to the expression of uncertainty in measurement
    seriesinfo:
       JCGM: 100:2008
    author:
      org: Joint Committee for Guides in Metrology
    date: September 2008
  IANA.cbor-tags: tags
  RFC8610: cddl

informative:
  RFC8575:
  RFC3161:

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

Version -00 of the individual submission that led to the present draft
opened up the possibilities provided by extended representations of
time in CBOR.
Version -01 consolidated this draft to non-speculative
content, the normative parts of which were believed will stay unchanged
during further development of the draft.  This version was provided to
aid the registration of the CBOR tag immediately needed.
Further versions of the individual submission made use of the IANA
allocations registered and made other editorial updates.
Now a WG document, future versions could re-introduce some of the
material from the initial submission, but in a more concrete form.

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

{::boilerplate bcp14-tagged}

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

* Indication of time scale.  Tags 0 and 1 are for UTC; however, some
  interchanges are better performed on TAI.  Other time scales may be
  registered once they become relevant (e.g., one of the proposed
  successors to UTC that might no longer use leap seconds, or a
  scale based on smeared leap seconds).

Not currently addressed, but possibly covered by the definition of
additional map keys for the map inside the tag:

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

Additional tags are defined for durations and periods.

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

* a reference time scale and epoch different from the default UTC and 1970-01-01

* information about clock quality parameters, such as source,
  accuracy, and uncertainty
<!-- precision, and resolution -->

Future keys may add:

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

Key -1: Time Scale {#key-timescale}
------

Key -1 is used to indicate a time scale.  The value 0 indicates UTC,
with the POSIX epoch {{TIME_T}}; the value 1 indicates TAI, with the
PTP (Precision Time Protocol) epoch {{IEEE1588-2008}}.

If key -1 is not present, time scale value 0 is implied.
Additional values can be registered in the (TBD define name for time
scale registry); values MUST be integers or text strings.

(Note that there should be no time scales "GPS" or "NTP" — instead,
the time should be converted to TAI or UTC using a single addition or subtraction.)

~~~ math
t_{utc} = t_{ntp} - 2208988800 \\
t_{tai} = t_{gps} + 315964819
~~~
{: #offset title="Converting Common Offset Time Scales"}


Clock Quality
------

A number of keys are defined to indicate the quality of clock that was
used to determine the point in time.

The first three are analogous to `clock-quality-grouping` in
{{RFC8575}}, which is in turn based on the definitions in
{{IEEE1588-2008}}; two more are specific to this document.

~~~ cddl
ClockQuality-group = (
  ? ClockClass => uint .size 1 ; PTP/RFC8575
  ? ClockAccuracy => uint .size 1 ; PTP/RFC8575
  ? OffsetScaledLogVariance => uint .size 2 ; PTP/RFC8575
  ? Uncertainty => ~time/~duration
  ? Guarantee => ~time/~duration
)
ClockClass = -2
ClockAccuracy = -4
OffsetScaledLogVariance = -5
Uncertainty = -7
Guarantee = -8
~~~

### ClockClass (Key -2)

Key -2 (ClockClass) can be used to indicate the clock class as per
Table 5 of {{IEEE1588-2008}}.
It is defined as a one-byte unsigned integer as that is the range defined there.

### ClockAccuracy (Key -4)


Key -4 (ClockAccuracy) can be used to indicate the clock accuracy as per
Table 6 of {{IEEE1588-2008}}.
It is defined as a one-byte unsigned integer as that is the range defined there.
The range between 32 and 47 is a slightly distorted logarithmic scale from
25 ns to 1 s (see {{formula-accuracy-enum}}); the number 254 is the
value to be used if an unknown accuracy needs to be expressed.

~~~ math
enum_{acc} \approx 48 + \lfloor 2 \cdot log_{10} {acc \over \mathrm{s}} - \epsilon \rfloor
~~~
{: #formula-accuracy-enum title="Approximate conversion from accuracy to accuracy enumeration value"}

### OffsetScaledLogVariance (Key -5)

Key -5 (OffsetScaledLogVariance) can be used to represent the variance
exhibited by the clock when it has lost its synchronization with an
external reference clock.  The details for the computation of this
characteristic are defined in Section 7.6.3 of {{IEEE1588-2008}}.

### Uncertainty (Key -7)

Key -7 (Uncertainty) can be used to represent a known measurement
uncertainty for the clock, as a numeric value in seconds or as a
duration ({{duration}}).

For this document, uncertainty is defined as in Section 2.2.3 of
{{GUM}}: "parameter, associated with the result of a measurement, that
characterizes the dispersion of the values that could reasonably be
attributed to the measurand".  More specifically, the value for this
key represents the extended uncertainty for k = 2, in seconds.

### Guarantee (Key -8)

Key -8 (Guarantee) can be used to represent a stated guarantee for the
accuracy of the point in time, as a numeric value in seconds or as a
duration ({{duration}})
representing the maximum allowed deviation from the true value.

While such a guarantee is unattainable in theory, existing standards
such as {{RFC3161}} stipulate the representation of such guarantees,
and therefore this format provides a way to represent them as well;
the time value given is nominally guaranteed to not deviate from the
actual time by more than the value of the guarantee, in seconds.

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

Key -4: Resolution
------

Key -4 can be used to indicate the resolution of the time provided
{{RESOLUTION}}:
"The minimum time interval that a clock can measure or whose passage a
timer can detect."
The value is expressed in SI seconds {{SI-SECOND}} and
can be any positive number, such as an integer, a floating point
value (major type 7 or Tag 5), or a decimal value (Tag 4).

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

{:/}

Duration Format {#duration}
===============

A duration is the length of an interval of time.
Durations in this format are given in SI seconds, possibly adjusted
for conventional corrections of the time scale given (e.g., leap
seconds).

Except for using Tag 1002 instead of 1001,
durations are structurally identical to time values.
Semantically, they do not measure the time elapsed from a given epoch,
but from the start to the end of (an otherwise unspecified) interval
of time.

In combination with an epoch identified in the context, a duration can
also be used to express an absolute time.

<aside markdown="1">
(TBD: Clearly, ISO8601 durations are rather different; we do not want to use these.)
</aside>

Period Format {#period}
=============

A period is a specific interval of time, specified as either two times
giving the start and the end of that interval, or as one of these two
plus a duration.

They are given as an array of unwrapped time and duration elements,
tagged with Tag 1003:

~~~ cddl
Period = #6.1003([
  start: ~Time / null
  end: ~Time / null
  ? duration: ~Duration / null
])
~~~

If the third array element is not given, the duration element is null.
Exactly two out of the three elements must be non-null, this can be
clumsily expressed in CDDL as:

~~~ cddl
Period = #6.1003([
  (start: ~Time,
   ((end: ~Time,
     ? duration: null) //
    (end: null,
     duration: ~Duration))) //
  (start: null,
   end: ~Time,
   duration: ~Duration)
])
~~~

<aside markdown="1">
(Issue: should start/end be given the two-element treatment, or start/duration?)
</aside>

CDDL typenames
==========

For the use with the CBOR Data Definition Language, CDDL {{-cddl}}, the
type names defined in {{tag-cddl}} are recommended:

~~~ cddl
etime = #6.1001({* (int/tstr) => any})
duration = #6.1002({* (int/tstr) => any})
period = #6.1003([~etime/null, ~etime/null, ~duration/null])
~~~
{: #tag-cddl title="Recommended type names for CDDL"}

IANA Considerations
============

In the registry {{-tags}},
IANA has allocated the tags in {{tab-tag-values}} from the
FCFS space, with the present document as the specification reference.

|  Tag | Data Item | Semantics               |
| 1001 | map       | [RFCthis] extended time |
| 1002 | map       | [RFCthis] duration      |
| 1003 | array     | [RFCthis] period        |
{: #tab-tag-values cols='r l l' title="Values for Tags"}

IANA is requested to change the "Data Item" column for Tag 1003 from
"map" to "array".

<aside markdown="1">
(TBD: Add registry for time scales.
Add registry for map keys and allocation policies for additional keys.)
</aside>

Security Considerations
============

The security considerations of RFC 8949 apply; the tags introduced
here are not expected to raise security considerations beyond those.

Time, of course, has significant security considerations; these
include the exploitation of ambiguities where time is security
relevant (e.g., for freshness or in a validity span) or the disclosure
of characteristics of the emitting system (e.g., time zone, or clock
resolution and wall clock offset).

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
{: numbered="false"}

<!--  LocalWords:  CBOR extensibility IANA uint sint IEEE endian TAI
 -->
<!--  LocalWords:  signedness endianness NTP
 -->
