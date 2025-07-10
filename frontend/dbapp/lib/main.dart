import 'package:dbapp/api_keys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : null,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔕 Background notification received: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640), // Android mobile base size
      minTextAdapt: true, // adapts text size for accessibility
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
            ).copyWith(
              secondary: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.blue,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.blue, // Cursor color
              selectionColor: Colors.blue.withOpacity(0.5), // Highlight color
              selectionHandleColor: Colors.blue, // Handle color
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.white,
            ),
            /*
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
        ),
*/
            checkboxTheme: CheckboxThemeData(
              //fillColor: MaterialStateProperty.all(Colors.blue),
              checkColor: MaterialStateProperty.all(Colors.white),
            ),
            /*
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          indicatorColor: Colors.white,
        ),
        
        */
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          home: TabBarPage(),
        );
      },
    );
  }
}

class TabBarPage extends StatefulWidget {
  @override
  _TabBarPageState createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = [
    'About Us',
    'Products',
    'Clients',
    'Contact Us',
    'Login',
  ];

  // Create a TextEditingController
  TextEditingController _userIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final authService = AuthService();

  // Variable to store the user input

  bool _isPasswordVisible = false; // Controls visibility of password
  bool _rememberMe = false; // Controls "Remember Me" checkbox

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error: $e');
      // Optionally, show a dialog or fallback action
    }
  }

  final String email = 'swamy.appachi@dbquest.in';
  final String phone = '+919965385621';
  final String name = 'A.Swaminathan - General Manager';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    print('Tabs length: ${_tabs.length}'); // Should print 5
    _loadSavedCredentials();
    _controller = VideoPlayerController.asset('videos/video1.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
        });
      });
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _openFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideo(controller: _controller),
      ),
    );
  }

  // Load from SharedPreferences
  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId') ?? '';
    final savedPassword = prefs.getString('password') ?? '';
    final remember = prefs.getBool('rememberMe') ?? false;

    setState(() {
      _userIdController.text = savedUserId;
      _passwordController.text = savedPassword;
      _rememberMe = remember;
    });
  }

// Save to SharedPreferences
  void _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('userId', _userIdController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('userId');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.menu, size: 25),
                  onPressed: () {
                    // Open the Drawer when the menu icon is clicked
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            title: Row(children: [
              Image.asset(
                'images/dbquestlogo.png', // path to your logo image in assets
                height: 25,
                width: 25,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10),
              Text(
                'DbQuest',
                style: TextStyle(fontSize: 20.0),
              ),
            ]),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(30.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey.withOpacity(0.5),
                  indicatorColor: Colors.blue,
                  tabs: _tabs.map((tab) {
                    return Tab(
                      child: Text(
                        tab,
                      ),
                    );
                  }).toList(),
                )),
          ),
          drawer: Drawer(
            child: Column(
              children: [
                // Drawer Header with text and icon
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'images/dbquestlogo.png', // path to your logo image in assets
                        height: 25,
                        width: 25,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'DbQuest',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                // List of options with icons
                buildListTile(icon: Icons.info, title: 'About Us', tabIndex: 0),
                buildListTile(
                    icon: Icons.shopping_cart, title: 'Products', tabIndex: 1),
                buildListTile(
                    icon: Icons.people, title: 'Clients', tabIndex: 2),
                buildListTile(
                    icon: Icons.contact_mail, title: 'Contact Us', tabIndex: 3),
                buildListTile(icon: Icons.login, title: 'Login', tabIndex: 4),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              aboutusmethod(),
              EasyProTab(),
              clientsmethod(),
              contactUsMethod(),
              loginmethod(),
            ],
          )),
    );
  }

  ListTile buildListTile({
    required IconData icon,
    required String title,
    required int tabIndex,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        _scaffoldKey.currentState?.closeDrawer();
        // Animate to the corresponding tab index
        _tabController.animateTo(tabIndex);
      },
    );
  }

  Widget contactUsMethod() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Contact',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('$name', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _launchUrl("tel:$phone"),
              child: Text('$phone',
                  style: TextStyle(
                      decoration: TextDecoration.underline, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _launchUrl("mailto:$email"),
              child: Text('$email',
                  style: TextStyle(
                      decoration: TextDecoration.underline, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () =>
                  _launchUrl("https://wa.me/${phone.replaceAll('+', '')}"),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.whatsapp,
                    //color: Colors.green,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Chat on WhatsApp',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      //color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text(
              'DbQuest Business Solutions\n26, Ramdev Apartment, Venkatesa Colony,\nPollachi, Tamil Nadu - 642001',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Hours',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Monday to Friday: 10 AM to 7 PM',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            /*
            const Text('Social Media:', style: TextStyle(fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram),
                  onPressed: () => _launchUrl(instagramUrl),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.twitter),
                  onPressed: () => _launchUrl(twitterUrl),
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  onPressed: () => _launchUrl(facebookUrl),
                ),
              ],
            ),
            */
          ],
        ),
      ),
    );
  }

  Widget clientsmethod() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildclientSection(
              title: 'AztraconPro',
              subtitle: 'ERP for AI Zamil Metal Works Factory',
              logo: 'images/about.jpeg',
            ),
            buildclientSection(
              title: 'TIIC',
              subtitle: 'TIIC Customer Help Desk App',
              logo: 'images/contact.jpeg',
            ),
            buildclientSection(
              title: 'DSPL',
              subtitle: 'ERP for Dhandapani Steels',
              logo: 'images/login.jpeg',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildclientSection({
    required String title,
    required String subtitle,
    required String logo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              logo,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    //color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget aboutusmethod() {
    final screenWidth = MediaQuery.of(context).size.width;
final videoWidth = screenWidth > 700 ? 600.0 : screenWidth * 0.9;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_isInitialized)
              Column(
                children: [
                  

SizedBox(
  width: videoWidth,
  child: AspectRatio(
    aspectRatio: _controller.value.aspectRatio,
    child: VideoPlayer(_controller),
  ),
),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon:
                            Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                        onPressed: _toggleMute,
                      ),
                      IconButton(
                        icon: Icon(Icons.fullscreen),
                        onPressed: _openFullScreen,
                      ),
                    ],
                  ),
                ],
              )
            else
              CircularProgressIndicator(),
            const SizedBox(height: 10),
            _buildServiceSection(
              icon: Icons.summarize,
              title: "Summary",
              description:
                  "Pioneers in Developing and Implementing ERP Solutions for Project-Based Manufacturing Industry",
            ),
            _buildServiceSection(
              icon: Icons.build,
              title: "ERP Developing",
              description:
                  "Designing efficient ERP applications to streamline workflows and optimize resources. Focused on seamless integration across business functions for better operations. Delivering scalable, user-friendly solutions tailored to organizational needs",
            ),
            _buildServiceSection(
              icon: Icons.web,
              title: "Web Development",
              description:
                  "Client-focused, customer-centric website solutions that deliver tangible business results, Appnovation's Web Developers helps brands navigate the ever-changing digital landscape.",
            ),
            _buildServiceSection(
              icon: Icons.phone_android,
              title: "App & iOS Development",
              description:
                  "Delivering Android app solutions to enterprises & startups, providing innovative and efficient mobile app development services.",
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView loginmethod() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Center(
          // Add padding if needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Adjust layout to wrap content
            children: [
              Text(
                'DbQuest Business Solutions',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    TextField(
                      controller: _userIdController,
                      style: TextStyle(
                          color:
                              Colors.black), // Text color inside the TextField
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        labelStyle:
                            TextStyle(color: Colors.grey), // Label color
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      // Text color inside the TextField
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle:
                            TextStyle(color: Colors.grey), // Label color
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  Text('Remember Me'),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    _saveCredentials(); // Save if checkbox is checked
                    authService.login(
                      context, // Pass the BuildContext
                      _userIdController.text, // User ID from the text field
                      _passwordController.text, // Password from the text field
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 16),
                  )),
              SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  _showForgotPasswordDialog();
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    //decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController _forgotUserIdController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: TextField(
          controller: _forgotUserIdController,
          decoration: InputDecoration(
            labelText: 'Enter Email ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String userId = _forgotUserIdController.text.trim();
              print(userId);
              if (userId.isNotEmpty) {
                Navigator.pop(context);
                ForgotPswd.sendOtp(userId).then((success) {
                  if (success) {
                    print('control passed to show otp verfication dialog');
                    _showOtpVerificationDialog(userId);
                  } else {
                    _showMessage('Failed to send OTP. Please try again.');
                  }
                });
              }
            },
            child: Text('Send OTP'),
          ),
        ],
      ),
    );
  }

  void _showOtpVerificationDialog(String userId) {
    final TextEditingController _otpController = TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();
    print('inside show otp verification dialog');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verify OTP & Reset Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final otp = _otpController.text.trim();
              final newPassword = _newPasswordController.text;
              final confirmPassword = _confirmPasswordController.text;

              if (otp.isEmpty ||
                  newPassword.isEmpty ||
                  confirmPassword.isEmpty) {
                _showMessage('Please fill all fields.');
                return;
              }
              if (newPassword != confirmPassword) {
                _showMessage('Passwords do not match.');
                return;
              }

              Navigator.pop(context);
              _verifyOtpAndResetPassword(userId, otp, newPassword);
            },
            child: Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  void _verifyOtpAndResetPassword(
      String userId, String otp, String newPassword) {
    ForgotPswd.resetPassword(userId, otp, newPassword).then((success) {
      if (success) {
        _showMessage('Password reset successfully. Please login.');
      } else {
        _showMessage('Invalid OTP or error resetting password.');
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

Widget _buildServiceSection({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 60.0,
          color: Colors.grey,
        ),
        SizedBox(height: 20.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.0),
        Text(
          description,
          style: TextStyle(
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

/*
CarouselSlider carouselmethod({Key? key, required List<String> imageList}) {
  return CarouselSlider(
    options: CarouselOptions(
      height: 200.0,
      enlargeCenterPage: true,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 3),
      viewportFraction: 0.8,
      aspectRatio: 16 / 9,
      initialPage: 0,
    ),
    items: imageList.map((imageUrl) {
      return Builder(
        builder: (BuildContext context) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          );
        },
      );
    }).toList(),
  );
}
*/
class EasyProTab extends StatefulWidget {
  @override
  _EasyProTabState createState() => _EasyProTabState();
}

class _EasyProTabState extends State<EasyProTab> {
  List<Map<String, dynamic>> departmentList = [];

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  void fetchDepartments() async {
    final result = await EasyProService.getDepartmentNames();
    if (result != null) {
      setState(() {
        departmentList = result;
      });
    }
  }

  void showVideoProcessesDialog(int slNo) async {
    final processList = await EasyProService.getEasyProVideoFilesBySlNo(slNo);
    if (processList == null) return;

    showDialog(
      context: context,
      builder: (context) {
        Map<String, List<Map<String, dynamic>>> videoLinksMap = {};
        Set<String> expandedProcesses = {}; // To track expanded tiles

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Processes'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: processList.map((process) {
                  final processDesc = process['processDesc'];
                  final videoNo = int.tryParse(process['videoNo']) ?? 0;
                  final isExpanded = expandedProcesses.contains(processDesc);

                  return ExpansionTile(
                    title: Text(
                      processDesc,
                      style: TextStyle(
                        fontWeight:
                            isExpanded ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) async {
                      setState(() {
                        if (expanded) {
                          expandedProcesses.add(processDesc);
                        } else {
                          expandedProcesses.remove(processDesc);
                        }
                      });

                      if (expanded && !videoLinksMap.containsKey(processDesc)) {
                        final links =
                            await EasyProService.getVideoLinksBySlNoAndVideoNo(
                                slNo, videoNo);
                        if (links != null) {
                          setState(() {
                            videoLinksMap[processDesc] = links;
                          });
                        }
                      }
                    },
                    children: (videoLinksMap[processDesc] ?? []).map((video) {
                      return ListTile(
                        title: Text(video['videoDesc']),
                        onTap: () async {
                          final url = Uri.parse(video['videoLinks']);
                          if (await canLaunchUrl(url)) {
                            launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Could not launch video link')),
                            );
                          }
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            "Easy Pro\n",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          Text(
            'This ERP is designed for engineers crafting pressure vessels, storage tanks, and heat exchangers. '
            'Its unique features include generating Bills of Materials from drawings, seamless integration with '
            'project BOMs and manufacturing assemblies, and streamlined material planning, procurement, and '
            'construction. It emphasizes robust project management for materials and processes.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Card(
            elevation: 4, // controls the shadow
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ExpansionTile(
              title: Text(
                'Modules',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: departmentList.map((dept) {
                final deptName = dept['deptName'];
                final slNo = int.tryParse(dept['SlNo']) ?? 0;

                return ListTile(
                  title: Text(deptName),
                  onTap: () => showVideoProcessesDialog(slNo),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Preview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 300.w, // Adjust width as needed
        height: 200.h, // Maintain aspect ratio or fixed height
        child: Image.asset(
          "images/graph1.jpg",
          fit: BoxFit.contain,
        ),
      ),
    ),

    SizedBox(height: 12.h),

    ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 300.w,
        height: 200.h,
        child: Image.asset(
          "images/graph2.png",
          fit: BoxFit.contain,
        ),
      ),
    ),

    SizedBox(height: 12.h),

    ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 300.w,
        height: 200.h,
        child: Image.asset(
          "images/graph3.png",
          fit: BoxFit.contain,
        ),
      ),
    ),
        ],
      ),
    );
  }
}

class FullScreenVideo extends StatelessWidget {
  final VideoPlayerController controller;

  const FullScreenVideo({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.close),
        //backgroundColor: Colors.white,
      ),
    );
  }
}
