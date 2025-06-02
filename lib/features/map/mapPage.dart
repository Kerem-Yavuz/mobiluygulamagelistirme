import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/core/base/base_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../complaints/DetailsPage.dart';
import 'map.dart';

class ComplaintsMapPage extends StatefulWidget {
  const ComplaintsMapPage({super.key});

  @override
  State<ComplaintsMapPage> createState() => _ComplaintsMapPageState();
}

class _ComplaintsMapPageState extends State<ComplaintsMapPage> {
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    final response = await Supabase.instance.client
        .from('Complaints')
        .select('id, coordinate');

    setState(() {
      complaints = List<Map<String, dynamic>>.from(response);
    });
  }
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'complaintmap'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child:
            Center(
              child: Text(
                'clickfordetails'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Expanded(
            child: MapWithPoints(
              points: complaints.map((complaint) {
                final coord = complaint['coordinate'] as Map<String, dynamic>;
                return {
                  'id': complaint['id'],
                  'dx': coord['lng'] as double,
                  'dy': coord['lat'] as double,
                };
              }).toList(),
              onPointTapped: (id) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComplaintDetailPage(id: id.toString()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
