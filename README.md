## 3D RECONSTRUCTION using 2 Kinect cameras


To perform the reconstruction, next steps were applied:
<ul>
   <li>Calibration of stereo setup</li>
      Capture at least 10 images of a checkerboad
      Camera Calibration Toolbox to find transformation matrix
      Calibrate each camera separately (to get intrinsic parameters)
      Then calibrate one camera with respect of each other (to get extrinsic parameters)
      <src href="https://prnt.sc/qy7d3i" align ="middle">
<li>Image preprocessing</li>
         Apply morphological erosion + bilateral filtering
<li>Calibrate the two depth cameras with respect of RGB data</li>
⋅⋅⋅* uint16 data type convert to double
⋅⋅⋅* сreate a 3d point cloud (left and right depth images separately), then we do alignment for left and right Kinect setup
<li>Align left and right Kinects using Extrinsic calibration data</li>
<li>Generate Point Clouds for left and right Kinects. Color pixel + Depth</li>
   <src href="https://prnt.sc/qy7ez2" align ="middle">
</ul>

## Limitations of the depth camera:

Limitations of depth camera:
⋅⋅* Systematic distance error: Approximations in the sinusoidal signal shape lead to some systematic depth error measurements in Kinect sensor. The magnitude of the systematic error has been shown to be relatively small, in the order of 1-2 m
⋅⋅* Depth inhomogeneity: At object boundaries pixels can have inconsistent depth values. This is because some of the light reflected is obtained from object but some from the background, mixing that information together can produce so called flying pixels which show object boundaries at incorrect coordinates.
⋅⋅* Multi-path effects: Since time of flight measuring principle relies on capturing light reflected back from the object surface, it can happen that light does not travel directly from illumination unit to object and back to sensor but instead takes indirect path being reflected from several surfaces. When such info is captured by sensor the depth measurement combines several waves and gives incorrect results. For very reflective surfaces, if it is positioned at relatively flat angle towards camera, no light might be reflected back and there is no depth info about that surface
⋅⋅* Semitransparent and scattering media: When surface, such as glass, only reflects part of the light directly and some other part is reflected from within the object, there is additional phase shift and the depth measurement is incorrect. For example, we had a bottle which was transparent – it wasn’t detected properly.
⋅⋅* It cannot handle reflections well. If object is transparent and the same wave gets partially reflected from object surface and partially reflected from background, the resulting depth image does not correspond to the true
situation (ex. – table) light has to reflect back to sensor for Kinect to register it these objects might not appear in depth image at all or have very distorted measurements
⋅⋅* Additionally, the method doesn’t work with fully symmetrical objects. If the depth info is identical in two frames, then ICP algorithm converges already with initial transformation guess (identity transformation) and the frames are not aligned correctly.

## Details: 
[the pdf](../3d_reconstruction_Proj_Boiko.pdf).
