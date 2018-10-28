PImage img;
PImage normalizedImg;
boolean landscape;

void setup() {
  size(960, 960);
  selectInput("Select an image to process", "imageSelected");
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
    surface.setSize(newSize, height);
  } else {
    surface.setSize(width, newSize);
  }
}

int resizeImg(PImage rImg) {
  float ratio;

  if (landscape) {
    ratio = float(height/2) / float(rImg.height);
  } else {
    ratio = float(width/2) / float(rImg.width);
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
