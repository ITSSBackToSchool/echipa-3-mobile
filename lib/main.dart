import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF232D3F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isBookNowExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1F2937),
                Color(0xFF4B5563),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF4B5563)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: const Border(
                  top: BorderSide(color: Colors.white, width: 1),
                  right: BorderSide(color: Colors.white, width: 1),
                  bottom: BorderSide(color: Colors.white, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ),
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 6, bottom: 6),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Divider(color: Colors.white54, thickness: 1.5),
                const SizedBox(height: 12.0),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: 65,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF374151),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Book\nYour\nSeat',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildExpansionTile(),
                  const SizedBox(height: 10),
                  _buildDrawerButton('My Bookings'),
                  const SizedBox(height: 10),
                  _buildDrawerButton('Weather'),
                  const SizedBox(height: 10),
                  _buildDrawerButton('Traffic Info'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        CircleAvatar(radius: 25, backgroundColor: Colors.grey),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cosmin Gheorghe', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            Text('cosmin@example.com', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Text('View profile', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(color: Colors.white38), // Empty body for now
    );
  }

  Widget _buildExpansionTile() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: const Text('Book now', style: TextStyle(color: Colors.black)),
            trailing: Icon(_isBookNowExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black),
            onTap: () => setState(() => _isBookNowExpanded = !_isBookNowExpanded),
          ),
          if (_isBookNowExpanded)
            Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  title: const Text('Office Seats', style: TextStyle(color: Colors.black87)),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 32.0),
                  title: const Text('Conference Rooms', style: TextStyle(color: Colors.black87)),
                  onTap: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(String title) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        onTap: () {},
      ),
    );
  }
}
