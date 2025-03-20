import 'package:flutter/material.dart';

class NetworkDetailsDialogue extends StatefulWidget {
  final String ssid;
  final Function(String, String) onConnect;

  const NetworkDetailsDialogue({super.key, required this.ssid, required this.onConnect});

  @override
  _NetworkDetailsDialogueState createState() => _NetworkDetailsDialogueState();
}

class _NetworkDetailsDialogueState extends State<NetworkDetailsDialogue> {
  bool _obscurePassword = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2, // ✅ Slightly above center
          left: 20,
          right: 20,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color.fromARGB(255, 243, 178, 92), // ✅ Light Orange Background
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter WiFi Password",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.ssid,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // ✅ White background for input field
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      cursorColor: Colors.black, // ✅ Cursor color set to black
                      style: const TextStyle(color: Colors.black), // ✅ Password text color set to black
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none, // ✅ No border
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      String password = _passwordController.text.trim();
                      if (password.isNotEmpty) {
                        widget.onConnect(widget.ssid, password);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00), // ✅ Dark Orange Button
                      foregroundColor: Colors.white, // ✅ White text inside button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    ),
                    child: const Text("Connect", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ✅ Show Dialog Without Shifting
void showNetworkDialog(BuildContext context, String ssid, Function(String, String) onConnect) {
  showDialog(
    context: context,
    builder: (context) => Stack(
      children: [
        Align(
          alignment: const Alignment(0, -0.3), // Moves the box slightly above center
          child: NetworkDetailsDialogue(
            ssid: "YourSSID",
            onConnect: (ssid, pass) {},
          ),
        ),
      ],
    ),
  );


}
