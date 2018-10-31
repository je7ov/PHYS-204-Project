import processing.video.*;

Capture cam;
PImage img;
PImage normalizedImg;
boolean landscape;
boolean usingCamera = false;
int mHeight;
int mWidth;

void setup() {
  size(64, 64);
  mHeight = displayHeight/5*4;
  mWidth = mHeight;

  cameraSetup();
  openUserImage();
}

void cameraSetup() {
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("No cameras available for capture");
  } else {
    for (int i=0; i<cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
  }
}

color normalizeRGBPixel(color pixel) {
  float r = red(pixel);  
  float g = green(pixel);
  float b = blue(pixel);
  float sum = r + b + g;

  return color(r/sum * 255, g/sum * 255, b/sum * 255);
}

void normalizeRGB() {  
  normalizedImg.loadPixels();
  for (int y=0; y<img.height; y++) {
    for (int x=0; x<img.width; x++) {
      int loc = x + y * img.width;

      color normalized = normalizeRGBPixel(img.pixels[loc]);

      normalizedImg.pixels[loc] = normalized;
    }
  }
  normalizedImg.updatePixels();
}

void draw() {
  clear();

  if (usingCamera) {
    if (cam.available()) {
      cam.read();
    }
    image(cam, 0, 0);
  }


  if (img != null) {
    image(img, 0, 0);
    if (landscape) {
      image(normalizedImg, 0, img.height);
    } else {
      image(normalizedImg, img.width, 0);
    }
  }
}

void imageSelected(File selection) {
  if (selection == null) {
    println("Window was closed or user clicked cancel");
  } else {
    img = loadImage(selection.getAbsolutePath());
    landscape = img.width > img.height;
    normalizedImg = createImage(img.width, img.height, RGB);

    resizeImgAndSurface(img);
    resizeImg(normalizedImg);

    normalizeRGB();
  }
}

void resizeImgAndSurface(PImage rImg) {
  int newSize = resizeImg(rImg);

  if (landscape) {
    surface.setSize(newSize, mHeight);
  } else {
    surface.setSize(mWidth, newSize);
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
      cam.start();
    }
  }
}