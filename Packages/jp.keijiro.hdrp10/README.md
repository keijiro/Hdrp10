HDRP10
======

**HDRP10** is a video format converter for Unity HDRP that allows HDR video
output via Windows HD Color.

![comparison](https://i.imgur.com/GYQ0fsC.jpg)

*Left: Standard dynamic range. Right: HDR enabled. You can see banding in the
dark area of the left photo. I used Dell U2720QM HDR monitor and took these
photos with an overexposure setting to emphasize the effect.*

Please note that this is just a proof-of-concept implementation. I wouldn't
recommend using it in a practical application.

How to install the package
--------------------------

Download this repository and copy `Packages/jp.keijiro.hdrp10` into your
project's `Packages` directory.

How to use the format converter
-------------------------------

Firstly, enable the HDR mode (*Use display in HDR mode*) in *Player Settings*.

HDRP10 only supports 10-bit HDR buffer, so set *Swap Chain Bit Depth* to
*Bit Depth 10*.

![screenshot](https://i.imgur.com/O9FCpH1l.jpg)

Then add `Hdrp10.FormatConversion` to *After Post Process* (*Project Settings*
-> *HDRP Default Settings* -> *Custom Post Process Orders*).

![screenshot](https://i.imgur.com/ZuB2z7tl.jpg)

Create a volume profile to disable *Tonemapping* and enable *Format
Conversion*. Select **Rec. 2020 ST 2084** in *Format*. You can also specify
a paper-white brightness (in nits).

![screenshot](https://i.imgur.com/UqcQVUum.jpg)

Optional: It's recommended increasing the color buffer precision in *Color
Buffer Format* and *Post-processing Buffer Format*.

![screenshot](https://i.imgur.com/fjd4zbIl.jpg)
![screenshot](https://i.imgur.com/7g3Yswel.jpg)

What this package does
----------------------

By disabling tonemapping, we get scene-linear images from HDRP with the Rec. 709
color primaries. The Format Conversion effect converts them using the Rec. 2020
color primaries, then apply the SMPTE ST 2084 transfer function (PQ).

This conversion process is implicitly done in the legacy (built-in) render
pipeline but not in scriptable render pipelines. So I simply re-implemented it
as a post-processing effect for HDRP.
