import 'package:flutter/material.dart';

class CompatibilityChartPage extends StatefulWidget {
  const CompatibilityChartPage({super.key});

  @override
  State<CompatibilityChartPage> createState() => _CompatibilityChartPageState();
}

class _CompatibilityChartPageState extends State<CompatibilityChartPage> with SingleTickerProviderStateMixin {
  int? selectedRowIndex;
  late TabController _tabController;
  bool showChart = true;

  final List<BloodGroupInfo> bloodGroups = [
    BloodGroupInfo(
      bloodGroup: "A+",
      acceptFrom: "A+ A- O+ O-",
      donateTo: "A+ AB+",
      percentage: "35.7%",
      facts: ["Second most common blood type", "High demand in hospitals", "Found in about 1 in 3 people"],
    ),
    BloodGroupInfo(
      bloodGroup: "A-",
      acceptFrom: "A- O-",
      donateTo: "A+ A- AB+ AB-",
      percentage: "6.3%",
      facts: ["Rare blood type", "Universal plasma donor", "Important for plasma donations"],
    ),
    BloodGroupInfo(
      bloodGroup: "B+",
      acceptFrom: "B+ B- O+ O-",
      donateTo: "B+ AB+",
      percentage: "8.5%",
      facts: ["More common in Asian populations", "Vital for specific ethnic groups", "Medium demand in hospitals"],
    ),
    BloodGroupInfo(
      bloodGroup: "B-",
      acceptFrom: "B- O-",
      donateTo: "B+ B- AB+ AB-",
      percentage: "1.5%",
      facts: ["Very rare blood type", "Critical for specific patients", "High value in blood banks"],
    ),
    BloodGroupInfo(
      bloodGroup: "O+",
      acceptFrom: "O+ O-",
      donateTo: "O+ A+ B+ AB+",
      percentage: "37.4%",
      facts: ["Most common blood type", "High demand worldwide", "Universal red cell donor to all positive types"],
    ),
    BloodGroupInfo(
      bloodGroup: "O-",
      acceptFrom: "O-",
      donateTo: "Everyone",
      percentage: "6.6%",
      facts: ["Universal donor", "Extremely valuable", "First choice in emergencies"],
    ),
    BloodGroupInfo(
      bloodGroup: "AB+",
      acceptFrom: "Everyone",
      donateTo: "AB+",
      percentage: "3.4%",
      facts: ["Universal plasma donor", "Rarest blood type", "Can receive from all types"],
    ),
    BloodGroupInfo(
      bloodGroup: "AB-",
      acceptFrom: "AB- A- B- O-",
      donateTo: "AB+ AB-",
      percentage: "0.6%",
      facts: ["Very rare blood type", "Can receive any negative type", "Important for specific treatments"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text(
          'Blood Compatibility Chart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Compatibility Chart'),
            Tab(text: 'Blood Type Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompatibilityTab(),
          _buildBloodTypeInfoTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFCC2B2B),
        child: const Icon(Icons.info_outline, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('About Blood Types'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection('What are Blood Types?',
                        'Blood types are determined by the presence or absence of certain antigens on the surface of red blood cells.'),
                    const SizedBox(height: 16),
                    _buildInfoSection('Why is Compatibility Important?',
                        'Matching blood types is crucial for safe transfusions. Incompatible blood can cause severe reactions.'),
                    const SizedBox(height: 16),
                    _buildInfoSection('Universal Donor and Recipient',
                        'O- is the universal donor (can give to all types)\nAB+ is the universal recipient (can receive from all types)'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompatibilityTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Find Compatible Blood Types',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFCC2B2B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Tap on a blood group to see detailed compatibility information',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Table(
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                children: [
                  _buildTableHeader(),
                  ...bloodGroups.asMap().entries.map((entry) {
                    final index = entry.key;
                    final group = entry.value;
                    return _buildTableRow(group, index);
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (selectedRowIndex != null)
            _buildDetailCard(bloodGroups[selectedRowIndex!]),
        ],
      ),
    );
  }

  Widget _buildBloodTypeInfoTab() {
    return ListView.builder(
      itemCount: bloodGroups.length,
      itemBuilder: (context, index) {
        final group = bloodGroups[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 2,
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC2B2B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  group.bloodGroup,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('${group.bloodGroup} Blood Type'),
              subtitle: Text('Population: ${group.percentage}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Key Facts:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...group.facts.map((fact) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_right, color: Color(0xFFCC2B2B)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(fact)),
                          ],
                        ),
                      )).toList(),
                      const Divider(height: 24),
                      _buildCompatibilityInfo(group),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompatibilityInfo(BloodGroupInfo group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompatibilityRow('Can Receive From:', group.acceptFrom.split(' '), Colors.green),
        const SizedBox(height: 12),
        _buildCompatibilityRow('Can Donate To:', group.donateTo.split(' '), const Color(0xFFCC2B2B)),
      ],
    );
  }

  Widget _buildCompatibilityRow(String title, List<String> types, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) => Chip(
            label: Text(
              type,
              style: TextStyle(color: color),
            ),
            backgroundColor: color.withOpacity(0.1),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFFCC2B2B),
          ),
        ),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFCC2B2B),
      ),
      children: [
        'Blood Group',
        'Accept From',
        'Donate To',
      ].map((header) => TableCell(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(
            header,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      )).toList(),
    );
  }

  TableRow _buildTableRow(BloodGroupInfo info, int index) {
    final isSelected = selectedRowIndex == index;
    return TableRow(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF3F3) : Colors.white,
      ),
      children: [
        info.bloodGroup,
        info.acceptFrom,
        info.donateTo,
      ].map((text) => TableCell(
        child: InkWell(
          onTap: () {
            setState(() {
              selectedRowIndex = selectedRowIndex == index ? null : index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: text == info.bloodGroup ? 18 : 14,
                fontWeight: text == info.bloodGroup ? FontWeight.bold : FontWeight.normal,
                color: text == info.bloodGroup ? const Color(0xFFCC2B2B) : Colors.black87,
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDetailCard(BloodGroupInfo info) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC2B2B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    info.bloodGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Compatibility Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCompatibilitySection(
              'Can Receive From:',
              info.acceptFrom.split(' '),
              Icons.arrow_downward,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildCompatibilitySection(
              'Can Donate To:',
              info.donateTo.split(' '),
              Icons.arrow_upward,
              const Color(0xFFCC2B2B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilitySection(
    String title,
    List<String> groups,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: groups.map((group) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              group,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class BloodGroupInfo {
  final String bloodGroup;
  final String acceptFrom;
  final String donateTo;
  final String percentage;
  final List<String> facts;

  BloodGroupInfo({
    required this.bloodGroup,
    required this.acceptFrom,
    required this.donateTo,
    required this.percentage,
    required this.facts,
  });
} 