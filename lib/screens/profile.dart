import 'package:dedo/screens/home/widgets/buildstat_card.dart';
import 'package:dedo/screens/home/widgets/notificationToggleTile.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("PROFILE"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: const [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  "https://media.licdn.com/dms/image/v2/D4E35AQFDQPGzJcqHug/profile-framedphoto-shrink_400_400/profile-framedphoto-shrink_400_400/0/1732880984213?e=1746943200&v=beta&t=aBYT05KDeCbqwgzlvmHcfzaRK_Rl_aq5or9aleJqQcs",
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Jasir Mooliyathodi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("Flutter Developer", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 30),

          //Graph Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "To-Do Completion Trend",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.white,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Day ${value.toInt()}",
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget:
                                (value, _) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      minX: 1,
                      maxX: 6,
                      minY: 0,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(1, 2),
                            FlSpot(2, 3),
                            FlSpot(3, 1),

                            FlSpot(4, 4),
                            FlSpot(5, 3),
                            FlSpot(6, 5),
                          ],
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [Color(0xff23b6e6), Color(0xff02d39a)],
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.teal,
                                strokeWidth: 1.5,
                                strokeColor: Colors.white,
                              );
                            },
                          ),

                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xff23b6e6).withOpacity(0.3),
                                const Color(0xff02d39a).withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          NotificationToggleTile(
            initialValue: true, // or false, based on user settings
            onChanged: (bool value) {
              // Save to preferences, database, or state management
              print('Notifications are now ${value ? 'enabled' : 'disabled'}');
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatCard(
                title: 'Done',
                value: '120',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              StatCard(
                title: 'Pending',
                value: '25',
                icon: Icons.access_time,
                color: Colors.orange,
              ),
              StatCard(
                title: 'Streak',
                value: '7 days',
                icon: Icons.local_fire_department,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
