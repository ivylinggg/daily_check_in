import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool checkedIn = false;
  String checkInDate = "--";
  String checkInTime = "--";

  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void checkIn() {
    DateTime now = DateTime.now();

    setState(() {
      checkedIn = true;

      checkInDate = "${now.day}/${now.month}/${now.year}";
      checkInTime = TimeOfDay.now().format(context);
      history.insert(0, "$checkInDate  $checkInTime");
    });

    if (history.length > 7) {
      history.removeLast();
    }

    saveData();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text("Check-In Successful!\n\nTime: $checkInTime"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("checkedIn", checkedIn);
    await prefs.setString("checkInDate", checkInDate);
    await prefs.setString("checkInTime", checkInTime);
    await prefs.setStringList("history", history);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    checkedIn = prefs.getBool("checkedIn") ?? false;
    checkInDate = prefs.getString("checkInDate") ?? "--";
    checkInTime = prefs.getString("checkInTime") ?? "--";
    history = prefs.getStringList("history") ?? [];

    checkToday();

    setState(() {});
  }

  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    setState(() {
      checkedIn = false;
      checkInDate = "--";
      checkInTime = "--";
      history.clear();
    });
  }

  void checkToday() {
    DateTime now = DateTime.now();

    String today = "${now.day}/${now.month}/${now.year}";

    if (checkInDate != today) {
      checkedIn = false;
      checkInDate = "--";
      checkInTime = "--";

      saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Daily Check-In"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: resetData),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                      size: 50,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Today's Status",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      checkedIn ? "Checked In" : "Not Checked In",
                      style: TextStyle(
                        fontSize: 18,
                        color: checkedIn ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Date : $checkInDate",
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Time : $checkInTime",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Today's Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: checkedIn ? null : checkIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: Text(
                checkedIn ? "Checked In Today" : "CHECK IN",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Check-In History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        "No Check-In History",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                            title: Text(history[index]),
                            subtitle: const Text("Successfully Checked In"),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
