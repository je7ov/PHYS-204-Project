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
  
  println("nImg width: " + normalizedImg.width);
  println("nImg height: " + normalizedImg.height);
}

void draw() {
  clear();
  if (img != null) {
    image(img, 0, 0);
    if (landscape) {
      image(normalizedImg, 0, img.height + 1);      
    } else {
      image(normalizedImg, img.width + 1, 0);
    }
  }
}

void imageSelected(File selection) {
  if (selection == null) {
    println("Window was closed or user clicked cancel");
  } else {
    img = loadImage(selection.getAbsolutePath());
    landscape = img.width > img.height;
    println("landscape: " + landscape);
    println("img width: " + img.width);
    println("img height: " + img.height);
    resizeImg();
    println("img width: " + img.width);
    println("img height: " + img.height);
    normalizedImg = createImage(img.width, img.height, RGB);
    normalizeRGB();
  }
}

void resizeImg() {
  float ratio;
  
  if (landscape) {
    ratio = float(height/2) / float(img.height);
  } else {
    ratio = float(width/2) / float(img.width);
  }
  
  int newH = floor(img.height * ratio);
  int newW = floor(img.width * ratio);
  
  if (landscape) {
    surface.setSize(newW, height);  
  } else {
    surface.setSize(width, newH); 
  }
  
  img.resize(newW, newH);
}
