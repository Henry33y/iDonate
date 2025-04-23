import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../models/user.dart';

class DonorsPage extends StatelessWidget {
  const DonorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donors'),
        backgroundColor: const Color(0xFFCC2B2B),
      ),
      body: Consumer<UsersProvider>(
        builder: (context, usersProvider, child) {
          if (usersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final donors = usersProvider.eligibleDonors;
          if (donors.isEmpty) {
            return const Center(
              child: Text(
                'No eligible donors available at the moment',
                style: TextStyle(fontSize: 16),
      ),
    );
  }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donors.length,
              itemBuilder: (context, index) {
              final donor = donors[index];
              return _buildDonorCard(donor);
            },
          );
        },
      ),
    );
  }

  Widget _buildDonorCard(User donor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFCC2B2B),
                          child: Text(
                    donor.anonymizedUsername.substring(6, 8),
                            style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                              fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                  Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.anonymizedUsername,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Blood Type: ${donor.bloodType ?? 'Not specified'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ),
            ],
          ),
          const SizedBox(height: 16),
            const Divider(),
          const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Age', '${donor.age ?? 'N/A'} years'),
                _buildInfoItem('Weight', '${donor.weight ?? 'N/A'} kg'),
                _buildInfoItem('Gender', donor.gender ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 8),
            if (donor.lastDonationDate != null)
              Text(
                'Last donation: ${_formatDate(donor.lastDonationDate!)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
        children: [
        Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
              value,
              style: const TextStyle(
            fontSize: 14,
                fontWeight: FontWeight.bold,
            ),
          ),
        ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
