import KinectPV2.KJoint;
import KinectPV2.*;
import java.util.*;
import processing.video.*;
import SimpleOpenNI. *;
KinectPV2 kinect;


float zVal = 300;
float rotX = PI;
float shoulderDifference;
float threshold = 0.05;
float angleThreshold = 0.05;
float angleThreshold2 = 0.05;
final int cameraWidth = 1850;
final int cameraHeight = 1000;
KJoint kneeRight;
KJoint ankleRight;
KJoint kneeLeft;
KJoint ankleLeft;
KJoint spineBase;
KJoint spineMid;
KJoint spineShoulder;

void drawBody(KJoint[] joints) {
  println("ready");
  KJoint shoulderRight = joints[KinectPV2.JointType_ShoulderRight];
  KJoint shoulderLeft = joints[KinectPV2.JointType_ShoulderLeft];
  shoulderDifference = abs(shoulderRight.getY() - shoulderLeft.getY());

  println("Joints size: " + joints.length);

  for (int i = 0; i<joints.length; i++) {
    print(i);
    println(joints[i]);
  }
  if (joints[KinectPV2.JointType_AnkleRight] != null) {
    ankleRight = joints[KinectPV2.JointType_AnkleRight];
  }
  if (joints[KinectPV2.JointType_KneeLeft] != null) {
    kneeLeft = joints[KinectPV2.JointType_KneeLeft];
  }
  if (joints[KinectPV2.JointType_AnkleLeft] != null) {
    ankleLeft = joints[KinectPV2.JointType_AnkleLeft];
  }
  if (joints[KinectPV2.JointType_SpineBase]!= null) {
    spineBase = joints[KinectPV2.JointType_SpineBase];
  }
  if (joints[KinectPV2.JointType_SpineMid]!= null) {
    spineMid = joints[KinectPV2.JointType_SpineMid];
  }
  if (joints[KinectPV2.JointType_SpineShoulder]!= null) {
    spineShoulder = joints[KinectPV2.JointType_SpineShoulder];
  }
  if (joints[KinectPV2.JointType_KneeRight]!= null) {
    kneeRight = joints[KinectPV2.JointType_KneeRight];
  }


  // Calculate angles for both legs
}

void setup() {
  size(1024, 768, P3D);
  //fullScreen();
  kinect = new KinectPV2(this);
  kinect.enableColorImg(true);

  //enable 3d  with (x,y,z) position
  kinect.enableSkeleton3DMap(true);
  kinect.init();
}

void draw() {
  background(0);
  image(kinect.getColorImage(), 0, 0, cameraWidth, cameraHeight);
  //translate the scene to the center
  pushMatrix();
  //translate(width/2, height/2, 0);
  scale(zVal);
  //rotateX(rotX);
  print(1);
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeleton3d();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      //Draw body
      color col  = skeleton.getIndexColor();
      stroke(col);
      drawBody(joints);
      //if (ankleRight!=null) {
      //  println(ankleRight.getY());
      //}
      //if (kneeRight!=null) {
      //  println(kneeRight.getY());
      //}
      //if (ankleRight!=null) {
      //  println(ankleRight.getX());
      //}
      //if (kneeRight!=null) {
      //  println(kneeRight.getX());
      //}
      if (ankleRight!=null && kneeRight!=null && ankleLeft!=null && kneeLeft!=null) {
        float angleRight = (float)Math.atan2(ankleRight.getY()-kneeRight.getY(), ankleRight.getX() - kneeRight.getX());
        float angleLeft = (float)Math.atan2(ankleLeft.getY() - kneeLeft.getY(), ankleLeft.getX() - kneeLeft.getX());
        if (abs(angleRight-angleLeft) > angleThreshold) {
          fill(255, 0, 0);
          textSize(20);
          text("Incorrect Posture: Bent Knees", 70, 100);
        }
      }
      if (joints[KinectPV2.JointType_Head] != null && joints[KinectPV2.JointType_SpineBase] != null && joints[KinectPV2.JointType_SpineMid] != null) {
        KJoint head = joints[KinectPV2.JointType_Head];
        KJoint spineBase = joints[KinectPV2.JointType_SpineBase];
        KJoint spineMid = joints[KinectPV2.JointType_SpineMid];

        // Calculate angles between head and spine
        float angleSpineHead = atan2(head.getY() - spineMid.getY(), head.getX() - spineMid.getX());
        float angleBaseMid = atan2(spineMid.getY() - spineBase.getY(), spineMid.getX() - spineBase.getX());
        float spineHeadAngle = abs(angleSpineHead - angleBaseMid);

        float angleThreshold3 = radians(30); // Adjust this threshold as needed

        if (spineHeadAngle > angleThreshold3) {
          // Display a message or take appropriate action for forward head posture
          fill(255, 0, 0);
          textSize(20);
          text("Incorrect Posture: Forward Head", 70, 200);
        }
      }
       // Adjust this threshold as needed
      if (spineMid!=null && spineBase!=null && spineShoulder!=null) {
        float angleBaseMid = atan2(spineMid.getY() - spineBase.getY(), spineMid.getX() - spineBase.getX());
        float angleMidShoulder = atan2(spineShoulder.getY() - spineMid.getY(), spineShoulder.getX() - spineMid.getX());
        float spineAngle = abs(angleBaseMid - angleMidShoulder);

        if (spineAngle > angleThreshold2) {
          // Display a message or take appropriate action for not maintaining a neutral spine
          fill(255, 0, 0);
          textSize(20);

          text("Incorrect Posture: Not Maintaining a Neutral Spine", 70, 150);
        }
      }
    }
  }


  if (shoulderDifference > threshold) {
    // Display a message or take appropriate action for uneven shoulders
    fill(255, 0, 0);
    textSize(50);
    text("Incorrect posture: Uneven shoulders", 70, 70);
  }
  popMatrix();
}
