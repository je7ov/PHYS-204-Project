import processing.video.*;

Capture cam;
boolean usingCamera = false;
int camWidth = 352;
int camHeight = 288;
int camNum = 9;

PImage img;
PImage thresholdImg;
boolean landscape;
boolean openingFile = false;
int mHeight;
int mWidth;
float xOffset = 0.0;
float dragged = 0.0;

float thresholdAmt = 15.0;
float thresholdMin = 0.0;
float thresholdMax = 100.0;

static final int RED = 0;
static final int GREEN = 1;
static final int BLUE = 2;
int currentFilter = RED;

void setup() {
  size(64, 64);
  mHeight = displayHeight/5*4;
  mWidth = displayHeight;

  cameraSetup();
  openUserImage();
}

void draw() {
  clear();

  if (!openingFile) {
    if (cam != null && usingCamera) {
      if (cam.available()) {
        cam.read();
        thresholdImg(cam);
      }
      image(cam, 0, 0);
      image(thresholdImg, 0, cam.height);
    } else {
      if (img != null) {
        thresholdImg(img);
        image(img, 0, 0);
        if (landscape) {
          image(thresholdImg, 0, img.height);
        } else {
          image(thresholdImg, img.width, 0);
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

void openUserImage() {
  selectInput("Select an image to process", "imageSelected");
}

void imageSelected(File selection) {
  openingFile = true;

  if (selection == null) {
    println("Window was closed or user clicked cancel");
  } else {
    img = loadImage(selection.getAbsolutePath());
    setupImages();
  }

  openingFile = false;
}

void setupImages() {
  if (usingCamera) {
    thresholdImg = createImage(camWidth, camHeight, RGB);
  } else {
    landscape = img.width > img.height;
    thresholdImg = createImage(img.width, img.height, RGB);
    resizeImgAndSurface(img);
    resizeImg(thresholdImg);
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

void thresholdImg(PImage pImg) {
  thresholdImg.loadPixels();
  for (int y=0; y<pImg.height; y++) {
    for (int x=0; x<pImg.width; x++) {
      int loc = x + y * pImg.width;

      color currentPixel = pImg.pixels[loc];

      color rChannel = redChannel(currentPixel);
      color gChannel = greenChannel(currentPixel);
      color bChannel = blueChannel(currentPixel);

      color c;
      switch(currentFilter) {
      case RED:
        color gbChannels = addChannels(gChannel, bChannel);
        color rFiltered = subtractChannels(rChannel, gbChannels);
        c = threshold(rFiltered);
        break;
      case GREEN:
        color rbChannels = addChannels(rChannel, bChannel);
        color gFiltered = subtractChannels(gChannel, rbChannels);
        c = threshold(gFiltered);
        break;
      default:
        color rgChannels = addChannels(rChannel, gChannel);
        color bFiltered = subtractChannels(bChannel, rgChannels);
        c = threshold(bFiltered);
      }

      if (thresholdImg.pixels.length <= loc) {
        println("img", img.width, img.height);
        println("thresholdImg", thresholdImg.width, thresholdImg.height);
      }
      thresholdImg.pixels[loc] = c;
    }
  }
  thresholdImg.updatePixels();
}

color redChannel(color pixel) {
  float r = red(pixel);
  return color(r, r, r);
}

color greenChannel(color pixel) {
  float g = green(pixel);
  return color(g, g, g);
}

color blueChannel(color pixel) {
  float b = blue(pixel);
  return color(b, b, b);
}

color addChannels(color pixel1, color pixel2) {
  float r = red(pixel1) + red(pixel2);
  float g = green(pixel1) + green(pixel2);
  float b = blue(pixel1) + blue(pixel2);

  return color(r, g, b);
}

color subtractChannels(color pixel1, color pixel2) {
  float r = red(pixel1) - red(pixel2);
  float g = green(pixel1) - green(pixel2);
  float b = blue(pixel1) - blue(pixel2);

  return color(r, g, b);
}

color threshold(color pixel) {
  colorMode(HSB);
  if (brightness(pixel) > thresholdAmt) {
    return color(hue(pixel), 0, 255);
  } else {
    return color(hue(pixel), 0, 0);
  }
}

void mousePressed() {
  xOffset = mouseX;
}

void mouseDragged() {
  dragged = mouseX - xOffset;
  xOffset = mouseX;
  thresholdAmt = constrain(thresholdAmt + dragged / 50, thresholdMin, thresholdMax);
}

void keyPressed() {
  if (key == 'o') {
    openUserImage();
  }
  if (key == 'r') {
    currentFilter = RED;
  } else if (key == 'g') {
    currentFilter = GREEN;
  } else if (key == 'b') {
    currentFilter = BLUE;
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
