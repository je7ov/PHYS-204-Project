PImage img;
PImage redImg;
PImage greenImg;
PImage blueImg;
boolean landscape;
int mHeight;
int mWidth;

static final int RED = 0;
static final int GREEN = 1;
static final int BLUE = 2;

void setup() {
  size(64, 64);
  mHeight = displayHeight/5*4;
  mWidth = displayHeight;
  openUserImage();
}

void draw() {
  clear();
  if (img != null) {
    image(img, 0, 0);
    if (landscape) {
      image(redImg, 0, img.height);
    } else {
      image(redImg, img.width, 0);
    }
  }
}

void openUserImage() {
  selectInput("Select an image to process", "imageSelected");
}

void imageSelected(File selection) {
  if (selection == null) {
    println("Window was closed or user clicked cancel");
  } else {
    img = loadImage(selection.getAbsolutePath());
    landscape = img.width > img.height;
    redImg = createImage(img.width, img.height, RGB);

    resizeImgAndSurface(img);
    resizeImg(redImg);

    threshold();
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

void threshold() {
  redImg.loadPixels();
  for (int y=0; y<img.height; y++) {
    for (int x=0; x<img.width; x++) {
      int loc = x + y * img.width;

      color gbChannels = addChannels(greenChannel(img.pixels[loc]), blueChannel(img.pixels[loc])); 
      color rFiltered = subChannels(redChannel(img.pixels[loc]), gbChannels);
      color c = rFiltered;

      redImg.pixels[loc] = c;
    }
  }
  redImg.updatePixels();
}

color redChannel(color pixel) {
  return color(red(pixel), 0, 0);
}

color greenChannel(color pixel) {
  color c = color(0, green(pixel), 0);
  float hueC = hue(c);
  println(hueC);
  return c;
}

color blueChannel(color pixel) {
  return color(0, 0, blue(pixel));
}

color addChannels(color pixel1, color pixel2) {
  float r = red(pixel1) + red(pixel2);
  float g = green(pixel1) + green(pixel2);
  float b = blue(pixel1) + blue(pixel2);

  return color(r, g, b);
}

color subChannels(color pixel1, color pixel2) {
  float r = red(pixel1) - red(pixel2);
  float g = green(pixel1) - green(pixel2);
  float b = blue(pixel1) - blue(pixel2);

  return color(r, g, b);
}

void keyPressed() {
  if (key == 'o') {
    openUserImage();
  }
}
