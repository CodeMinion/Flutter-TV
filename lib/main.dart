import 'dart:typed_data';

import 'package:another_brother/label_info.dart';
import 'package:another_tv_remote/another_tv_remote.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:another_brother/printer_info.dart' as abPi;
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Pizza Recipe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Uint8List ? _testImageBytes;
  final Recipe _recipe = const Recipe(
      info: RecipeInfo(
        name: "Homemade Pizza & Pizza Dough",
        cookTime: "30 mins",
        prepTime: "2 hrs",
        totalTime: "2 hrs 30 mins",
        servings: "4 to 6 servings",
        yield: "2 10-inch pizzas"
      ),
      sections: <RecipeSection>[
        RecipeSection(heading: "Pizza Dough: Makes enough dough for two 10-12 inch pizzas",
            sections: <RecipeSectionItem>[
              RecipeSectionItem(line: "1 1/2 cups (355 ml) warm water (105°F-115°F)"),
              RecipeSectionItem(line: "1 package (2 1/4 teaspoons) active dry yeast"),
              RecipeSectionItem(line: "3 3/4 cups (490g) bread flour"),
              RecipeSectionItem(line: "2 tablespoons extra virgin olive oil (omit if cooking pizza in a wood-fired pizza oven)"),
              RecipeSectionItem(line: "2 teaspoons kosher salt"),
              RecipeSectionItem(line: "1 teaspoon sugar"),
            ]),
        RecipeSection(heading: "Pizza Ingredients and Topping Options",
            sections: <RecipeSectionItem>[
              RecipeSectionItem(line: "Extra virgin olive oil"),
              RecipeSectionItem(line: "Cornmeal (to help slide the pizza onto the pizza stone)"),
              RecipeSectionItem(line: "Tomato sauce (smooth or pureed)"),
              RecipeSectionItem(line: "Firm mozzarella cheese, grated"),
              RecipeSectionItem(line: "Fresh soft mozzarella cheese, separated into small clumps"),
              RecipeSectionItem(line: "Fontina cheese, grated"),
              RecipeSectionItem(line: "Parmesan cheese, grated"),
              RecipeSectionItem(line: "Feta cheese, crumbled"),
              RecipeSectionItem(line: "Mushrooms, very thinly sliced if raw, otherwise first sautéed"),
              RecipeSectionItem(line: "Bell peppers, stems and seeds removed, very thinly sliced"),
              RecipeSectionItem(line: "Italian pepperoncini, thinly sliced"),
              RecipeSectionItem(line: "Italian sausage, cooked ahead and crumbled"),
              RecipeSectionItem(line: "Sliced black olives"),
              RecipeSectionItem(line: "Chopped fresh basil"),
              RecipeSectionItem(line: "Baby arugula, tossed in a little olive oil, added as pizza comes out of the oven"),
              RecipeSectionItem(line: "Pesto"),
              RecipeSectionItem(line: "Pepperoni, thinly sliced"),
              RecipeSectionItem(line: "Onions, thinly sliced raw or caramelized"),
              RecipeSectionItem(line: "Ham, thinly sliced"),

            ])
      ],
      imageUrls: <String>[
        "assets/images/pizza_1.png",
        "assets/images/pizza_2.png",
        //"assets/images/pizza_3.png",
      ]);

  late ScrollController _listController;


  @override
  void initState() {
    super.initState();
    _listController = ScrollController();
    AnotherTvRemote.getTvRemoteEvents().listen((event) {
      print ("Received event: $event");
      if (event.action == KeyAction.down) {
        if (event.type == KeyType.dPadDown) {
          _listController.animateTo(_listController.position.pixels + 100,
              duration: const Duration(microseconds: 100), curve: Curves.easeIn);
        }
        else if (event.type == KeyType.dPadUp) {
          _listController.animateTo(_listController.position.pixels - 100,
              duration: const Duration(microseconds: 100), curve: Curves.easeIn);
        }
        else if (event.type == KeyType.ok) {
          _printIngredientsList();
        }
      }
    });
  }

  @override
  void disposed() {
    super.dispose();
    _listController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image:
          AssetImage("assets/images/tile_background.png"),
           repeat: ImageRepeat.repeat
          )
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                        width: constraints.maxWidth / 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RecipeWidget(
                            listScrollController: _listController,
                            recipe: _recipe,),
                        ))),

                Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                        width: constraints.maxWidth / 2,
                        child: RecipeShowcaseWidget(recipe: _recipe,))),

                if (_testImageBytes != null)...[
                  Image.memory( _testImageBytes!)
                ]
              ],
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _printIngredientsList,
        tooltip: 'List',
        child: const Icon(Icons.shopping_basket_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _printIngredientsList() async {

    /*
    ui.Image testImage = await _generateShoppingList(recipe: _recipe);
    Uint8List listImageTest = (await testImage.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();

    setState((){
      _testImageBytes = listImageTest;
    });

     */

    // Configure printer.
    //////////////////////////////////////////////////
    /// Request the Storage permissions required by
    /// another_brother to print.
    //////////////////////////////////////////////////
    if (!await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Access to storage is needed in order print."),
        ),
      ));
      return;
    }
    //////////////////////////////////////////////////
    /// Configure printer
    /// Printer: QL1110NWB
    /// Connection: Bluetooth
    /// Paper Size: W62
    /// Important: Printer must be paired to the
    /// phone for the BT search to find it.
    //////////////////////////////////////////////////
    var printer = abPi.Printer();
    var printInfo = abPi.PrinterInfo();
    printInfo.printerModel = abPi.Model.QL_1110NWB;
    printInfo.printMode = abPi.PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = abPi.Port.NET;
    // Set the label type.
    printInfo.labelNameIndex = QL1100.ordinalFromID(QL1100.W62.getId());

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model available in the network.
    List<abPi.NetPrinter> printers =
    await printer.getNetPrinters([abPi.Model.QL_1110NWB.getName()]);

/*
    if (printers.isEmpty) {
      print("No printers found");
      // Show a message if no printers are found.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("No paired printers found on your device."),
        ),
      ));
      return;
    }
*/
    // Note: NSD Is not supported on the emulator so we need to use
    // the printer's IP when running on the emulator.
    printInfo.ipAddress = "192.168.1.80";

    // Get the IP Address from the first printer found.
    //printInfo.ipAddress = printers.single.ipAddress;
    //print ("Priner Found: ${printers.single.toMap()}");
    printer.setPrinterInfo(printInfo);

    ui.Image listImage = await _generateShoppingList(recipe: _recipe);

    // Print labels one at a time.
    abPi.PrinterStatus status = await printer.printImage(listImage);

  }

  Future<ui.Image> _generateShoppingList(
      {required Recipe recipe}) async {

    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);

    double baseSize = 900;
    double labelWidthPx = baseSize;
    //double qrSizePx = labelHeightPx / 2;

    double titleFontSize = 50;
    double sublinesFontSize = 35;
    // Create Paragraph
    ui.ParagraphBuilder paraBuilder =
    ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.start));

    var labelFontStyle = GoogleFonts.macondo();
    // Add heading to paragraph
    paraBuilder.pushStyle(ui.TextStyle(
        fontFamily: labelFontStyle.fontFamily,
        fontSize: titleFontSize,
        color: Colors.black,
        fontWeight: FontWeight.bold));
    paraBuilder.addText("Ingredients\n");
    paraBuilder.pop();

    for (var section in recipe.sections) {
      paraBuilder.pushStyle(ui.TextStyle(
          fontFamily: labelFontStyle.fontFamily,
          fontSize: sublinesFontSize,
          color: Colors.black,
          fontWeight: FontWeight.bold));
      paraBuilder.addText("\n\n${section.heading}\n");
      paraBuilder.pop();

      for(var item in section.sections){
        paraBuilder.pushStyle(ui.TextStyle(
            fontFamily: labelFontStyle.fontFamily,
            fontSize: sublinesFontSize,
            color: Colors.black,
            fontWeight: FontWeight.bold));
        paraBuilder.addText("\n[ ] ${item.line}");
        paraBuilder.pop();
      }
    }

    ui.Paragraph infoPara = paraBuilder.build();
    // Layout the pargraph in the remaining space.
    infoPara.layout(ui.ParagraphConstraints(width: labelWidthPx));

    Paint paint = Paint();
    paint.color = const Color.fromRGBO(255, 255, 255, 1);
    Rect bounds = Rect.fromLTWH(0, 0, labelWidthPx, infoPara.height);
    canvas.save();
    canvas.drawRect(bounds, paint);

    // Draw paragraph on canvas.
    Offset paraOffset = Offset.zero;
    canvas.drawParagraph(infoPara, paraOffset);

    var picture = await recorder
        .endRecording()
        .toImage(labelWidthPx.toInt(), infoPara.height.toInt());

    return picture;
  }
}

class RecipeWidget extends StatelessWidget {
  const RecipeWidget({Key? key, required this.recipe, required this.listScrollController}) : super(key: key);

  final Recipe recipe;
  final ScrollController listScrollController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
        child: Column(
          children: [
            Text(recipe.info.name, textAlign: TextAlign.center, style: GoogleFonts.macondo(fontSize: 24, fontWeight: FontWeight.bold),),
            Padding(
              padding: const EdgeInsets.only(top:32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                InfoSectionWidget(heading: "PREP TIME", content: recipe.info.prepTime,),
                InfoSectionWidget(heading: "COOK TIME", content: recipe.info.cookTime,),
                InfoSectionWidget(heading: "TOTAL TIME", content: recipe.info.totalTime,),

              ],),
            ),
            Padding(
              padding: const EdgeInsets.only(top:16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InfoSectionWidget(heading: "SERVINGS", content: recipe.info.servings,),
                    InfoSectionWidget(heading: "YIELD", content: recipe.info.yield,),

                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top:32.0),
              child: Text("Ingredients", style: GoogleFonts.macondo(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 64),
                controller: listScrollController,
                  itemCount: recipe.sections.length,
                  itemBuilder: (BuildContext context, int index){
                return RecipeSectionWidget(section: recipe.sections[index]);
              }),
            )
          ],
        ),
      ),
    );
  }
}

class InfoSectionWidget extends StatelessWidget {
  const InfoSectionWidget({Key? key, required this.heading, required this.content}) : super(key: key);

  final String heading;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(heading, style: GoogleFonts.macondo(fontSize: 14, fontWeight: FontWeight.bold),),
        Text(content, style: GoogleFonts.macondo(fontSize: 12))
      ],
    );
  }
}

class RecipeSectionWidget extends StatelessWidget {
  const RecipeSectionWidget({Key? key, required this.section}) : super(key: key);

  final RecipeSection section;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(section.heading, style: GoogleFonts.macondo(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          for (var sectionItem in section.sections) RecipeSectionItemWidget(item: sectionItem)
        ],
      ),
    );
  }
}

class RecipeSectionItemWidget extends StatelessWidget {
  const RecipeSectionItemWidget({Key? key, required this.item}) : super(key: key);

  final RecipeSectionItem item;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
      child: Row(
        children: [
          const Icon(Icons.local_pizza_outlined),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only( left: 16.0),
              child: Text(item.line, maxLines: 2, style: GoogleFonts.macondo(fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}

class RecipeShowcaseWidget extends StatelessWidget {
  const RecipeShowcaseWidget({Key? key, required this.recipe}) : super(key: key);
  final Recipe recipe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom:16,  right: 16),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return OutlinedCard(
            child: CarouselSlider(
              options: CarouselOptions(autoPlay: true),
              items: recipe.imageUrls
                  .map((item) => Center(
                      child:
                      Image.asset(item, fit: BoxFit.cover, width: constraints.maxWidth)))
                  .toList(),
            ),
          );
        }
      ),
    );
  }
}

class OutlinedCard extends StatefulWidget {
  const OutlinedCard({
    Key? key,
    required this.child,
    this.clickable = true,
  }) : super(key: key);
  final Widget child;
  final bool clickable;
  @override
  State<OutlinedCard> createState() => _OutlinedCardState();
}

class _OutlinedCardState extends State<OutlinedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_hovered ? 20 : 16);
    const animationCurve = Curves.easeInOut;
    return MouseRegion(
      onEnter: (_) {
        if (!widget.clickable) return;
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        if (!widget.clickable) return;
        setState(() {
          _hovered = false;
        });
      },
      cursor: widget.clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: kThemeAnimationDuration,
        curve: animationCurve,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          borderRadius: borderRadius,
        ),
        foregroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(
            _hovered ? 0.12 : 0,
          ),
          borderRadius: borderRadius,
        ),
        child: TweenAnimationBuilder<BorderRadius>(
          duration: kThemeAnimationDuration,
          curve: animationCurve,
          tween: Tween(begin: BorderRadius.zero, end: borderRadius),
          builder: (context, borderRadius, child) => ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: borderRadius,
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}


class Recipe {

  const Recipe({required this.info, required this.sections, required this.imageUrls});
  final RecipeInfo info;
  final List<RecipeSection> sections;
  final List<String> imageUrls;
}

class RecipeInfo {
  const RecipeInfo(
      {required this.cookTime,
      required this.prepTime,
      required this.name,
      required this.servings,
      required this.totalTime,
      required this.yield});

  final String name;
  final String prepTime;
  final String cookTime;
  final String totalTime;
  final String servings;
  final String yield;
}

class RecipeSection {

  const RecipeSection({required this.heading, required this.sections});

  final String heading;
  final List<RecipeSectionItem> sections;

}

class RecipeSectionItem {

  const RecipeSectionItem({required this.line});
  final String line;
}
