import controlP5.*;
import java.util.Arrays;
import java.util.List;

String sourceFolder = "";
String maskFolder = "";
ArrayList<PImage> sources = new ArrayList<PImage>();
ArrayList<PImage> masks = new ArrayList<PImage>();
ControlP5 cp5;
int numberOfOutputs = 10;

Controller btnProcess;
Textlabel labelSource;
Textlabel labelMask;

void setup() {
  size(640, 480);
  cp5 = new ControlP5(this);
  cp5.addButton("selectSourceFolder")
    .setPosition(10, 10)
    .setSize(200, 20);
  cp5.addButton("selectMaskFolder")
    .setPosition(10, 40)
    .setSize(200, 20);
  cp5.addNumberbox("numberOfOutputs")
    .setPosition(10, 70)
    .setRange(1, 100)
    .setSize(100, 20);
  btnProcess = cp5.addButton("process")
    .setPosition(10, 130)
    .setSize(200, 20)
    .setVisible(false);
  labelSource = cp5.addTextlabel("labelSource")
    .setPosition(220, 10);
  labelMask = cp5.addTextlabel("labelMask")
    .setPosition(220, 40);
}

void draw() {
  background(0);
  if (sourceFolder != "" && maskFolder != "") {
    btnProcess.setVisible(true);
  }
  if (sourceFolder != "") {
    labelSource.setText(sourceFolder);
  }
  if (maskFolder != "") {
    labelMask.setText(maskFolder);
  }
}

boolean isImage(File file) {
  String[] allowedExtensions = new String[]{".png", ".jpg"};
  String name = file.getName();
  String extension = name.substring(name.lastIndexOf("."));
  List<String> list = Arrays.asList(allowedExtensions);
  return list.contains(extension);
}

void process() {
  String timestamp = year() + "-" + hour() + "-" + minute() + "-" + second();
  sources.clear();
  masks.clear();

  File[] files;

  files = listFiles(sourceFolder);
  for (int i = 0; i < files.length; i++) {
    if (isImage(files[i])) {
      sources.add(loadImage(files[i].getPath()));
      println("Loaded Source: " + files[i]);
    }
  }

  files = listFiles(maskFolder);
  for (int i = 0; i < files.length; i++) {
    if (isImage(files[i])) {
      masks.add(loadImage(files[i].getPath()));
      println("Loaded Mask: " + files[i]);
    }
  }

  for (int i = 0; i < numberOfOutputs; i++) {
    int randomMaskIndex = floor(random(0, masks.size()));
    int randomSourceIndex = floor(random(0, sources.size()));

    PImage mask = masks.get(randomMaskIndex);
    PImage source = sources.get(randomSourceIndex);

    PGraphics output = createGraphics(mask.width, mask.height);
    PGraphics sourceComp = createGraphics(mask.width, mask.height);
    PGraphics maskComp = createGraphics(mask.width, mask.height);

    int randomX = floor(random(0, source.width - mask.width));
    int randomY = floor(random(0, source.height - mask.height));

    maskComp.beginDraw();
    maskComp.background(0);
    maskComp.image(mask, 0, 0);
    maskComp.endDraw();

    sourceComp.beginDraw();
    sourceComp.image(source, -randomX, -randomY);
    sourceComp.endDraw();
    sourceComp.mask(maskComp);

    output.beginDraw();
    output.image(sourceComp, 0, 0);
    output.endDraw();
    output.save("../../Assets/sliceup-output/" + timestamp + "/slice-"+i+".png");
  }
}

void selectSourceFolder() {
  selectFolder("Select a Source Folder", "onSelectSourceFolder");
}

void selectMaskFolder() {
  selectFolder("Select a Mask Folder", "onSelectMaskFolder");
}

void onSelectSourceFolder(File selection) {
  if (selection != null) {
    sourceFolder = selection.getAbsolutePath();
  }
}

void onSelectMaskFolder(File selection) {
  if (selection != null) {
    maskFolder = selection.getAbsolutePath();
  }
}
