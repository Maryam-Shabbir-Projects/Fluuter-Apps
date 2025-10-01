import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Profile App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Image
              const CircleAvatar(
                radius: 65,
                backgroundImage: AssetImage('assets/images/image.png'),
              ),
              const SizedBox(height: 15),

              // Name & Contact Info
              const Text(
                'Maryam Shabbir',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'maryamshabbir1043@example.com',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 6),
              Text(
                '0303-78654321',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                'Hasilpur, Pakistan',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Skills Section
              Row(
                children: [
                  Expanded(
                    child: _SectionCard(
                      title: "Skills",
                      items: const [
                        'Cyber Analyses',
                        'Mobile App Development',
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SectionCard(
                      title: "Experience",
                      items: const [
                        '2 years of experience',
                        'Proficient in Flutter',
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Education and Projects Section
              Row(
                children: [
                  Expanded(
                    child: _SectionCard(
                      title: "Education",
                      items: const [
                        'BSSE, COMSATS University (2023–2027)',
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SectionCard(
                      title: "Projects",
                      items: const [
                        'pdf reader App',
                        'Transport Management System',
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Social Links Section
              Row(
                children: [
                  Expanded(
                    child: _SectionCard(
                      title: "Social Links",
                      items: const [
                        'https:'
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SectionCard(
                      title: "Certifications",
                      items: const [
                        'Certified Flutter Developer',
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _SectionCard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.deepPurple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}