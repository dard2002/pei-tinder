import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  FirebaseDatabase database = FirebaseDatabase.instance;

  await initalizeDb();
}

Future<void> initalizeDb() async {
  List<Map<String, dynamic>> sharPeis = [
    {
      "id": 0,
      "name": "Brandy",
      "age": "8",
      "location": "Melbourne",
      "imageUrl":
      "https://www.pedigree.com.au/cdn-cgi/image/width=520,format=auto,q=90/sites/g/files/fnmzdf2091/files/2022-11/large_8fba6d99-ffed-4a75-97ab-eae5228daf08.jpg",
      "liked": false
    },
    {
      "id": 1,
      "name": "Narlah",
      "age": "8",
      "location": "Melbourne",
      "imageUrl":
      "https://www.vidavetcare.com/wp-content/uploads/sites/234/2022/04/chinese-sharpei-dog-breed-info.jpeg",
      "liked": false
    }
  ];

  for(int x = 0; x < sharPeis.length - 1; x++) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("dog/$x");
    await ref.set(sharPeis[x]);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pei Tinder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        home: const ImageList());
  }
}

class ImageList extends StatefulWidget {
  const ImageList({super.key});

  @override
  State createState() => _ImageListState();
}

Future<Map<String, dynamic>> nextSharPei(int id) async {
  DatabaseReference sharPeiRef = FirebaseDatabase.instance.ref("dog/$id");
  DatabaseEvent event = await sharPeiRef.once();

  return Map<String, dynamic>.from(event.snapshot.value as Map);
}

Future<void> updateSharPeiLikedStatus(int id, bool likes) async {
  DatabaseReference sharPeiRef = FirebaseDatabase.instance.ref("dog/$id");

  await sharPeiRef.update({
    "liked": likes
  });
}

class _ImageListState extends State<ImageList> {
  String _name = "";
  bool _shouldDisplay = false;
  Future<Map<String, dynamic>>? _currentSharPei;

  void updateSharPei(int id, bool likes) async {
    await updateSharPeiLikedStatus(id, likes);

    setState(() {
      _currentSharPei = nextSharPei(id + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pei Tinder"),
        ),
      body: _shouldDisplay
          ? FutureBuilder<Map<String, dynamic>>(
        future: _currentSharPei,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var sharPei = snapshot.data!;
            return Column(
              children: <Widget>[
                Text("Hello $_name!"),
                Image.network(sharPei["imageUrl"] ?? ''),
                ListTile(
                  leading: Text(sharPei["name"] ?? ''),
                  trailing: Text("${sharPei["age"]}, ${sharPei["location"]}"),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    updateSharPei((sharPei["id"]), true);
                  },
                  child: const Icon(Icons.plus_one),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    updateSharPei((sharPei["id"]), false);
                  },
                  child: const Icon(Icons.heart_broken_rounded),
                ),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _name = "";
                      _shouldDisplay = false;
                    });
                  },
                  child: const Text("Log Off"),
                ),
              ],
            );
          } else {
            return const Center(child: Text("No Shar Pei is here."));
          }
        },
      )
          : Column(
        children: <Widget>[
          TextField(
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter your name",
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (_name.isNotEmpty) {
                  _shouldDisplay = true;
                  _currentSharPei = nextSharPei(0);
                }
              });
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }
}
