import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyClock extends StatefulWidget {
  @override
  State<MyClock> createState() => _MyClockState();
}

class _MyClockState extends State<MyClock> {
  String currentTime = '';
  final List<TimeOfDay> alarms = [];
  final Set<String> triggeredAlarms = {};

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    setState(() => currentTime = DateFormat('hh:mm:ss a').format(now));

    for (var alarm in alarms) {
      final key = '${alarm.hour}:${alarm.minute}';
      if (now.hour == alarm.hour && now.minute == alarm.minute && now.second == 0 && !triggeredAlarms.contains(key)) {
        triggeredAlarms.add(key);
        _showAlarmDialog(alarm);
      }
    }
  }

  void _showAlarmDialog(TimeOfDay alarm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.deepPurple,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text("Alarm Time!", style: TextStyle(color: Colors.white, fontSize: 22)),
            Text(alarm.format(context), style: TextStyle(color: Colors.white, fontSize: 18)),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Dismiss"))
          ],
        ),
      ),
    );
  }

  Future<void> _pickAlarm() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => alarms.add(picked));
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.purple.shade300,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.alarm, size: 50, color: Colors.white),
              Text("Alarm Set For:", style: TextStyle(color: Colors.white)),
              Text(picked.format(context), style: TextStyle(fontSize: 22, color: Colors.white)),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
            ],
          ),
        ),
      );
    }
  }

  void _removeAlarm(int index) {
    final key = '${alarms[index].hour}:${alarms[index].minute}';
    setState(() {
      alarms.removeAt(index);
      triggeredAlarms.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Clock',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(currentTime, style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Set Alarms', style: TextStyle(fontSize: 24, color: Colors.white)),
            Expanded(
              child: alarms.isEmpty
                  ? Center(child: Text('No Alarms Set', style: TextStyle(color: Colors.white70, fontSize: 18)))
                  : ListView.builder(
                      itemCount: alarms.length,
                      itemBuilder: (_, index) {
                        final alarm = alarms[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.alarm, color: Colors.purple),
                            title: Text(alarm.format(context), style: TextStyle(fontSize: 20)),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAlarm(index),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.alarm),
        onPressed: _pickAlarm,
      ),
    );
  }
}
