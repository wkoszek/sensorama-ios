# Sensorama

Sensorama is a data science platform. Its purpose is to see if the
information gathered from modern sensors could be turned into an
understanding of real events from the sensor's place of origin.  For
example, for the mobile cell phone which comes with an accelerometer and a
gyroscope, when enough sensor data is collected and analyzed, it could be
valuable to see if detection of activities such as jogging or playing drums
is possible. Additional experiment could consist of a smart-phone attached
to drummers arm and seeing Sensorama being able to understand patterns
played by the musician.  Industrial sensor on the other hand may lead to
conclusions about the state of machines such as CNC routers, robots on
assembly line etc.

Initial implementation of Sensorama is meant to be an exercise in mobile
cross-platform mobile programming in Android and iOS ecosystems.

# Introduction

Sensors come in a wide variety of types, but the most popular are GPS,
accelerometer, temperature, gravity, gyroscope and proximity sensors. All
these sensors act as smart A/D converters, in which the MEMS chip
translates analog singals from the environment to something that modern
processors can understand. Software layer provides a way to enable the
sensor, and later translates these events into a numeric data which is
provided through the sensor data source. Programs typically subscribe to
these sources to receive notification about the sensor state change.

# Design

Design of Sensorama consists of frontend UI facing end user, thin controller
interacting with main Sensorama Core class and model, which in turn
interacts with various sensors. Even though in this and further examples
cell phone programming platforms are mentioned, design ought to be
prepared to encompass embedded dongles with handful of various sensors,
which send a sensor data through the wireless channel. SensorTag from TI is
an example of such a dongle.

# Data

Sensors vary greatly in ways in which they submit data. For example, the
battery sensor may only send an update every couple of seconds, while the
accelerometer may do it continually. While makes sense to capture the data
from an accelerometer on a regular basis with short intervals, capturing the
data from a battery every couple of milliseconds makes little sense. Thus
data coming from a battery status sensor might be performed only on state
change. In other words, design should support non-uniform data samples,
meaning that the sample format can vary in between submissions.

# Data encoding

The Sensorama core must encompass slight differences in different cell phone
designs and the number and type of different sensors. For example, some
phones may have a humidity sensor, while others may not. Design should
encompass this so that without application redesign, more feature rich
phones can submit more data without causing a data from less featured phones
to be invalidated. Type of a sensor should be thus included as a tag along
with provided data, or a handshake protocol should be included as a way of
discovering of what the format of transmitted data will be.

# Timestamping

Data from sensors should be tagged with time too. Tagging with time is
necessary, since it is important to understand the time elapsed in between
samples. It too may provide an insight into understanding the cell phone
feasibility as a sensoring platforms, since thread and process scheduling on
a phone may turn out to be inaccurate for very precise sample timestamping.
For example: timers which are meant to fire and execute a function every
250ms may in reality take longer or may be queued together. In case this
hipothesis proves incorrect, it should be possible to adjust amount of data
submitted from the phone. One may imagine two types of sample timestamping:
absolute and relative. Absolute timestamp would return a
microsecond-accurate wall-clock time in situation where accuracy of sampling
is unclear. Relative timestamping could be used when a sampling accuracy is
known, in which case the wall-clock time could be submitted only once. Every
further sample could be either tagged with a 32-bit number, or maybe not
tagged at all (implying that data arrives in order or that order doesn't
matter).

# Data aggregation

One can imagine the case where submitting individual data samples may become
unnecessary, if algorithm to turn sensor data to a meaning is provided. In
such cases Sensorama may need more aggregated sensor samples to run a
clustering function on and to submit only an actual result of evalution of
the data. For example, one may imagine a function which turns 5 individual
battery sensors readouts to something like "Something start to eat battery
very fast" signal.

# Data confidentiality

Sensorama in theory should handle all possible types of sensors, including
location (GPS), audio (microphone) and video (camera). Decision on whether
the data samples from certain sensors should be submitted or not should 
be available to the user, so that he can decide whether to upload this
data or not. For example, user may have recorded a valuable sample with
a lot of accelerometer/gyroscope data, but may not be willing to share 
his location.

# Serialization

Data serialization is quite likely accomplished by writing samples data to
the file. File should have easy to understand structure, so that easy
parsing with Python or Ruby is possible. Some sort of CSV would work, yet it
needs to be expressive enough to understand different sensor types. For
example: self describing CSV could work, since one could run common set of
utilities regardless of whether the phone had a given sensor or not.

# Storage

There should be a way to understand what the data consumption on a certain
device will be. One of the units of measure could be number of MB per minute
of monitoring. Its quite likely that compression might be necessary. Data
should be recorder to the file which is either binary, or is a simple ASCII,
so that the data compression can work in an efficient way.


# Filtering

One could argue that for worthwhile data analysis, to be address all data
samples should be present in raw form. Some sensors such as accelerometer or
gyroscope are fine to be used in such context, yet anothers aren't. For
example, user may want to include the GPS coordinates always unless they
represent location of user's address, in which case GPS coordinates should
be skipped. Filtering could be a partial answer to data confidentiality.
Easy user interface would have to be provided however ('Do you want suppress
GPS logging in 300ft radius from your current location?'), to make it more
appealing to users to submit and share the data.

# Distribution

Architecture should be granular enough to provide further distribution if
necessary. For example, turning a simple battery reading status in Android
Emulator resulted in a warning about inability to cope with the load of
work put on the main thread. Thus it may require to decouple a core design
from per-sensor gathering classes, so that multithreading can be included
"for free". Another idea would be to provide a gateway into turning
Sensorama into a distributed platform, where sensor data is submitted
through BlueTooth
