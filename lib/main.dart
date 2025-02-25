import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.indigo),
          headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
          labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 6,
          ),
        ),
      ),
      home: const PortfolioHomePage(),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  int _selectedIndex = 0;
  String _currentLang = 'en';
  Map<String, dynamic> _content = {};
  int _discoverySubTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final String response = await rootBundle.loadString('assets/data/content.json');
      final data = jsonDecode(response);
      setState(() {
        _content = data['languages'];
      });
    } catch (e) {
      print('Error loading content: $e');
      setState(() {
        _content = {};
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 6) _discoverySubTabIndex = 0;
    });
  }

  void _onSubTabTapped(int index) {
    setState(() {
      _discoverySubTabIndex = index;
    });
  }

  void _switchLanguage(String lang) {
    setState(() {
      _currentLang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_content.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final navItems = _content[_currentLang]['nav'];
    final pages = [
      HomePage(content: _content[_currentLang]['home']),
      CVPage(content: _content[_currentLang]['cv']),
      PublicationsPage(content: _content[_currentLang]['publications']),
      ProjectsPage(content: _content[_currentLang]['projects']),
      BlogPage(content: _content[_currentLang]['blog']),
      GeoLayersPage(content: _content[_currentLang]['geolayers']),
      DiscoverySearchPage(
        content: _content[_currentLang]['discovery_search'],
        subTabIndex: _discoverySubTabIndex,
        onSubTabTapped: _onSubTabTapped,
      ),
      ContactPage(content: _content[_currentLang]['contact']),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_content[_currentLang]['app_title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        elevation: 12,
        actions: [
          if (MediaQuery.of(context).size.width > 900) ...[
            for (int i = 0; i < pages.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GestureDetector(
                  onTap: () => _onNavItemTapped(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: _selectedIndex == i
                          ? const LinearGradient(colors: [Colors.purple, Colors.indigo], begin: Alignment.topLeft, end: Alignment.bottomRight)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _selectedIndex == i
                          ? [const BoxShadow(color: Colors.purpleAccent, blurRadius: 10, offset: Offset(0, 4))]
                          : null,
                    ),
                    child: Text(
                      navItems.values.toList()[i],
                      style: TextStyle(
                        color: _selectedIndex == i ? Colors.white : Colors.white70,
                        fontWeight: _selectedIndex == i ? FontWeight.bold : FontWeight.normal,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            DropdownButton<String>(
              value: _currentLang,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: Colors.indigo[800],
              items: [
                const DropdownMenuItem(value: 'en', child: Text('EN', style: TextStyle(color: Colors.white))),
                const DropdownMenuItem(value: 'es', child: Text('ES', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) => _switchLanguage(value!),
            ),
            const SizedBox(width: 18),
          ],
        ],
      ),
      drawer: MediaQuery.of(context).size.width <= 900
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.indigo[900]),
                    child: Text(navItems['home'], style: const TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  for (int i = 0; i < pages.length; i++)
                    ListTile(
                      title: Text(navItems.values.toList()[i]),
                      onTap: () {
                        _onNavItemTapped(i);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: SingleChildScrollView(child: pages[_selectedIndex]),
          ),
        ),
      ),
    );
  }
}

// Page Widgets
class HomePage extends StatelessWidget {
  final Map<String, dynamic> content;
  const HomePage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
      child: Column(
        children: [
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(seconds: 1),
            child: Text(content['welcome'], style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 40),
          const CircleAvatar(radius: 100, backgroundImage: AssetImage('assets/images/profile.jpeg')),
          const SizedBox(height: 25),
          Text(content['intro'], style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text('“${content['quote']}”', style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.rocket_launch),
            label: Text(content['button']),
          ),
          const SizedBox(height: 50),
          Text(content['mission'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(content['passion'], style: const TextStyle(fontSize: 18, color: Colors.indigo), textAlign: TextAlign.center),
          const SizedBox(height: 50),
          Wrap(
            spacing: 60,
            runSpacing: 25,
            alignment: WrapAlignment.center,
            children: content['stats'].map<Widget>((stat) => Column(
                  children: [
                    Text(stat['value'], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    Text(stat['label'], style: const TextStyle(fontSize: 16)),
                  ],
                )).toList(),
          ),
        ],
      ),
    );
  }
}

class CVPage extends StatelessWidget {
  final Map<String, dynamic> content;
  const CVPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(content['title'], style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          Text(content['summary'], style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          const SizedBox(height: 50),
          _buildSection('Education', content['education'], (edu) => ListTile(
                leading: const Icon(Icons.school, color: Colors.indigo),
                title: Text(edu['degree'], style: Theme.of(context).textTheme.labelLarge),
                subtitle: Text('${edu['institution']} - ${edu['year']}\n${edu['details']}'),
              )),
          _buildSection('Experience', content['experience'], (exp) => ListTile(
                leading: const Icon(Icons.work, color: Colors.indigo),
                title: Text(exp['role'], style: Theme.of(context).textTheme.labelLarge),
                subtitle: Text('${exp['company']} (${exp['duration']})\n${exp['description']}'),
              )),
          _buildSection('Skills', content['skills'], (skill) => Chip(
                label: Text(skill),
                backgroundColor: Colors.indigo.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ), isWrap: true),
          _buildSection('Certifications', content['certifications'], (cert) => ListTile(
                leading: const Icon(Icons.verified, color: Colors.indigo),
                title: Text(cert['name']),
                subtitle: Text('${cert['issuer']} - ${cert['year']}'),
              )),
          _buildSection('Awards', content['awards'], (award) => ListTile(
                leading: const Icon(Icons.star, color: Colors.indigo),
                title: Text(award['name']),
                subtitle: Text('${award['event']} - ${award['year']}'),
              )),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: () => _launchURL('https://example.com/cv.pdf'),
            icon: const Icon(Icons.download),
            label: Text(content['cv_download']),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List items, Widget Function(dynamic) builder, {bool isWrap = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
        const SizedBox(height: 20),
        isWrap
            ? Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: items.map(builder).toList())
            : Column(children: items.map(builder).toList()),
        const SizedBox(height: 50),
      ],
    );
  }
}

class PublicationsPage extends StatelessWidget {
  final Map<String, dynamic> content;
  const PublicationsPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(content['title'], style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          ...content['items'].map<Widget>((item) => Card(
                child: ListTile(
                  leading: const Icon(Icons.article, color: Colors.indigo),
                  title: Text(item['title'], style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text(item['subtitle']),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.indigo),
                    onPressed: () => _launchURL(item['link']),
                  ),
                ),
              )).toList(),
        ],
      ),
    );
  }
}

class ProjectsPage extends StatelessWidget {
  final Map<String, dynamic> content;
  const ProjectsPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(content['title'], style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: content['items'].map<Widget>((item) => SizedBox(
                  width: 360,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(item['image'], height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 220)),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'], style: Theme.of(context).textTheme.labelLarge),
                              const SizedBox(height: 12),
                              Text(item['description']),
                              const SizedBox(height: 12),
                              Text('Tech: ${item['tech']}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }
}

class BlogPage extends StatelessWidget {
  final Map<String, dynamic> content;
  const BlogPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(content['title'], style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          ...content['posts'].map<Widget>((post) => Card(
                child: ListTile(
                  leading: const Icon(Icons.edit, color: Colors.indigo),
                  title: Text(post['title'], style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text('${post['snippet']} - ${post['date']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.read_more, color: Colors.indigo),
                    onPressed: () => _launchURL(post['link']),
                  ),
                ),
              )).toList(),
        ],
      ),
    );
  }
}

class GeoLayersPage extends StatelessWidget {
  final Map<String, dynamic> content;
  const GeoLayersPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(content['title'], style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          Text(content['description'], style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: content['layers'].map<Widget>((layer) => SizedBox(
                  width: 320,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Icon(_getLayerIcon(layer['icon']), size: 80, color: Colors.indigo),
                          const SizedBox(height: 15),
                          Text(layer['name'], style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 12),
                          Text(layer['detail'], textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getLayerIcon(String icon) {
    switch (icon) {
      case 'people':
        return Icons.people;
      case 'terrain':
        return Icons.terrain;
      case 'cloud':
        return Icons.cloud;
      case 'traffic':
        return Icons.traffic;
      default:
        return Icons.layers;
    }
  }
}

class DiscoverySearchPage extends StatefulWidget {
  final Map<String, dynamic> content;
  final int subTabIndex;
  final Function(int) onSubTabTapped;

  const DiscoverySearchPage({
    super.key,
    required this.content,
    required this.subTabIndex,
    required this.onSubTabTapped,
  });

  @override
  State<DiscoverySearchPage> createState() => _DiscoverySearchPageState();
}

class _DiscoverySearchPageState extends State<DiscoverySearchPage> {
  bool _scriptLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadGoogleAIScript();
  }

  void _loadGoogleAIScript() {
    if (html.document.getElementById('google-ai-script') == null) {
      final script = html.ScriptElement()
        ..id = 'google-ai-script'
        ..src = 'https://cloud.google.com/ai/gen-app-builder/client?hl=de'
        ..async = true
        ..onLoad.listen((event) {
          setState(() {
            _scriptLoaded = true;
          });
          _injectWidget();
        });
      html.document.head!.append(script);
    } else {
      setState(() {
        _scriptLoaded = true;
      });
      _injectWidget();
    }
  }

  void _injectWidget() {
    final existingWidget = html.document.getElementById('gen-search-widget-container');
    if (existingWidget != null) {
      existingWidget.remove();
    }

    final subtabs = widget.content['subtabs'];
    final subtabKeys = subtabs.keys.toList();
    final currentConfigId = subtabs[subtabKeys[widget.subTabIndex]]['configId'] ?? '830bbc04-78f0-4afd-8c6a-fd7effaf424d';

    final container = html.DivElement()..id = 'gen-search-widget-container';
    html.document.body!.append(container);

    final searchWidget = html.Element.tag('gen-search-widget') // Renamed to avoid shadowing
      ..setAttribute('configId', currentConfigId)
      ..setAttribute('triggerId', 'searchWidgetTrigger');
    container.append(searchWidget);

    final existingTrigger = html.document.getElementById('searchWidgetTrigger');
    if (existingTrigger == null) {
      final trigger = html.InputElement()
        ..id = 'searchWidgetTrigger'
        ..placeholder = 'Search here'
        ..style.display = 'none';
      html.document.body!.append(trigger);
    }
  }

  void _triggerSearchWidget() {
    final trigger = html.document.getElementById('searchWidgetTrigger') as html.InputElement?;
    if (trigger != null) {
      trigger.click();
    }
  }

  @override
  void didUpdateWidget(covariant DiscoverySearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subTabIndex != widget.subTabIndex && _scriptLoaded) {
      _injectWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtabs = widget.content['subtabs'];
    final subtabKeys = subtabs.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.content['title'], style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(subtabKeys.length, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ChoiceChip(
                      label: Text(subtabs[subtabKeys[index]]['title']),
                      selected: widget.subTabIndex == index,
                      onSelected: (selected) => widget.onSubTabTapped(index),
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(color: widget.subTabIndex == index ? Colors.white : Colors.black87, fontSize: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 50),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Image.asset(subtabs[subtabKeys[widget.subTabIndex]]['image'], height: 280, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 280)),
                  const SizedBox(height: 25),
                  Text(subtabs[subtabKeys[widget.subTabIndex]]['title'], style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 15),
                  Text(subtabs[subtabKeys[widget.subTabIndex]]['description'], style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                  const SizedBox(height: 15),
                  Text('Example: ${subtabs[subtabKeys[widget.subTabIndex]]['example']}', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _scriptLoaded ? _triggerSearchWidget : null,
                    icon: const Icon(Icons.chat),
                    label: const Text('Open Generative Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _scriptLoaded ? Colors.indigo : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    final container = html.document.getElementById('gen-search-widget-container');
    if (container != null) {
      container.remove();
    }
    super.dispose();
  }
}

class ContactPage extends StatefulWidget {
  final Map<String, dynamic> content;
  const ContactPage({super.key, required this.content});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.content['title'], style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 25),
          Text(widget.content['intro'], style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          const SizedBox(height: 50),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: widget.content['name_label'],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: widget.content['email_label'],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.email, color: Colors.indigo),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: widget.content['message_label'],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    prefixIcon: const Icon(Icons.message, color: Colors.indigo),
                  ),
                  maxLines: 6,
                  validator: (value) => value!.isEmpty ? 'Please enter a message' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message Sent! (Demo)')));
                      _nameController.clear();
                      _emailController.clear();
                      _messageController.clear();
                    }
                  },
                  child: Text(widget.content['send_button']),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Text(widget.content['location'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          Text(widget.content['availability'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          const SizedBox(height: 40),
          Wrap(
            spacing: 25,
            runSpacing: 25,
            alignment: WrapAlignment.center,
            children: widget.content['social'].map<Widget>((social) => ElevatedButton.icon(
                  onPressed: () => _launchURL(social['link']),
                  icon: const Icon(Icons.link),
                  label: Text(social['platform']),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[700]),
                )).toList(),
          ),
        ],
      ),
    );
  }
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
}