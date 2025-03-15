import 'package:flutter/material.dart';
import 'home_page.dart';
import '../widgets/NetworkDetailsDialogue.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, dynamic>> availableNetworks = [
    {"name": "Office", "strength": 3, "secure": true, "connected": false},
    {"name": "HomeWifi_Personal", "strength": 4, "secure": false, "connected": false},
    {"name": "AbcdefghiKLM_0987", "strength": 2, "secure": true, "connected": false},
    {"name": "Defghi", "strength": 5, "secure": false, "connected": false},
  ];

  Map<String, dynamic>? connectedNetwork;

  @override
  void initState() {
    super.initState();
    connectToStrongestNetwork();
  }

  void scanForNetworks() {
    setState(() {
      availableNetworks = [
        {"name": "Network_A", "strength": 4, "secure": true, "connected": false},
        {"name": "Network_B", "strength": 5, "secure": false, "connected": false},
        {"name": "Network_C", "strength": 3, "secure": true, "connected": false},
        {"name": "Network_D", "strength": 2, "secure": false, "connected": false},
      ];
    });
  }

  void connectToStrongestNetwork() {
    availableNetworks.sort((a, b) => b["strength"].compareTo(a["strength"]));
    setState(() {
      connectedNetwork = availableNetworks.first;
      connectedNetwork!["connected"] = true;
      availableNetworks.removeAt(0);
    });
  }

  void connectToNetwork(Map<String, dynamic> network) {
    if (network["secure"]) {
      showDialog(
        context: context,
        builder: (context) => NetworkDetailsDialogue(
          ssid: network["name"],
          onConnect: (ssid, password) {
            setState(() {
              if (connectedNetwork != null) {
                connectedNetwork!["connected"] = false;
                availableNetworks.add(connectedNetwork!); // Move old network down
              }
              availableNetworks.remove(network);
              network["connected"] = true;
              connectedNetwork = network;
            });
          },
        ),
      );
    } else {
      setState(() {
        if (connectedNetwork != null) {
          connectedNetwork!["connected"] = false;
          availableNetworks.add(connectedNetwork!);
        }
        availableNetworks.remove(network);
        network["connected"] = true;
        connectedNetwork = network;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              // App Bar
              Container(
                height: 80,
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => const HomePage())
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 171, 75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      
                      // Title
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      // ✅ Restored Settings Icon
                      GestureDetector(
                        onTap: () {
                          print("Settings Icon Tapped");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 171, 75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Connected Network Box
              if (connectedNetwork != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Connected Network",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 252, 217, 166),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wifi,
                              color: Color.fromARGB(255, 223, 127, 24),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              connectedNetwork!["name"],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Available Networks
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Available Networks",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...availableNetworks.map((network) => GestureDetector(
                          onTap: () => connectToNetwork(network),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 252, 217, 166),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  network["secure"] ? Icons.wifi_lock : Icons.wifi,
                                  color: const Color.fromARGB(255, 223, 127, 24),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  network["name"],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 14),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: scanForNetworks,
                        child: const Text(
                          "Scan for Networks",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
