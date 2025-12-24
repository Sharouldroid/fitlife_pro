import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String calories;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Optional delete action

  const ActivityCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.calories,
    this.icon = Icons.fitness_center,
    this.color = Colors.teal,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 1. Icon Container
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),

                // 2. Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.local_fire_department, size: 14, color: Colors.orange[300]),
                          const SizedBox(width: 4),
                          Text(
                            calories,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Arrow Icon
                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}