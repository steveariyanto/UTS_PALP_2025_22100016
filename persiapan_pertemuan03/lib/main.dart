import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Company Profile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinCare Consulting'),
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: Text('Home')),
            ListTile(title: Text('Services')),
            ListTile(title: Text('Contact')),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return SingleChildScrollView(
            child: Column(
              children: [
                HeaderSection(isMobile: isMobile),
                ServicesSection(isMobile: isMobile),
                ContactSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final bool isMobile;
  const HeaderSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      color: Colors.blueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your Trusted Financial Consultant',
              style: TextStyle(fontSize: isMobile ? 24 : 32, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('We provide career consultation, financial guidance, and CV review services.',
              style: TextStyle(fontSize: isMobile ? 16 : 20, color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('Get Started')),
        ],
      ),
    );
  }
}

class ServicesSection extends StatelessWidget {
  final bool isMobile;
  const ServicesSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Our Services', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              ServiceCard(title: 'Financial Consultation', icon: Icons.attach_money),
              ServiceCard(title: 'Career Coaching', icon: Icons.work),
              ServiceCard(title: 'CV Review', icon: Icons.assignment),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const ServiceCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[200],
      child: Column(
        children: [
          const Text('Contact Us', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Email: support@fincare.com | Phone: +123 456 7890'),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: const Text('Get in Touch')),
        ],
      ),
    );
  }
}