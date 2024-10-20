import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(const ClassmateApp());
}

class ClassmateApp extends StatelessWidget {
  const ClassmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySQL - Show Classmates',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ClassmateHomePage(title: 'Classmates Data'),
    );
  }
}

class ClassmateHomePage extends StatefulWidget {
  const ClassmateHomePage({super.key, required this.title});

  final String title;

  @override
  State<ClassmateHomePage> createState() => _ClassmateHomePageState();
}

// State of the homepage
class _ClassmateHomePageState extends State<ClassmateHomePage> {

  // Function to fetch data from a MySQL database
  Future<List<Map<String, dynamic>>> _fetchClassmates() async {
    // Connect to the MySQL database
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: 'pass',
      db: 'class',
    ));

    // Execute SQL query
    final results = await conn.query('SELECT * FROM classmates');
    await conn.close();

    // Map the query results to a list of maps
    return results.map((row) => row.fields).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchClassmates(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // If data is available, build a list
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final classmate = snapshot.data![index];
                return ListTile(
                  title: Text('${classmate['name']} ${classmate['last_name']}'),
                  subtitle: Text('${classmate['sex']}, ${classmate['age']} years'),
                );
              },
            );
          } else if (snapshot.hasError) {
            // Display an error message if something goes wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Show a loading indicator while data is being fetched
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
