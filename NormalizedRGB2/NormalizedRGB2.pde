import processing.video.*;

Capture cam;
boolean usingCamera = false;
int camWidth = 352;
int camHeight = 288;
int camNum = 9;

PImage img;
PImage normalizedImg;
boolean landscape;
boolean openingFile = false;
int mHeight;
int mWidth;
int sHeight = 64;
int sWidth = 64;

void setup() {
  size(64, 64);
  mHeight = displayHeight/5*4;
  mWidth = mHeight;

  cameraSetup();
  openUserImage();
}

void draw() {
  clear();

  if (!openingFile) {
    if (cam != null && usingCamera) {
      if (cam.available()) {
        cam.read();
        normalizeRGB(cam);
      }
      image(cam, 0, 0);
      image(normalizedImg, 0, cam.height);
    } else {
      if (img != null) {
        normalizeRGB(img);
        image(img, 0, 0);
        if (landscape) {
          image(normalizedImg, 0, img.height);
        } else {
          image(normalizedImg, img.width, 0);
        }
      }
    }
  }
}

void cameraSetup() {
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("No cameras available for capture");
  } else {
    for (int i=0; i<cameras.length; i++) {
      println(i, cameras[i]);
    }
    cam = new Capture(this, cameras[camNum]);
  }
}

color normalizeRGBPixel(color pixel) {
  float r = red(pixel);  
  float g = green(pixel);
  float b = blue(pixel);
  float sum = r + b + g;

  return color(r/sum * 255, g/sum * 255, b/sum * 255);
}

void normalizeRGB(PImage pImg) {  
  normalizedImg.loadPixels();

  for (int y=0; y<pImg.height; y++) {
    for (int x=0; x<pImg.width; x++) {
      int loc = x + y * pImg.width;

      color normalized = normalizeRGBPixel(pImg.pixels[loc]);
      
      normalizedImg.pixels[loc] = normalized;
    }
  }

  normalizedImg.updatePixels();
}

void imageSelected(File selection) {
  openingFile = true;
  
  if (selection == null) {
    println("Window was closed or user clicked cancel");
  } else {
    usingCamera = false;
    img = loadImage(selection.getAbsolutePath());
    setupImages();
  }
  
  openingFile = false;
}

void setupImages() {
  if (usingCamera) { 
    normalizedImg = createImage(camWidth, camHeight, RGB);
  } else {
    if (img != null) {
      landscape = img.width > img.height;
      normalizedImg = createImage(img.width, img.height, RGB);
      resizeImgAndSurface(img);
      resizeImg(normalizedImg);
    }
  }
}

void resizeImgAndSurface(PImage rImg) {
  int newSize = resizeImg(rImg);

  if (landscape) {
    surface.setSize(newSize, mHeight);
    sWidth = newSize;
    sHeight = mHeight;
  } else {
    surface.setSize(mWidth, newSize);
    sWidth = mWidth;
    sHeight = newSize;
  }
}

int resizeImg(PImage rImg) {
  float ratio;

  if (landscape) {
    ratio = float(mHeight/2) / float(rImg.height);
  } else {
    ratio = float(mWidth/2) / float(rImg.width);
  }

  int newH = floor(rImg.height * ratio);
  int newW = floor(rImg.width * ratio);

  rImg.resize(newW, newH);

  if (landscape) {
    return newW;
  } else {
    return newH;
  }
}

void openUserImage() {
  selectInput("Select an image to process", "imageSelected");
}

void keyPressed () {
  if (key == 'o') {
    openUserImage();
  }
  if (key == 'c') {
    if (usingCamera) {
      usingCamera = false;
      cam.stop();
    } else {
      usingCamera = true;
      surface.setSize(camWidth, camHeight*2);
      cam.start();
    }
    setupImages();
  }
}
